@echo OFF
set __dir__=%~dp0
set __bash__=%__dir__%\MinGW\msys\1.0\bin\bash.exe
pushd %__dir__%
if "x%1" == "x" ( %__bash__%  --init-file init.sh ) else %__bash__%  %1
popd