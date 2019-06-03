@echo off

if "%~1"=="" goto NOPARAM
if "%~2"=="" goto NOPARAM
goto OK

:NOPARAM
@echo USAGE:
@echo   5commit.bat PathToProject CommitText
@echo WHERE:
@echo   PathToProject	- Local path to store project
@echo   CommitText 		- Commit text

exit

:OK
@echo ===== Commit changes %1 =====
cd %1
git add %1\src
git commit -m "%~2"
git push origin master