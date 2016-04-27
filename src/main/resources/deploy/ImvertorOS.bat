@echo off
SETLOCAL ENABLEEXTENSIONS

call c:\Tools\ImvertorOS\environment.bat

set inpdir=%imvertor_os_input%
set outdir=%imvertor_os_output%
set workdir=%imvertor_os_work%
set bindir=%imvertor_os_bin%

set jarfile=ChainTranslateAndReport.jar

set eapfile=%~1
set hisfile=%~2
set propfile=%~3

if exist %propfile% set propfilepath=%propfile%
if exist %propfile% (goto PROPOKAY)

set propfilepath=%inpdir%\propfile\%propfile%.properties
if exist %propfilepath% (goto PROPOKAY)

REM fallback; error will be given by imvertor
set propfilepath=%propfile%
:PROPOKAY

rem eerste 3 parameters overslaan, de rest van de parameters worden toegevoegd
SHIFT
SHIFT
SHIFT
:LOOP
IF [%1]==[] GOTO CONTINUE
  set PARMS=%PARMS% %1
SHIFT
GOTO LOOP
:CONTINUE

set PATH=%PATH%;%bindir%\bin\EA;

SET jvmparms=-Xms512m -Xmx1024m

SET JAVA_HOME=%bindir%\bin\java\jre7
IF EXIST "%JAVA_HOME%\bin\java.exe" SET javaexe=%JAVA_HOME%\bin\java.exe
IF NOT EXIST "%JAVA_HOME%\bin\java.exe" SET javaexe=java.exe

call "%javaexe%" %jvmparms% ^
    -Dhttp.proxyHost=%imvertor_os_proxyhost% ^
	-Dhttp.proxyPort=%imvertor_os_proxyport% ^
    -Dlog4j.configuration="file:%bindir%\cfg\log4j.properties" ^
	-Dinstall.dir="%bindir%" ^
	-Doutput.dir="%outdir%" ^
    -Dinput.dir="%inpdir%" ^
    -Dwork.dir="%workdir%\default" ^
    -jar "%bindir%\bin\%jarfile%" ^
	-arguments "%propfilepath%"  ^
	-umlfile "%eapfile%" ^
	-hisfile "%hisfile%" ^
	%PARMS% 

goto END

:END
