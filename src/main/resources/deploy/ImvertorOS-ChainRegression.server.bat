@echo off
SETLOCAL ENABLEEXTENSIONS

set jar=%~1
set propfilepath=%~2
set owner=%~3

set d=%~dp0
cd %d%
cd ..
call environment.server.bat %owner% 
cd %d%

set bindir=%imvertor_os_bin%
set inpdir=%imvertor_os_input%
set outdir=%imvertor_os_output%
set workdir=%imvertor_os_work%

SET jvmparms=-Xms512m -Xmx1024m

SET JAVA_HOME=%bindir%\bin\java\jre7
IF EXIST "%JAVA_HOME%\bin\java.exe" SET javaexe=%JAVA_HOME%\bin\java.exe
IF NOT EXIST "%JAVA_HOME%\bin\java.exe" SET javaexe=java.exe

call "%javaexe%" %jvmparms% ^
    -Dlog4j.configuration=file:%bindir%\cfg\log4j.properties ^
	-Dinstall.dir="%bindir%" ^
	-Doutput.dir="%outdir%" ^
    -Dinput.dir="%inpdir%" ^
    -Dwork.dir="%workdir%" ^
    -classpath "%bindir%\bin\%jar%_lib" ^
    -jar "%bindir%\bin\%jar%.jar" ^
	-arguments "%propfilepath%"
	
goto END

:END
