# s3scripts using aws-cli
Simple scripts to interact with a S3 bucket.

## Reqirements
This scripts use the common aws-cli which must already exist

## settings.sh
In this version, the scripts always require that the file `settings.sh` to be present in the same directory as the scripts.
Mandatory parameters:
+ s3Bucket

Optional parameters:
+ s3Key
+ s3Secret 

## Remarks
If the aws credentials are not specified, it is up to the aws-cli to get them.

