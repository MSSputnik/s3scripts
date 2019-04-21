# s3scripts using Azure cli
Simple scripts to interact with a az file share, not blob store.  

Unfortunately the settings scripts are not yet created for the Azure Cli.

## Reqirements
This scripts use the common az cli which must already exist

## settings.sh
In this version, the scripts no not require the file `settings.sh` to be present in the same directory as the scripts.
When using role based authentication, only the azBucket is required. This can also be set as environment variable: `export azBucket=<bucketname>`

Optional parameters:
+ azBucket
+ AZURE_STORAGE_ACCOUNT 
+ AZURE_STORAGE_KEY

## Remarks
If the az credentials are not specified, it is up to the az cli to get them.

