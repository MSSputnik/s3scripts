#!/bin/bash
#Version=201512251845
sourcefile=$1
#if [ -z "$sourcefile" ]
#then
#  echo No directory specified. Nothing to list.
#  exit 3
#fi

SCRIPT_DIR=$(dirname $(readlink -f $0))
if [ ! -e "${SCRIPT_DIR}/settings.sh" ]
then
  echo No settings file found. Plesae crate a settings file ${SCRIPT_DIR}/settings.sh
  echo The settings file must contain the parameter s3Bucket, s3Key, s3Secret
  exit 10
fi
. ${SCRIPT_DIR}/settings.sh

resource="${repository}/${sourcefile}"
#dateValue=`date -R`
#stringToSign="DELETE\n\n${contentType}\n${dateValue}\n${resource}"
#signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${s3Secret} -binary | base64`

echo SourceFile: $sourcefile
echo List:       $resource

ls -l "${resource}"
if [ $? -eq 0 ]
then
  echo List success
else
  echo ERROR List directory
  exit 2
fi

