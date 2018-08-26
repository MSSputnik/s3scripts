#!/bin/bash
#Version=201808252215

sourcefile=$1
if [ -z "$sourcefile" ]
then
  echo No source file specified. Nothing to download.
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
  echo Optional s3Key, s3Secret, curlProperties
  exit 10
fi

filename=`basename ${sourcefile}`
directory=$2
if [ -n "$directory" ]
then
  # directory is not empty
  if [ ! -d "$directory" ]
  then
    if [ -a "$directory" ]
    then 
      echo
      echo "***************************************************************************************"
      echo ERROR: Destination directory $directory exist and it is not a directory. Please correct.
      echo "***************************************************************************************"
      echo
      exit 3
    else
     mkdir -p "$directory"
     if [ ! -d "$directory" ]
     then
       echo
       echo "***************************************************************************************"
       echo ERROR: Create destination directory $directory failed. Please correct.
       echo "***************************************************************************************"
       echo
       exit 3
     else
       directory=${directory}/
     fi
    fi
  else
    directory=${directory}/
  fi
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

resource="/${s3Bucket}/${sourcefile}"
destfile="${directory}${filename}"
dateValue=`date -R`

#stringToSign="GET\n\n${contentType}\n${dateValue}\n${sigToken}${resource}"
stringToSign="GET\n\n${contentType}\n${dateValue}\n$sigToken${resource}"
signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${s3Secret} -binary | base64`

#echo String2Sign: $stringToSign
echo SourceFile: $sourcefile
echo Filename:   $destfile
echo Resource:   $resource

curl -X GET -f -o "${destfile}" \
  $curlProperties \
  -H "$sigHeader" \
  -H "Host: ${s3Bucket}.s3.amazonaws.com" \
  -H "Date: ${dateValue}" \
  -H "Content-Type: ${contentType}" \
  -H "Authorization: AWS ${s3Key}:${signature}" \
  https://${s3Bucket}.s3.amazonaws.com/${sourcefile}
if [ $? -eq 0 ]; then 
  echo Download Success 
else
  echo ERROR downloading file
  exit 2
fi

