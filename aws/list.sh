#!/bin/bash
scriptVersion=201808261115
sourcefile=$1

SCRIPT_DIR=$(dirname $(readlink -f $0))
if [ -e "${SCRIPT_DIR}/settings.sh" ]; then
  . ${SCRIPT_DIR}/settings.sh
fi

if [ -z "$s3Bucket" ]; then
  echo No bucket name defined.
  echo Set env variable s3Bucket or create a settings file ${SCRIPT_DIR}/settings.sh
  echo The settings file must contain the parameter s3Bucket
  echo Optional are s3Key, s3Secret, curlProperties
  exit 10
fi

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

