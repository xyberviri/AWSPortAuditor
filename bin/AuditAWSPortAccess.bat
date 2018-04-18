@ECHO OFF
REM		AWS Port Auditor
SET var_AuditStartTime=%TIME%

REM	Figure out what profiles we can audit.
:startOfAuditor
IF [%1] == [] (
	ECHO No profile was specified on launch, your ~/aws/config has the following profiles.
	FOR /F "tokens=* USEBACKQ" %%B IN (`getProfileList.bat`) DO ( 
	ECHO     %%B 
	)
	ECHO.
	ECHO Type the name of a profile you wish to audit.
	SET /p var_Profile=:
) ELSE (
	SET var_Profile=%1
)

IF [%var_Profile%] == [] ( GOTO startOfAuditor )


REM Everything after this line will require us to be authenticated to AWS
REM Check if users has a valid access key set.
@call checkAuthStatus.bat %var_Profile%
IF %ERRORLEVEL% NEQ 0 (
ECHO You weren't able to authenticate, something went wrong or you didn't follow directions.
ECHO This application will now close.
PAUSE
EXIT /B 1
)


REM Figure out what region were running in
FOR /F "tokens=* USEBACKQ" %%F IN (`aws configure get region --profile="%var_Profile%"`) DO (SET var_TargetRegionToAudit=%%F)


REM Target VPC IDs to audit
IF [%2] == [] ( 
FOR /F "tokens=* USEBACKQ" %%F IN (`aws ec2 describe-vpcs --profile "%var_Profile%" --output text --query "Vpcs[*].{VpcId:VpcId}" ^|sed ":a;N;$!ba;s/\n/,/g"`) DO (SET var_VPCids=%%F)
) ELSE (
SET var_VPCids=%2
)

REM Count VPC
SET _var_vpcCount=0
for /d %%B in (%var_VPCids%) do ( set /a "_var_vpcCount=_var_vpcCount+1" )



REM Optional report file name
IF [%3] == [] ( 
SET varReportFile=report.txt
) ELSE (
SET varReportFile=%3
)


REM What your expecting more? this is baby uses .bat and some gnu32 utilites.
REM Last chance to cancel the app, if you got this far your authenticated and ready to rock.
REM some pretty fluff
ECHO.
ECHO    Target Profile: %var_Profile%
ECHO    Target Region : %var_TargetRegionToAudit%
ECHO    Target VPCs   : %var_VPCids%
ECHO    Output file   : %varReportFile%
ECHO.
ECHO Ready to fire!
pause


REM Gather instance id's to query from supplied vpc id's
ECHO Gathering instance Id's
aws ec2 describe-instances --profile "%var_Profile%" --filters "Name=vpc-id,Values=%var_VPCids%" --output text --query "Reservations[*].Instances[*].{InstanceId:InstanceId}">instanceIDs.txt

SET _var_instanceCount=0
for /F "tokens=*" %%B in (instanceIDs.txt) do ( set /a "_var_instanceCount=_var_instanceCount+1" )
ECHO Found %_var_instanceCount% instances in %_var_vpcCount% VPC(s)

REM more fluff
ECHO Open port report>%varReportFile%
ECHO Audited Region               : %var_TargetRegionToAudit%>>%varReportFile%
ECHO Virtual Private Cloud Id's   : %var_VPCids%>>%varReportFile%
ECHO Audit Date                   : %DATE% %var_AuditStartTime%>>%varReportFile%
ECHO.>>%varReportFile%
ECHO Audited VPC(s) %_var_vpcCount% total>>%varReportFile%

REM Dump names of VPCs to report.
for /d %%B in (%var_VPCids%) do (
@CALL getTag.bat %var_Profile% %%B Name >>%varReportFile%
@CALL getPortsByVPC.bat %var_Profile% %%B > %%B-summary.txt
)
REM Dump a summary of all the security groups so we can track down ports easier.
@CALL getSGSummary.bat %var_Profile% > %var_Profile%-SecurityGroupSummary.txt
ECHO.>>%varReportFile%
ECHO.>>%varReportFile%

REM gather data on each instance and spit out to report file.
for /F "tokens=*" %%A in (instanceIDs.txt) do (
	ECHO Gathering Data for %%A
	ECHO.>>%varReportFile%
@CALL getInstanceData.bat %var_Profile% %%A true >>%varReportFile%
)

REM Done, clean up any extra files we created.
REM remove temp instanceID.txt file.
SET var_AuditEndTime=%TIME%
@DEL /F /S /Q instanceIDs.txt > nul 2>&1

REM open the report file for the end users.
ECHO. Complete!
ECHO. Please See '%varReportFile%' for the results
ECHO. Audit Start: %var_AuditStartTime%
ECHO. Audit End  : %var_AuditEndTime%
ECHO. Auditor will now close.
start notepad %varReportFile%
for /d %%B in (%var_VPCids%) do (
start notepad %%B-summary.txt
)
PAUSE
