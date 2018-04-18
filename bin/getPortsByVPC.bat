@ECHO OFF
IF %2 == "" EXIT /B 1
SET var_getPortsByVPC_targetProfile=%1
shift
SET var_getPortsByVPC_targetVPC=%~1

FOR /F "tokens=* USEBACKQ" %%B IN (`aws ec2 describe-instances --profile "%var_getPortsByVPC_targetProfile%" --filters "Name=vpc-id,Values=%var_getPortsByVPC_targetVPC%" --output text --query "Reservations[*].Instances[*].SecurityGroups[*].{GroupId:GroupId}" ^|sort -n ^|uniq ^|sed ":a;N;$!ba;s/\n/,/g"`) DO (
SET var_getPortsByVPC_targetSecurityGroups=%%B
)

 	ECHO From	To	Protocol
aws ec2 describe-security-groups --profile "%var_getPortsByVPC_targetProfile%" --filters "Name=group-id,Values=%var_getPortsByVPC_targetSecurityGroups%" --query "SecurityGroups[*].IpPermissions[*].{FromPort:FromPort,ToPort:ToPort,ipProtocol:IpProtocol}" --output text|sed "s/None\tNone/1\t65535/;s/-1\t-1/1\t65535/;s/\t-1$/\tAll/"|sed ":a;N;$!ba;s/\nACCESSIBLE_FROM_SG\t/,/g;s/\nACCESSIBLE_FROM_IP\t/,/g"|sed "s/,/\t\t/"|sort -n|uniq
