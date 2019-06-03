@echo off

if "%~1"=="" goto NOPARAM
if "%~2"=="" goto NOPARAM
goto OK

:NOPARAM
@echo USAGE:
@echo   1checkout PathToProject GitUrl
@echo WHERE:
@echo   PathToProject	 - Local path to store project
@echo   GitUrl			 - Url to clone git
exit

:OK
IF EXIST %1 goto DIREXIST
@echo ===== Cloning project %2 =====
git clone %2 %1
:DIREXIST
cd %1
@echo ===== Checkout branch master =====
git checkout --track origin/master
@echo ===== Pull updates =====
git pull .