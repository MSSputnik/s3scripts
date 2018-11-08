#!/bin/bash
scriptVersion=201811080845
sourcefile=$1

SCRIPT_DIR=$(dirname $(readlink -f $0))
if [ -e "${SCRIPT_DIR}/settings.sh" ]; then
  . ${SCRIPT_DIR}/settings.sh
fi

if [ -z "$azBucket" ]; then
  echo No bucket name defined.
  echo Set env variable azBucket or create a settings file ${SCRIPT_DIR}/settings.sh
  echo The settings file must contain the parameter auBucket
  echo Optional are AZURE_STORAGE_ACCOUNT and AZURE_STORAGE_KEY 
  exit 10
fi

resource="${sourcefile}"

if [ "$AZURE_STORAGE_KEY" ]; then
  ACCESS_KEY="--account-key $AZURE_STORAGE_KEY"
fi
if [ "$AZURE_STORAGE_ACCOUNT" ]; then
  ACCESS_ACC="--account-name $AZURE_STORAGE_ACCOUNT"
fi
if [ "$resource" ]; then
  DIR="--path $resource"
fi

echo SourceFile: $sourcefile
echo List:       $resource

#az storage blob list --container-name $azBucket --output table  $ACCESS_ACC $ACCESS_KEY
az storage file list --share-name $azBucket $DIR $ACCESS_ACC $ACCESS_KEY --output table 2>/dev/null
if [ $? -eq 0 ]
then
  echo List success
else
  echo ERROR List directory
  exit 2
fi

