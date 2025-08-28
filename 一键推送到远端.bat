@echo off
REM 默认隐藏命令本身，仅显示主动输出内容
setlocal enabledelayedexpansion

REM 设置UTF-8编码，避免中文乱码（隐藏此命令的执行日志）
@chcp 65001 > nul

REM 1. 检查当前目录是否为Git仓库
echo 正在检测Git仓库...
git rev-parse --is-inside-work-tree > nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ 检测到Git仓库，继续操作...
) else (
    echo ❌ 错误：当前目录不是Git仓库，请切换到仓库目录后重新运行脚本！
    pause
    exit /b 1
)

REM 2. 获取并验证远程仓库信息
echo.
echo 正在获取远程仓库信息...
for /f "tokens=1,2" %%a in ('git remote -v ^| findstr /i "push"') do (
    set remote_name=%%a
    set remote_url=%%b
    goto :remote_found
)

:remote_found
if "!remote_name!"=="" (
    echo ❌ 错误：未配置远程仓库！
    echo 请先执行命令配置：git remote add origin 你的远程仓库地址（如https://github.com/用户名/仓库名.git）
    pause
    exit /b 1
) else (
    echo ✅ 检测到远程仓库信息：
    echo    远程名称: !remote_name!
    echo    远程地址: !remote_url!
)

REM 3. 获取当前分支名称
for /f "delims=" %%i in ('git rev-parse --abbrev-ref HEAD') do (
    set current_branch=%%i
)
echo.
echo 当前分支: !current_branch!

REM 4. 确认推送并执行
echo.
set /p confirm=是否确认推送到以上远程仓库？(输入y/Y确认，其他键取消)：
if /i "!confirm!"=="y" (
    echo.
    echo 🚀 开始执行推送，以下是Git操作日志：
    echo ----------------------------------------
    REM 尝试推送并设置上游分支（解决no upstream branch问题）
    git push --set-upstream !remote_name! !current_branch!
    echo ----------------------------------------
    if %errorlevel% equ 0 (
        echo ✅ 推送成功！
    ) else (
        echo ❌ 推送失败，请查看上方Git日志排查问题（如网络、权限、分支冲突等）。
    )
) else (
    echo.
    echo ⏹️  已取消推送操作。
)

echo.
pause
endlocal
