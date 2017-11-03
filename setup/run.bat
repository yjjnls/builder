@echo OFF
set __dir__=%~dp0
pushd %__dir__%
cd %__dir__%\..
set __ROOTDIR__=%CD%
chcp 936
if not exist %__ROOTDIR__%\~tmp mkdir %__ROOTDIR__%\~tmp
REM powershell Set-ExecutionPolicy RemoteSigned
REM powershell -file %__ROOTDIR__%\setup\_MinGW.ps1

REM ==== install MinGW ===
powershell Set-ExecutionPolicy RemoteSigned
if %ERRORLEVEL% neq 0 (
   echo "You should use adminstrator to run the bat."
   pause
   exit/b 1
) 


powershell -file %__ROOTDIR__%\setup\_MinGW.ps1
if %ERRORLEVEL% neq 0 (
   echo "Install MinGW Failed!"
   pause
   exit/b 1
) 


cd %__ROOTDIR__%\MinGW\bin
REM mingw-get mingw-developer-toolkit
mingw-get install msys-base

mingw-get install msys-wget
mingw-get install msys-flex
mingw-get install msys-bison
mingw-get install msys-perl
REM echo %__ROOTDIR__%\MinGW\msys\1.0\msys.bat >%__ROOTDIR__%\shell.cmd
%__ROOTDIR__%\bash.cmd ./setup/setup.sh
if %ERRORLEVEL% neq 0 (
   echo "Setup Failed!"
   pause
   exit/b 1
) 

cd %__ROOTDIR__%
