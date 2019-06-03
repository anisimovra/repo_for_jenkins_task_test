@echo off

if "%~1"=="" goto NOPARAM
if "%~2"=="" goto NOPARAM
if "%~3"=="" goto NOPARAM
if "%~4"=="" goto NOPARAM
if "%~5"=="" goto NOPARAM
if "%~6"=="" goto NOPARAM
if "%~7"=="" goto NOPARAM
if "%~8"=="" goto NOPARAM
goto OK

:NOPARAM
@echo USAGE:
@echo   3get_patch PathToEclipse Server Owner User Password PathToZip PathToPck PathToProject
@echo WHERE:
@echo   PathToEclipse		- Local path to Eclipse folder
@echo   Server				- Server TNS or connection string
@echo   Owner				- Schema owner
@echo   User				- User
@echo   Password			- Password
@echo   PathToZip			- Path to create patch zip
@echo   PathToPck			- Path to pck file
@echo   PathToProject 		- Local path to project
exit

:OK
chcp 1251
set EXPORT_LOG=export.log
if exist %EXPORT_LOG% del /F %EXPORT_LOG%
if exist %6 del /F %6
if exist "%8" del /s /f /q "%8\*.*"
for /f %%f in ("dir /ad /b %8\") do rd /s /q %8\%%f
@echo ===== Export changed sources =====
"%1\eclipsec.exe" -clean -nosplash -nl ru_RU -application ru.cft.platform.deployment.bootstrap.Deployment -export -server "%2" -owner "%3" -username "%4" -pass "%5" -filepath "%6" -pckpath "%7" -data "%8" -poolconfig "pool-settings.xml" -log "%EXPORT_LOG%" --launcher.suppressErrors