#!/bin/bash
scriptVersion=201811080900

sourcefile=$1
if [ -z "$sourcefile" ]
then
  echo No source file specified. Nothing to upload.
  exit 3
fi

SCRIPT_DIR=$(dirname $(readlink -f $0))
if [ -e "${SCRIPT_DIR}/settings.sh" ]; then
  . ${SCRIPT_DIR}/settings.sh
fi

if [ -z "$azBucket" ]; then
  echo No bucket name defined.
  echo Set env variable auBucket or create a settings file ${SCRIPT_DIR}/settings.sh
  echo The settings file must contain the parameter azBucket
  echo Optional are AZURE_STORAGE_ACCOUNT and AZURE_STORAGE_KEY
  exit 10
fi

filename=`basename ${sourcefile}`
directory=$2
if [ -z "$directory" ]
then
  echo no upload directory specifid. Upload to root
else
  echo "upload to $director"
  if [ "${directory: -1}" == "/" ]
  then
    directory=${directory::-1}
  fi
fi

permission=$3
if [ "$permission" == "public" ]
then
  permheader="--acl public"
else
  permheader=""
fi

if [ "$AZURE_STORAGE_KEY" ]; then
  ACCESS_KEY="--account-key $AZURE_STORAGE_KEY"
fi
if [ "$AZURE_STORAGE_ACCOUNT" ]; then
  ACCESS_ACC="--account-name $AZURE_STORAGE_ACCOUNT"
fi

directory=${directory//\//\\}
if [ "$directory" ]; then
  DIR="--path $directory"
fi


resource="${directory}${filename}"
echo SourceFile: $sourcefile
echo Filename:   $filename
echo Resource:   $resource
echo Destination Dir: $directory

if [ "$directory" ]; then
echo "Check if destination directory $directory exists."
az storage directory exists --name $directory --share-name $azBucket $ACCESS_ACC $ACCESS_KEY | grep '"exists": true'
erg=$?
if [ $erg -ne 0 ]; then
  echo "Directory missing. Create..."
  subdir=""
  for d in ${directory//\\/ }; do
    subdir=${subdir}${d}
    echo "Subdir $subdir"
    az storage directory exists --name $subdir --share-name $azBucket $ACCESS_ACC $ACCESS_KEY | grep '"exists": true'
    erg=$?
    if [ $erg -ne 0 ]; then
      echo "Create directory $subdir"
      az storage directory create --name $subdir --share-name $azBucket $ACCESS_ACC $ACCESS_KEY | grep '"created": true'
      erg=$?
      if [ $erg -ne 0 ]; then
        echo "ERROR: Faild to create missing directory"
        exit 1
      fi
    fi
    subdir=${subdir}\\
  done
fi
fi

if [ -e $sourcefile ]; then
  echo Upload $filename
#  az storage blob upload \
#    --container-name $azBucket \
#    --name $resource \
#    --file $sourcefile $ACCESS_ACC $ACCESS_KEY
  az storage file upload --share-name $azBucket \
  --source $sourcefile $DIR $ACCESS_ACC $ACCESS_KEY
  if [ $? -eq 0 ]; then
    echo Upload success 
    exit 0
  else
    echo ERROR uploading file
    exit 2
  fi
else
  echo $sourcefile does not exist. Can not upload.
  exit 1
fi

