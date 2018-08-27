#!/bin/bash
scriptVersion=201808271655

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

resource="/${s3Bucket}/${sourcefile}"
destfile="${directory}${filename}"

echo SourceFile: $sourcefile
echo Filename:   $destfile
echo Resource:   $resource

echo Execute: gsutil -q cp s3:/${resource} $destfile 
gsutil -q cp gs:/${resource} $destfile 
if [ $? -eq 0 ]
then 
  
echo Download Success 
else
  echo ERROR downloading file
  exit 2
fi

