@echo off
SETLOCAL ENABLEEXTENSIONS

set eapfile=%~1
set hisfile=%~2
set propfile=%~3
set owner=%~4

set d=%~dp0
cd %d%
cd ..
call environment.bat "%owner%" 
cd %d%

set inpdir=%d%\input\%owner%

set outdir=%imvertor_os_output%
set workdir=%imvertor_os_work%
set bindir=%imvertor_os_bin%
set eapath=%imvertor_os_eapath%
set eaenabled=%imvertor_os_eaenabled%

set jarfile=ChainTranslateAndReport.jar

if exist %propfile% set propfilepath=%propfile%
if exist %propfile% (goto PROPOKAY)

set propfilepath=%inpdir%\propfile\%propfile%.properties
if exist %propfilepath% (goto PROPOKAY)

REM fallback; error will be given by imvertor
set propfilepath=%propfile%
:PROPOKAY

rem eerste 4 parameters overslaan, de rest van de parameters worden toegevoegd
SHIFT
SHIFT
SHIFT
SHIFT
:LOOP
IF [%1]==[] GOTO CONTINUE
  set PARMS=%PARMS% %1
SHIFT
GOTO LOOP
:CONTINUE

set PATH=%PATH%;%eapath%;

SET jvmparms=-Xms512m -Xmx1024m

SET JAVA_HOME=%bindir%\bin\java\jre1.8.0_101
IF EXIST "%JAVA_HOME%\bin\java.exe" SET javaexe=%JAVA_HOME%\bin\java.exe
IF NOT EXIST "%JAVA_HOME%\bin\java.exe" SET javaexe=java.exe

call "%javaexe%" %jvmparms% ^
    -Dhttp.proxyHost=%imvertor_os_proxyhost% ^
	-Dhttp.proxyPort=%imvertor_os_proxyport% ^
    -Dlog4j.configuration="file:%bindir%\log4j.properties" ^
	-Dinstall.dir="%bindir%" ^
	-Doutput.dir="%outdir%" ^
    -Downer.name="%owner%" ^
    -Dwork.dir="%workdir%\default" ^
    -Dgit.token=%imvertor_os_git_token% ^
    -classpath "%bindir%\bin\ChainTranslateAndReport_lib" ^
    -jar "%bindir%\bin\%jarfile%" ^
	-arguments "%propfilepath%"  ^
	-umlfile "%eapfile%" ^
	-hisfile "%hisfile%" ^
	%PARMS% 
	
rem -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=y
	
goto END

:END
