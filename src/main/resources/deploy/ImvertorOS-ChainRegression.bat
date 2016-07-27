@echo off
SETLOCAL ENABLEEXTENSIONS

set jar=%~1
set jobid=%~2
set propfile=%~3
set owner=%~4
set reffolder=%~5
set tstfolder=%~6
set outfolder=%~7
set identifier=%~8

set d=%~dp0
cd %d%
cd ..
call environment.bat %owner% 
cd %d%

set bindir=%imvertor_os_bin%
set inpdir=%imvertor_os_input%
set outdir=%imvertor_os_output%
set workdir=%imvertor_os_work%

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
    -Dlog4j.configuration=file:%bindir%\cfg\log4j.properties ^
	-Dinstall.dir="%bindir%" ^
	-Doutput.dir="%outdir%" ^
    -Dinput.dir="%inpdir%" ^
    -Dwork.dir="%workdir%\%jobid%" ^
    -classpath "%bindir%\bin\%jar%_lib" ^
    -jar "%bindir%\bin\%jar%.jar" ^
	-arguments "%propfilepath%" ^
	-owner "%owner%" ^
	-reffolder "%reffolder%" ^
	-tstfolder "%tstfolder%" ^
	-outfolder "%outfolder%" ^
    -identifier "%identifier%"
	
goto END

:END
