@ECHO OFF

:awsPromptForCredentials
IF [%1] == [] (
ECHO Enter a profile to authenticate against.
ECHO The following profiles are setup to work with this utility.
@CALL getMFAProfileList.bat
	SET /p var_PromptForProfile=:
) ELSE (
	SET var_PromptForProfile=%1
)

IF [%var_PromptForProfile%] == [] ( GOTO awsPromptForCredentials )

:awsPromptForMFASerial
ECHO Enter the serial number for your MFA device.
	SET /p var_PromptForMFASerial=:
IF [%var_PromptForMFASerial%] == [] ( GOTO awsPromptForMFASerial )

:awsPromptForMFAOTP
ECHO Enter the one time pass from your MFA device.
	SET /p var_PromptForMFAOTP=:
IF [%var_PromptForMFAOTP%] == [] ( GOTO awsPromptForMFAOTP )

@call awsAuthenticate.bat %var_PromptForProfile% "%var_PromptForMFASerial%" %var_PromptForMFAOTP%
IF %ERRORLEVEL% NEQ 0 (
	set /p "var_PromptTryAgain=Try again (Y/N)?"
	if /i ["%var_PromptTryAgain:~,1%"] == ["Y"] ( GOTO awsPromptForCredentials )
) ELSE (
	ECHO. Success, you are now authenticated until your session token expires.
)

:Eof
EXIT /B %ERRORLEVEL%