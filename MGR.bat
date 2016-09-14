:: ---- luxe MGR.bat
:: ---- Updated 2016/05/25 00:45 EDT
:: ---- John Stanley
:: ---- Helps automate staging of manager PCs with L'Oreal's Win7 x86 LUXE MGR image.

@ECHO OFF
SETLOCAL
TITLE LUXE MGR Staging

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
) ELSE (
	ECHO Administrator privileges detected!
)



:: **** DISPLAY WARNING ****
ECHO.
ECHO ----------------------------------------------
ECHO --                                          --
ECHO -- This file is for TSI staging of L'Oreal  --
ECHO -- MARS manager workstations.               --
ECHO --                                          --
ECHO -- If you are using this file for any other --
ECHO -- register, DO NOT continue, enter No or   --
ECHO -- close this window immediately.           --
ECHO --                                          --
ECHO ----------------------------------------------
ECHO.
CHOICE /C YN /M "Continue staging a MARS manager workstation"
IF ERRORLEVEL 2 (
	SET RETURN=0
	GOTO :ExitFile
)



:: PATH FOR STAGING FILES
SET FILES=%~dp0Staging Files

:: PATH FOR MARS SPECIFIC FILES
SET MARSFILES=%FILES%\MARS

:: PATH FOR MARS MANAGER PC SPECIFIC FILES
SET MGRFILES=%MARSFILES%\Manager PC

:: PATH FOR BATCH FILES
SET BATFILES=%FILES%\BAT Files


:Start


:: - VARIABLE FOR COUNTRY
SET COUNTRY=

:: - VARIABLE FOR STORE BRAND
SET BRAND=

:: - VARIABLE FOR BRAND NAME
SET BRANDLONG=



:: **** GET COUNTRY ****
ECHO.
ECHO Enter the country.
ECHO U - US
ECHO C - Canada
CHOICE /C UC
IF ERRORLEVEL 1 (
	SET COUNTRY=US
)
IF ERRORLEVEL 2 (
	SET COUNTRY=CA
)
VERIFY > NUL


:: **** GET STORE BRAND ****
ECHO.
ECHO Enter the brand of store.
ECHO C - CPD Outlet
ECHO D - Carol's Daughter
ECHO K - Kiehl's
ECHO L - Luxury Beauty ^(DFCCO^)
ECHO M - Maybelline
ECHO N - NYX
::ECHO S - Sister ^(em^)
ECHO U - Urban Decay
CHOICE /C CDKLMNU
IF ERRORLEVEL 1 (
	SET BRAND=C
	SET BRANDLONG=CPD Outlet
)
IF ERRORLEVEL 2 (
	SET BRAND=D
	SET BRANDLONG=Carol's Daughter
)
IF ERRORLEVEL 3 (
	SET BRAND=K
	SET BRANDLONG=Kiehl's
)
IF ERRORLEVEL 4 (
	SET BRAND=L
	SET BRANDLONG=Luxury Beauty
)
IF ERRORLEVEL 5 (
	SET BRAND=M
	SET BRANDLONG=Maybelline NY
)
IF ERRORLEVEL 6 (
	SET BRAND=N
	SET BRANDLONG=NYX
)
IF ERRORLEVEL 7 (
	SET BRAND=U
	SET BRANDLONG=Urban Decay
)
VERIFY > NUL



:: **** VERIFY INPUT ****
CLS
ECHO.
ECHO.
ECHO Continue staging for %COUNTRY% %BRANDLONG% manager PC?
CHOICE /C YN
IF ERRORLEVEL 2 (
	GOTO :Start
)
VERIFY > NUL



:: **** SET TIME ZONE ****
ECHO.
ECHO Setting time zone...
START /WAIT CMD /C "%BATFILES%\TimeZone.bat" %COUNTRY%
IF %ERRORLEVEL% NEQ 0 (
	ECHO ERROR!!!!
	ECHO Manually set the time zone before continuing.
	CHOICE /C Y /M "Continue"
)
VERIFY > NUL



:: **** UPDATE ETIME LINKS ****
ECHO.
ECHO Updating eTIME shortcuts...
START /WAIT CMD /C "%BATFILES%\UpdateEtime.bat"
IF %ERRORLEVEL% NEQ 0 (
	ECHO ERROR!!!!
	ECHO Before continuing, copy the new eTIME link to the 
	ECHO Public Desktop and Admin\DESKTOP_ICONS folder manually.
	CHOICE /C Y /M "Continue"
)
VERIFY > NUL



:: **** COPY MARS BACKGROUNDS ****
ECHO.
ECHO Copying MARS background files...
START /WAIT CMD /C "%BATFILES%\CopyBackgrounds.bat"
IF %ERRORLEVEL% NEQ 0 (
	ECHO ERROR!!!!
	ECHO Before continuing, manually run the CopyBackgrounds
	ECHO file as an administrator.
	CHOICE /C Y /M "Continue"
)
VERIFY > NUL



:: **** COPY E-MAIL LINK ****
ECHO.
ECHO Copying e-mail shortcut...
COPY /V /Y "%MGRFILES%\e-mail.url" "%PUBLIC%\Desktop\"
VERIFY > NUL
ECHO Creating backup copy...
COPY /V /Y "%PUBLIC%\Desktop\e-mail.url" "%SYSTEMDRIVE%\Admin\DESKTOP_ICONS\"
VERIFY > NUL



:: **** CREATE SHARED FOLDER ****
ECHO.
ECHO Creating SHARED folder....
IF NOT EXIST "%SYSTEMDRIVE%\SHARED" (
	MKDIR "%SYSTEMDRIVE%\SHARED"
	IF %ERRORLEVEL% NEQ 0 (
		ECHO ERROR!!!!
		ECHO Before continuing, manually create the 
		ECHO %SYSTEMDRIVE%\SHARED folder.
		CHOICE /C Y /M "Continue"
	)
)
ECHO         Done!
VERIFY > NUL



:: **** COPY SHARED LINK ****
ECHO.
ECHO Copying SHARED shortcut....
COPY /V /Y "%MGRFILES%\SHARED.lnk" "%PUBLIC%\Desktop\"
VERIFY > NUL



:: **** EXTRACT ZIP FILES ****
ECHO.
ECHO Extracting zip files...
START /WAIT CMD /C "%BATFILES%\MarsMgrUnpacker.bat" %COUNTRY%
IF %ERRORLEVEL% NEQ 0 (
	ECHO ERROR!!!!
	ECHO Before continuing, manually run the MarsMgrUnpacker
	ECHO file as an administrator.
	CHOICE /C Y /M "Continue"
)
START /WAIT CMD /C "%BATFILES%\M225dnUnpacker.bat"
IF %ERRORLEVEL% NEQ 0 (
		ECHO ERROR!!!!
		ECHO Before continuing, manually run the M225dnUnpacker
		ECHO file as an administrator.
		CHOICE /C Y /M "Continue"
	)
VERIFY > NUL


:: **** OPEN POWER OPTIONS ****
ECHO.
ECHO Open Power Options....
POWERCFG.CPL
ECHO.
ECHO Continue after setting power options for balanced
ECHO mode to never put the computer to sleep.
CHOICE /C Y /M "Continue"
VERIFY > NUL



:: **** INSTALL MARS ****
ECHO.
ECHO Installing MARS...
IF %COUNTRY%==US (
	START /WAIT CMD /C "%SYSTEMDRIVE%\Admin\MARS-Upgrade\Version-11.14.1391.315\BO-Upgrade.bat"
	IF %ERRORLEVEL% NEQ 0 (
		ECHO ERROR!!!!
		ECHO Before continuing, run the MARS version
		ECHO 11.14.1391.315 BO-Upgrade.bat manually.
		CHOICE /C Y /M "Continue"
	)
)
IF %COUNTRY%==CA (
	START /WAIT CMD /C "%SYSTEMDRIVE%\Admin\MARS-Upgrade\Version-11.14.1391.242\BO-Upgrade.bat"

	IF %ERRORLEVEL% NEQ 0 (
		ECHO ERROR!!!!
		ECHO Before continuing, run the MARS version
		ECHO 11.14.1391.242 BO-Upgrade.bat manually.
		CHOICE /C Y /M "Continue"
	)
)
ECHO         Done!
VERIFY > NUL



:: **** UPDATE MARS LICENSE ****
ECHO.
ECHO Update MARS license...
REGEDIT.EXE "%MARSFILES%\MARSLicense3-3-2016\LOREALv11-04-RegSeria.L'OREAL32.reg"
IF %ERRORLEVEL% NEQ 0 (
	ECHO ERROR!!!!
	ECHO Before continuing, merge the MARS license manually.
	CHOICE /C Y /M "Continue"
) ELSE (
	ECHO         Done!
)
VERIFY > NUL



:: **** NOTIFIY EDIT BACK OFFICE LINK ****
ECHO.
ECHO Manually edit the MARS BACK OFFICE link.
ECHO Computer may take time to respond after clicking properties.
"%MARSFILES%\POS link.txt"
ECHO.
CHOICE /C Y /M "Has the MARS BACK OFFICE link been edited"
VERIFY > NUL



:: **** COPY STORE BACKGROUND ****
:: Currently CPD does not get a background.
IF %BRAND%==C (
	GOTO :EndBackground
)
ECHO.
ECHO Copying store background file...
COPY /V /Y "%SYSTEMDRIVE%\Admin\Backgrounds\%BRANDLONG%\eBOS5.hsc" "%PROGRAMFILES%\CEGID\Cegid Business\app\Mode\"
:EndBackground
VERIFY > NUL



:: **** NOTIFY SHARE SHARED FOLDER ****
ECHO.
ECHO Share the SHARED folder with Everyone and 
ECHO set Permission Level to Read/Write.
EXPLORER %SYSTEMDRIVE%
ECHO.
ECHO Has the SHARED folder been shared with Everyone
CHOICE /C Y /M "and the Permission Level set to Read/Write"
VERIFY > NUL



:: **** INSTALL PRINTER ****
ECHO.
ECHO Install printer.
START /WAIT CMD /C "%BATFILES%\InstallPrinter.bat" LUXEMGR
IF %ERRORLEVEL% NEQ 0 (
	ECHO ERROR!!!!
	ECHO Before continuing, manually install the
	ECHO printer software or drivers.
	CHOICE /C Y /M "Continue"
)
VERIFY > NUL



:: **** COPY / INSTALL FRENCH LANGUAGE PACK ****
IF %COUNTRY%==CA (
	ECHO.
	ECHO Creating French folder....
	IF NOT EXIST "%SYSTEMDRIVE%\Admin\French" (
		MKDIR "%SYSTEMDRIVE%\Admin\French"
		IF %ERRORLEVEL% NEQ 0 (
			ECHO ERROR!!!!
			ECHO Before continuing, manually create the 
			ECHO %SYSTEMDRIVE%\Admin\French folder.
			CHOICE /C Y /M "Continue"
		)
	)
	ECHO         Done!
	VERIFY > NUL
	ECHO Copying French language pack...
	COPY /V /Y "%MARSFILES%\French\windows6.1-kb2483139-x86-fr-fr_f57427487dfc2f49da67cac22480ab1f48983d22.exe" "%SYSTEMDRIVE%\Admin\French\"
	VERIFY > NUL
	ECHO.
	ECHO Installing French language pack.
	"%SYSTEMDRIVE%\Admin\French\windows6.1-kb2483139-x86-fr-fr_f57427487dfc2f49da67cac22480ab1f48983d22.exe"
	IF %ERRORLEVEL% NEQ 0 (
		ECHO ERROR!!!!
		ECHO Before continuing, install the French language pack.
		CHOICE /C Y /M "Continue"
	)
	ECHO         Done!
)



:: **** EXIT ****
ECHO.
ECHO **** Check for errors before exiting! ****
ECHO.
CHOICE /C Y /M "Exit"
CALL "%BATFILES%\EjectUSB.bat"
SET RETURN=0
GOTO :ExitFile


:ExitFile
ENDLOCAL & EXIT %RETURN%
