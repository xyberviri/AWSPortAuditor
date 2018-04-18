@ECHO OFF
REM Return a list of security groups referenced by this security group.
IF %2 == "" EXIT /B 1
SET targetProfile=%~1
shift
SET targetGroupIDs=%~1

aws ec2 describe-security-groups --profile "%targetProfile%" --filters "Name=group-id,Values=%targetGroupIDs%" --query "SecurityGroups[*].IpPermissions[*].UserIdGroupPairs[*].GroupId" --output text|sed "s/\t/\r\n/g"|sort|uniq