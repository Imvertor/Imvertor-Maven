@echo off

rem =====================================================================================================================================
rem this batch file is part of the BRO OFFICE implementation, and allows a single document to be pushed directly to GIThub
rem =====================================================================================================================================

set git=%imvertor_os_gitexe%

if not %1.==. goto external

:internal
rem --------- example data ----------
set branch=gh-pages
set local-repos=d:\projects\gitprojects\test-environment
set remote-repos=https://github.com/Imvertor/test-environment
set local-file-name=update-git.txt
set local-file-path=c:\bat
set commit-comment=update git txt drie
goto start

:external
rem --------- real data ----------
set branch=%1
set local-repos=%2
set remote-repos=%3
set local-file-name=%4
set local-file-path=%5
set commit-comment=%6
goto start

:start

if exist %local-repos% goto rexists
if not exist %local-repos% goto rnew

:rexists
@rem the repos already exists, just pull
    	@echo [STP]
		@echo pull
		cd %local-repos%
		"%git%" pull
		if %ERRORLEVEL% neq 0 goto err   
goto next

:rnew
@rem the repos is new, must be created
		@echo [STP]
		@echo clone
		"%git%" clone %remote-repos% %local-repos%
		cd %local-repos%
	    @echo [STP]
		@echo checkout
		"%git%" checkout -b %branch%
		if %ERRORLEVEL% neq 0 goto err
	    @echo [STP]
		@echo set-branch
		"%git%" branch --set-upstream-to=origin/%branch% %branch%   
		if %ERRORLEVEL% neq 0 goto err
goto next

:next
@rem Ensure local is aligned with remote 
	    @echo [STP]
		@echo reset
		"%git%" reset --hard origin/%branch%
		if %ERRORLEVEL% neq 0 goto err   
@rem Add the new file
		copy "%local-file-path%\%local-file-name%" "data\%local-file-name%"

        @echo [STP]
		@echo add
		"%git%" add "data\%local-file-name%"
		if %ERRORLEVEL% neq 0 goto err   
@rem Commit to the index
		@echo [STP]
		@echo commit
		"%git%" commit -m "%commit-comment%" "data\%local-file-name%"
		if %ERRORLEVEL% neq 0 goto err   
@rem Push upstream
		@echo [STP]
		@echo push
		"%git%" push origin %branch%
		if %ERRORLEVEL% neq 0 goto err   
@rem get the SHA
		@echo [STP]
		@echo sha
		@echo [SHA]
		"%git%" rev-parse --verify HEAD 
		if %ERRORLEVEL% neq 0 goto err   
goto end

:err
:end
@rem return by passing the error level, and write that to log
	@echo [ERR]
	@echo %ERRORLEVEL%
	exit 0
    