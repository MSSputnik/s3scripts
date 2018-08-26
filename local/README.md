# s3scripts using curl and openssh 
Simple scripts to interact with a S3 bucket.

## Reqirements
This scripts use local file system commands like `ls` and `cp`.

## settings.sh
In this version, the scripts always require that the file `settings.sh` to be present in the same directory as the scripts.
Mandatory parameters:
+ repository

Unsupported parameters:
+ s3Bucket
+ s3Key
+ s3Secret 

## Remarks
Currently only get.sh and list.sh is implemented. The other 2 commands just tell you that they are not yet implemented.

