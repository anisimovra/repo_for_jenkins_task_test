@echo off

if "%~1"=="" goto NOPARAM
if "%~2"=="" goto NOPARAM
if "%~3"=="" goto NOPARAM
if "%~4"=="" goto NOPARAM
goto OK

:NOPARAM
@echo USAGE:
@echo   2get_pck PathToProject PathToWF ConnStr CommitTextToFind
@echo WHERE:
@echo   PathToProject		- Local path to store project
@echo	PathToWF			- Local path to working folder
@echo   ConnStr 			- Connect String To OWNER of IB System Object.
@echo   CommitTextToFind 	- Find last commit with this text

exit

:OK
@echo ===== Geting last sync date =====
cd %1
set LAST_SYNC_DATE_FILE=%2\LastSyncDate.log
set LAST_SYNC_DATE=
set TEXT="%~4"
echo Commit text: %TEXT%
git log --pretty="format:%%cd" --grep=%TEXT% --max-count=1 --reverse --date=format:"%%d/%%m/%%Y %%H:%%M:%%S" > "%LAST_SYNC_DATE_FILE%"
for /f "Tokens=*" %%a in (%LAST_SYNC_DATE_FILE%) do @set LAST_SYNC_DATE=%%a

if "%LAST_SYNC_DATE%"=="" goto SETSYNCDATE

:GETPCK
echo "Last sync date: %LAST_SYNC_DATE%"
cd %2
if exist modified_locals.pck del /F modified_locals.pck
chcp 1251
@echo ===== Geting pck with modified objects =====
sqlplus %3 @modified_locals_pck %LAST_SYNC_DATE%
goto END

:SETSYNCDATE
rem Получение текущей даты и времени
for /f %%x in ('wmic path win32_utctime get /format:list ^| findstr "="') do set %%x

rem Отнимем 2 месяца
set MINUS_MONTHS=2
for /f "" %%# in ('WMIC Path Win32_LocalTime Get month /format:value') do (
    for /f %%Z in ("%%#") do set /a %%Z-%MINUS_MONTHS%
)
if %month% equ 0 set month=12

set LAST_SYNC_DATE=%Day%/%month%/%Year% %Hour%:%Minute%:%Second%
goto GETPCK

:END