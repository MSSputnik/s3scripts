#!/bin/bash
#Version=201808260845

clientRepo="https://raw.githubusercontent.com/MSSputnik/s3scripts/master"
clientRFiles="get.sh list.sh"
clientWFiles="upload.sh delete.sh"
clientSFiles=
echo "Installscript for s3scripts"
clientType=$1
clientMode=$2
clientPath=$3

if [ -z "$clientType" ]; then
  clientType=curl
fi
if [ -z "$clientMode" ]; then
  clientMode=rw
fi
if [ -z "$clientPath" ]; then
  clientPath=.
fi

echo Using:
echo clientType: $clientType
echo clientMode: $clientMode
echo clientPath: $clientPath

if [ -e "$clientPath" ]; then
  if [ ! -d "$clientPath" ]; then
    echo "ERROR: clientPath $clientPath exists but is not a diretory."
    exit 1
  fi
else
  echo "clientPath $clientPath does not exist. Creating..."
  mkdir -p $clientPath
  erg=$?
  if [ $erg -gt 0 ]; then
    echo "ERROR: Create clientPath $clientPath failed. Abort installation."
    exit $erg
  fi
fi

if [ "${clientPath: -1}" != "/" ]; then
  clientPath=$clientPath/
fi

if [ $clientMode == "ro" ]; then
  clientFiles="$clientRFiles"
fi
if [ $clientMode == "wo" ]; then
  clientFiles="$clientWFiles"
fi
if [ -z "$clientFiles" ]; then
  clientFiles="$clientRFiles $clientWFiles"
fi
clientFiles="$clientFiles $clientSFiles"

echo "Files to download: $clientFiles"

erg=0
for f in $clientFiles; do
  clientSource=$clientRepo/$clientType/$f
  clientDest=$clientPath$f
  echo "curl $clientSource $clientDest"
  curl -f -o "$clientDest" $clientSource 
  erg+=$?
done
if [ $erg -gt 0 ]; then
  echo
  echo "ERROR: Not all files downloaded."
fi
exit $erg

