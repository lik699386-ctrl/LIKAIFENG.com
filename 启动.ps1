# Personal Website Launcher
# Auto-detect and start local server

Write-Host "Starting personal website..." -ForegroundColor Cyan
Write-Host ""

$port = 8000
$url = "http://localhost:$port"

# Check if port is in use
$portInUse = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
if ($portInUse) {
    Write-Host "Port $port is in use, trying 8001..." -ForegroundColor Yellow
    $port = 8001
    $url = "http://localhost:$port"
}

# Try Python
Write-Host "Checking Python..." -ForegroundColor Gray
$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
if ($pythonCmd) {
    $pythonVersion = python --version 2>&1
    Write-Host "Found $pythonVersion" -ForegroundColor Green
    Write-Host ""
    Write-Host "Server starting at: $url" -ForegroundColor Cyan
    Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
    Write-Host ""
    
    Start-Sleep -Seconds 1
    Start-Process $url
    
    python -m http.server $port
    exit
}

# Try Node.js
Write-Host "Checking Node.js..." -ForegroundColor Gray
$nodeCmd = Get-Command node -ErrorAction SilentlyContinue
if ($nodeCmd) {
    $nodeVersion = node --version
    Write-Host "Found Node.js $nodeVersion" -ForegroundColor Green
    
    $httpServerCmd = Get-Command http-server -ErrorAction SilentlyContinue
    if ($httpServerCmd) {
        Write-Host "Found http-server" -ForegroundColor Green
        Write-Host ""
        Write-Host "Server starting at: $url" -ForegroundColor Cyan
        Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
        Write-Host ""
        
        Start-Sleep -Seconds 1
        Start-Process $url
        
        http-server -p $port
        exit
    }
}

# Try PHP
Write-Host "Checking PHP..." -ForegroundColor Gray
$phpCmd = Get-Command php -ErrorAction SilentlyContinue
if ($phpCmd) {
    $phpVersion = php --version | Select-Object -First 1
    Write-Host "Found PHP" -ForegroundColor Green
    Write-Host ""
    Write-Host "Server starting at: $url" -ForegroundColor Cyan
    Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
    Write-Host ""
    
    Start-Sleep -Seconds 1
    Start-Process $url
    
    php -S localhost:$port
    exit
}

# Open HTML directly
Write-Host ""
Write-Host "No server found, opening HTML file directly..." -ForegroundColor Yellow
Write-Host ""

$indexPath = Join-Path $PSScriptRoot "index.html"
Start-Process $indexPath

Write-Host "Page opened in browser" -ForegroundColor Green
Write-Host ""
