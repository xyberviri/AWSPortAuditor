@ECHO OFF
REM return a list of profiles with a -auth] name
grep "\[profile" %userprofile%/.aws/config|grep \-auth\]|sed -e "s/\[profile\s//g;s/\]//g;s/\-auth//g"