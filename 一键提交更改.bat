@echo off
REM 启用延迟环境变量扩展
setlocal enabledelayedexpansion

REM 设置UTF-8编码，避免中文乱码
@chcp 65001 > nul

REM 1. 检查当前目录是否为Git仓库
echo 🔍 正在检测Git仓库...
git rev-parse --is-inside-work-tree > nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 错误：当前目录不是Git仓库，请切换到仓库目录后重新运行！
    pause
    exit /b 1
)
echo ✅ 已在Git仓库目录中

REM 2. 提示用户输入提交信息
echo.
set /p commit_msg=📝 请输入提交信息（描述本次变更）: 

REM 3. 检查提交信息是否为空
if "!commit_msg!"=="" (
    echo.
    echo ❌ 错误：提交信息不能为空！
    echo    请重新运行脚本并输入有意义的提交信息。
    pause
    exit /b 1
)

REM 4. 执行Git暂存和提交操作
echo.
echo 📦 开始执行提交操作...
echo ----------------------------------------
REM 显示Git命令执行过程
git add .
REM equ =; neq !=
if %errorlevel% equ 0 (
    echo ✅ git add 执行成功（已暂存所有变更）
) else (
    echo ❌ git add 执行失败，请检查是否有特殊文件无法暂存
    echo 错误码：%errorlevel%
    pause
    exit /b 1
)

echo.
git commit -m "!commit_msg!"
if %errorlevel% equ 0 (
    echo ----------------------------------------
    echo ✅ 提交成功！
    echo    提交信息：!commit_msg!
) else (
    echo ----------------------------------------
    echo ❌ 提交失败！
    echo    可能原因：没有实质变更、冲突或配置问题
    pause
    exit /b 1
)

REM 5. 操作完成提示
echo.
echo 🎉 所有操作已完成
echo    可以运行推送脚本将变更推送到远程仓库
pause

endlocal