@ECHO OFF
REM Description: return a list of ports with access limits associated with a security group(s), quotes are required when querying multiple security groups.
REM Usage : getPorts.bat default sg-c15279bb
REM Usage : getPorts.bat default "sg-1503256f,sg-1103256b,sg-c4177fb9"
REM Return: 80      80
REM Return: 555     5555
REM Return: 162     162
REM Return: -1      -1
REM Return: 445     445
REM Return: 443     443
REM Return: etc etc etc
REM Needed: sort.exe(gnu32) sed.exe(gnu32)
IF %2 == "" EXIT /B 1
SET var_getPorts_targetProfile=%~1
shift
SET var_getPorts_targetGroupIDs=%~1
REM sed "s/None\tNone/1\t65535/;s/-1\t-1/1\t65535/;s/\t-1$/\tAll/"					Change non numeric port ranges to real ranges
REM sed ":a;N;$!ba;s/\nACCESSIBLE_FROM_SG\t/,/g;s/\nACCESSIBLE_FROM_IP\t/,/g"		Consolidate mutiple security groups and ip ranges to one line 
REM sed "s/,/\t/"																	Turn first comma per line from previous step into a tab
REM sort -n																			Sort complete output using gnu32 sort using "real" numerical value
aws ec2 describe-security-groups --profile "%var_getPorts_targetProfile%" --filters "Name=group-id,Values=%var_getPorts_targetGroupIDs%" --query "SecurityGroups[*].IpPermissions[*].{FromPort:FromPort,ToPort:ToPort,ipProtocol:IpProtocol,Accessible_From_IP:IpRanges[*].CidrIp,Accessible_From_SG:UserIdGroupPairs[*].GroupId}" --output text|sed "s/None\tNone/1\t65535/;s/-1\t-1/1\t65535/;s/\t-1$/\tAll/"|sed ":a;N;$!ba;s/\nACCESSIBLE_FROM_SG\t/,/g;s/\nACCESSIBLE_FROM_IP\t/,/g"|sed "s/,/\t\t/"|sort -n
