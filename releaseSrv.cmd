@echo off

setlocal

set CURDIR=%~dp0
call ..\ScrnMakeEnv.cmd %CURDIR%

echo Removing previous release files...
del /S /Q %RELEASEDIR%\*

:: Sanity check
if exist %RELEASEDIR%\System\%KFPACKAGE%.u (
    echo Failed to cleanup the release directory
    set /A ERR=100
    goto :error
)

del %KFDIR%\System\%KFPACKAGE%.ucl 2>nul

echo Compiling project...
call make.cmd
set /A ERR=%ERRORLEVEL%
if %ERR% NEQ 0 goto error

echo Exporting .int file...
%KFDIR%\System\ucc dumpint %KFPACKAGE%.u

echo.
echo Copying release files...
xcopy /F /I /Y *.ini %RELEASEDIR%
xcopy /F /I /Y *.txt %RELEASEDIR%
xcopy /F /I /Y *.md  %RELEASEDIR%

mkdir %RELEASEDIR%\System 2>nul
xcopy /F /I /Y %KFDIR%\System\%KFPACKAGE%.int %RELEASEDIR%\System\
xcopy /F /I /Y %KFDIR%\System\%KFPACKAGE%.u %RELEASEDIR%\System\
xcopy /F /I /Y %KFDIR%\System\%KFPACKAGE%.ucl %RELEASEDIR%\System\
xcopy /F /I /Y %KFDIR%\System\ScrnSP.* %RELEASEDIR%\System\
xcopy /F /I /Y %KFDIR%\System\ScrnVotingHandlerV4.* %RELEASEDIR%\System\

mkdir %RELEASEDIR%\Animations 2>nul
xcopy /F /I /Y %STEAMDIR%\Animations\ScrnAnims.ukx %RELEASEDIR%\Animations\

mkdir %RELEASEDIR%\Sounds 2>nul
xcopy /F /I /Y %STEAMDIR%\Sounds\ScrnSnd.uax %RELEASEDIR%\Sounds\

REM mkdir %RELEASEDIR%\StaticMeshes 2>nul

mkdir %RELEASEDIR%\Textures 2>nul
xcopy /F /I /Y %STEAMDIR%\Textures\ScrnTex.utx %RELEASEDIR%\Textures\
xcopy /F /I /Y %STEAMDIR%\Textures\ScrnAch_T.utx %RELEASEDIR%\Textures\
xcopy /F /I /Y %STEAMDIR%\Textures\TSC_T.utx %RELEASEDIR%\Textures\

if not exist %RELEASEDIR%\System\%KFPACKAGE%.u (
    echo Release failed
    set /A ERR=101
    goto :error
)

echo.
echo Update public release notes
xcopy /F /I /Y README.md %WEBDIR%\ScrnBalanceVersionHistory.md

echo.
echo Updating the bundle...
xcopy /F /I /Y %RELEASEDIR%\Animations\*            %BUNDLEDIR%\Animations\
xcopy /F /I /Y %RELEASEDIR%\Sounds\*                %BUNDLEDIR%\Sounds\
REM xcopy /F /I /Y %RELEASEDIR%\StaticMeshes\*          %BUNDLEDIR%\StaticMeshes\
xcopy /F /I /Y %RELEASEDIR%\System\*                %BUNDLEDIR%\System\
xcopy /F /I /Y %RELEASEDIR%\Textures\*              %BUNDLEDIR%\Textures\
xcopy /F /I /Y %RELEASEDIR%\KFMapVote.ini           %BUNDLEDIR%\System\
xcopy /F /I /Y %RELEASEDIR%\ScrnLock.ini            %BUNDLEDIR%\System\
xcopy /F /I /Y %RELEASEDIR%\ScrnMapInfo.ini         %BUNDLEDIR%\System\
xcopy /F /I /Y %RELEASEDIR%\ScrnVoting.ini          %BUNDLEDIR%\System\
xcopy /F /I /Y %RELEASEDIR%\ScrnWaves.ini           %BUNDLEDIR%\System\

echo Release is ready!

goto :end

:error
color 0C

:end
endlocal & SET _EC=%ERR%
exit /b %_EC%
