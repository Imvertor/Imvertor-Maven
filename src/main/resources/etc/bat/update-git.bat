@echo off

rem =====================================================================================================================================
rem this batch file is part of the BRO OFFICE implementation, and allows a single document to be pushed directly to GIThub
rem this file assumes git.exe is on the path
rem =====================================================================================================================================

set git=c:\Program Files\Git\bin\git.exe

if not %1.==. goto external

:internal
set branch=gh-pages

set local-repos=d:\projects\gitprojects\test-environment
set remote-repos=https://github.com/Imvertor/test-environment

set local-file-name=update-git.txt
set local-file-path=c:\bat

set commit-comment=update git txt drie

goto start

:external
set branch=%1

set local-repos=%2
set remote-repos=%3

set local-file-name=%4
set local-file-path=%5

set commit-comment=%6

goto start

:start

echo 1
if not exist %local-repos%                  "%git%" clone %remote-repos% %local-repos%
echo 2
cd %local-repos%
echo 3
if exist %local-repos%\*.*                  "%git%" pull %branch%
echo 4
if not exist %local-repos%\*.*              "%git%" checkout -b %branch%
echo 5
"%git%" reset --hard origin/%branch%
echo 6
@rem Everyting is exactly as the GIT repos & branch.
copy "%local-file-path%\%local-file-name%" "%local-file-name%"
echo 7
"%git%" add "%local-file-name%"
echo 8
"%git%" commit -m "%commit-comment%" "%local-file-name%"
echo 9
"%git%" push origin %branch%
echo 10 last line is SHA
"%git%" rev-parse --verify HEAD 
