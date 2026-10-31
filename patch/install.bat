@echo off
setlocal
set "SRC=%~dp0winmm.dll"
if "%~1"=="" (
  set /p "TARGET=Typora 安装目录（包含 Typora.exe）: "
) else (
  set "TARGET=%~1"
)
if not exist "%SRC%" (echo 找不到 %SRC% & pause & exit /b 1)
if not exist "%TARGET%\Typora.exe" (echo 该目录没有 Typora.exe，请检查 & pause & exit /b 1)
if exist "%TARGET%\winmm.dll" (
  echo 目标目录已有 winmm.dll，备份为 winmm.dll.bak
  copy /y "%TARGET%\winmm.dll" "%TARGET%\winmm.dll.bak" >nul
)
copy /y "%SRC%" "%TARGET%\winmm.dll" >nul
if errorlevel 1 (echo 复制失败，请以管理员身份运行 & pause & exit /b 1)
echo 已安装到 %TARGET%
echo 重新启动 Typora 生效。卸载：删除该目录的 winmm.dll 即可。
pause
