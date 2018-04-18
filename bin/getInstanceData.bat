@ECHO OFF
setlocal enableextensions
REM Usage : getInstanceData.bat default i-0123456789
IF %2 == "" EXIT /B 1
SET var_getInstanceData_targetProfile=%1
shift
SET var_getInstanceData_targetInstanceID=%1
shift
SET extraDetail=%1


REM Get IPAddress
FOR /F "tokens=* USEBACKQ" %%B IN (`aws ec2 describe-instances --profile "%var_getInstanceData_targetProfile%" --output text --instance-ids %var_getInstanceData_targetInstanceID% --query "Reservations[*].Instances[*].{IP:PrivateIpAddress}"`) DO (
SET varIPAddress=%%B
)

REM GET Servername
FOR /F "tokens=* USEBACKQ" %%B IN (`getTag.bat %var_getInstanceData_targetProfile% %var_getInstanceData_targetInstanceID% Name`) DO (
SET varServerName=%%B
)

REM Get Security Groups
FOR /F "tokens=* USEBACKQ" %%B IN (`getSecurityGroups.bat %var_getInstanceData_targetProfile% %var_getInstanceData_targetInstanceID%^|sed ":a;N;$!ba;s/\n/,/g"`) DO (SET var_InstanceScurityGroups=%%B)




REM Fluff out some text about the server.
ECHO Server				%varServerName%
ECHO AWS-ID				%var_getInstanceData_targetInstanceID%
ECHO Server IP			%varIPAddress%
ECHO.

REM Get open ports from security groups

REM Brief report combines all ports into one output
REM Detailed report breaks up ports by security group.
IF [%extraDetail%] == [] (
		ECHO Ports opened by security groups "%var_InstanceScurityGroups%"
		ECHO From	To	Protocol	Allowed CIDR Range/Security Groups
		@call getPorts.bat %var_getInstanceData_targetProfile% "%var_InstanceScurityGroups%"
) ELSE (
	for /d %%B in (%var_InstanceScurityGroups%) do (
		REM ECHO The following ports are opened by security group "%%B"
		aws ec2 describe-security-groups --profile="%var_getInstanceData_targetProfile%" --filters="Name=group-id,Values=%%B"|jq -r ".SecurityGroups[].Description"|sed "s/^/Ports opened by %%B - /"
		ECHO From	To	Protocol	Allowed CIDR Range/Security Groups
		@call getPorts.bat %var_getInstanceData_targetProfile% "%%B"
		ECHO.
	)
)

REM AWS uses a software defined network, meaning resources can access resources by being a member of a security group.
REM Get Security groups referenced by our assigned security groups
SET var_InstanceOtherScurityGroups=
FOR /F "tokens=* USEBACKQ" %%B IN (`getOtherSecurityGroups.bat %var_getInstanceData_targetProfile% "%var_InstanceScurityGroups%"^|sed ":a;N;$!ba;s/\n/,/g"`) DO (SET var_InstanceOtherScurityGroups=%%B)

REM If we refrenced any security groups in our security groups, figure out what those groups give access to.
IF ["%var_InstanceOtherScurityGroups%"] NEQ [""] (
	ECHO =Referenced Security Groups===================
		for /d %%B in (%var_InstanceOtherScurityGroups%) do (
			aws ec2 describe-security-groups --profile="%var_getInstanceData_targetProfile%" --filters="Name=group-id,Values=%%B"|jq -r ".SecurityGroups[].Description"|sed "s/^/%%B\t\t/"
		)
)

ECHO --
REM Done
:getInstanceDataEof
EXIT /B 0