@echo off
title Backup Maker - INDEV
color 6
goto :loader

:loader
set getconfigcallback=:menu
echo Verifying data...
cd %appdata%
if exist backupmakerdata\*.* goto :getconfig
goto :firstlaunch


:firstlaunch
cls
set updateconfigcallback=:menu
set getconfigcallback=:menu
echo Welcome to Backup Maker !
echo We are getting started to configurate the program !
echo.
pause
cls
echo Enter the access file of the folder to copy !
echo.
set /p pathToBackup=" > "
cls
echo Enter the access file where the backup have to be put.
echo.
set /p pathOfBackup=" > "
cls
echo Do you want to continue with this configuration ?
echo Folder to copy: %pathToBackup%
echo Folder of the backup: %pathOfBackup%
echo.
echo [1] Confirm
echo [2] Cancel and restart
echo [3] Cancel and leave
echo.
set /p confirmationcreation=" > "
if /i "%confirmationcreation%"=="1" goto :updateconfig
if /i "%confirmationcreation%"=="2" goto :firstlaunch
if /i "%confirmationcreation%"=="3" exit
goto :menu


:updateconfig
cls
echo Updating config...
if exist backupmakerdata\*.* rmdir backupmakerdata /s /q
mkdir backupmakerdata
cd backupmakerdata
<nul set /p="%pathToBackup%" >> pathToBackup.config
<nul set /p="%pathOfBackup%" >> pathOfBackup.config
pause
cd ..
cls
color 2
echo Done !
color 6
goto %updateconfigcallback%


:settings
cls
echo [1] Edit config
echo [2] Full reset (this will relaunch the firstlaunch config and delete all the current config)
echo [3] Goto menu
echo.
set /p choix=" > "
if /i "%choix%"=="1" goto :editconfig
if /i "%choix%"=="2" (
    cd %appdata%
    rmdir backupmakerdata /s /q
    goto :firstlaunch
)

if /i "%choix%"=="3" goto :menu
echo Invalid Option
pause
goto :settings


:editconfig
cls
echo [CONFIG EDITOR]
echo.
echo Current path to backup: %pathToBackup%
echo Current path of backup store: %pathOfBackup%
echo.
echo [1] Edit path to backup
echo [2] Edit path of backup store
echo [3] Return to settings
echo.
set /p choix=" > "
if /i "%choix%"=="1" (
    cls
    echo Enter the new path to backup
    echo.
    set /p pathToBackup=" > "
    set updateconfigcallback=:editconfig
    call :updateconfig
    goto :editconfig
)
if /i "%choix%"=="2" (
    cls
    echo Enter the new path of backup store
    echo.
    set /p pathOfBackup=" > "
    set updateconfigcallback=:editconfig
    call :updateconfig
    goto :editconfig
)
goto :settings


:createbackup
cls
echo "%pathOfBackup%"
echo "%pathToBackup%"
cd "%pathOfBackup%"
if exist backup-maker rmdir backup-maker /s /q
mkdir backup-maker
cd backup-maker
xcopy "%pathToBackup%" /e /i
cd %appdata%
pause
goto :menu


:deletebackup
cls
cd "%pathOfBackup%"
if exist backup-maker (
    :askdeletebackupconfirmation
    cls
    echo Are you sure you want to confirm the delete of the backup?
    echo.
    echo [1] Confirm
    echo [2] Cancel
    echo.
    set /p deleteconfirmation=" > "

    if "%deleteconfirmation%"=="1" (
        cls
        echo Deleting backup...
        rmdir backup-maker /s /q
        echo Done !
        pause
        goto :menu
    ) else if "%deleteconfirmation%"=="2" (
        color 4
        cls
        echo Cancelled.
        pause
        color 6
        goto :menu
    ) else (
        echo Option not valid.
        pause
        goto :askdeletebackupconfirmation
    )
)


:checkbackup
cls
cd "%pathOfBackup%"
if exist backup-maker (
    :checkbackupopenexplorerconfirmation
    cls
    set "openexplorer="
    echo Backup found !
    echo.
    echo Do you want to open the file explorer at his location ?
    echo [1] Yes [2] No
    echo.
    set /p openexplorer=" > "
    if /i "%openexplorer%"=="1" (
        cls
        cd backup-maker
        start explorer .
        echo Done !
        cd %appdata%
        pause
        goto :menu
    ) else if "%openexplorer%"=="2" (
        cls
        goto :menu
    )
        cls
        color 4
        echo Option invalid.
        color 6
        pause
        goto :checkbackupopenexplorerconfirmation
    )
color 4
echo Backup not found !
pause
color 6
goto :menu

:getconfig
cls
echo Getting config...
cd backupmakerdata
set /p pathToBackup=<pathToBackup.config
set /p pathOfBackup=<pathOfBackup.config
cd ..
goto %getconfigcallback%

:menu
cls
echo [1] Make a backup
echo [2] Verify if backup exist
echo [3] Delete backup 
echo [4] Settings
echo [5] Exit
echo.

set /p choix=" > "
if /i "%choix%"=="1" goto :createbackup
if /i "%choix%"=="2" goto :checkbackup
if /i "%choix%"=="3" goto :deletebackup
if /i "%choix%"=="4" goto :settings
if /i "%choix%"=="#DEBUG" goto :debug
if /i "%choix%"=="5" exit

echo Option not found
pause
goto :menu

:debug
cls
echo YOU HAVE ENTERED THE DEBUG MODE
echo.
echo [1] Open debug prompt
echo [2] Force Data Uptade
echo [3] Force Data Reload
echo [4] Go to main menu
echo.
set /p choix=" > "

if /i "%choix%"=="2" (
    cls
    set updateconfigcallback=:debug
    call :updateconfig
    echo Done !
    pause
    goto :debug
)
if /i "%choix%"=="3" (
    cls
    set getconfigcallback=:debug
    call :getconfig
    echo Done !
    pause
    goto :debug
)
if /i "%choix%"=="4" goto :menu

:debug-cmd
set /p cmd="%__CD__%> "

if /i "%cmd%"=="menu" (
    goto :menu
)

if /i "%cmd%"=="ls" (
    powershell ls
    goto :debug-cmd
)
if /i "%cmd%"=="debug" (
    goto :debug
)
%cmd%
goto :debug-cmd
