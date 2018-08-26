#!/bin/bash
#Version=201512251845

sourcefile=$1
if [ -z "$sourcefile" ]
then
  echo No source file specified. Nothing to upload.
  exit 3
fi

#We just give this erro message. We did not modify the script yet!
echo "ERROR: UPLOAD not supported on local share"
exit 1

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
#  permheader="x-amz-acl: public-read"
#  permsig="x-amz-acl:public-read\n"
else
  permheader=""
#  permheader="x-amz-acl: private"
#  permsig="x-amz-acl:private\n"
fi

resource="/${s3Bucket}/${directory}${filename}"
#contentType="application/x-compressed-tar"
#dateValue=`date -R`
#stringToSign="PUT\n\n${contentType}\n${dateValue}\n${permsig}${resource}"
#signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${s3Secret} -binary | base64`
echo SourceFile: $sourcefile
echo Filename:   $filename
echo Resource:   $resource
echo Destination Dir: $directory


if [ -e $sourcefile ]
then
  echo Upload $filename
#curl -X PUT  -T "${sourcefile}" \
#  $curlProperties \
#  -H "$permheader" \
#  -H "Host: ${s3Bucket}.s3.amazonaws.com" \
#  -H "Date: ${dateValue}" \
#  -H "Content-Type: ${contentType}" \
#  -H "Authorization: AWS ${s3Key}:${signature}" \
#  https://${s3Bucket}.s3.amazonaws.com/${directory}${filename}
aws s3 cp "${sourcefile}" "s3:/${resource}" ${permheader}
if [ $? -eq 0 ]
then
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

