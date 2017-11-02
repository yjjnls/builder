set __dir__=%~dp0
pushd %__dir__%
cd %__dir__%\..
set __ROOTDIR__=%CD%
echo root directory : %__ROOTDIR__%
if not exist %__ROOTDIR__%\~tmp mkdir %__ROOTDIR__%\~tmp
powershell Set-ExecutionPolicy RemoteSigned
powershell -file %__ROOTDIR__%\setup\_MinGW.ps1



cd %__ROOTDIR__%\MinGW\bin
REM mingw-get mingw-developer-toolkit
mingw-get install msys-base

mingw-get install msys-wget
mingw-get install msys-flex
mingw-get install msys-bison
mingw-get install msys-perl
echo %__ROOTDIR__%\MinGW\msys\1.0\msys.bat >%__ROOTDIR__%\shell.cmd
cd %__ROOTDIR__%
