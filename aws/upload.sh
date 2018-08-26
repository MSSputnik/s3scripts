#!/bin/bash
scriptVersion=201602081130

sourcefile=$1
if [ -z "$sourcefile" ]
then
  echo No source file specified. Nothing to upload.
  exit 3
fi

SCRIPT_DIR=$(dirname $(readlink -f $0))
if [ ! -e "${SCRIPT_DIR}/settings.sh" ]
then 
  echo No settings file found. Plesae crate a settings file ${SCRIPT_DIR}/settings.sh
  echo The settings file must contain the parameter s3Bucket, s3Key, s3Secret
  exit 10
fi
. ${SCRIPT_DIR}/settings.sh

filename=`basename ${sourcefile}`
directory=$2
if [ -z "$directory" ]
then
  echo no upload directory specifid. Upload to root
else
  if [ ! "${directory: -1}" == "/" ]
  then
    directory=${directory}/
  fi
fi

permission=$3
if [ "$permission" == "public" ]
then
  permheader="--acl public"
else
  permheader=""
fi

if [ "$s3Key" ]; then
  export AWS_ACCESS_KEY_ID=$s3Key
fi
if [ "$s3Secret" ]; then
  export AWS_SECRET_ACCESS_KEY=$s3Secret
fi


resource="/${s3Bucket}/${directory}${filename}"
echo SourceFile: $sourcefile
echo Filename:   $filename
echo Resource:   $resource
echo Destination Dir: $directory


if [ -e $sourcefile ]; then
  echo Upload $filename
  aws s3 cp "${sourcefile}" "s3:/${resource}" ${permheader}
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

