@echo off
SETLOCAL ENABLEEXTENSIONS

set jar=%~1
set artifact=%~2
set jobid=%~3
set propfile=%~4
set owner=%~5
set reg=%~6

set d=%~dp0
cd %d%
cd ..
call environment.server.bat %owner% %reg%
cd %d%

set inpdir=%d%\input\%owner%

set outdir=%imvertor_os_output%
set workdir=%imvertor_os_work%
set bindir=%imvertor_os_bin%
set eaenabled=%imvertor_os_eaenabled%

if exist %propfile% set propfilepath=%propfile%
if exist %propfile% (goto PROPOKAY)

set propfilepath=%inpdir%\propfile\%propfile%.properties
if exist %propfilepath% (goto PROPOKAY)

REM fallback; error will be given by imvertor
set propfilepath=%propfile%
:PROPOKAY

SET jvmparms=-Xms512m -Xmx1024m

SET JAVA_HOME=%bindir%\bin\java\jre1.8.0_101
IF EXIST "%JAVA_HOME%\bin\java.exe" SET javaexe=%JAVA_HOME%\bin\java.exe
IF NOT EXIST "%JAVA_HOME%\bin\java.exe" SET javaexe=java.exe

call "%javaexe%" %jvmparms% ^
    -Dhttp.proxyHost=%imvertor_os_proxyhost% ^
	-Dhttp.proxyPort=%imvertor_os_proxyport% ^
    -Dlog4j.configuration=file:%bindir%\log4j.properties ^
	-Dinstall.dir="%bindir%" ^
	-Doutput.dir="%outdir%" ^
    -Downer.name="%owner%" ^
    -Dwork.dir="%workdir%\%jobid%" ^
    -Dea.enabled=%imvertor_os_eaenabled% ^
    -Dgit.token=%imvertor_os_git_token% ^
    -cp "%bindir%\bin\%jar%.jar" ^
	nl.imvertor.%artifact% ^
	-arguments "%propfilepath%" ^
	-owner "%owner%"

    rem removed: -classpath "%bindir%\bin\ChainTranslateAndReport_lib" ^
    
goto END

:END
