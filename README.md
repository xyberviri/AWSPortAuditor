# AWSPortAuditor
A collection of scripts created to simplify the auditing of "open" ports in AWS security groups.

Download and execute run.cmd

you will be prompted to select a profile to run this against. 


# To configure MFA support

This tool supports MFA by way of the `sts get-session-token` api. Ideally your "real" aws cli key only has access to the sts:GetSessionToken api. Using that api this requests a set of temporary credentials and then updates your "<home>\.aws\credentials" file

First open your "<home>\.aws\config" file and an duplicate any existing named  profile, a named profile is one that is identified by the [profile name] heading. Append -auth to the duplicated profile:
  
Original:

    [default]
    output = json
    region = us-east-1
    
    [profile prod]
    output = json
    region = us-east-1

New:

    [default]
    output = json
    region = us-east-1
    
    [profile prod]
    output = json
    region = us-east-1
    
    [profile prod-auth]
    output = json
    region = us-east-1

Next edit your "<home>\.aws\credentials" the same way:
  
  Original:

    [default]
    aws_access_key_id=AKIAIOSFODNN7EXAMPLE
    aws_secret_access_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

    [prod]
    aws_access_key_id=AKIAIOSFODNN7EXAMPLE
    aws_secret_access_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

  
  New:

    [default]
    aws_access_key_id=AKIAIOSFODNN7EXAMPLE
    aws_secret_access_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

    [prod]
    aws_access_key_id=AKIAIOSFODNN7EXAMPLE
    aws_secret_access_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
    
    [prod-auth]
    aws_access_key_id=AKIAIOSFODNN7EXAMPLE
    aws_secret_access_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

From this point your named-auth profile will be your "original" profile and your named profile will use MFA credentials. After MFA authentication for the first time you will notice that the "named" non -auth profile will now have a `AWS_SESSION_TOKEN` field, this is normal.

When prompted to authenticate your MFA Serial, this is the full arn for your Assigned MFA device, this can be found under the "security credentials" tab below the last login field. It is similar to your User ARN except it has ":mfa/" instead of ":user/" in it. 

# Configuration of your IAM policies is outside the scope of support.
For information about restricting api access to MFA verfied sessions please read the following documents:

https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_mfa_configure-api-require.html
https://aws.amazon.com/premiumsupport/knowledge-center/authenticate-mfa-cli/


Basically both aws:MultiFactorAuthAge & aws:MultiFactorAuthPresen conditions should be  present on all of your apis that you want to protect with the only access to your non MFA api key being "sts getsessiontoken", speak with your AWS SYSOPS Administrator.

Additional note: the root account can not be MFA protected.

