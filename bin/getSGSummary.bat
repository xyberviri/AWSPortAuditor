@ECHO OFF
IF %1 == "" EXIT /B 1
SET var_getSGSummary_targetProfile=%1

FOR /F "tokens=* USEBACKQ" %%B IN (`aws ec2 describe-instances --profile "%var_getSGSummary_targetProfile%"  --output text --query "Reservations[*].Instances[*].SecurityGroups[*].{GroupId:GroupId}" ^|sort -n ^|uniq ^|sed ":a;N;$!ba;s/\n/,/g"`) DO (
SET var_getSGSummary_targetSecurityGroups=%%B
)

aws ec2 describe-security-groups --profile "%var_getSGSummary_targetProfile%" --filters "Name=group-id,Values=%var_getSGSummary_targetSecurityGroups%" --query "SecurityGroups[].[GroupId,VpcId,Tags[?Key==`Name`].Value[] | [0],GroupName,IpPermissions[*].{FromPort:FromPort,ToPort:ToPort,ipProtocol:IpProtocol}]" --output text
