@echo off
title Preparing...
color 06
Mode 130,45
setlocal EnableDelayedExpansion

REM Make Directories
mkdir %SYSTEMDRIVE%\OptiWin >nul 2>&1
mkdir %SYSTEMDRIVE%\OptiWin\Resources >nul 2>&1
cd %SYSTEMDRIVE%\OptiWin

REM Run as Admin
reg add HKLM /F >nul 2>&1
if %errorlevel% neq 0 start "" /wait /I /min powershell -NoProfile -Command start -verb runas "'%~s0'" && exit /b

REM Show Detailed BSoD
reg add "HKLM\System\CurrentControlSet\Control\CrashControl" /v "DisplayParameters" /t REG_DWORD /d "1" /f >nul 2>&1

REM Blank/Color Character
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (set "DEL=%%a" & set "COL=%%b")

REM Add ANSI escape sequences
reg add HKCU\CONSOLE /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1

:Disclaimer
reg query "HKCU\Software\OptiWin" /v "Disclaimer" >nul 2>&1
cls
echo.
echo.
call :OptiTitle
echo.
echo                           %COL%[90m              OptiWin is a free and open-source fork of HoneCTRL
echo                           %COL%[90m                   made to improve your computing experience
echo.
echo.
echo                           %COL%[90m                                   WARNING:
echo                           %COL%[90m  Please note that there is no guarantee of an FPS boost or latency reduction
echo                           %COL%[90m                         as every system is different.
echo.
echo                           %COL%[90m  If you don't know what a tweak is, do not use it and instead research more
echo                           %COL%[90m                                    on it.
echo.
echo                           %COL%[90m   For any questions and/or concerns, please research on your own from the
echo                           %COL%[90m                           original tweak sources.
echo.
echo                           %COL%[90m             Please enter "I agree" without quotes to continue:
echo.
echo.
echo.
set /p "input=%DEL%                                                            >: %COL%[92m"
if /i "!input!" neq "i agree" goto Disclaimer
reg add "HKCU\Software\OptiWin" /v "Disclaimer" /f >nul 2>&1

REM HKCU & HKLM backup

for /F "tokens=2" %%i in ('date /t') do set date=%%i
set date1=%date:/=.%
>nul 2>&1 md %SYSTEMDRIVE%\OptiWin\\%date1%
reg export HKCU %SYSTEMDRIVE%\OptiWin\%date1%\HKLM.reg /y >nul 2>&1
reg export HKCU %SYSTEMDRIVE%\OptiWin\%date1%\HKCU.reg /y >nul 2>&1
echo set "firstlaunch=0" > %SYSTEMDRIVE%\OptiWin\firstlaunch.bat

:MainMenu
Mode 130,45
TITLE Hone Control Panel %localtwo%
set "choice="
cls
echo.
echo.
call :OptiTitle
echo.
echo                            %COL%[90m              OptiWin is a free and open-source fork of HoneCTRL
echo                            %COL%[90m                   made to improve your computing experience
echo.
echo.
echo.
echo.
echo.
echo.
echo                                             %COL%[33m[%COL%[37m 1 %COL%[33m]%COL%[37m Optimizations          %COL%[33m[%COL%[37m 2 %COL%[33m]%COL%[37m Advanced 
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                            %COL%[31m[ X to close ]%COL%[37m
echo.
%SYSTEMROOT%\System32\choice.exe /c:1234567XD /n /m "%DEL%                                        Select a corresponding number to the options above > "
set choice=%errorlevel%
if "%choice%"=="1" set PG=TweaksPG1 & goto Tweaks
if "%choice%"=="2" goto :Advanced
goto MainMenu

:OptiTitle
echo                                                  ::::::::::    :::::::::::  ::::::::::   :::           
echo                                                 :+:    :+:    :+:     :+:      :+:      :+:            
echo                                                +:+    +:+    :+:     +:+      +:+      +:+             
echo                                               +#+    +:+    +#+ +:+ +#+      +:+      +#+              
echo                                              +#+    +#+    +#+              +#+      +#+               
echo                                             #+#    #+#    #+#              #+#      #+#                
echo                                            ##########    ###              ###      ###                 
goto :eof

:Tweaks
Mode 130,45
TITLE OptiWin Panel %localtwo%
set "choice="
set "BLANK=   "
REM Check Values
for %%i in (PWROF MEMOF AUDOF TMROF NETOF AFFOF MOUOF AFTOF NICOF DSSOF SERVOF DEBOF MITOF ME2OF NPIOF NVIOF NVTOF HDCOF CMAOF ALLOF MSIOF TCPOF DWCOF CRSOF) do (set "%%i=%COL%[92mON ") >nul 2>&1
(
	REM MSI Mode
	for /f %%g in ('wmic path win32_VideoController get PNPDeviceID ^| findstr /L "VEN_"') do (
		reg query "HKLM\SYSTEM\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" | find "0x1" || set "MSIOF=%COL%[91mOFF"
		reg query "HKLM\System\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" && set "MSIOF=%COL%[91mOFF"
	)
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do (
		reg query "HKLM\SYSTEM\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" | find "0x1" || set "MSIOF=%COL%[91mOFF"
		reg query "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" && set "MSIOF=%COL%[91mOFF"
	)
	REM Services Optimization
	for /f "tokens=2 delims==" %%i in ('wmic os get TotalVisibleMemorySize /value') do (set /a mem=%%i + 1024000)
	for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB"') do (set /a currentmem=%%a)
	if "!currentmem!" neq "!mem!" set "MEMOF=%COL%[91mOFF"
	REM Nvidia Telemetry
	reg query "HKCU\Software\OptiWin" /v "NVTTweaks" || set "NVTOF=%COL%[91mOFF"
	REM Nvidia HDCP
	for /f %%a in ('reg query "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HKEY"') do reg query "%%a" /v "RMHdcpKeyglobZero" | find "0x1" || set "HDCOF=%COL%[91mOFF"
	REM Disable Preemption
	reg query "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemption" | find "0x1" || set "CMAOF=%COL%[91mOFF"
	reg query "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableCudaContextPreemption" | find "0x1" || set "CMAOF=%COL%[91mOFF"
	reg query "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "EnableCEPreemption" | find "0x0" || set "CMAOF=%COL%[91mOFF"
	reg query "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemptionOnS3S4" | find "0x1" || set "CMAOF=%COL%[91mOFF"
	reg query "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "ComputePreemption" | find "0x0" || set "CMAOF=%COL%[91mOFF"
	REM CSRSS
	reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions" /v CpuPriorityClass | find "0x4" || set "CRSOF=%COL%[91mOFF"
	reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions" /v IoPriority | find "0x3" || set "CRSOF=%COL%[91mOFF"
	REM Power Plan
	powercfg /GetActiveScheme | find "Hone" || set "PWROF=%COL%[91mOFF"
	REM All GPU Tweaks
	reg query "HKCU\Software\OptiWin" /v "AllGPUTweaks" || set "ALLOF=%COL%[91mOFF"
	REM Profile Inspector Tweaks
	reg query "HKCU\Software\OptiWin" /v "NpiTweaks" || set "NPIOF=%COL%[91mOFF"
	REM TCPIP
	reg query "HKCU\Software\OptiWin" /v "TCPIP" || set "TCPOF=%COL%[91mOFF"
	REM Nvidia Tweaks
	reg query "HKCU\Software\OptiWin" /v "NvidiaTweaks" || set "NVIOF=%COL%[91mOFF"
	REM Memory Optimization
	reg query "HKCU\Software\OptiWin" /v "MemoryTweaks" || set "ME2OF=%COL%[91mOFF"
	REM Network Internet Tweaks
	reg query "HKCU\Software\OptiWin" /v "InternetTweaks" || set "NETOF=%COL%[91mOFF"
	REM Services Tweaks
	reg query "HKCU\Software\OptiWin" /v "ServicesTweaks" || set "SERVOF=%COL%[91mOFF"
	REM Debloat Tweaks
	reg query "HKCU\Software\OptiWin" /v "DebloatTweaks" || set "DEBOF=%COL%[91mOFF"
	REM Mitigations Tweaks
	reg query "HKCU\Software\OptiWin" /v "MitigationsTweaks" || set "MITOF=%COL%[91mOFF"
	REM Affinities
	reg query "HKCU\Software\OptiWin" /v "AffinityTweaks" || set "AFFOF=%COL%[91mOFF"
	REM DisableWriteCombining
	reg query "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableWriteCombining" || set "DWCOF=%COL%[91mOFF"
	REM Mouse Fix
	reg query "HKCU\Control Panel\Mouse" /v "SmoothMouseYCurve" | find "0000000000000000000038000000000000007000000000000000A800000000000000E00000000000" || set "MOUOF=%COL%[91mOFF"
	REM NIC
	if not exist "%SYSTEMDRIVE%\OptiWinognic1.reg" set "NICOF=%COL%[91mOFF"
	REM Intel iGPU
	reg query "HKLM\SOFTWARE\Intel\GMM" /v "DedicatedSegmentSize" | find "0x400" || set "DSSOF=%COL%[91mOFF"
	REM Timer Res
	sc query STR | find "RUNNING" || set "TMROF=%COL%[91mOFF"
	REM Audio Service
	sc query HoneAudio | find "RUNNING" || set "AUDOF=%COL%[91mOFF"
	REM Check If Applicable For PC
	REM Laptop
	wmic path Win32_Battery Get BatteryStatus | find "1" && set "PWROF=%COL%[93mN/A"
	REM GPU
	for /f "tokens=2 delims==" %%a in ('wmic path Win32_VideoController get VideoProcessor /value') do (
		for %%n in (NVIDIA NVS Quadro GeForce MX RTX GTX) do echo %%a | find "%%n" >nul && set "NVIDIAGPU=Found"
		for %%n in (AMD Ryzen Radeon HD XT FirePro) do echo %%a | find "%%n" >nul && set "AMDGPU=Found"
		for %%n in (Intel HD UHD Iris XE Arc) do echo %%a | find "%%n" >nul && set "INTELGPU=Found"
	)
	if "!NVIDIAGPU!" neq "Found" for %%g in (HDCOF CMAOF NPIOF NVTOF NVIOF) do set "%%g=%COL%[93mN/A"
	if "!AMDGPU!" neq "Found" for %%g in (AMDOF) do set "%%g=%COL%[93mN/A"
	if "!INTELGPU!" neq "Found" for %%g in (DSSOF) do set "%%g=%COL%[93mN/A"
) >nul 2>&1

goto %PG%
:TweaksPG1
cls
echo.
echo                                                                                               %COL%[36mPage 1/2
call :OptiTitle
echo                                                                                           %COL%[1;4;34mTweaks%COL%[0m
echo.
echo              %COL%[33m[%COL%[37m 1 %COL%[33m]%COL%[37m Power Plan %PWROF%                 %COL%[33m[%COL%[37m 2 %COL%[33m]%COL%[37m SvcHostSplitThreshold %MEMOF%      %COL%[33m[%COL%[37m 3 %COL%[33m]%COL%[37m CSRSS High Priority %CRSOF%
echo              %COL%[90mDesktop Power Plan, not good         %COL%[90mChanges the split threshold for      %COL%[90mCSRSS is responsible for mouse input
echo              %COL%[90mto use with a laptop battery.        %COL%[90mservice host to your RAM             %COL%[90mset to high to improve input latency
echo.
echo                                   %COL%[33m[%COL%[37m 4 %COL%[33m]%COL%[37m MSI Mode %MSIOF%                   %COL%[33m[%COL%[37m 5 %COL%[33m]%COL%[37m Affinity %AFFOF%
echo                                   %COL%[90mEnable MSI Mode for gpu and          %COL%[90mThis tweak will spread devices
echo                                   %COL%[90mnetwork adapters                     %COL%[90mon multiple cpu cores
echo.
echo                                   %COL%[33m[%COL%[37m 6 %COL%[33m]%COL%[37m W32 Priority Seperation %BLANK%    %COL%[33m[%COL%[37m 7 %COL%[33m]%COL%[37m Memory Optimization %ME2OF%
echo                                   %COL%[90mOptimizes the usage priority of      %COL%[90mOptimizes your fsutil, win
echo                                   %COL%[90myour running services                %COL%[90mstartup settings and more
echo.
echo                                                                                          %COL%[1;4;34mNvidia Tweaks%COL%[0m
echo.
echo              %COL%[33m[%COL%[37m 8 %COL%[33m]%COL%[37m Disable HDCP %HDCOF%              %COL%[33m[%COL%[37m 9 %COL%[33m]%COL%[37m Disable Preemption %CMAOF%        %COL%[33m[%COL%[37m 10 %COL%[33m]%COL%[37m ProfileInspector %NPIOF%
echo              %COL%[90mDisable copy protection technology   %COL%[90mDisable preemption requests from     %COL%[90mWill edit your Nvidia control panel
echo              %COL%[90mof illegal High Definition content   %COL%[90mthe GPU scheduler                    %COL%[90mand add various tweaks
echo.
echo              %COL%[33m[%COL%[37m 11 %COL%[33m]%COL%[37m Disable Nvidia Telemetry %NVTOF%  %COL%[33m[%COL%[37m 12 %COL%[33m]%COL%[37m Nvidia Tweaks %NVIOF%           %COL%[33m[%COL%[37m 13 %COL%[33m]%COL%[37m Disable Write Combining %DWCOF%
echo              %COL%[90mRemove built in Nvidia telemetry     %COL%[90mVarious essential tweaks for         %COL%[90mStops data from being combined
echo              %COL%[90mfrom your computer and driver.       %COL%[90mNvidia graphics cards                %COL%[90mand temporarily stored
echo.
echo.
echo.
echo                                     %COL%[90m[ B for back ]         %COL%[31m[ X to close ]         %COL%[36m[ N page two ]
echo.
set /p choice="%DEL%                                        %COL%[37mSelect a corresponding number to the options above > "
if /i "%choice%"=="1" goto PowerPlan
if /i "%choice%"=="2" goto ServicesOptimization
if /i "%choice%"=="3" goto CSRSS
if /i "%choice%"=="4" goto MSI
if /i "%choice%"=="5" goto Affinity
if /i "%choice%"=="6" goto W32PrioSep
if /i "%choice%"=="7" goto MemOptimization
if /i "%choice%"=="8" goto DisableHDCP
if /i "%choice%"=="9" goto DisablePreemtion
if /i "%choice%"=="10" goto ProfileInspector
if /i "%choice%"=="11" goto NVTelemetry
if /i "%choice%"=="12" goto NvidiaTweaks
if /i "%choice%"=="13" goto DisableWriteCombining
if /i "%choice%"=="X" exit /b
if /i "%choice%"=="B" goto MainMenu
if /i "%choice%"=="N" (set "PG=TweaksPG2") & goto TweaksPG2
goto Tweaks

:TweaksPG2
cls
echo.
echo                                                                                                                        %COL%[36mPage 2/2
call :OptiTitle
echo                                                           %COL%[1;4;34mNetwork Tweaks%COL%[0m
echo.
echo              %COL%[33m[%COL%[37m 1 %COL%[33m]%COL%[37m Optimize TCP/IP %TCPOF%            %COL%[33m[%COL%[37m 2 %COL%[33m]%COL%[37m Optimize NIC %NICOF%               %COL%[33m[%COL%[37m 3 %COL%[33m]%COL%[37m Optimize Netsh %NETOF%
echo              %COL%[90mTweaks your Internet Protocol        %COL%[90mOptimize your Network Card settings  %COL%[90mThis tweak will optimize your
echo              %COL%[91mDon't use if you are using Wi-Fi     %COL%[91mDon't use if you are using Wi-Fi     %COL%[90mcomputer network configuration
echo.
echo                                                             %COL%[1;4;34mGPU ^& CPU%COL%[0m
echo.
echo              %COL%[33m[%COL%[37m 4 %COL%[33m]%COL%[37m All GPU Tweaks %ALLOF%             %COL%[33m[%COL%[37m 5 %COL%[33m]%COL%[37m Optimize Intel iGPU %DSSOF%        %COL%[33m[%COL%[37m 6 %COL%[33m]%COL%[37m AMD GPU Tweaks %AMDOF%
echo              %COL%[90mVarious essential tweaks for all     %COL%[90mIncrease dedicated video vram on     %COL%[90mConfigure AMD GPU to optimized
echo              %COL%[90mGPU brands and manufacturers         %COL%[90ma intel iGPU                         %COL%[90msettings
echo.
echo                                                        %COL%[1;4;34mMiscellaneous Tweaks%COL%[0m
echo.
echo                                                   %COL%[33m[%COL%[37m 7 %COL%[33m]%COL%[37m Disable Mitigations %MITOF%
echo                                                               %COL%[90mDisable protections against memory
echo                                                               %COL%[90mbased attacks that consume perf
echo.
echo.
echo.
echo                                     %COL%[90m[ B for back ]         %COL%[31m[ X to close ]         %COL%[36m[ N page one ]
echo.
set /p choice="%DEL%                                        %COL%[37mSelect a corresponding number to the options above > "
if /i "%choice%"=="1" goto TCPIP
if /i "%choice%"=="2" goto NIC
if /i "%choice%"=="3" goto Netsh
if /i "%choice%"=="4" goto AllGPUTweaks
if /i "%choice%"=="5" goto Intel
if /i "%choice%"=="6" goto AMD
if /i "%choice%"=="8" goto Mitigations
if /i "%choice%"=="X" exit /b
if /i "%choice%"=="B" goto MainMenu
if /i "%choice%"=="N" (set "PG=TweaksPG1") & goto TweaksPG1
goto TweaksPG2

:PowerPlan
if "%PWROF%" == "%COL%[91mOFF" (
	curl -g -k -L -# -o "%SYSTEMDRIVE%\OptiWin\Resources\OptiWin.pow" "https://github.com/thedeveloperever/optiwin/raw/main/Resources/OptiWin.pow"
	powercfg /d 44444444-4444-4444-4444-444444444444
	powercfg -import "%SYSTEMDRIVE%\OptiWin\Resources\OptiWin.pow" 44444444-4444-4444-4444-444444444444
	powercfg /changename 44444444-4444-4444-4444-444444444444 "OptiWin Power Plan" "Lowers latency and boosts FPS"
REM Enable Idle on Hyper-Threading
set THREADS=%NUMBER_OF_PROCESSORS%
	for /f "tokens=2 delims==" %%n in ('wmic cpu get numberOfCores /value') do set CORES=%%n
	if "%CORES%" == "%NUMBER_OF_PROCESSORS%" (
		powercfg -setacvalueindex 44444444-4444-4444-4444-444444444444 sub_processor IDLEDISABLE 1
) else (
		powercfg -setacvalueindex 44444444-4444-4444-4444-444444444444 sub_processor IDLEDISABLE 0 
)
	powercfg -setacvalueindex 44444444-4444-4444-4444-444444444444 sub_processor IDLEDISABLE 0
	powercfg -setactive "44444444-4444-4444-4444-444444444444"
) >nul 2>&1 else (
	powercfg -restoredefaultschemes
) >nul 2>&1
goto tweaks

:ServicesOptimization
if "%MEMOF%" == "%COL%[91mOFF" (
	for /f "tokens=2 delims==" %%i in ('wmic os get TotalVisibleMemorySize /value') do set /a mem=%%i + 1024000
		reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB" /t REG_DWORD /d %mem% /f
) >nul 2>&1 else (
	reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB" /t REG_DWORD /d 3670016 /f
) >nul 2>&1
goto tweaks

goto tweaks

:CSRSS
if "%CRSOF%" == "%COL%[91mOFF" (
	reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions" /v CpuPriorityClass /t Reg_DWORD /d "4" /f
	reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions" /v IoPriority /t Reg_DWORD /d "3" /f
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NoLazyMode" /t REG_DWORD /d "1" /f
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "AlwaysOn" /t REG_DWORD /d "1" /f
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d "10" /f
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d "0" /f
) >nul 2>&1 else (
	reg delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions" /v CpuPriorityClass /f
	reg delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions" /v IoPriority /f
	reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NoLazyMode" /f
	reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "AlwaysOn" /f
	reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /f
	reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /f
) >nul 2>&1
goto Tweaks

:MSI
if "%MSIOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\OptiWin" /v "MSIModeTweaks" /f
	for /f %%g in ('wmic path win32_VideoController get PNPDeviceID ^| findstr /L "VEN_"') do reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d "1" /f
	for /f %%g in ('wmic path win32_VideoController get PNPDeviceID ^| findstr /L "VEN_"') do reg delete "HKLM\System\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /f
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d "1" /f
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /f
) >nul 2>&1 else (
	reg delete "HKCU\Software\OptiWin" /v "MSIModeTweaks" /f
	for /f %%g in ('wmic path win32_VideoController get PNPDeviceID ^| findstr /L "VEN_"') do reg delete "HKLM\SYSTEM\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /f
	for /f %%g in ('wmic path win32_VideoController get PNPDeviceID ^| findstr /L "VEN_"') do reg delete "HKLM\System\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /f
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do reg delete "HKLM\SYSTEM\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /f
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority " /f
) >nul 2>&1
goto Tweaks

:Affinity
if "%AFFOF%" == "%COL%[91mOFF" (
reg add "HKCU\Software\OptiWin" /v AffinityTweaks /f
for /f "tokens=*" %%f in ('wmic cpu get NumberOfCores /value ^| find "="') do set %%f
for /f "tokens=*" %%f in ('wmic cpu get NumberOfLogicalProcessors /value ^| find "="') do set %%f
if "!NumberOfCores!" == "2" (
	cls
	echo You have 2 cores. Affinities won't work.
	pause
	reg delete "HKCU\Software\OptiWin" /v AffinityTweaks /f
	goto Tweaks
)
if !NumberOfCores! gtr 4 (
	for /f %%i in ('wmic path Win32_VideoController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
		reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "3" /f
		reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /f
	)
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
		reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "5" /f
		reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /f
	)
)
if !NumberOfLogicalProcessors! gtr !NumberOfCores! (
REM HyperThreading Enabled
for /f %%i in ('wmic path Win32_USBController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "C0" /f
)
for /f %%i in ('wmic path Win32_VideoController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "C0" /f
)
for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "30" /f
)
) else (
REM HyperThreading Disabled
for /f %%i in ('wmic path Win32_USBController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "08" /f
)
for /f %%i in ('wmic path Win32_VideoController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "02" /f
)
for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "04" /f
)
)
) >nul 2>&1 else (
reg delete "HKCU\Software\OptiWin" /v AffinityTweaks /f
for /f %%i in ('wmic path Win32_USBController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /f
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /f
)
for /f %%i in ('wmic path Win32_VideoController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /f
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /f
)
for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /f
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /f
)
) >nul 2>&1
goto Tweaks

:W32PrioSep
cls
echo.
echo.
echo.
echo.
echo                                                      ::::::::::    :::::::::::  ::::::::::   :::           
echo                                                     :+:    :+:    :+:     :+:      :+:      :+:            
echo                                                    +:+    +:+    :+:     +:+      +:+      +:+             
echo                                                   +#+    +:+    +#+ +:+ +#+      +:+      +#+              
echo                                                  +#+    +#+    +#+              +#+      +#+               
echo                                                 #+#    #+#    #+#              #+#      #+#                
echo                                                ##########    ###              ###      ###                 
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                    %COL%[33m[ %COL%[37m1 %COL%[33m] %COL%[37m26 Hex                        %COL%[33m[ %COL%[37m2 %COL%[33m] %COL%[37m2A Hex
echo                    %COL%[90mDefault                                                        %COL%[90mMight be better
echo                    %COL%[90mShort, Variable, High foreground boost.                        %COL%[90mShort, Fixed, High foreground boost.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                       [ press X to go back ]
echo.
echo.
%SYSTEMROOT%\System32\choice.exe /c:12X /n /m "%DEL%                                                               >:"
if %errorlevel% == 3 goto Tweaks
if %errorlevel% == 1 reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d "38" /f >nul 2>&1
if %errorlevel% == 2 reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d "42" /f >nul 2>&1
goto Tweaks

:DisableHDCP
for /f %%a in ('reg query "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HKEY"') do (
	if "%HDCOF%" == "%COL%[91mOFF" (
		reg add "HKCU\Software\OptiWin" /v HDCTweaks /f
		reg add "%%a" /v "RMHdcpKeyglobZero" /t REG_DWORD /d "1" /f
	) else (
		reg delete "HKCU\Software\OptiWin" /v HDCTweaks /f
		reg add "%%a" /v "RMHdcpKeyglobZero" /t REG_DWORD /d "0" /f
	)
) >nul 2>&1
goto Tweaks

:DisablePreemtion
if "%CMAOF%" == "%COL%[91mOFF" (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemption" /t Reg_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableCudaContextPreemption" /t Reg_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "EnableCEPreemption" /t Reg_DWORD /d "0" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemptionOnS3S4" /t Reg_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "ComputePreemption" /t Reg_DWORD /d "0" /f
) >nul 2>&1 else (
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemption" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableCudaContextPreemption" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "EnableCEPreemption" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemptionOnS3S4" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "ComputePreemption" /f
) >nul 2>&1
goto Tweaks

:ProfileInspector
if "%NPIOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\OptiWin" /v NpiTweaks /f
	rmdir /S /Q "%SYSTEMDRIVE%\OptiWin\Resources\nvidiaProfileInspector\"
	curl -g -L -# -o %SYSTEMDRIVE%\OptiWin\Resources\nvidiaProfileInspector.zip "https://github.com/Orbmu2k/nvidiaProfileInspector/releases/latest/download/nvidiaProfileInspector.zip"
	powershell -NoProfile Expand-Archive '%SYSTEMDRIVE%\OptiWin\Resources\nvidiaProfileInspector.zip' -DestinationPath '%SYSTEMDRIVE%\OptiWin\Resources\nvidiaProfileInspector\'
	del /F /Q "%SYSTEMDRIVE%\OptiWin\Resources\nvidiaProfileInspector.zip"
	curl -g -L -# -o "%SYSTEMDRIVE%\OptiWin\Resources\nvidiaProfileInspector\NVIDIAProfileInspector.nip" "https://raw.githubusercontent.com/thedeveloperever/optiwin/main/Resources/OptiWin.nip"
	cd "%SYSTEMDRIVE%\OptiWin\Resources\nvidiaProfileInspector\"
	nvidiaProfileInspector.exe "OptiWin.nip"
) >nul 2>&1 else (
	rem https://github.com/Orbmu2k/nvidiaProfileInspector/releases/latest/download/nvidiaProfileInspector.zip
	reg delete "HKCU\Software\OptiWin" /v NpiTweaks /f
	rmdir /S /Q "%SYSTEMDRIVE%\OptiWin\Resources\nvidiaProfileInspector\"
	curl -g -L -# -o %SYSTEMDRIVE%\OptiWin\Resources\nvidiaProfileInspector.zip "https://github.com/Orbmu2k/nvidiaProfileInspector/releases/latest/download/nvidiaProfileInspector.zip"
	powershell -NoProfile Expand-Archive '%SYSTEMDRIVE%\OptiWin\Resources\nvidiaProfileInspector.zip' -DestinationPath '%SYSTEMDRIVE%\OptiWin\Resources\nvidiaProfileInspector\'
	del /F /Q "%SYSTEMDRIVE%\OptiWin\Resources\nvidiaProfileInspector.zip"
	curl -g -L -# -o "%SYSTEMDRIVE%\OptiWin\Resources\nvidiaProfileInspector\Base_Profile.nip" "https://raw.githubusercontent.com/thedeveloperever/optiwin/main/Resources/Base_Profile.nip"
	cd "%SYSTEMDRIVE%\OptiWin\Resources\nvidiaProfileInspector\"
	nvidiaProfileInspector.exe "Base_Profile.nip"
) >nul 2>&1goto Tweaks

:NVTelemetry
if "%NVTOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\OptiWin" /v NVTTweaks /f
	reg add "HKLM\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" /v "OptInOrOutPreference" /t REG_DWORD /d 0 /f
	reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID44231" /t REG_DWORD /d 0 /f
	reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID64640" /t REG_DWORD /d 0 /f
	reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID66610" /t REG_DWORD /d 0 /f
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "NvBackend" /f
	schtasks /change /disable /tn "NvTmRep_CrashReport1_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"
	schtasks /change /disable /tn "NvTmRep_CrashReport2_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"
	schtasks /change /disable /tn "NvTmRep_CrashReport3_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"
	schtasks /change /disable /tn "NvTmRep_CrashReport4_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"
) >nul 2>&1 else (
	reg delete "HKCU\Software\OptiWin" /f
	reg delete "HKLM\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" /v "OptInOrOutPreference" /f
	reg delete "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID44231" /f
	reg delete "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID64640" /f
	reg delete "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID66610" /f
	schtasks /change /enable /tn "NvTmRep_CrashReport1_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"
	schtasks /change /enable /tn "NvTmRep_CrashReport2_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"
	schtasks /change /enable /tn "NvTmRep_CrashReport3_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"
	schtasks /change /enable /tn "NvTmRep_CrashReport4_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"
) >nul 2>&1
goto tweaks

:NvidiaTweaks
if "%NVIOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\OptiWin" /v "NvidiaTweaks" /f
	rem Nvidia Reg
	reg add "HKCU\Software\NVIDIA Corporation\Global\NVTweak\Devices\509901423-0\Color" /v "NvCplUseColorCorrection" /t Reg_DWORD /d "0" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "PlatformSupportMiracast" /t Reg_DWORD /d "0" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" /v "DisplayPowerSaving" /t Reg_DWORD /d "0" /f
	rem Unrestricted Clocks
	cd "%SYSTEMDRIVE%\Program Files\NVIDIA Corporation\NVSMI\"
	nvidia-smi -acp UNRESTRICTED
	nvidia-smi -acp DEFAULT
	rem Nvidia Registry Key
	for /f %%a in ('reg query "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HKEY"') do (
		rem Disalbe Tiled Display
		reg add "%%a" /v "EnableTiledDisplay" /t REG_DWORD /d "0" /f
		rem Disable TCC
		reg add "%%a" /v "TCCSupported" /t REG_DWORD /d "0" /f
	)
	rem Silk Smoothness Option
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\FTS" /v "EnableRID61684" /t REG_DWORD /d "1" /f
) >nul 2>&1 else (
	reg delete "HKCU\Software\OptiWin" /v "NvidiaTweaks" /f
	rem Nvidia Reg
	reg delete "HKCU\Software\NVIDIA Corporation\Global\NVTweak\Devices\509901423-0\Color" /v "NvCplUseColorCorrection" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "PlatformSupportMiracast" /t Reg_DWORD /d "1" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" /v "DisplayPowerSaving" /f
	rem Nvidia Registry Key
	for /f %%a in ('reg query "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HKEY"') do (
		rem Reset Tiled Display
		reg delete "%%a" /v "EnableTiledDisplay" /f
		rem Reset TCC
		reg delete "%%a" /v "TCCSupported" /f
	)
) >nul 2>&1
goto Tweaks

:DisableWriteCombining
if "%DWCOF%" == "%COL%[91mOFF" (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableWriteCombining" /t Reg_DWORD /d "1" /f
) >nul 2>&1 else (
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableWriteCombining" /f
) >nul 2>&1
goto Tweaks

:Mitigations
if "%MITOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\OptiWin" /v MitigationsTweaks /f
	REM Turn Core Isolation Memory Integrity OFF
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Enabled" /t REG_DWORD /d "0" /f
	REM Disable SEHOP
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DisableExceptionChainValidation" /t Reg_DWORD /d "1" /f
	REM Disable Spectre And Meltdown
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettings" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d "3" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d "3" /f
	cd %TEMP%
	if not exist "%TEMP%\NSudo.exe" curl -g -L -# -o "%TEMP%\NSudo.exe" "https://github.com/auraside/OptiWin/raw/main/Files/NSudo.exe"
	NSudo -U:S -ShowWindowMode:Hide -wait cmd /c "reg add "HKLM\SYSTEM\CurrentControlSet\Services\TrustedInstaller" /v "Start" /t Reg_DWORD /d "3" /f"
	NSudo -U:S -ShowWindowMode:Hide -wait cmd /c "sc start "TrustedInstaller""
	NSudo -U:T -P:E -M:S -ShowWindowMode:Hide -wait cmd /c "ren %SYSTEMROOT%\System32\mcupdate_GenuineIntel.dll mcupdate_GenuineIntel.old"
	NSudo -U:T -P:E -M:S -ShowWindowMode:Hide -wait cmd /c "ren %SYSTEMROOT%\System32\mcupdate_AuthenticAMD.dll mcupdate_AuthenticAMD.old"
	REM Disable CFG Lock
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "EnableCfg" /t Reg_DWORD /d "0" /f
	REM Disable NTFS/ReFS and FS Mitigations
	reg add "HKLM\System\CurrentControlSet\Control\Session Manager" /v "ProtectionMode" /t Reg_DWORD /d "0" /f
) >nul 2>&1 else (
	reg delete "HKCU\Software\OptiWin" /v MitigationsTweaks /f
	REM Turn Core Isolation Memory Integrity ON
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Enabled" /t REG_DWORD /d "1" /f
	REM Enable SEHOP
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DisableExceptionChainValidation" /f
	REM Enable Spectre And Meltdown
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettings /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverride /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverrideMask /f
	cd %TEMP%
	if not exist "%TEMP%\NSudo.exe" curl -g -L -# -o "%TEMP%\NSudo.exe" "https://github.com/auraside/OptiWin/raw/main/Files/NSudo.exe"
	NSudo -U:S -ShowWindowMode:Hide -wait cmd /c "reg add "HKLM\SYSTEM\CurrentControlSet\Services\TrustedInstaller" /v "Start" /t Reg_DWORD /d "2" /f"
	NSudo -U:S -ShowWindowMode:Hide -wait cmd /c "sc start "TrustedInstaller"" 
	NSudo -U:T -P:E -M:S -ShowWindowMode:Hide -wait cmd /c "ren %SYSTEMROOT%\System32\mcupdate_GenuineIntel.old mcupdate_GenuineIntel.dll"
	NSudo -U:T -P:E -M:S -ShowWindowMode:Hide -wait cmd /c "ren %SYSTEMROOT%\System32\mcupdate_AuthenticAMD.old mcupdate_AuthenticAMD.dll"
	REM Enable CFG Lock
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "EnableCfg" /f
	REM Enable NTFS/ReFS and FS Mitigations
	reg delete "HKLM\System\CurrentControlSet\Control\Session Manager" /v "ProtectionMode" /f
) >nul 2>&1
goto Tweaks

:TCPIP
Reg query "HKCU\Software\OptiWin" /v "WifiDisclaimer" >nul 2>&1 && goto TCPIP2
cls
echo.
echo.
call :OptiTitle
echo.
echo                            %COL%[90m              OptiWin is a free and open-source fork of HoneCTRL
echo                            %COL%[90m                   made to improve your computing experience
echo.
echo.
echo.
echo %COL%[91m  WARNING:
echo %COL%[91m  This tweak is for Ethernet users only, if you're on Wi-Fi, do not run this tweak.
echo.
echo   %COL%[37mFor any questions and/or concerns, please join our discord: discord.gg/hone
echo.
echo   %COL%[37mPlease enter "I understand" without quotes to continue:
echo.
echo.
echo.
set /p "input=%DEL%                                                            >: %COL%[92m"
if /i "!input!" neq "i understand" goto Tweaks
Reg add "HKCU\Software\OptiWin" /v "WifiDisclaimer" /f >nul 2>&1
:TCPIP2
if "%TCPOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\OptiWin" /v "TCPIP" /f
	powershell -NoProfile -NonInteractive -Command ^
	Enable-NetAdapterQos -Name "*";^
	Disable-NetAdapterPowerManagement -Name "*";^
	Disable-NetAdapterIPsecOffload -Name "*";^
	Set-NetTCPSetting -SettingName "*" -MemoryPressureProtection Disabled -InitialCongestionWindow 10 -ErrorAction SilentlyContinue
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpMaxConnectRetransmissions" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Tcp1323Opts" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpTimedWaitDelay" /t REG_DWORD /d "32" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DelayedAckFrequency" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DelayedAckTicks" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "CongestionAlgorithm" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "MultihopSets" /t REG_DWORD /d "15" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "IRPStackSize" /t REG_DWORD /d "50" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "SizReqBuf" /t REG_DWORD /d "17424" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "Size" /t REG_DWORD /d "3" /f
	reg add "HKLM\Software\Policies\Microsoft\Windows\Psched" /v "TimerResolution" /t REG_DWORD /d "1" /f
	reg add "HKLM\System\CurrentControlSet\Services\Tcpip\QoS" /v "Do not use NLA" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "NegativeCacheTime" /t REG_DWORD /d "0" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "NegativeSOACacheTime" /t REG_DWORD /d "0" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "NetFailureCacheTime" /t REG_DWORD /d "0" /f
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DoNotShowFeedbackNotifications" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "EnableAutoDoh" /t REG_DWORD /d "2" /f
	reg add "HKLM\SYSTEM\CurrDisableNagleentControlSet\Services\AFD\Parameters" /v "DoNotHoldNicBuffers" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "DisableRawSecurity" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "NonBlockingSendSpecialBuffering" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "IgnorePushBitOnReceives" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "DynamicSendBufferDisable" /t REG_DWORD /d "0" /f
	reg add "HKLM\Software\Microsoft\MSMQ\Parameters" /v "TCPNoDelay" /t REG_DWORD /d "1" /f
	for /f "tokens=3*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkCards" /f "ServiceName" /s ^|findstr /i /l "ServiceName"') do (
		reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TCPNoDelay" /t Reg_DWORD /d "1" /f
		reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TcpAckFrequency" /t Reg_DWORD /d "1" /f
		reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TcpDelAckTicks" /t Reg_DWORD /d "0" /f
		reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TcpInitialRTT" /d "300" /t REG_DWORD /f
		reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "UseZeroBroadcast" /d "0" /t REG_DWORD /f
		reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "DeadGWDetectDefault" /d "1" /t REG_DWORD /f
	)
) >nul 2>&1 else (
	reg delete "HKCU\Software\OptiWin" /v "TCPIP" /f
	powershell -NoProfile -NonInteractive -Command ^
	Set-NetTCPSetting -SettingName "*" -InitialCongestionWindow 4 -ErrorAction SilentlyContinue
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpMaxConnectRetransmissions" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Tcp1323Opts" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpTimedWaitDelay" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DelayedAckFrequency" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DelayedAckTicks" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "CongestionAlgorithm" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "MultihopSets" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "IRPStackSize" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "SizReqBuf" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "Size" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\QoS" /v "Do not use NLA" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "NegativeCacheTime" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "NegativeSOACacheTime" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "NetFailureCacheTime" /f
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /f
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DoNotShowFeedbackNotifications" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "EnableAutoDoh" /f
	reg delete "HKLM\SYSTEM\CurrDisableNagleentControlSet\Services\AFD\Parameters" /v "DoNotHoldNicBuffers" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "DisableRawSecurity" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "NonBlockingSendSpecialBuffering" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "IgnorePushBitOnReceives" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "DynamicSendBufferDisable" /f
	reg delete "HKLM\Software\Microsoft\MSMQ\Parameters" /v "TCPNoDelay" /f
	for /f "tokens=3*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkCards" /f "ServiceName" /s ^|findstr /i /l "ServiceName"') do (
		reg delete "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TCPNoDelay" /f
		reg delete "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TcpAckFrequency" /f
		reg delete "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TcpDelAckTicks" /f
		reg delete "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TcpInitialRTT" /f
		reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "UseZeroBroadcast" /f
		reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "DeadGWDetectDefault" /f
	)
) >nul 2>&1
start /B cmd /c "ipconfig /release & ipconfig /renew" >nul 2>&1
goto Tweaks

:NIC
Reg query "HKCU\Software\OptiWin" /v "WifiDisclaimer2" >nul 2>&1 && goto NIC2
cls
echo.
echo.
call :OptiTitle
echo.
echo                            %COL%[90m              OptiWin is a free and open-source fork of HoneCTRL
echo                            %COL%[90m                   made to improve your computing experience
echo.
echo.
echo.
echo %COL%[91m  WARNING:
echo %COL%[91m  This tweak is for ethernet users only, if you're on Wi-Fi, do not run this tweak.
echo.
echo   %COL%[37mFor any questions and/or concerns, please join our discord: discord.gg/hone
echo.
echo   %COL%[37mPlease enter "I understand" without quotes to continue:
echo.
echo.
echo.
set /p "input=%DEL%                                                            >: %COL%[92m"
if /i "!input!" neq "i understand" goto Tweaks
Reg add "HKCU\Software\OptiWin" /v "WifiDisclaimer2" /f >nul 2>&1
:NIC2
cd %SYSTEMDRIVE%\OptiWin\HoneRevert
if "%NICOF%" neq "%COL%[91mOFF" (
	reg import ognic1.reg
	reg import ognic2.reg
	reg import ognic3.reg
	reg import ognic4.reg
	del ognic1.reg
	del ognic2.reg
	del ognic3.reg
	del ognic4.reg
	goto Tweaks
) >nul 2>&1
set ognic=1
for /f "tokens=*" %%f in ('wmic cpu get NumberOfCores /value ^| find "="') do set %%f
for /f "tokens=3*" %%a in ('reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\NetworkCards" /k /v /f "Description" /s /e ^| findstr /ri "REG_SZ"') do (
	for /f %%g in ('reg query "HKLM\System\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}" /s /f "%%b" /d ^| findstr /C:"HKEY"') do (
		reg export "%%g" "%SYSTEMDRIVE%\OptiWinognic!ognic!.reg" /y
		reg add "%%g" /v "MIMOPowerSaveMode" /t REG_SZ /d "3" /f
		reg add "%%g" /v "PowerSavingMode" /t REG_SZ /d "0" /f
		reg add "%%g" /v "EnableGreenEthernet" /t REG_SZ /d "0" /f
		reg add "%%g" /v "*EEE" /t REG_SZ /d "0" /f
		reg add "%%g" /v "EnableConnectedPowerGating" /t REG_DWORD /d "0" /f
		reg add "%%g" /v "EnableDynamicPowerGating" /t REG_SZ /d "0" /f
		reg add "%%g" /v "EnableSavePowerNow" /t REG_SZ /d "0" /f
		reg add "%%g" /v "PnPCapabilities" /t REG_SZ /d "24" /f
		REM more powersaving options
		reg add "%%g" /v "*NicAutoPowerSaver" /t REG_SZ /d "0" /f
		reg add "%%g" /v "ULPMode" /t REG_SZ /d "0" /f
		reg add "%%g" /v "EnablePME" /t REG_SZ /d "0" /f
		reg add "%%g" /v "AlternateSemaphoreDelay" /t REG_SZ /d "0" /f
		reg add "%%g" /v "AutoPowerSaveModeEnabled" /t REG_SZ /d "0" /f
		set /a ognic+=1
	)
) >nul 2>&1
start /B cmd /c "ipconfig /release & ipconfig /renew" >nul 2>&1
goto Tweaks

:Netsh
if "%NETOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\OptiWin" /v InternetTweaks /f
	netsh int tcp set global dca=enabled
	netsh int tcp set global netdma=enabled
	netsh interface isatap set state disabled
	netsh int tcp set global timestamps=disabled
	netsh int tcp set global rss=enabled
	netsh int tcp set global nonsackrttresiliency=disabled
	netsh int tcp set global initialRto=2000
	netsh int tcp set supplemental template=custom icw=10
	netsh interface ip set interface ethernet currenthoplimit=64
) >nul 2>&1 else (
	reg delete "HKCU\Software\OptiWin" /v InternetTweaks /f
	netsh int tcp set supplemental Internet congestionprovider=default
	netsh int tcp set global initialRto=3000
	netsh int tcp set global rss=default
	netsh int tcp set global chimney=default
	netsh int tcp set global dca=default
	netsh int tcp set global netdma=default
	netsh int tcp set global timestamps=default
	netsh int tcp set global nonsackrttresiliency=default
) >nul 2>&1
goto Tweaks

:AllGPUTweaks
if "%ALLOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\OptiWin" /v "AllGPUTweaks" /f
	REM Enable Hardware Accelerated Scheduling
	reg query "HKLM\System\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" && reg add "HKLM\System\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t Reg_DWORD /d "2" /f
	REM Enable gdi hardware acceleration
	for /f %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class" /v "VgaCompatible" /s ^| findstr "HKEY"') do reg add "%%a" /v "KMD_EnableGDIAcceleration" /t Reg_DWORD /d "1" /f
	REM Enable GameMode
	reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t Reg_DWORD /d "1" /f
	reg add "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /t Reg_DWORD /d "1" /f
	REM FSO
	reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d "0" /f
	reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d "2" /f
	reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehavior" /t REG_DWORD /d "2" /f
	reg add "HKCU\System\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d "1" /f
	reg add "HKCU\System\GameConfigStore" /v "GameDVR_DXGIHonorFSEWindowsCompatible" /t REG_DWORD /d "1" /f
	reg add "HKCU\System\GameConfigStore" /v "GameDVR_EFSEFeatureFlags" /t REG_DWORD /d "0" /f
	reg add "HKCU\System\GameConfigStore" /v "GameDVR_DSEBehavior" /t REG_DWORD /d "2" /f
	REM Disable GpuEnergyDrv
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\GpuEnergyDrv" /v "Start" /t Reg_DWORD /d "4" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\GpuEnergyDr" /v "Start" /t Reg_DWORD /d "4" /f
	REM Disable Preemption
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v "EnablePreemption" /t Reg_DWORD /d "0" /f
) >nul 2>&1 else (
	reg delete "HKCU\Software\OptiWin" /v "AllGPUTweaks" /f
	REM Enable Hardware Accelerated Scheduling
	reg query "HKLM\System\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" && reg add "HKLM\System\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t Reg_DWORD /d "1" /f
	REM Disable gdi hardware acceleration
	for /f %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class" /v "VgaCompatible" /s ^| findstr "HKEY"') do reg delete "%%a" /v "KMD_EnableGDIAcceleration" /f
	REM Enable GameMode
	reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t Reg_DWORD /d "1" /f
	reg add "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /t Reg_DWORD /d "1" /f
	REM FSO
	reg delete "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /f
	reg delete "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /f
	reg delete "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehavior" /f
	reg delete "HKCU\System\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /f
	reg delete "HKCU\System\GameConfigStore" /v "GameDVR_DXGIHonorFSEWindowsCompatible" /f
	reg delete "HKCU\System\GameConfigStore" /v "GameDVR_EFSEFeatureFlags" /f
	reg delete "HKCU\System\GameConfigStore" /v "GameDVR_DSEBehavior" /f
	REM Disable GpuEnergyDrv
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\GpuEnergyDrv" /v "Start" /t Reg_DWORD /d "2" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\GpuEnergyDr" /v "Start" /t Reg_DWORD /d "2" /f
	REM Disable Preemption
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v "EnablePreemption" /t Reg_DWORD /d "1" /f
) >nul 2>&1
goto Tweaks

:Intel
echo %DSSOF% | find "N/A" >nul && call :OptiWinError "You don't have an intel GPU" && goto Tweaks
REM DedicatedSegmentSize in Intel iGPU
if "%DSSOF%" == "%COL%[91mOFF" (
	reg add "HKLM\SOFTWARE\Intel\GMM" /v "DedicatedSegmentSize" /t REG_DWORD /d "1024" /f
) >nul 2>&1 else (
	reg delete "HKLM\SOFTWARE\Intel\GMM" /v "DedicatedSegmentSize" /f
) >nul 2>&1
goto Tweaks

:AMD
echo %AMDOF% | find "N/A" >nul && call :OptiWinError "You don't have an AMD GPU" && goto Tweaks
REM AMD Registry Location
for /f %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /s /v "DriverDesc"^| findstr "HKEY AMD ATI"') do if /i "%%i" neq "DriverDesc" (set "REGPATH_AMD=%%i")
REM AMD Tweaks
reg add "%REGPATH_AMD%" /v "3D_Refresh_Rate_Override_DEF" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "3to2Pulldown_NA" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "AAF_NA" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "Adaptive De-interlacing" /t Reg_DWORD /d "1" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "AllowRSOverlay" /t Reg_SZ /d "false" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "AllowSkins" /t Reg_SZ /d "false" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "AllowSnapshot" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "AllowSubscription" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "AntiAlias_NA" /t Reg_SZ /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "AreaAniso_NA" /t Reg_SZ /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "ASTT_NA" /t Reg_SZ /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "AutoColorDepthReduction_NA" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "DisableSAMUPowerGating" /t Reg_DWORD /d "1" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "DisableUVDPowerGatingDynamic" /t Reg_DWORD /d "1" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "DisableVCEPowerGating" /t Reg_DWORD /d "1" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "EnableAspmL0s" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "EnableAspmL1" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "EnableUlps" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "EnableUlps_NA" /t Reg_SZ /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "KMD_DeLagEnabled" /t Reg_DWORD /d "1" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "KMD_FRTEnabled" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "DisableDMACopy" /t Reg_DWORD /d "1" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "DisableBlockWrite" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "StutterMode" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "EnableUlps" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "PP_SclkDeepSleepDisable" /t Reg_DWORD /d "1" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "PP_ThermalAutoThrottlingEnable" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "DisableDrmdmaPowerGating" /t Reg_DWORD /d "1" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "KMD_EnableComputePreemption" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%\UMD" /v "Main3D_DEF" /t Reg_SZ /d "1" /f >nul 2>&1
reg add "%REGPATH_AMD%\UMD" /v "Main3D" /t Reg_BINARY /d "3100" /f >nul 2>&1
reg add "%REGPATH_AMD%\UMD" /v "FlipQueueSize" /t Reg_BINARY /d "3100" /f >nul 2>&1
reg add "%REGPATH_AMD%\UMD" /v "ShaderCache" /t Reg_BINARY /d "3200" /f >nul 2>&1
reg add "%REGPATH_AMD%\UMD" /v "Tessellation_OPTION" /t Reg_BINARY /d "3200" /f >nul 2>&1
reg add "%REGPATH_AMD%\UMD" /v "Tessellation" /t Reg_BINARY /d "3100" /f >nul 2>&1
reg add "%REGPATH_AMD%\UMD" /v "VSyncControl" /t Reg_BINARY /d "3000" /f >nul 2>&1
reg add "%REGPATH_AMD%\UMD" /v "TFQ" /t Reg_BINARY /d "3200" /f >nul 2>&1
reg add "%REGPATH_AMD%\DAL2_DATA__2_0\DisplayPath_4\EDID_D109_78E9\Option" /v "ProtectionControl" /t Reg_BINARY /d "0100000001000000" /f >nul 2>&1
goto Tweaks

:Advanced
REM for /f "tokens=2 delims==" %%a in ('wmic path Win32_Battery Get BatteryStatus /value ^| findstr "BatteryStatus"') do set status=%%a
REM if %status% == 1 ( set Battery=DC ) else ( set Battery=AC )
set "choice="
for %%i in (DSCOF AUTOF DRIOF BCDOF NONOF CS0OF TOFOF PS0OF IDLOF CONG DPSOF) do (set "%%i=%COL%[92mON ") >nul 2>&1
(
	rem Disable Idle
	powercfg /qh scheme_current sub_processor IDLEDISABLE | find "AC Power Setting Index: 0x00000000" && set "IDLOF=%COL%[91mOFF"
	rem powercfg /qh scheme_current sub_processor IDLEDISABLE | find "Current %Battery% Power Setting Index: 0x00000000" && set "IDLOF=%COL%[91mOFF"
	rem DSCP Tweaks
	reg query "HKLM\Software\Policies\Microsoft\Windows\QoS\javaw" || set "DSCOF=%COL%[91mOFF"
	rem AutoTuning Tweak
	reg query "HKCU\Software\OptiWin" /v "TuningTweak" || set "AUTOF=%COL%[91mOFF"
	rem Congestion Provider Tweak
	reg query "HKCU\Software\OptiWin" /v "CongestionAdvancedON" || set "CONG=%COL%[91mOFF"
	rem Disable USB Powersavings
	reg query "HKCU\Software\OptiWin" /v "DUSBPowerSavings" || set "DPSOF=%COL%[91mOFF"
	rem Nvidia Drivers
	cd "%SYSTEMDRIVE%\Program Files\NVIDIA Corporation\NVSMI"
	for /f "tokens=1 skip=1" %%a in ('nvidia-smi --query-gpu^=driver_version --format^=csv') do if "%%a" neq "528.24" set "DRIOF=%COL%[91mOFF"
	rem BCDEDIT
	reg query "HKCU\Software\OptiWin" /v "BcdEditTweaks" || set "BCDOF=%COL%[91mOFF"
	rem NonBestEffortLimit Tweak
	reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" | find "0xa" || set "NONOF=%COL%[91mOFF"
	rem CS0 Tweak
	reg query "HKLM\SYSTEM\ControlSet001\Control\Class\{4D36E968-E325-11CE-BFC1-08002BE10318}\0000" /v "AllowDeepCStates" | find "0x0" || set "CS0OF=%COL%[91mOFF"
	rem Task Offloading
	reg query "HKLM\SYSTEM\CurrentControlSet\Services\TCPIP\Parameters" /v "DisableTaskOffload" | find "0x1" || set "TOFOF=%COL%[91mOFF"
	rem PStates0
	For /F "tokens=*" %%i in ('reg query "HKLM\SYSTEM\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HK"') do (reg query "%%i" /v "DisableDynamicPstate" | find "0x1" || set "PS0OF=%COL%[91mOFF")
	rem Check If Applicable For PC
	rem GPU
	for /f "tokens=2 delims==" %%a in ('wmic path Win32_VideoController get VideoProcessor /value') do (
		for %%n in (GeForce NVIDIA RTX GTX) do echo %%a | find "%%n" >nul && set "NVIDIAGPU=Found"
		for %%n in (AMD Ryzen) do echo %%a | find "%%n" >nul && set "AMDGPU=Found"
		for %%n in (Intel UHD) do echo %%a | find "%%n" >nul && set "INTELGPU=Found"
	)
	if "!NVIDIAGPU!" neq "Found" for %%g in (PS0OF DRIOF) do set "%%g=%COL%[93mN/A"
) >nul 2>&1
cls
echo.
echo.
call :OptiTitle
echo                                                           %COL%[1;4;34mNetwork Tweaks%COL%[0m
echo.
echo              %COL%[33m[%COL%[37m 1 %COL%[33m]%COL%[37m Disable Task Offloading %TOFOF%    %COL%[33m[%COL%[37m 2 %COL%[33m]%COL%[37m NonBestEffortLimit %NONOF%         %COL%[33m[%COL%[37m 3 %COL%[33m]%COL%[37m AutoTuning %AUTOF%
echo              %COL%[90mTask Offloading assigns the          %COL%[90mAllocate more bandwidth to apps      %COL%[90mDisabling it can reduce bufferbloat,
echo              %COL%[90mCPU to handle the NIC load           %COL%[90mUse only on fast connections         %COL%[90mbut lower your Network speed
echo.
echo                           %COL%[33m[%COL%[37m 4 %COL%[33m]%COL%[37m DSCP Value %DSCOF%                      %COL%[33m[%COL%[37m 5 %COL%[33m]%COL%[37m Wi-fi Congestion Provider %CONG%
echo                           %COL%[90mSet the priority of your network          %COL%[91mTurn ON only, if you have Wi-Fi.
echo                           %COL%[90mtraffic to expedited forwarding           %COL%[90mChanges the algorithm on how data is processed.
echo.
echo.
echo                                                            %COL%[1;4;34mPower Tweaks%COL%[0m
echo.
echo              %COL%[33m[%COL%[37m 6 %COL%[33m]%COL%[37m Disable C-States %CS0OF%           %COL%[33m[%COL%[37m 7 %COL%[33m]%COL%[37m PStates 0 %PS0OF%                  %COL%[33m[%COL%[37m 8 %COL%[33m]%COL%[37m Disable Idle %IDLOF%
echo              %COL%[90mKeep CPU at C0 stopping throttling   %COL%[90mRun graphics card at its highest     %COL%[90mForce CPU to always be running
echo              %COL%[90mwill make PC generate more heat      %COL%[90mdefined frequencies                  %COL%[90mat highest CPU state
echo.
echo.
echo                                                            %COL%[1;4;34mOther Tweaks%COL%[0m
echo.
echo              %COL%[33m[%COL%[37m 10 %COL%[33m]%COL%[37m BCDEdit %BCDOF%                   %COL%[33m[%COL%[37m 11 %COL%[33m]%COL%[37m Disable USB Power Savings %DPSOF%
echo              %COL%[90mTweaks your windows boot config      %COL%[90mDisable USB power savings that
echo              %COL%[90mdata to optimized settings           %COL%[90maffect latency
echo.
echo.
echo.
echo                                                 %COL%[90m[ B for back ]         %COL%[31m[ X to close ]%COL%[37m
echo.
set /p choice="%DEL%                                        %COL%[37mSelect a corresponding number to the options above > "
if /i "%choice%"=="1" goto TaskOffloading
if /i "%choice%"=="2" goto NonBestEffortLimit
if /i "%choice%"=="3" goto Autotuning
if /i "%choice%"=="4" goto DSCPValue
if /i "%choice%"=="5" goto Congestion
if /i "%choice%"=="6" goto cstates
if /i "%choice%"=="7" goto pstates0
if /i "%choice%"=="8" goto DisableIdle
if /i "%choice%"=="9" goto Driver
if /i "%choice%"=="10" goto BCDEdit
if /i "%choice%"=="11" goto DUSBPowerSavings
if /i "%choice%"=="X" exit /b
if /i "%choice%"=="B" goto MainMenu
goto Advanced

:TaskOffloading
if "%TOFOF%" == "%COL%[91mOFF" (
	netsh int ip set global taskoffload=disabled >nul 2>&1
	reg add HKLM\SYSTEM\CurrentControlSet\Services\TCPIP\Parameters /v DisableTaskOffload /t REG_DWORD /d 1 /f
) >nul 2>&1 else (
	netsh int ip set global taskoffload=enabled >nul 2>&1
	reg add HKLM\SYSTEM\CurrentControlSet\Services\TCPIP\Parameters /v DisableTaskOffload /t REG_DWORD /d 0 /f
) >nul 2>&1
goto Advanced

:NonBestEffortLimit
if "%NONOF%" == "%COL%[91mOFF" (
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /t REG_DWORD /d "10" /f
) >nul 2>&1 else (
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /f
) >nul 2>&1
goto Advanced


:Autotuning
if "%AUTOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\OptiWin" /v TuningTweak /f
	netsh int tcp set global autotuninglevel=disabled
	netsh winsock set autotuning off
) >nul 2>&1 else (
	reg delete "HKCU\Software\OptiWin" /v TuningTweak /f
	netsh int tcp set global autotuninglevel=normal
	netsh winsock set autotuning on
) >nul 2>&1
goto Advanced

:DSCPValue
if "%DSCOF%" == "%COL%[91mOFF" (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Psched" /v "Start" /t Reg_DWORD /d "1" /f
	sc start Psched
	for %%i in (csgo VALORANT-Win64-Shipping javaw FortniteClient-Win64-Shipping ModernWarfare r5apex) do (
		reg query "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" || (
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Application Name" /t Reg_SZ /d "%%i.exe" /f
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Version" /t Reg_SZ /d "1.0" /f
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Protocol" /t Reg_SZ /d "*" /f
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Local Port" /t Reg_SZ /d "*" /f
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Local IP" /t Reg_SZ /d "*" /f
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Local IP Prefix Length" /t Reg_SZ /d "*" /f
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Remote Port" /t Reg_SZ /d "*" /f
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Remote IP" /t Reg_SZ /d "*" /f
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Remote IP Prefix Length" /t Reg_SZ /d "*" /f
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "DSCP Value" /t Reg_SZ /d "46" /f
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Throttle Rate" /t Reg_SZ /d "-1" /f
		)
	)
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingConforming" /v "ServiceTypeGuaranteed" /t REG_DWORD /d "46" /f
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingConforming" /v "ServiceTypeNetworkControl" /t REG_DWORD /d "56" /f
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingNonConforming" /v "ServiceTypeGuaranteed" /t REG_DWORD /d "46" /f
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingNonConforming" /v "ServiceTypeNetworkControl" /t REG_DWORD /d "56" /f
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\UserPriorityMapping" /v "ServiceTypeGuaranteed" /t REG_DWORD /d "5" /f
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\UserPriorityMapping" /v "ServiceTypeNetworkControl" /t REG_DWORD /d "7" /f
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "MaxOutstandingSends" /t REG_DWORD /d "65000" /f
) >nul 2>&1 else (
	for %%i in (csgo VALORANT-Win64-Shipping javaw FortniteClient-Win64-Shipping ModernWarfare r5apex) do (
		reg delete "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /f
	)
	reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingConforming" /v "ServiceTypeGuaranteed" /f
	reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingConforming" /v "ServiceTypeNetworkControl" /f
	reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingNonConforming" /v "ServiceTypeGuaranteed" /f
	reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingNonConforming" /v "ServiceTypeNetworkControl" /f
	reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\UserPriorityMapping" /v "ServiceTypeGuaranteed" /f
	reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\UserPriorityMapping" /v "ServiceTypeNetworkControl" /f
	reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "MaxOutstandingSends" /f
) >nul 2>&1
goto Advanced

:Congestion
Reg query "HKCU\Software\OptiWin" /v "WifiDisclaimer3" >nul 2>&1 && goto Congestion2
cls
echo.
echo.
call :OptiTitle
echo.
echo                            %COL%[90m              OptiWin is a free and open-source fork of HoneCTRL
echo                            %COL%[90m                   made to improve your computing experience
echo.
echo.
echo.
echo %COL%[91m  WARNING:
echo %COL%[91m  This tweak is for Wi-Fi users only, if you're on Ethernet, do not run this tweak.
echo.
echo   %COL%[37mFor any questions and/or concerns, please join our discord: discord.gg/hone
echo.
echo   %COL%[37mPlease enter "I understand" without quotes to continue:
echo.
echo.
echo.
set /p "input=%DEL%                                                            >: %COL%[92m"
if /i "!input!" neq "i understand" goto Tweaks
Reg add "HKCU\Software\OptiWin" /v "WifiDisclaimer3" /f >nul 2>&1
:Congestion2
if "%CONG%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\OptiWin" /v CongestionAdvancedON /f
	netsh int tcp set supplemental Internet congestionprovider=newreno
) >nul 2>&1 else (
	reg delete "HKCU\Software\OptiWin" /v CongestionAdvancedON /f
	netsh int tcp set supplemental Internet congestionprovider=default
) >nul 2>&1
goto Advanced

:cstates
if "%CS0OF%" == "%COL%[91mOFF" (
	reg add "HKLM\SYSTEM\ControlSet001\Control\Class\{4D36E968-E325-11CE-BFC1-08002BE10318}\0000" /v "AllowDeepCStates" /t REG_DWORD /d "0" /f
) >nul 2>&1 else (
	reg add "HKLM\SYSTEM\ControlSet001\Control\Class\{4D36E968-E325-11CE-BFC1-08002BE10318}\0000" /v "AllowDeepCStates" /t REG_DWORD /d "1" /f
) >nul 2>&1
call :OptiWinRestart "CStates" "%CS0OF%"
Mode 130,45
goto Advanced

:PStates0
if "%PS0OF%" == "%COL%[91mOFF" (
	for /f %%i in ('reg query "HKLM\System\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HKEY"') do (
		reg add "%%i" /v "DisableDynamicPstate" /t REG_DWORD /d "1" /f
	)
) >nul 2>&1 else  (
	for /f %%i in ('reg query "HKLM\System\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HKEY"') do (
		reg delete "%%i" /v "DisableDynamicPstate" /f
	)
) >nul 2>&1
call :OptiWinRestart "PStates 0" "%PS0OF%"
Mode 130,45
goto Advanced

:DisableIdle
if "%IDLOF%" == "%COL%[91mOFF" (
powercfg /setacvalueindex scheme_current sub_processor IDLEDISABLE 1
REM	if %battery% == AC (
REM		powercfg /setacvalueindex scheme_current sub_processor IDLEDISABLE 1
REM	) else (
REM		powercfg /setdcvalueindex scheme_current sub_processor IDLEDISABLE 1
REM	)
) else (
powercfg -setacvalueindex scheme_current sub_processor IDLEDISABLE 0
REM	if %battery% == AC (
REM		powercfg -setacvalueindex scheme_current sub_processor IDLEDISABLE 0
REM	) else (
REM		powercfg -setdcvalueindex scheme_current sub_processor IDLEDISABLE 0
REM	)
)
goto Advanced

:BCDEdit
if "%BCDOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\OptiWin" /v BcdEditTweaks /f
	rem tscsyncpolicy
	bcdedit /set tscsyncpolicy enhanced
	rem Quick Boot
	rem if "%dualboot%" == "no" (bcdedit /timeout 3)
	bcdedit /set bootux disabled
	bcdedit /set bootmenupolicy standard
	rem bcdedit /set hypervisorlaunchtype off
	rem bcdedit /set tpmbootentropy ForceDisable
	bcdedit /set quietboot yes
	rem Windows 8 Boot (windows 8.1)
	rem for /f "tokens=4-9 delims=. " %%i in ('ver') do set winversion=%%i.%%j
	rem if "!winversion!" == "6.3.9600" (
	rem 	bcdedit /set {globalsettings} custom:16000067 true
	rem 	bcdedit /set {globalsettings} custom:16000068 true
	rem )
	rem nx
	echo %PROCESSOR_IDENTIFIER% ^| find "Intel" >nul && bcdedit /set nx optout || bcdedit /set nx alwaysoff
	rem Disable some of the kernel memory mitigations
	rem Forcing Intel SGX and setting isolatedcontext to No will cause a black screen
	rem bcdedit /set isolatedcontext No
	bcdedit /set allowedinmemorysettings 0x0
	rem Disable DMA memory protection and cores isolation
	bcdedit /set vsmlaunchtype Off
	bcdedit /set vm No
	reg add "HKLM\Software\Policies\Microsoft\FVE" /v "DisableExternalDMAUnderLock" /t Reg_DWORD /d "0" /f
	reg add "HKLM\Software\Policies\Microsoft\Windows\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /t Reg_DWORD /d "0" /f
	reg add "HKLM\Software\Policies\Microsoft\Windows\DeviceGuard" /v "HVCIMATRequired" /t Reg_DWORD /d "0" /f
	rem Avoid using uncontiguous low-memory. Boosts memory performance & microstuttering.
	rem Can freeze the system on unstable memory OC
	rem bcdedit /set firstmegabytepolicy UseAll
	rem bcdedit /set avoidlowmemory 0x8000000
	rem bcdedit /set nolowmem Yes
	rem Enable X2Apic and enable Memory Mapping for PCI-E devices
	bcdedit /set x2apicpolicy Enable
	bcdedit /set uselegacyapicmode No
	bcdedit /set configaccesspolicy Default
	bcdedit /set usephysicaldestination No
	bcdedit /set usefirmwarepcisettings No 
) >nul 2>&1 else (
	reg delete "HKCU\Software\OptiWin" /v "BcdEditTweaks" /f
	rem Better Input
	bcdedit /deletevalue tscsyncpolicy
	rem Quick Boot
	rem if "%dualboot%" == "no" (bcdedit /timeout 0)
	bcdedit /deletevalue bootux
	bcdedit /set bootmenupolicy standard
	bcdedit /set hypervisorlaunchtype Auto
	bcdedit /deletevalue tpmbootentropy
	bcdedit /deletevalue quietboot
	rem Windows 8 Boot Stuff (windows 8.1)
	rem for /f "tokens=4-9 delims=. " %%i in ('ver') do set winversion=%%i.%%j
	rem if "!winversion!" == "6.3.9600" (
	rem	bcdedit /set {globalsettings} custom:16000067 false
	rem	bcdedit /set {globalsettings} custom:16000069 false
	rem	bcdedit /set {globalsettings} custom:16000068 false
	rem )
	rem nx
	bcdedit /set nx optin
	rem Disable some of the kernel memory mitigations
	bcdedit /set allowedinmemorysettings 0x17000077
	bcdedit /set isolatedcontext Yes
	rem Disable DMA memory protection and cores isolation
	bcdedit /deletevalue vsmlaunchtype
	bcdedit /deletevalue vm
	reg delete "HKLM\Software\Policies\Microsoft\FVE" /v "DisableExternalDMAUnderLock" /f
	reg delete "HKLM\Software\Policies\Microsoft\Windows\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /f
	reg delete "HKLM\Software\Policies\Microsoft\Windows\DeviceGuard" /v "HVCIMATRequired" /f
	bcdedit /deletevalue firstmegabytepolicy
	bcdedit /deletevalue avoidlowmemory
	bcdedit /deletevalue nolowmem
	bcdedit /deletevalue configaccesspolicy
	bcdedit /deletevalue x2apicpolicy
	bcdedit /deletevalue usephysicaldestination
	bcdedit /deletevalue usefirmwarepcisettings
	bcdedit /deletevalue uselegacyapicmode
) >nul 2>&1
goto Advanced

:DUSBPowerSavings
if "%DPSOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\OptiWin" /v DUSBPowerSavings /f
	for /f "tokens=*" %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum" /s /f "StorPort" ^| findstr "StorPort"') do reg add "%%i" /v "EnableIdlePowerManagement" /t REG_DWORD /d "0" /f
	for /f "tokens=*" %%i in ('wmic PATH Win32_PnPEntity GET DeviceID ^| findstr "USB\VID_"') do (
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "EnhancedPowerManagementEnabled" /t REG_DWORD /d "0" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "AllowIdleIrpInD3" /t REG_DWORD /d "0" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "EnableSelectiveSuspend" /t REG_DWORD /d "0" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "DeviceSelectiveSuspended" /t REG_DWORD /d "0" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "SelectiveSuspendEnabled" /t REG_DWORD /d "0" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "SelectiveSuspendOn" /t REG_DWORD /d "0" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "D3ColdSupported" /t REG_DWORD /d "0" /f
	)
) >nul 2>&1 else (
	reg delete "HKCU\Software\OptiWin" /v DUSBPowerSavings /f
	for /f "tokens=*" %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum" /s /f "StorPort" ^| findstr "StorPort"') do reg delete "%%i" /v "EnableIdlePowerManagement" /f
	for /f "tokens=*" %%i in ('wmic PATH Win32_PnPEntity GET DeviceID ^| findstr "USB\VID_"') do (
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "EnhancedPowerManagementEnabled" /f
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "AllowIdleIrpInD3" /f
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "EnableSelectiveSuspend" /f
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "DeviceSelectiveSuspended" /f
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "SelectiveSuspendEnabled" /f
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "SelectiveSuspendOn" /f
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "D3ColdSupported" /f
	)
) >nul 2>&1
goto Advanced

:Credits
cls
call :OptiTitle
echo.
echo.
echo.
echo %COL%[90m                                                         Product Lead
echo %COL%[97m                                                       Levi - thenstop
echo.
echo.
echo.
echo %COL%[90m                                                   Product Development Lead
echo %COL%[97m                                                       Levi - thenstop
echo %COL%[97m                                                        Sky - vawmpira
echo.
echo.
echo.
echo %COL%[90m                                                          Credits to
echo %COL%[97m                                                       AdamX - DSCP Values, HDCP research
echo %COL%[97m                                                  Djdallmann - Networking and General research
echo %COL%[97m                                                     Calypto - Most of these "custom" power plans
echo %COL%[97m                                                      Melody - csrss.exe priority
echo %COL%[97m                                                     mbk1969 - MSI Mode research
echo %COL%[97m                                                    Timecard - Networking research
echo.
echo.
echo.
call :ColorText 8 "                                                     [ press B to go back ]"
echo.
%SYSTEMROOT%\System32\choice.exe /c:B /n /m "%DEL%                                                               >:"
set choice=%errorlevel%
if "%choice%"=="1" goto More

:Backup
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "SystemRestorePointCreationFrequency" /t REG_DWORD /d 0 /f >nul 2>&1
powershell Enable-ComputerRestore -Drive 'C:\', 'D:\', 'E:\', 'F:\', 'G:\' >nul 2>&1
powershell Checkpoint-Computer -Description 'Hone Restore Point' >nul 2>&1
for /F "tokens=2" %%i in ('date /t') do set date=%%i  >nul 2>&1
set date1=%date:/=.%  >nul 2>&1
md %SYSTEMDRIVE%\OptiWin%date1%  >nul 2>&1
reg export HKCU %SYSTEMDRIVE%\OptiWin%date1%\HKLM.reg /y & reg export HKCU %SYSTEMDRIVE%\OptiWin%date1%\HKCU.reg /y >nul 2>&1
cls
goto :eof

:ColorText
echo off
<nul set /p ".=%DEL%" > "%~2"
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul
goto :eof

:OptiWinRestart
setlocal DisableDelayedExpansion
if "%~2" == "%COL%[91mOFF" (set "ed=enable") else (set "ed=disable")
start "Restart" cmd /V:ON /C @echo off
Mode 65,16
color 06
echo.
echo  --------------------------------------------------------------
echo                       Restart to fully apply
echo  --------------------------------------------------------------
echo.
echo      To %ed% %~1 you must restart, would
echo      you like to restart now?
echo.
echo.
echo.
echo.
echo      [Y] Yes
echo      [N] No
echo.
:restartchoice
set /p choice=Would you like to continue and restart your PC? Y or N?: 
if /i "%choice%" == "y" (
	shutdown /r /f /d p:0:0
) else if /i "%choice%" == "n" (
	exit /b
) else (
	goto restartchoice
)

:eof
