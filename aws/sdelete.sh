#!/bin/bash
scriptVersion=201904210940

sourcefile=$1
if [ -z "$sourcefile" ]
then
  echo No file specified. Nothing to delete.
  exit 3
fi

#user can overwrite the aws command
if [ -z "$s3AWSCMD" ]; then
  s3AWSCMD=aws
fi

SCRIPT_DIR=$(dirname $(readlink -f $0))
if [ -e "${SCRIPT_DIR}/settings.sh" ]; then
  . ${SCRIPT_DIR}/settings.sh
fi

if [ -z "$s3SettingsBucket" ]; then
  s3SettingsBucket=$s3Bucket
fi

if [ -z "$s3SettingsBucket" ]; then
  echo No bucket name defined.
  echo Set env variable s3SettingsBucket, s3Bucket or create a settings file ${SCRIPT_DIR}/settings.sh
  echo The settings file must contain the parameter s3SettingsBucket or s3Bucket
  echo Optional are s3Key, s3Secret, s3SettingsPath, s3AWSCMD
  exit 10
fi

# calculate source settings directory
if [ -z "$s3SettingPath" ]; then
  settingPath="settings/$($s3AWSCMD sts get-caller-identity --query UserId --output text)"
else
  settingPath=$s3SettingPath
fi

if [ "$settingPath" -a "${settingPath: -1}" != "/" ]; then
  settingPath=$settingPath/
fi

resource="/${s3SettingsBucket}/${settingPath}${sourcefile}"

if [ "$s3Key" ]; then
  export AWS_ACCESS_KEY_ID=$s3Key
fi
if [ "$s3Secret" ]; then
  export AWS_SECRET_ACCESS_KEY=$s3Secret
fi

echo SourceFile: $sourcefile
echo Delete:     $resource

$s3AWSCMD s3 rm "s3:/${resource}"
if [ $? -eq 0 ]; then
  echo Delete success
else
  echo ERROR deleting file
  exit 2
fi

