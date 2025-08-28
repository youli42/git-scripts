@echo off
REM 启用延迟扩展
setlocal enabledelayedexpansion

REM 设置编码为系统默认ANSI，提高兼容性
chcp 65001 > nul

REM 1. 检查Git是否安装
echo 正在检测Git是否安装...
git --version > nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 未检测到Git安装
    echo 请先安装Git，下载地址：
    echo https://git-scm.com/downloads/win
    echo.
    pause
    exit /b 1
) else (
    echo ✅ Git已安装
)

REM 2. 检查当前目录是否已为Git仓库
echo.
echo 正在检测当前目录是否为Git仓库...
git rev-parse --is-inside-work-tree > nul 2>&1
if %errorlevel% equ 0 (
    echo ⚠️ 当前目录已是Git仓库，无需重复初始化
    goto :configure_user
) else (
    echo ✅ 当前目录不是Git仓库，准备初始化
)

REM 3. 初始化Git仓库
echo.
echo 正在初始化Git仓库...
git init
if %errorlevel% equ 0 (
    echo ✅ 仓库初始化成功
) else (
    echo ❌ 仓库初始化失败
    pause
    exit /b 1
)

:configure_user
REM 4. 检查并配置本地用户信息（仅针对当前仓库）
echo.
echo 正在检查本地用户信息...

REM 检查本地用户名
git config user.name > nul 2>&1
if %errorlevel% neq 0 (
    set /p user_name=请输入您的用户名（仅用于当前仓库）：
    git config user.name "!user_name!"
    echo ✅ 已设置本地用户名：!user_name!
) else (
    for /f "delims=" %%i in ('git config user.name') do set existing_name=%%i
    echo ℹ️ 已存在本地用户名：!existing_name!
)

REM 检查本地邮箱
git config user.email > nul 2>&1
if %errorlevel% neq 0 (
    set /p user_email=请输入您的邮箱（仅用于当前仓库）：
    git config user.email "!user_email!"
    echo ✅ 已设置本地邮箱：!user_email!
) else (
    for /f "delims=" %%i in ('git config user.email') do set existing_email=%%i
    echo ℹ️ 已存在本地邮箱：!existing_email!
)

REM 5. 询问是否添加远程仓库
echo.
set /p add_remote=是否需要添加远程仓库？(输入y/Y确认，其他键取消)：
if /i "!add_remote!"=="y" (
    set /p remote_name=请输入远程仓库别名（通常为origin）：
    if "!remote_name!"=="" set remote_name=origin
    
    set /p remote_url=请输入远程仓库URL：
    if "!remote_url!"=="" (
        echo ❌ 远程仓库URL不能为空
        pause
        exit /b 1
    )
    
    git remote add !remote_name! !remote_url!
    if %errorlevel% equ 0 (
        echo ✅ 已添加远程仓库：!remote_name!（!remote_url!）
    ) else (
        echo ❌ 添加远程仓库失败，请检查URL是否正确或是否已存在同名远程仓库
    )
) else (
    echo ℹ️ 未添加远程仓库，可稍后使用"git remote add 别名 仓库URL"命令添加
)

echo.
echo 🎉 仓库初始化流程完成！
echo 后续常用命令: 

echo - 添加文件：git add 文件名

echo - 提交更改：git commit -m "提交说明"

echo - 如需推送，先添加远程仓库后使用：git push
pause
endlocal