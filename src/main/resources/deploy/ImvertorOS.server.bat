@echo off
SETLOCAL ENABLEEXTENSIONS

set jar=%~1
set jobid=%~2
set propfile=%~3
set owner=%~4

set d=%~dp0
cd %d%
cd ..
call environment.server.bat %owner% 
cd %d%

set inpdir=%imvertor_os_input%
set outdir=%imvertor_os_output%
set workdir=%imvertor_os_work%
set bindir=%imvertor_os_bin%

if exist %propfile% set propfilepath=%propfile%
if exist %propfile% (goto PROPOKAY)

set propfilepath=%inpdir%\propfile\%propfile%.properties
if exist %propfilepath% (goto PROPOKAY)

REM fallback; error will be given by imvertor
set propfilepath=%propfile%
:PROPOKAY

SET jvmparms=-Xms512m -Xmx1024m

SET JAVA_HOME=%bindir%\bin\java\jre7
IF EXIST "%JAVA_HOME%\bin\java.exe" SET javaexe=%JAVA_HOME%\bin\java.exe
IF NOT EXIST "%JAVA_HOME%\bin\java.exe" SET javaexe=java.exe

call "%javaexe%" %jvmparms% ^
    -Dhttp.proxyHost=%imvertor_os_proxyhost% ^
	-Dhttp.proxyPort=%imvertor_os_proxyport% ^
    -Dlog4j.configuration=file:%bindir%\cfg\log4j.properties ^
	-Dinstall.dir="%bindir%" ^
	-Doutput.dir="%outdir%" ^
    -Dinput.dir="%inpdir%" ^
    -Dwork.dir="%workdir%\%jobid%" ^
    -classpath "%bindir%\bin\ChainTranslateAndReport_lib" ^
    -jar "%bindir%\bin\%jar%.jar" ^
	-arguments "%propfilepath%" ^
	-owner "%owner%"

goto END

:END
