@echo off
setlocal
set VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe
if exist "%VSWHERE%" (
  for /f "usebackq tokens=*" %%i in (`"%VSWHERE%" -latest -property installationPath`) do set VSPATH=%%i
)
if not defined VSPATH set VSPATH=C:\Program Files\Microsoft Visual Studio\2022\Professional
call "%VSPATH%\VC\Auxiliary\Build\vcvars64.bat" >nul
if errorlevel 1 (echo vcvars64 not found & exit /b 1)
cd /d "%~dp0"
where python >nul 2>nul && python gen_payload.py
ml64 /nologo /c /Fo winmm_asm.obj winmm_stubs.asm
if errorlevel 1 exit /b 1
cl /nologo /LD /MT /O2 /EHsc /DUNICODE /D_UNICODE winmm_proxy.cpp winmm_stubs.cpp winmm_asm.obj /link /Brepro /DEF:winmm_proxy.def /OUT:..\patch\winmm.dll
if errorlevel 1 exit /b 1
echo built ..\patch\winmm.dll
