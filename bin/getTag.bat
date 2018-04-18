@ECHO OFF
IF %2 == "" EXIT /B 1
SET targetProfile=%1
shift
SET targetInstanceIDs=%1
shift
set targetTag=%1
aws ec2 describe-tags --profile "%targetProfile%" --filters "Name=key,Values=%targetTag%" "Name=resource-id,Values=%targetInstanceIDs%"|jq -r .Tags[].Value
EXIT /B %ERRORLEVEL%
