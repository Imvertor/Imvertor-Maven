@echo off
SETLOCAL ENABLEEXTENSIONS

SET jar=%~1
SET artifact=%~2
SET jobid=%~3
SET propfile=%~4
SET owner=%~5
SET reg=%~6
SET adorn=%~7

SET bindir=%~dp0
SET jvmparms=-Xms512m -Xmx1024m

SET JAVA_HOME=%bindir%\bin\java\jre1.8.0_101
IF EXIST "%JAVA_HOME%\bin\java.exe" SET javaexe=%JAVA_HOME%\bin\java.exe
IF NOT EXIST "%JAVA_HOME%\bin\java.exe" SET javaexe=java.exe

call "%javaexe%" %jvmparms% ^
    -Dlog4j.configuration=file:%bindir%\log4j.properties ^
	-Dinstall.dir="%bindir%" ^
	-Drun.mode=deployed ^
    -Downer.name="%owner%" ^
    -Djob.id="%jobid%" ^
    -Dis.reg="%reg%" ^
    -Dversion.adornment="%adorn%" ^
    -cp "%bindir%\bin\EA\eaapi.jar;%bindir%\bin\%jar%.jar" ^
	nl.imvertor.%artifact% ^
	-arguments "%propfile%" ^
	-owner "%owner%"

:END
