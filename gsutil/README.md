# s3scripts using gsutil 
Simple scripts to interact with a google cloud storage.

Unfortunately the settings scripts are not yet created for gsutil.

## Reqirements
This scripts use the common gsutil which must already exist

## settings.sh
In this version, the scripts no not require the file `settings.sh` to be present in the same directory as the scripts.
When using role based authentication, only the bucket name is required. This can also be set as environment variable: `export s3Bucket=<bucketname>`

Optional parameters:
+ s3Bucket

## Remarks
If the cloud credentials are not specified, it is up to the gsutil to get them. 

