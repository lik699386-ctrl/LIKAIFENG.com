# 🚀 GitHub Release 快速开始脚本

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "  GitHub Release 快速配置向导  " -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# 步骤1: 检查GitHub CLI
Write-Host "📋 步骤 1/4: 检查 GitHub CLI" -ForegroundColor Yellow
Write-Host ""

$ghInstalled = Get-Command gh -ErrorAction SilentlyContinue
if (-not $ghInstalled) {
    Write-Host "❌ 未安装 GitHub CLI" -ForegroundColor Red
    Write-Host ""
    Write-Host "请选择安装方式：" -ForegroundColor Cyan
    Write-Host "  [1] 使用 winget 自动安装（推荐）" -ForegroundColor Green
    Write-Host "  [2] 手动安装（打开官网）" -ForegroundColor Yellow
    Write-Host "  [3] 跳过" -ForegroundColor Gray
    Write-Host ""
    
    $choice = Read-Host "请选择 (1-3)"
    
    switch ($choice) {
        "1" {
            Write-Host "正在安装 GitHub CLI..." -ForegroundColor Cyan
            winget install GitHub.cli
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ 安装成功！请重新运行此脚本" -ForegroundColor Green
            }
            exit
        }
        "2" {
            Start-Process "https://cli.github.com"
            Write-Host "✅ 已打开官网，安装后请重新运行此脚本" -ForegroundColor Green
            exit
        }
        default {
            Write-Host "⏭️ 已跳过安装" -ForegroundColor Gray
            exit
        }
    }
}

Write-Host "✅ GitHub CLI 已安装" -ForegroundColor Green
Write-Host ""

# 步骤2: 检查登录状态
Write-Host "📋 步骤 2/4: 检查登录状态" -ForegroundColor Yellow
Write-Host ""

$authStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 未登录 GitHub" -ForegroundColor Red
    Write-Host ""
    Write-Host "是否现在登录？" -ForegroundColor Cyan
    Write-Host "  [Y] 是（推荐）" -ForegroundColor Green
    Write-Host "  [N] 否" -ForegroundColor Gray
    Write-Host ""
    
    $login = Read-Host "请选择 (Y/N)"
    
    if ($login -eq "Y" -or $login -eq "y") {
        Write-Host "正在启动登录流程..." -ForegroundColor Cyan
        gh auth login
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ 登录成功！" -ForegroundColor Green
        } else {
            Write-Host "❌ 登录失败，请手动运行: gh auth login" -ForegroundColor Red
            exit
        }
    } else {
        Write-Host "⏭️ 已跳过登录" -ForegroundColor Gray
        exit
    }
} else {
    Write-Host "✅ 已登录 GitHub" -ForegroundColor Green
}

Write-Host ""

# 步骤3: 选择要上传的文件
Write-Host "📋 步骤 3/4: 选择要上传的文件" -ForegroundColor Yellow
Write-Host ""

Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
$FileBrowser.Title = "选择要上传的文件"
$FileBrowser.Filter = "所有文件 (*.*)|*.*|ZIP文件 (*.zip)|*.zip|压缩文件 (*.rar,*.7z)|*.rar;*.7z"
$FileBrowser.InitialDirectory = [Environment]::GetFolderPath('Desktop')

if ($FileBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    $FilePath = $FileBrowser.FileName
    $FileInfo = Get-Item $FilePath
    $FileSizeMB = [math]::Round($FileInfo.Length / 1MB, 2)
    $FileSizeGB = [math]::Round($FileInfo.Length / 1GB, 2)
    
    Write-Host "✅ 已选择文件：" -ForegroundColor Green
    Write-Host "   文件名: $($FileInfo.Name)" -ForegroundColor Cyan
    if ($FileSizeGB -ge 1) {
        Write-Host "   大小: $FileSizeGB GB" -ForegroundColor Cyan
    } else {
        Write-Host "   大小: $FileSizeMB MB" -ForegroundColor Cyan
    }
    Write-Host ""
    
    # 检查文件大小
    if ($FileInfo.Length -gt 2GB) {
        Write-Host "⚠️ 警告：文件超过 2GB，GitHub Release 不支持！" -ForegroundColor Red
        Write-Host ""
        Write-Host "建议：" -ForegroundColor Yellow
        Write-Host "  1. 压缩文件以减小体积" -ForegroundColor Gray
        Write-Host "  2. 使用分卷压缩" -ForegroundColor Gray
        Write-Host "  3. 使用其他云存储方案" -ForegroundColor Gray
        Write-Host ""
        pause
        exit
    }
} else {
    Write-Host "❌ 未选择文件" -ForegroundColor Red
    exit
}

# 步骤4: 填写应用信息
Write-Host "📋 步骤 4/4: 填写应用信息" -ForegroundColor Yellow
Write-Host ""

$AppName = Read-Host "应用名称"
if ([string]::IsNullOrWhiteSpace($AppName)) {
    $AppName = [System.IO.Path]::GetFileNameWithoutExtension($FileInfo.Name)
}

$Version = Read-Host "版本号 (例如: v1.0.0)"
if ([string]::IsNullOrWhiteSpace($Version)) {
    $Version = "v1.0.0"
}
if (-not $Version.StartsWith("v")) {
    $Version = "v" + $Version
}

$Description = Read-Host "版本说明 (可选，直接回车跳过)"
if ([string]::IsNullOrWhiteSpace($Description)) {
    $Description = "发布 $AppName $Version 版本"
}

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "  确认信息  " -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host "应用名称: $AppName" -ForegroundColor White
Write-Host "版本号: $Version" -ForegroundColor White
Write-Host "文件: $($FileInfo.Name)" -ForegroundColor White
Write-Host "大小: $FileSizeMB MB" -ForegroundColor White
Write-Host "说明: $Description" -ForegroundColor White
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

$Confirm = Read-Host "确认上传？(Y/N)"

if ($Confirm -ne "Y" -and $Confirm -ne "y") {
    Write-Host "❌ 已取消上传" -ForegroundColor Red
    exit
}

# 执行上传
Write-Host ""
Write-Host "🚀 开始上传..." -ForegroundColor Cyan
Write-Host ""

$uploadScript = Join-Path $PSScriptRoot "upload-to-release.ps1"
& $uploadScript -FilePath $FilePath -Version $Version -AppName $AppName -Description $Description

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "  下一步  " -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. 复制上面的应用配置JSON" -ForegroundColor Yellow
Write-Host "2. 编辑 releases-config.json 文件" -ForegroundColor Yellow
Write-Host "3. 将配置添加到 apps 数组中" -ForegroundColor Yellow
Write-Host "4. 保存文件" -ForegroundColor Yellow
Write-Host "5. 刷新网站查看效果" -ForegroundColor Yellow
Write-Host ""
Write-Host "💡 提示：也可以直接运行脚本自动更新配置：" -ForegroundColor Cyan
Write-Host "   .\update-config.ps1" -ForegroundColor Gray
Write-Host ""

pause

