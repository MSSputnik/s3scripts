#!/bin/bash
#Version=201808252215

sourcefile=$1

SCRIPT_DIR=$(dirname $(readlink -f $0))
if [ -e "${SCRIPT_DIR}/settings.sh" ]; then
  . ${SCRIPT_DIR}/settings.sh
fi

if [ -z "$s3Bucket" ]; then
  echo No bucket name defined.
  echo Set env variable s3Bucket or create a settings file ${SCRIPT_DIR}/settings.sh
  echo The settings file must contain the parameter s3Bucket
  echo Optional s3Key, s3Secret, curlProperties
  exit 10
fi

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

contentType="text/plain"
resource="/${s3Bucket}/"
dateValue=`date -R`
stringToSign="GET\n\n${contentType}\n${dateValue}\n$sigToken${resource}"
signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${s3Secret} -binary | base64`

echo "SourceFile: ${sourcefile}."
if [ $sourcefile ]; then
  sourcefile="&prefix=${sourcefile}"
fi
 
echo SourceFile: $sourcefile
echo Resource:   $resource

curl -X GET -f -k -o /tmp/list1.out \
  $curlProperties \
  -H "$sigHeader" \
  -H "Host: ${s3Bucket}.s3.amazonaws.com" \
  -H "Date: ${dateValue}" \
  -H "Content-Type: ${contentType}" \
  -H "Authorization: AWS ${s3Key}:${signature}" \
  "https://${s3Bucket}.s3.amazonaws.com/?list-type=2${sourcefile}&delimiter=/"
if [ $? -eq 0 ]; then 
  echo Download Success 
else
  echo ERROR downloading file
  exit 2
fi

if [ -f /tmp/list1.out ]; then
  grep "<Key>" /tmp/list1.out > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    sed 's/><\([^/]\)/>\n<\1/g' /tmp/list1.out |grep "<Key>" | sed 's/<Key>\(.*\)<\/Key>/\1/g'
  else
    grep "<Prefix>" /tmp/list1.out > /dev/null 2>&1
    if [ $? -eq 0 ]; then
      sed 's/><\([^/]\)/>\n<\1/g' /tmp/list1.out |grep "<Prefix>" | sed 's/<Prefix>\(.*\)<\/Prefix>.*/\1/g'
    else
      cat /tmp/list1.out
    fi
  fi
  rm /tmp/list1.out
fi

