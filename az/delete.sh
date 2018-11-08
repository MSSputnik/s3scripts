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

if [ "${sourcefile: -1}" == "/" ]; then
  echo "Delete Direcory"
  deldir=1
fi 

sourcefile="${sourcefile//\//\\}"

if [ "$AZURE_STORAGE_KEY" ]; then
  ACCESS_KEY="--account-key $AZURE_STORAGE_KEY"
fi
if [ "$AZURE_STORAGE_ACCOUNT" ]; then
  ACCESS_ACC="--account-name $AZURE_STORAGE_ACCOUNT"
fi
if [ "$resource" ]; then
  DIR="--path $resource"
fi

if [ "$deldir" == "1" ]; then
  echo Directory: $sourcefile
  az storage directory delete --name $sourcefile --share-name $azBucket $ACCESS_ACC $ACCESS_KEY  2>&1 | grep '"deleted": true'  
  erg=$?
else
  echo File: $sourcefile
  az storage file delete --path $sourcefile --share-name $azBucket $ACCESS_ACC $ACCESS_KEY --output table 2>/dev/null
  erg=$?
fi
if [ $erg -eq 0 ]
then
  echo delete success
else
  echo ERROR delete file
  exit 2
fi

