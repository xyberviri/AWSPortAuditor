@ECHO OFF
REM https://aws.amazon.com/premiumsupport/knowledge-center/authenticate-mfa-cli/
REM return the serial number on my MFA profile in AWS, this was used to figure out what i should be typing as my serial number.
IF [%1] == [] (
SET var_getMFASerial_MFAProfile=default
) ELSE (
SET var_getMFASerial_MFAProfile=%1
)

aws iam list-mfa-devices --profile="%var_getMFASerial_MFAProfile%"|jq -r ".MFADevices[0].SerialNumber"
EXIT /B %ERRORLEVEL%