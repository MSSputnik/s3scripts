#!/bin/bash
scriptVersion=201602081130
sourcefile=$1
if [ -z "$sourcefile" ]
then
  echo No file specified. Nothing to delete.
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

resource="/${s3Bucket}/${sourcefile}"

if [ "$s3Key" ]; then
  export AWS_ACCESS_KEY_ID=$s3Key
fi
if [ "$s3Secret" ]; then
  export AWS_SECRET_ACCESS_KEY=$s3Secret
fi

echo SourceFile: $sourcefile
echo Delete:     $resource

aws s3 rm "s3:/${resource}"
if [ $? -eq 0 ]
then
  echo Delete success
else
  echo ERROR deleting file
  exit 2
fi

