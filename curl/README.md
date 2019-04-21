# s3scripts using curl and openssh 
Simple scripts to interact with a S3 bucket.

Unfortunately the settings scripts are not yet created for curl.

## Reqirements
This scripts use `curl` and `openssl` which must already exist

## settings.sh
In this version, the scripts no not require the file `settings.sh` to be present in the same directory as the scripts.
When using role based authentication, only the s3Bucket is required. This can also be set as environment variable: `export s3Bucket=<bucketname>`

Optional parameters:
+ s3Bucket
+ s3Key
+ s3Secret 
+ curlProperties

## Remarks
If the aws credentials are not specified, the commands tries to get temporary access credentials.

The commands currently support ony signature version 2. So they work not in every AWS region. See https://docs.aws.amazon.com/general/latest/gr/signature-version-2.html .

