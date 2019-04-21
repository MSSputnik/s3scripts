#!/bin/sh
#Version=201904211015

# known clientMode:
# ro: get.sh list.sh 
# wo: upload.sh delete.sh
# sr: sget.sh slist.sh
# sw: supload.sh sdelete.sh
# sro: get.sh list.sh sget.sh slist.sh
# swo: upload.sh delete.sh supload.sh slist.sh
# srw: get.sh list.sh upload.sh delete.sh sget.sh slist.sh supload.sh sdelete.sh 
# so: sget.sh slist.sh supload.sh sdelete.sh
# default: get.sh list.sh upload.sh delete.sh
clientRepo="https://raw.githubusercontent.com/MSSputnik/s3scripts/master"
clientRFiles="get.sh list.sh"
clientWFiles="upload.sh delete.sh"
clientRSFiles="sget.sh slist.sh"
clientWSFiles="supload.sh sdelete.sh"
clientSFiles=
echo "Installscript for s3scripts"
clientType=$1
clientMode=$2
clientPath=$3
httpClient=$4

if [ -z "$clientType" ]; then
  clientType=curl
fi
if [ -z "$clientMode" ]; then
  clientMode=rw
fi
if [ -z "$clientPath" ]; then
  clientPath=.
fi
if [ -z "$httpClient" ]; then
  httpClient=curl
fi

echo Using:
echo clientType: $clientType
echo clientMode: $clientMode
echo clientPath: $clientPath
if [ $httpClient != "curl" -a $httpClient != "wget" ]; then
  echo "ERROR: httpClient invalid http client specified. [curl|wget]"
  exit 1
fi

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

if ! echo "${clientPath}" | grep '/$'; then
  clientPath=$clientPath/
fi

if [ $clientMode = "ro" ]; then
  clientFiles="$clientRFiles"
fi
if [ $clientMode = "wo" ]; then
  clientFiles="$clientWFiles"
fi
if [ $clientMode = "sr" ]; then
  clientFiles="$clientRSFiles"
fi
if [ $clientMode = "sw" ]; then
  clientFiles="$clientWSFiles"
fi
if [ $clientMode = "sro" ]; then
  clientFiles="$clientRFiles $clientRSFiles"
fi
if [ $clientMode = "swo" ]; then
  clientFiles="$clientWFiles $clientWSFiles"
fi
if [ $clientMode = "srw" ]; then
  clientFiles="$clientRFiles $clientWFiles $clientRSFiles $clientWSFiles"
fi
if [ $clientMode = "so" ]; then
  clientFiles="$clientRSFiles $clientWSFiles"
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
  if [ $httpClient = "wget" ]; then
    echo "wget $clientSource $clientDest"
    wget -O "$clientDest" $clientSource
    erg=$(( $erg+$? ))
  else
    echo "curl $clientSource $clientDest"
    curl -f -o "$clientDest" $clientSource
    erg=$(( $erg+$? ))
  fi
  if [ -e $clientDest ]; then
    chmod 755 $clientDest
  fi
done
if [ $erg -gt 0 ]; then
  echo
  echo "ERROR: Not all files downloaded."
else
  echo
  echo "All scripts downloaded successfully."
fi
exit $erg
