@ECHO OFF
REM Usage : getSecurityGroups.bat default i-0123456789
REM Return: sg-12345678
IF %2 == "" EXIT /B 1
SET targetProfile=%1
shift
SET targetInstanceIDs=%1
aws ec2 describe-instances --profile "%targetProfile%" --output text --instance-ids %targetInstanceIDs% --query "Reservations[*].Instances[*].SecurityGroups[*].{GroupId:GroupId}"
EXIT /B %ERRORLEVEL%