#!/bin/bash
scriptVersion=201811081000

sourcefile=$1
if [ -z "$sourcefile" ]
then
  echo No source file specified. Nothing to download.
  exit 3
fi


SCRIPT_DIR=$(dirname $(readlink -f $0))
if [ -e "${SCRIPT_DIR}/settings.sh" ]; then
  . ${SCRIPT_DIR}/settings.sh
fi

if [ -z "$azBucket" ]; then
  echo No bucket name defined.
  echo Set env variable azBucket or create a settings file ${SCRIPT_DIR}/settings.sh
  echo The settings file must contain the parameter s3Bucket
  echo Optional are AZURE_STORAGE_ACCOUNT and AZURE_STORAGE_KEY
  exit 10
fi

filename=`basename ${sourcefile}`
sourcedir=`dirname ${sourcefile}`
directory=$2
if [ -n "$directory" ]
then
  # directory is not empty
  if [ ! -d "$directory" ]
  then
    if [ -a "$directory" ]
    then 
      echo
      echo "***************************************************************************************"
      echo ERROR: Destination directory $directory exist and it is not a directory. Please correct.
      echo "***************************************************************************************"
      echo
      exit 3
    else
     mkdir -p "$directory"
     if [ ! -d "$directory" ]
     then
       echo
       echo "***************************************************************************************"
       echo ERROR: Create destination directory $directory failed. Please correct.
       echo "***************************************************************************************"
       echo
       exit 3
     else
       directory=${directory}/
     fi
    fi
  else
    directory=${directory}/
  fi
fi


destfile="${directory}${filename}"

if [ "$AZURE_STORAGE_KEY" ]; then
  ACCESS_KEY="--account-key $AZURE_STORAGE_KEY"
fi
if [ "$AZURE_STORAGE_ACCOUNT" ]; then
  ACCESS_ACC="--account-name $AZURE_STORAGE_ACCOUNT"
fi
if [ "$resource" ]; then
  DIR="--path $resource"
fi

sourcefile=${sourcefile//\//\\}

echo SourceFile: ${sourcefile}
echo Filename:   $destfile

az storage file download --path $sourcefile --dest $destfile --share-name $azBucket $ACCESS_ACC $ACCESS_KEY --output table 2>/dev/null 
if [ $? -eq 0 ]
then 
  
echo Download Success 
else
  echo ERROR downloading file
  exit 2
fi

