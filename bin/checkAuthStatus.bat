@ECHO OFF
REM Check if the user is authenticated and if not ask them to log in.
IF %1 == "" EXIT /B 1
SET targetProfile=%1
aws iam list-mfa-devices --profile="%targetProfile%" 1>NUL
IF %ERRORLEVEL% EQU 0 ( GOTO userSessionValid )

ECHO Looks like your session token isn't valid, let's try to login.

:promptUserForCreds
@call promptUserToLogin.bat
IF %ERRORLEVEL% NEQ 0 ( GOTO promptUserForCreds )

:userSessionValid
EXIT /B %ERRORLEVEL%