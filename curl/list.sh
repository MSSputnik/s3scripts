#!/bin/bash
#Version=201411291123

sourcefile=$1
tempfile='/tmp/list2.out'

SCRIPT_DIR=$(dirname $(readlink -f $0))
if [ ! -e "${SCRIPT_DIR}/settings.sh" ]
then
  echo No settings file found. Plesae crate a settings file ${SCRIPT_DIR}/settings.sh
  echo The settings file must contain the parameter s3Bucket, s3Key, s3Secret
  exit 10
fi
. ${SCRIPT_DIR}/settings.sh

contentType="text/plain"
resource="/${s3Bucket1}/"
dateValue=`date -R`
stringToSign="GET\n\n${contentType}\n${dateValue}\n${resource}"
signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${s3Secret} -binary | base64`

echo "SourceFile: ${sourcefile}."
if [ $sourcefile ]; then
  sourcefile="&prefix=${sourcefile}"
fi
 
echo SourceFile: $sourcefile
echo Resource:   $resource

curl -X GET -f -o ${tempfile} \
  $curlProperties \
  -H "Host: ${s3Bucket1}.s3.amazonaws.com" \
  -H "Date: ${dateValue}" \
  -H "Content-Type: ${contentType}" \
  -H "Authorization: AWS ${s3Key}:${signature}" \
  "https://${s3Bucket1}.s3.amazonaws.com/?list-type=2{$sourcefile}&delimiter=/"
if [ $? -eq 0 ]
then 
  echo Download Success 
else
  echo ERROR downloading file
  exit 2
fi

if [ -f ${tempfile} ]; then
  grep "<Key>" ${tempfile} > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    sed 's/><\([^/]\)/>\n<\1/g' ${tempfile} |grep "<Key>" | sed 's/<Key>\(.*\)<\/Key>/\1/g'
  else
    grep "<Prefix>" ${tempfile} > /dev/null 2>&1
    if [ $? -eq 0 ]; then
      sed 's/><\([^/]\)/>\n<\1/g' ${tempfile} |grep "<Prefix>" | sed 's/<Prefix>\(.*\)<\/Prefix>.*/\1/g'
    else
      cat ${tempfile}
    fi
  fi
  rm ${tempfile}
else
  echo "Temporary file $tempfile does not exist. Can not show results."
fi

