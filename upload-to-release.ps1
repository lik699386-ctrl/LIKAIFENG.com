# GitHub Release 文件上传脚本
# 使用方法：.\upload-to-release.ps1 -FilePath "你的文件路径.zip" -Version "v1.0.0" -AppName "应用名称"

param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath,
    
    [Parameter(Mandatory=$true)]
    [string]$Version,
    
    [Parameter(Mandatory=$true)]
    [string]$AppName,
    
    [string]$Description = "新版本发布"
)

$RepoOwner = "lik699386-ctrl"
$RepoName = "cyberone-website"

Write-Host "================================" -ForegroundColor Cyan
Write-Host "GitHub Release 文件上传工具" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# 检查文件是否存在
if (-not (Test-Path $FilePath)) {
    Write-Host "❌ 错误：文件不存在 - $FilePath" -ForegroundColor Red
    exit 1
}

$FileInfo = Get-Item $FilePath
$FileSizeMB = [math]::Round($FileInfo.Length / 1MB, 2)

Write-Host "📦 准备上传文件" -ForegroundColor Green
Write-Host "   文件名: $($FileInfo.Name)" -ForegroundColor Gray
Write-Host "   大小: $FileSizeMB MB" -ForegroundColor Gray
Write-Host "   版本: $Version" -ForegroundColor Gray
Write-Host "   应用: $AppName" -ForegroundColor Gray
Write-Host ""

# 检查文件大小（GitHub限制2GB）
if ($FileInfo.Length -gt 2GB) {
    Write-Host "❌ 错误：文件超过2GB限制" -ForegroundColor Red
    exit 1
}

# 检查是否安装了 GitHub CLI
$ghInstalled = Get-Command gh -ErrorAction SilentlyContinue
if (-not $ghInstalled) {
    Write-Host "❌ 未安装 GitHub CLI" -ForegroundColor Red
    Write-Host ""
    Write-Host "请先安装 GitHub CLI：" -ForegroundColor Yellow
    Write-Host "  方法1: winget install GitHub.cli" -ForegroundColor Cyan
    Write-Host "  方法2: 访问 https://cli.github.com 下载安装" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "安装后运行: gh auth login" -ForegroundColor Yellow
    exit 1
}

# 检查是否已登录
$authStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 未登录 GitHub" -ForegroundColor Red
    Write-Host ""
    Write-Host "请先登录: gh auth login" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ GitHub CLI 已就绪" -ForegroundColor Green
Write-Host ""

# 创建 Release
Write-Host "📤 创建 Release: $Version" -ForegroundColor Cyan

$ReleaseTitle = "$AppName - $Version"
$ReleaseNotes = @"
## $AppName - $Version

$Description

### 下载说明
- 文件名: $($FileInfo.Name)
- 文件大小: $FileSizeMB MB
- 发布时间: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

### 安装步骤
1. 下载文件
2. 解压到目标目录
3. 按照说明文档操作

---
*通过 [LIKAIFENG.Net](https://github.com/$RepoOwner/$RepoName) 发布*
"@

# 创建或更新 Release
gh release create $Version `
    --repo "$RepoOwner/$RepoName" `
    --title "$ReleaseTitle" `
    --notes "$ReleaseNotes" `
    $FilePath 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ 上传成功！" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Release 信息：" -ForegroundColor Cyan
    Write-Host "   仓库: https://github.com/$RepoOwner/$RepoName" -ForegroundColor Gray
    Write-Host "   Release: https://github.com/$RepoOwner/$RepoName/releases/tag/$Version" -ForegroundColor Gray
    Write-Host ""
    
    # 生成下载链接
    $DownloadUrl = "https://github.com/$RepoOwner/$RepoName/releases/download/$Version/$($FileInfo.Name)"
    $CDNUrl = "https://cdn.jsdelivr.net/gh/$RepoOwner/$RepoName@$Version/$($FileInfo.Name)"
    
    Write-Host "🔗 下载链接：" -ForegroundColor Cyan
    Write-Host "   GitHub: $DownloadUrl" -ForegroundColor Gray
    Write-Host "   CDN加速: $CDNUrl" -ForegroundColor Gray
    Write-Host ""
    
    # 生成配置JSON
    $AppConfig = @{
        id = [int](Get-Date -UFormat %s)
        name = $AppName
        version = $Version
        fileName = $FileInfo.Name
        fileSize = "$FileSizeMB MB"
        downloadUrl = $DownloadUrl
        cdnUrl = $CDNUrl
        uploadDate = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    } | ConvertTo-Json -Depth 10
    
    Write-Host "📝 应用配置（复制到网站）：" -ForegroundColor Cyan
    Write-Host $AppConfig -ForegroundColor Yellow
    Write-Host ""
    
} else {
    Write-Host ""
    Write-Host "❌ 上传失败" -ForegroundColor Red
    Write-Host "错误信息: $authStatus" -ForegroundColor Red
}

