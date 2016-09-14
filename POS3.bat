:: ---- luxe POS3.bat
:: ---- Updated 2016/05/25 00:30 EDT
:: ---- John Stanley
:: ---- Help automate staging of registers with L'Oreal's Win7 x86 LUXE POS image
:: ----  and laptops with the CPD POS image.
:: ----  file 3 of 3

@ECHO OFF
SETLOCAL
TITLE LUXE POS Staging 3/3

:: Return code
SET RETURN=1

CLS

:: **** CHECK FOR ADMIN PRIVILEGES ****
AT > NUL
IF %ERRORLEVEL% NEQ 0 (
	ECHO.
	ECHO ** Administrator privileges required! **
	ECHO Try restarting the computer and logging in again.
	PAUSE
	SET RETURN=1
	GOTO :ExitFile
)
ECHO Administrator privileges detected!

:: Location of staging files
SET STAGINGFILES=%PUBLIC%\Desktop\Staging Files

:: log file
SET LOGFILE=%STAGINGFILES%\log.txt

:: US or Canada
SET COUNTRY=""
IF EXIST "%STAGINGFILES%\US.txt" (
	SET COUNTRY=US
)
IF EXIST "%STAGINGFILES%\CA.txt" (
	SET COUNTRY=CA
)

:: register or laptop
SET COMPUTER=""
IF EXIST "%STAGINGFILES%\register.txt" (
	SET COMPUTER=register
)
IF EXIST "%STAGINGFILES%\laptop.txt" (
	SET COMPUTER=laptop
)

ECHO Start luxe POS3. >> "%LOGFILE%"
%SYSTEMDRIVE%

:: **** RUN POLE DISPLAY UTILITY ****
:PDSetup
ECHO.
ECHO Set correct COM port and test the customer display.
ECHO Running Pole Display Setup Utility...
CD \
CD "%PROGRAMFILES%\Logic Controls PD OPOS"
"PDSetup.exe"
IF %ERRORLEVEL% NEQ 0 (
	ECHO    **** ERROR ****
	ECHO "%CD%"
	ECHO PDSetup.exe
	ECHO Troubleshoot and correct issue running program before continuing.
	CHOICE /C Y /M "Continue"
)
ECHO.
CHOICE /C YN /M "Customer display test good"
IF ERRORLEVEL 2 (
	ECHO Troubleshoot issue and continue to retry.
	CHOICE /C Y /M "Continue"
	GOTO :PDSetup
)
ECHO End RUN POLE DISPLAY UTILITY. >> "%LOGFILE%"
VERIFY > NUL


:: **** RUN HMUTILITY ****
:HMUtility
ECHO.
ECHO Use hmUtility to test the receipt printer and cash drawer.
ECHO.
ECHO Running hmUtility....
CD \
CD "HP Receipt Printer Firmware Update A799\Utility"
"hmUtility.exe"
IF %ERRORLEVEL% NEQ 0 (
	ECHO    **** ERROR ****
	ECHO "%CD%"
	ECHO hmUtility.exe
	ECHO Before continuing, manually run hmUtility
	ECHO to test the receipt printer and cash drawer.
	CHOICE /C Y /M "Continue"
)
CHOICE /C YN /M "Receipt printer and cash drawer test good"
IF ERRORLEVEL 2 (
	ECHO Troubleshoot issue and continue to retry.
	CHOICE /C Y /M "Continue"
	GOTO :HMUtility
)
ECHO End RUN HMUTILITY. >> "%LOGFILE%"
VERIFY > NUL


:: **** INSTALL MSR UTILITY ****
:: Laptops don't have keyboard MSRs.
IF %COMPUTER%==laptop (
	GOTO :EndMSR
)
ECHO.
ECHO Installing MSR Utility...
CD \
CD "Admin\POS 5800"
CD "ID TECH Keyboard\80066804-007_MagSwipe_Configuration_Utility_v2_2_A"
"setup.exe"
IF %ERRORLEVEL% NEQ 0 (
	ECHO    **** ERROR ****
	ECHO "%CD%"
	ECHO setup.exe
	ECHO Troubleshoot and correct installation before continuing.
	CHOICE /C Y /M "Continue"
)
ECHO         Done!
ECHO End INSTALL MSR UTILITY. >> "%LOGFILE%"
VERIFY > NUL

:: **** RUN MSR UTILITY ****
ECHO.
ECHO Change basic reader settings and disable the reader.
ECHO Running MSR Utility...
CD \
CD "%PROGRAMFILES%\ID TECH\MagSwipe Configuration Utility"
"MagSwipeCfgUtil.exe"
IF %ERRORLEVEL% NEQ 0 (
	ECHO ERROR!!!!
	ECHO Before continuing, manually run the MagSwipe
	ECHO Configuration Utility and disable the reader.
	CHOICE /C Y /M "Continue"
)
ECHO         Done!
ECHO End RUN MSR UTILITY. >> "%LOGFILE%"
:EndMSR
VERIFY > NUL


:: *****************************************************
:: Canada does not get VeriFones.  No drivers installed.
:: No form loader program installed.  No loading forms.
IF %COUNTRY%==CA (
	GOTO :EndVeriFone
)
:: *****************************************************

:: **** INSTALL VERIFONE DRIVERS ****
ECHO.
ECHO Running VeriFone driver installer...
CD \
CD "Admin\POS 5800"
CD "VERIFONE\Win7-Vista-XP-(Embedded) 32bit USB Driver\usb_installvfi_3_1"
"usb_installvfi_3_1.msi"
IF %ERRORLEVEL% NEQ 0 (
	ECHO ERROR!!!!
	ECHO "%CD%"
	ECHO usb_installvfi_3_1.msi
	ECHO Troubleshoot and correct installation before continuing.
	CHOICE /C Y /M "Continue"
)
ECHO         Done!
ECHO End INSTALL VERIFONE DRIVERS. >> "%LOGFILE%"
VERIFY > NUL

:: **** OPEN DEVICES AND PRINTERS (VeriFone) ****
ECHO.
ECHO Open Devices and Printers...
CD \
CONTROL /name Microsoft.DevicesAndPrinters
ECHO End OPEN DEVICES AND PRINTERS (VeriFone). >> "%LOGFILE%"

:: **** PROMPT TO CONNECT VERIFONE ****
ECHO.
ECHO Connect the VeriFone and allow drivers to install before continuing.
ECHO Make sure the device is set to COM5.
CHOICE /C Y /M "Continue"
VERIFY > NUL

:: **** INSTALL MX LOADER ****
ECHO.
ECHO Install MX Downloader.
ECHO Uncheck boxes that add option to right click and edit firewall rule.
ECHO Choose to not start MX Downloader after install completes.
ECHO Installing MX Downloader...
CD \
CD "Admin\FORMS-MX915\MX915_RELOAD\MxDownloader_2.8.0_Setup"
"MxDownloader_2.8.0_Setup.exe"
IF %ERRORLEVEL% NEQ 0 (
	ECHO    **** ERROR ****
	ECHO "%CD%"
	ECHO MxDownloader_2.8.0_Setup.exe
	ECHO Troubleshoot and correct installation before continuing.
	CHOICE /C Y /M "Continue"
)
ECHO         Done!
:: Copy forms shortcut to MX Downloader folder
COPY /V /Y "%STAGINGFILES%\FORMS-MX915.lnk" "%PROGRAMFILES%\VeriFone\MxDownloader\"
ECHO End INSTALL MX LOADER. >> "%LOGFILE%"
VERIFY > NUL

:: **** LOAD FORMS TO VERIFONE ****
ECHO.
ECHO Prepare the VefiFone to download forms before continuing.
ECHO 1 - MX-915
ECHO X - Skip loading forms.
CHOICE /C 1X
IF ERRORLEVEL 2 (
	GOTO :EndVeriFone
)
IF ERRORLEVEL 1 (
	ECHO.
	ECHO Load the forms to the VeriFone before continuing.
	CD \
	CD "%PROGRAMFILES%\VeriFone\MxDownloader"
	"MxDownloader.exe"	
	CHOICE /C Y /M "Continue"
)
ECHO End LOAD FORMS TO VERIFONE. >> "%LOGFILE%"
:EndVeriFone
VERIFY > NUL


:: *****************************************************
:: US does not get fingerprint drivers or French
:: language pack installed.
IF %COUNTRY%==US (
	GOTO :EndFrench
)
:: *****************************************************

:: **** INSTALL FINGERPRINT READER DRIVERS ****
ECHO.
ECHO Running fingerprint reader driver installer...
CD \
CD "Admin\RTE"
"Setup.exe"
IF %ERRORLEVEL% NEQ 0 (
	ECHO    **** ERROR ****
	ECHO "%CD%"
	ECHO Setup.exe
	ECHO Troubleshoot and correct installation before continuing.
	CHOICE /C Y /M "Continue"
)
ECHO.
ECHO Continue after the fingerprint reader installer has completed.
CHOICE /C Y /M "Continue"
ECHO End INSTALL FINGERPRINT READER DRIVERS. >> "%LOGFILE%"
VERIFY > NUL

:: **** INSTALL FRENCH LANGUAGE PACK ****
ECHO.
ECHO Installing the French language pack...
CD \
CD "Admin\French"
"windows6.1-kb2483139-x86-fr-fr_f57427487dfc2f49da67cac22480ab1f48983d22.exe"
IF %ERRORLEVEL% NEQ 0 (
	ECHO    **** ERROR ****
	ECHO "%CD%"
	ECHO windows6.1-kb2483139-x86-fr-fr_f57427487dfc2f49da67cac22480ab1f48983d22.exe
	ECHO Troubleshoot and correct installation before continuing.
	CHOICE /C Y /M "Continue"
)
ECHO         Done!
ECHO End INSTALL FRENCH LANGUAGE PACK. >> "%LOGFILE%"
:EndFrench
VERIFY > NUL


:: **** OPEN REGEDIT ****
ECHO.
ECHO Edit permissions on
ECHO HKEY_LOCAL_MACHINE\SOFTWARE\OLEforRetail\ServiceOPOS
ECHO set USERS group to Full Control.
ECHO Opening regedit...
CD \
regedit.exe
IF %ERRORLEVEL% NEQ 0 (
	ECHO ERROR!!!!
	ECHO Run regedit manually.
) 
ECHO Continue after editing the registry.
CHOICE /C Y /M "Continue"
ECHO End OPEN REGEDIT. >> "%LOGFILE%"
VERIFY > NUL


:: **** CONFIRM TEST SCANNER AND MSR ****
:Test
ECHO.
ECHO BEFORE CONTINUING DO THE FOLLOWING!
ECHO 1 - Program the scanner.
ECHO 2 - Test the scanner.
IF %COMPUTER%==register (
	ECHO 3 - Verify the MSR is disabled.
)
NOTEPAD
ECHO.
IF %COMPUTER%==register (
	ECHO Scanner test good and MSR disabled?
)
IF %COMPUTER%==laptop (
	ECHO Scanner test good?
)
CHOICE /C YN
IF ERRORLEVEL 2 (
	ECHO Reprogram the scanner or replace if necessary.
	ECHO Rerun the MagSwipe Configuration utilty and
	ECHO disable MSR reading if necessary.
	GOTO :Test
)
ECHO End CONFIRM TEST SCANNER AND MSR. >> "%LOGFILE%"
VERIFY > NUL


:: **** INSTALL CISCO ANYCONNECT ****
:: Laptops with the CPD image already have AnyConnect installed.
IF %COMPUTER%==laptop (
	GOTO :EndCiscoInstall
)
ECHO.
ECHO Installing Cisco VPN client....
CD \
CD "Admin\Cisco AnyConnect"
START /WAIT CMD /C CiscoWebClientInstall.bat
IF %ERRORLEVEL% NEQ 0 (
	ECHO    **** ERROR ****
	ECHO "%CD%"
	ECHO CiscoWebClientInstall.bat
	ECHO Troubleshoot and correct installation before continuing.
	CHOICE /C Y /M "Continue"
)
ECHO         Done!
ECHO End INSTALL CISCO ANYCONNECT. >> "%LOGFILE%"
:EndCiscoInstall
VERIFY > NUL


:: **** UPDATE CISCO ANYCONNECT ****
:: part 1
ECHO.
ECHO Updating Cisco AnyConnect part 1/2....
CD \
CD "Admin\CiscoAnyconnectWebAgentCertRe-Reg"
START /WAIT CMD /C ACWS-Certificate-Update.bat
IF %ERRORLEVEL% NEQ 0 (
	ECHO    **** ERROR ****
	ECHO "%CD%"
	ECHO ACWS-Certificate-Update.bat
	ECHO Troubleshoot and correct before continuing.
	CHOICE /C Y /M "Continue"
)
ECHO         Done!
ECHO End UPDATE CISCO ANYCONNECT part 1. >> "%LOGFILE%"
VERIFY > NUL
::part 2
ECHO.
ECHO Updating Cisco AnyConnect part 2/2....
CD \
CD "Admin\Update_Cisco_WebSecurity_Profile"
START /WAIT CMD /C MARS_Update_WebSecurity_Profile.bat
IF %ERRORLEVEL% NEQ 0 (
	ECHO    **** ERROR ****
	ECHO "%CD%"
	ECHO MARS_Update_WebSecurity_Profile.bat
	ECHO Troubleshoot and correct before continuing.
	CHOICE /C Y /M "Continue"
)
ECHO         Done!
ECHO End UPDATE CISCO ANYCONNECT part 2. >> "%LOGFILE%"
VERIFY > NUL


:: **** UPGRADE MARS ****
ECHO.
ECHO Upgrading MARS...
CD \
IF %COUNTRY%==US (
	CD "Admin\MARS-Upgrade\Version-11.14.1391.315"
)
IF %COUNTRY%==CA (
	CD "Admin\MARS-Upgrade\Version-11.14.1391.315"
)
START /WAIT CMD /C "FO-Upgrade.bat"
IF %ERRORLEVEL% NEQ 0 (
	ECHO    **** ERROR ****
	ECHO "%CD%"
	ECHO FO-Upgrade.bat
	ECHO Troubleshoot and correct the upgrade before continuing.
	CHOICE /C Y /M "Continue"
)
ECHO         Done!
ECHO End UPGRADE MARS. >> "%LOGFILE%"
VERIFY > NUL


:: **** UPDATE MARS LICENSE ****
ECHO.
ECHO Update MARS license...
REGEDIT.EXE "%STAGINGFILES%\LOREALv11-04-RegSeria.L'OREAL32.reg"
IF %ERRORLEVEL% NEQ 0 (
	ECHO    **** ERROR ****
	ECHO Before continuing, merge the new MARS license manually.
	CHOICE /C Y /M "Continue"
)
ECHO         Done!
ECHO End UPDATE MARS LICENSE. >> "%LOGFILE%"
VERIFY > NUL


:: **** NOTIFIY EDIT POS LINK ****
ECHO.
ECHO Manually edit the POS link.
CD \
"%STAGINGFILES%\POS link.txt"
ECHO.
CHOICE /C Y /M "Has the POS link been edited"
ECHO End NOTIFIY EDIT POS LINK. >> "%LOGFILE%"
VERIFY > NUL


:: **** COPY MARS BACKGROUND ****
:: Currently CPD does not get backgrounds.
IF EXIST "%STAGINGFILES%\eFOS5.hsc" (
	ECHO.
	ECHO Copying store background file...
	COPY /V /Y "%STAGINGFILES%\eFOS5.hsc" "%PROGRAMFILES%\CEGID\Cegid Business\app\Mode\"
)
ECHO End COPY MARS BACKGROUND. >> "%LOGFILE%"
VERIFY > NUL


:: **** NOTIFY EDIT AUTO LOGIN FILE ****
ECHO.
ECHO BEFORE CONTINUING DO THE FOLLOWING!
ECHO 1 - Edit the AutoLogin.reg file to contain the correct user name.
ECHO 2 - SAVE and close the file.
CD \
NOTEPAD "%STAGINGFILES%\AutoLogin.reg"
ECHO Continue after editing the reg file.
CHOICE /C Y /M "Continue"
VERIFY > NUL


:: **** MERGE AUTO LOGIN FILE TO REGISTRY ****
ECHO.
ECHO Merging registry file...
REGEDIT.EXE "%STAGINGFILES%\AutoLogin.reg"
IF %ERRORLEVEL% NEQ 0 (
	ECHO    **** ERROR ****
	ECHO Before continuing, manually merge
	ECHO the AutoLogin.reg file.
	CHOICE /C Y /M "Continue"
)
ECHO         Done!
ECHO End  MERGE AUTO LOGIN FILE TO REGISTRY. >> "%LOGFILE%"
VERIFY > NUL


:: **** PAUSE FOR ERROR CHECK ****
ECHO.
ECHO *********************************************************
ECHO **                                                     **
ECHO ** !! PLEASE REVIEW ABOVE FOR ERRORS BEFORE EXITING !! **
ECHO **                                                     **
ECHO **          LOG OFF THEN BACK IN AS .\POS.ADMIN        **
ECHO **       THEN SHUTDOWN AND CONNECT TO MARS NETGATE     **
ECHO **                                                     **
ECHO *********************************************************
ECHO.
CHOICE /C Y /M "Exit"
SET RETURN=0
ECHO End luxe POS3. >> "%LOGFILE%"
VERIFY > NUL


:: **** DELETE STAGING FILES ****
CD \
RD /S /Q "%STAGINGFILES%"
DEL /F "%PUBLIC%\Desktop\luxe POS3.bat"


:ExitFile
ENDLOCAL & EXIT %RETURN%
