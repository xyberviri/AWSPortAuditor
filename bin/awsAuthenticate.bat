@ECHO OFF

IF [%1] == [] (
	ECHO no profile
	EXIT /B 1
) ELSE (
	SET var_awsAuthenticate_MFAProfile=%1
)

IF [%2] == [] (
	ECHO NO MFA Serial find it in the consol or use "getMFASerial.bat %var_awsAuthenticate_MFAProfile%"
	EXIT /B 1
) ELSE (
	SET var_awsAuthenticate_MFASerial=%~2
)

IF [%3] == [] (
	ECHO NO OTP
	EXIT /B 1
) ELSE (
	SET var_awsAuthenticate_MFAOTP=%3
)

IF [%4] == [] (
	SET "var_awsAuthenticate_MFAAuthProfile=%var_awsAuthenticate_MFAProfile%-auth"
) ELSE (
	SET var_awsAuthenticate_MFAAuthProfile=%4
)

call getAuthToken.bat %var_awsAuthenticate_MFAAuthProfile% "%var_awsAuthenticate_MFASerial%" %var_awsAuthenticate_MFAOTP%>%var_awsAuthenticate_MFAProfile%.session
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%

FOR /F "tokens=* USEBACKQ" %%F IN (`jq -r ".Credentials.AccessKeyId" %var_awsAuthenticate_MFAProfile%.session`) DO (
REM	SET var_AccessKeyId=%%F
	aws configure --profile %var_awsAuthenticate_MFAProfile% set aws_access_key_id %%F
	IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%
)
FOR /F "tokens=* USEBACKQ" %%F IN (`jq -r ".Credentials.SecretAccessKey" %var_awsAuthenticate_MFAProfile%.session`) DO (
REM	SET var_SecretAccessKey=%%F
	aws configure --profile %var_awsAuthenticate_MFAProfile% set aws_secret_access_key %%F
	IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%
)
FOR /F "tokens=* USEBACKQ" %%F IN (`jq -r ".Credentials.SessionToken" %var_awsAuthenticate_MFAProfile%.session`) DO (
REM	SET var_SessionToken=%%F
	aws configure --profile %var_awsAuthenticate_MFAProfile% set aws_session_token %%F
	IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%
)
DEL /Q /F %var_awsAuthenticate_MFAProfile%.session
EXIT /B 0