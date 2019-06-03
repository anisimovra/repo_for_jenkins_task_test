@echo off

rem ИЗМЕНИТЬ ЗНАЧЕНИЯ ПЕРЕД ЗАПУСКОМ
rem Путь рабочего каталога
set WORKING_DIR_PATH=D:\Work\Stuff\AutoSync
rem SSH URL до проекта в git
set GIT_PROJECT_URL=git@bsgit.ftc.ru:Timur/gittest.git
rem Текст коммита для определения даты последней синхронизации.
set COMMIT_TEXT="Sync master with production db"
rem Путь до папки с CFT Platfrom IDE
set ECLIPSE_PATH=C:\Eclipse\2MCA-latest2\cft-platform-ide-2mca
rem Схема для получения патча. Путь до TNS должен быть прописан в А2
set SCHEMA=CORE_DEV5
rem Владелец схемы
set OWNER=IBS
rem Пользователь
set USER=IBS
rem Пароль пользователя
set PASSWORD=IBS

rem НЕ ТРОГАТЬ
rem Путь до временного каталога с исходниками
set PROJECT_PATH=%WORKING_DIR_PATH%\Project
rem Путь до временного каталога с workspacом
set WORKSPACE_PATH=%WORKING_DIR_PATH%\Workspace
rem Путь до патча
set PATCH_PATH_ZIP=modified_locals.zip
rem Путь до pck с измененными объектами
set MODIFIED_PCK=modified_locals.pck

call start-ssh-agent
call %WORKING_DIR_PATH%\1checkout.bat %PROJECT_PATH% %GIT_PROJECT_URL%
call %WORKING_DIR_PATH%\2get_pck.bat %PROJECT_PATH% %WORKING_DIR_PATH% %USER%/%PASSWORD%@%SCHEMA% %COMMIT_TEXT%
rem call %WORKING_DIR_PATH%\3get_patch.bat %ECLIPSE_PATH% %SCHEMA% %OWNER% %USER% %PASSWORD% %PATCH_PATH_ZIP% %MODIFIED_PCK% %WORKSPACE_PATH%
if errorlevel 1 goto END
cd %WORKING_DIR_PATH%
call %WORKING_DIR_PATH%\4unzip_patch.bat %PATCH_PATH_ZIP% %PROJECT_PATH%
call %WORKING_DIR_PATH%\5commit.bat %PROJECT_PATH% %COMMIT_TEXT%
:END