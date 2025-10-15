@echo off
chcp 65001 >nul
title 个人网页 - 启动服务器

echo.
echo 🚀 正在启动个人网页...
echo.

REM 检查 Python
where python >nul 2>&1
if %errorlevel% == 0 (
    echo ✓ 找到 Python
    echo.
    echo 🌐 启动服务器: http://localhost:8000
    echo 按 Ctrl+C 停止服务器
    echo.
    timeout /t 1 /nobreak >nul
    start http://localhost:8000
    python -m http.server 8000
    goto :end
)

REM 检查 Node.js
where node >nul 2>&1
if %errorlevel% == 0 (
    where http-server >nul 2>&1
    if %errorlevel% == 0 (
        echo ✓ 找到 Node.js 和 http-server
        echo.
        echo 🌐 启动服务器: http://localhost:8000
        echo 按 Ctrl+C 停止服务器
        echo.
        timeout /t 1 /nobreak >nul
        start http://localhost:8000
        http-server -p 8000
        goto :end
    )
)

REM 检查 PHP
where php >nul 2>&1
if %errorlevel% == 0 (
    echo ✓ 找到 PHP
    echo.
    echo 🌐 启动服务器: http://localhost:8000
    echo 按 Ctrl+C 停止服务器
    echo.
    timeout /t 1 /nobreak >nul
    start http://localhost:8000
    php -S localhost:8000
    goto :end
)

REM 直接打开 HTML
echo ⚠️  未找到 Python、Node.js 或 PHP
echo 💡 直接在浏览器中打开 index.html...
echo.
start index.html
echo ✓ 已在浏览器中打开页面
echo.

:end
pause

