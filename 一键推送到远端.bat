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

    REM 不知道为什么，不空行就报错，不管他
    echo    远程地址别名: !remote_name!
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
    REM 执行推送并捕获错误码
    git push --set-upstream !remote_name! !current_branch!
    set push_result=!errorlevel!
    echo ----------------------------------------
    if !push_result! equ 0 (
    ) else (
        echo ❌ 推送失败，错误原因：
        if !push_result! equ 1 (
            echo    - 远程仓库有本地没有的更新，请先执行：
            echo      git pull !remote_name! !current_branch!
        ) else if !push_result! equ 128 (
            echo    - 仓库访问失败：
            echo      - 可能是网络连接问题
            echo      - 远程仓库不存在或地址错误
            echo      - 没有访问该仓库的权限
        ) else if !push_result! equ 129 (
            echo    - Git命令语法错误
            echo      - 可能是脚本参数配置有误
        ) else if !push_result! equ 130 (
            echo    - 操作被用户中断（通常是按了Ctrl+C）
        ) else if !push_result! equ 131 (
            echo    - Git进程崩溃
            echo      - 建议检查Git安装完整性
        ) else if !push_result! equ 132 (
            echo    - 发生严重错误（如内存访问错误）
        ) else if !push_result! equ 133 (
            echo    - 程序被信号终止
        ) else if !push_result! equ 134 (
            echo    - 程序异常终止
        ) else if !push_result! equ 255 (
            echo    - 认证失败：
            echo      - 用户名或密码错误
            echo      - SSH密钥未配置或权限不足
            echo      - 建议检查远程仓库访问权限
        ) else (
            echo    - 错误代码：!push_result!
            echo    - 请查看上方Git日志获取详细信息
            echo    - 常见解决方案：
            echo      1. 确保本地有最新代码：git pull
            echo      2. 检查分支保护规则（某些分支可能需要审核）
            echo      3. 确认有推送权限：git remote show !remote_name!
        )
    )
) else (
    echo.
    echo ⏹️  已取消推送操作。
)

echo.
pause
endlocal
