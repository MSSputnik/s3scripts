#!/bin/bash
scriptVersion=201808271655

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
  exit 10
fi

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
else
  permheader=""
fi


resource="/${s3Bucket}/${directory}${filename}"
echo SourceFile: $sourcefile
echo Filename:   $filename
echo Resource:   $resource
echo Destination Dir: $directory


if [ -e $sourcefile ]; then
  echo Upload $filename
  gsutil -q cp "${sourcefile}" "gs:/${resource}" ${permheader}
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

