@ECHO OFF
REM Return a list of profiles setup for AWS.
grep "\[default\]" %userprofile%/.aws/config|sed -e "s/\[//g;s/\]//g"
grep "\[profile" %userprofile%/.aws/config|grep -v \-auth]|sed -e "s/\[profile\s//g;s/\]//g"