# s3scripts using curl and openssh 
Simple scripts to interact with a S3 bucket.

## Reqirements
This scripts use `curl` and `openssl` which must already exist

## settings.sh
In this version, the scripts always require that the file `settings.sh` to be present in the same directory as the scripts.
Mandatory parameters:
+ s3Bucket
+ s3Key
+ s3Secret 

Optional parameters:
+ curlProperties

## Remarks
If the aws credentials are not specified, the commands do not work.

The commands currently support ony signature version 2. So they work not in every AWS region. See (https://docs.aws.amazon.com/general/latest/gr/signature-version-2.html).

