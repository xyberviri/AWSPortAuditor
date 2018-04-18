ECHO OFF

IF [%1] == [] (
ECHO no profile
EXIT /B 1
) ELSE (
SET var_getAuthtoken_MFAProfile=%1
)

IF [%2] == [] (
ECHO ERROR no MFA serial-number
EXIT /B 1
) ELSE (
SET var_getAuthtoken_MFASerial=%2
)

IF [%3] == [] (
ECHO NO OTP
EXIT /B 1
) ELSE (
SET var_getAuthtoken_MFAOTP=%3
)

aws sts get-session-token --profile="%var_getAuthtoken_MFAProfile%" --serial-number "%var_getAuthtoken_MFASerial%" --token-code %var_getAuthtoken_MFAOTP%
EXIT /B %ERRORLEVEL%