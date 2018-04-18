@ECHO OFF
REM Description: Return a list of RDS instances, searched using any value (uses grep)
REM Usage : getSecurityGroupAssociations.bat default sg-1234567
IF %1 == "" EXIT /B 1
SET targetProfile=%1
shift
SET targetGroupIDs=%1

IF [%1] == [] (
aws rds --profile "%targetProfile%" describe-db-instances --query "DBInstances[*].{ID:DBInstanceIdentifier,Address:Endpoint.Address,GroupID:VpcSecurityGroups[*].VpcSecurityGroupId}" --output text|sed ":a;N;$!ba;s/\nGROUPID/\t/g;s/\t\t/\t/g"
) ELSE (
aws rds --profile "%targetProfile%" describe-db-instances --query "DBInstances[*].{ID:DBInstanceIdentifier,Address:Endpoint.Address,GroupID:VpcSecurityGroups[*].VpcSecurityGroupId}" --output text|sed ":a;N;$!ba;s/\nGROUPID/\t/g;s/\t\t/\t/g"|grep %targetGroupIDs%
)