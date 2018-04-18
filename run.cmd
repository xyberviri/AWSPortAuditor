@ECHO OFF
SET AWSPortAuditorRoot=%~dp0
PUSHD bin
@CALL AuditAWSPortAccess.bat
POPD