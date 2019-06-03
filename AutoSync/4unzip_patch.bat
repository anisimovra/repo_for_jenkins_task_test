@echo off

if "%~1"=="" goto NOPARAM
if "%~2"=="" goto NOPARAM
goto OK

:NOPARAM
@echo USAGE:
@echo   4unzip_patch PathToZip TargetPath
@echo WHERE:
@echo   PathToZip		- Local path to patch zip
@echo	TargetPath		- Local path to extract
exit

:OK
@echo ===== Unzip patch =====
if exist %1 goto UNZIP
@echo File %1 not exist!
goto END

:UNZIP
rem Исключаем файлы modified.info и .project
7za.exe x %1 -o%2 -r -x!modified.info -x!.project -aoa

:END