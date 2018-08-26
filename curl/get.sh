#!/bin/bash
#Version=201411291123

sourcefile=$1
if [ -z "$sourcefile" ]
then
  echo No source file specified. Nothing to download.
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

resource="/${s3Bucket1}/${sourcefile}"
destfile="${directory}${filename}"
dateValue=`date -R`
stringToSign="GET\n\n${contentType}\n${dateValue}\n${resource}"
signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${s3Secret} -binary | base64`

echo SourceFile: $sourcefile
echo Filename:   $destfile
echo Resource:   $resource

curl -X GET -f -o "${destfile}" \
  $curlProperties \
  -H "Host: ${s3Bucket1}.s3.amazonaws.com" \
  -H "Date: ${dateValue}" \
  -H "Content-Type: ${contentType}" \
  -H "Authorization: AWS ${s3Key}:${signature}" \
  https://${s3Bucket1}.s3.amazonaws.com/${sourcefile}
if [ $? -eq 0 ]
then 
  echo Download Success 
else
  echo ERROR downloading file
  exit 2
fi

