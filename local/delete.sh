#!/bin/bash
#Version=201511262100
sourcefile=$1
if [ -z "$sourcefile" ]
then
  echo No file specified. Nothing to delete.
  exit 3
fi

#We just give this error message. We did not modify the script yet!
echo "ERROR: DELETE not supported on local share"
exit 1


SCRIPT_DIR=$(dirname $(readlink -f $0))
if [ ! -e "${SCRIPT_DIR}/settings.sh" ]
then
  echo No settings file found. Plesae crate a settings file ${SCRIPT_DIR}/settings.sh
  echo The settings file must contain the parameter s3Bucket, s3Key, s3Secret
  exit 10
fi
. ${SCRIPT_DIR}/settings.sh

resource="/${s3Bucket}/${sourcefile}"
#dateValue=`date -R`
#stringToSign="DELETE\n\n${contentType}\n${dateValue}\n${resource}"
#signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${s3Secret} -binary | base64`

echo SourceFile: $sourcefile
echo Delete:     $resource

#curl -X DELETE -f \
#  $curlProperties \
#  -H "Host: ${s3Bucket}.s3.amazonaws.com" \
#  -H "Date: ${dateValue}" \
#  -H "Content-Type: ${contentType}" \
#  -H "Authorization: AWS ${s3Key}:${signature}" \
#  https://${s3Bucket}.s3.amazonaws.com/${sourcefile}
#echo aws s3 rm "s3:/${resource}"
aws s3 rm "s3:/${resource}"
if [ $? -eq 0 ]
then
  echo Delete success
else
  echo ERROR deleting file
  exit 2
fi

