# s3scripts using aws-cli
Simple scripts to interact with a S3 bucket.

## Reqirements
This scripts use the common aws-cli which must already exist  

## settings.sh
In this version, the scripts no not require the file `settings.sh` to be present in the same directory as the scripts.
When using role based authentication, only the s3Bucket is required. This can also be set as environment variable: `export s3Bucket=<bucketname>`  
You can configure an alternative aws command (eg. when using Git Bash on Windows, the aws command is `aws.cmd` )

Optional parameters:
+ s3Bucket
+ s3Key
+ s3Secret
+ s3AWSCMD

Additional parameters for the settings scripts:
+ s3SettingsBucket (when omitted, s3Bucket is used)
+ s3SettingPath (defaults to `settings/$(aws sts get-caller-identity --query UserId --output text)`)

## Remarks
If the aws credentials are not specified, it is up to the aws-cli to get them.

