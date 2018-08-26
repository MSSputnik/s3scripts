#!/bin/bash
#Version=201412071150

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

if [ -z "$s3Bucket" ]; then
  echo No bucket name defined.
  echo Set env variable s3Bucket or create a settings file ${SCRIPT_DIR}/settings.sh
  echo The settings file must contain the parameter s3Bucket
  echo Optional are s3Key, s3Secret, curlProperties 
  exit 10
fi

filename=`basename ${sourcefile}`
directory=$2
if [ -z "$directory" ]; then
  echo no upload directory specifid. Upload to root
else
  if [ ! "${directory: -1}" == "/" ]; then
    directory=${directory}/
  fi
fi

permission=$3
if [ "$permission" == "public" ]
then
  permheader="x-amz-acl: public-read"
  permsig="x-amz-acl:public-read\n"
else
  permheader="x-amz-acl: private"
  permsig="x-amz-acl:private\n"
fi

# retrieve temporary credentials when necessary
if [ -z "$s3Key" ]; then
  echo "Using temporary security token"
  iamrole=$(curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/)
  security=$(curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/$iamrole)

  #echo $security

  s3Key=$(echo $security | sed "s/.*\"AccessKeyId\" : \"\([a-zA-Z0-9]*\)\".*/\1/")
  s3Secret=$(echo $security | sed "s/.*\"SecretAccessKey\" : \"\([a-zA-Z0-9/]*\)\".*/\1/")
  s3Token=$(echo $security | sed "s/.*\"Token\" : \"\([a-zA-Z0-9+/=]*\)\".*/\1/")
  #expiration=$(echo $security | sed "s/.*\"Expiration\" : \"\([0-9ZT:-]*\)\".*/\1/")
  sigToken=x-amz-security-token:$s3Token\\n
  sigHeader="x-amz-security-token: $s3Token"
fi
#echo
#echo AccessKey: $s3Key
#echo SecretAccessKey: $s3Secret
#echo SecretToken: $s3Token
#echo Expiration: $expiration

#echo sigToken: $sigToken
#echo sigHeader: $sigHeader


resource="/${s3Bucket}/${directory}${filename}"
contentType="application/x-compressed-tar"
dateValue=`date -R`
stringToSign="PUT\n\n${contentType}\n${dateValue}\n${permsig}$sigToken${resource}"
signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${s3Secret} -binary | base64`
echo SourceFile: $sourcefile
echo Filename:   $filename
echo Resource:   $resource
echo Destination Dir: $directory


if [ -e $sourcefile ]
then
  echo Upload $filename
  curl -X PUT  -T "${sourcefile}" \
    $curlProperties \
    -H "$permheader" \
    -H "$sigHeader" \
    -H "Host: ${s3Bucket}.s3.amazonaws.com" \
    -H "Date: ${dateValue}" \
    -H "Content-Type: ${contentType}" \
    -H "Authorization: AWS ${s3Key}:${signature}" \
    https://${s3Bucket}.s3.amazonaws.com/${directory}${filename}
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

