@echo OFF
set __dir__=%~dp0
set __bash__=%__dir__%\MinGW\msys\1.0\bin\bash.exe
if not exist %__bash__% (
   echo "You may not run setup,please run /setup/run.bat with admin"
   pause
   exit 1
)
pushd %__dir__%
if "x%1" == "x" ( %__bash__%  --init-file init.sh ) else %__bash__%  %1
popd