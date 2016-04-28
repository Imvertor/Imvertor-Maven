@echo off
set curdir=%cd%

echo --------------------------------------------
echo This run will produce no warnings or errors.
echo --------------------------------------------

call ..\..\imvertor-bin\imvertorOS ^
 %curdir%\SampleBase.1.xmi ^
 %curdir%\none ^
 %curdir%\SampleBase.1.properties
 
pause