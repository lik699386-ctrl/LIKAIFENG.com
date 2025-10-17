# 自动更新 releases-config.json 配置文件

param(
    [string]$AppName,
    [string]$Description,
    [string]$Version,
    [string]$Category = "utility",
    [string]$FileName,
    [string]$FileSize,
    [string]$DownloadUrl,
    [string]$CdnUrl
)

$ConfigFile = Join-Path $PSScriptRoot "releases-config.json"

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "  更新配置文件工具  " -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# 检查配置文件是否存在
if (-not (Test-Path $ConfigFile)) {
    Write-Host "❌ 未找到配置文件: $ConfigFile" -ForegroundColor Red
    Write-Host "正在创建默认配置..." -ForegroundColor Yellow
    
    $DefaultConfig = @{
        apps = @()
        repo = @{
            owner = "lik699386-ctrl"
            name = "cyberone-website"
            url = "https://github.com/lik699386-ctrl/cyberone-website"
        }
        settings = @{
            useCDN = $true
            autoUpdate = $true
        }
    }
    
    $DefaultConfig | ConvertTo-Json -Depth 10 | Set-Content $ConfigFile -Encoding UTF8
    Write-Host "✅ 已创建默认配置文件" -ForegroundColor Green
}

# 读取现有配置
$Config = Get-Content $ConfigFile -Raw -Encoding UTF8 | ConvertFrom-Json

# 交互式输入（如果参数未提供）
if ([string]::IsNullOrWhiteSpace($AppName)) {
    $AppName = Read-Host "应用名称"
}

if ([string]::IsNullOrWhiteSpace($Version)) {
    $Version = Read-Host "版本号 (例如: v1.0.0)"
}
if (-not $Version.StartsWith("v")) {
    $Version = "v" + $Version
}

if ([string]::IsNullOrWhiteSpace($Description)) {
    $Description = Read-Host "应用描述"
}

if ([string]::IsNullOrWhiteSpace($FileName)) {
    $FileName = Read-Host "文件名 (例如: MyApp.zip)"
}

if ([string]::IsNullOrWhiteSpace($FileSize)) {
    $FileSize = Read-Host "文件大小 (例如: 1.5 GB)"
}

# 生成下载链接
$RepoOwner = $Config.repo.owner
$RepoName = $Config.repo.name

if ([string]::IsNullOrWhiteSpace($DownloadUrl)) {
    $DownloadUrl = "https://github.com/$RepoOwner/$RepoName/releases/download/$Version/$FileName"
}

if ([string]::IsNullOrWhiteSpace($CdnUrl)) {
    $CdnUrl = "https://cdn.jsdelivr.net/gh/$RepoOwner/$RepoName@$Version/$FileName"
}

Write-Host ""
Write-Host "📝 分类选择：" -ForegroundColor Cyan
Write-Host "  [1] productivity - 生产力" -ForegroundColor White
Write-Host "  [2] utility - 实用工具" -ForegroundColor White
Write-Host "  [3] creative - 创意设计" -ForegroundColor White
Write-Host "  [4] development - 开发工具" -ForegroundColor White
Write-Host "  [5] other - 其他" -ForegroundColor White
Write-Host ""

$CategoryChoice = Read-Host "请选择分类 (1-5，默认2)"
if ([string]::IsNullOrWhiteSpace($CategoryChoice)) {
    $CategoryChoice = "2"
}

$CategoryMap = @{
    "1" = "productivity"
    "2" = "utility"
    "3" = "creative"
    "4" = "development"
    "5" = "other"
}

$Category = $CategoryMap[$CategoryChoice]
if ([string]::IsNullOrWhiteSpace($Category)) {
    $Category = "utility"
}

# 生成新应用配置
$NewApp = [PSCustomObject]@{
    id = [int](Get-Date -UFormat %s)
    name = $AppName
    description = $Description
    version = $Version
    category = $Category
    fileName = $FileName
    fileSize = $FileSize
    downloadUrl = $DownloadUrl
    cdnUrl = $CdnUrl
    uploadDate = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    icon = $null
}

# 添加到配置
$AppsList = [System.Collections.ArrayList]@($Config.apps)
$AppsList.Insert(0, $NewApp)
$Config.apps = $AppsList

# 保存配置
$Config | ConvertTo-Json -Depth 10 | Set-Content $ConfigFile -Encoding UTF8

Write-Host ""
Write-Host "✅ 配置已更新！" -ForegroundColor Green
Write-Host ""
Write-Host "📋 应用信息：" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "  名称: $AppName" -ForegroundColor White
Write-Host "  版本: $Version" -ForegroundColor White
Write-Host "  分类: $Category" -ForegroundColor White
Write-Host "  文件: $FileName ($FileSize)" -ForegroundColor White
Write-Host "  描述: $Description" -ForegroundColor White
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host ""
Write-Host "🔗 下载链接：" -ForegroundColor Cyan
Write-Host "  GitHub: $DownloadUrl" -ForegroundColor Gray
Write-Host "  CDN: $CdnUrl" -ForegroundColor Gray
Write-Host ""
Write-Host "💡 下一步：" -ForegroundColor Yellow
Write-Host "  1. 启动网站: .\启动.ps1" -ForegroundColor White
Write-Host "  2. 在浏览器中查看效果" -ForegroundColor White
Write-Host ""

# 询问是否立即启动网站
$Launch = Read-Host "是否立即启动网站？(Y/N)"
if ($Launch -eq "Y" -or $Launch -eq "y") {
    Write-Host ""
    Write-Host "🚀 正在启动网站..." -ForegroundColor Cyan
    & (Join-Path $PSScriptRoot "启动.ps1")
}

