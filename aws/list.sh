#!/bin/bash
scriptVersion=201602081115
sourcefile=$1

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
echo List:       $resource

aws s3 ls "s3:/${resource}" 
if [ $? -eq 0 ]
then
  echo List success
else
  echo ERROR List directory
  exit 2
fi

