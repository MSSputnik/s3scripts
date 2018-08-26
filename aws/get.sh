#!/bin/bash
scriptVersion=201602081115

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

resource="/${s3Bucket}/${sourcefile}"
destfile="${directory}${filename}"

if [ "$s3Key" ]; then
  export AWS_ACCESS_KEY_ID=$s3Key
fi
if [ "$s3Secret" ]; then
  export AWS_SECRET_ACCESS_KEY=$s3Secret
fi

echo SourceFile: $sourcefile
echo Filename:   $destfile
echo Resource:   $resource

echo Execute: aws s3 cp s3:/${resource} $destfile --quiet
aws s3 cp s3:/${resource} $destfile --quiet
if [ $? -eq 0 ]
then 
  
echo Download Success 
else
  echo ERROR downloading file
  exit 2
fi

