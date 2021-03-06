# s3scripts
Simple scripts to interact with a bucket (AWS, Azure or Google Cloud)

## Objective
The purpose of this scripts is to have unique commands to interact with your software repository independed of the repository implementation.  
The new 's' scripts were introduced to support the separation of settings and installation files. This new type of scripts interact with the settings store which can be configured in the settings.sh. The default settings store depends on the implementation. See there for more details.

## Usage
See subfolder for details.

### (s)get.sh
`get.sh <source> <destination>`

**source**
- source must be a file within your repository. Wildcards or paths are not allowed.
- source is always relative to the root directory of your repository.

**destination**
- destination is optional.
- if omitted the current directory is used
- destination must be a directory. 
- rename of files during download is not supported.

### (s)list.sh
`list.sh <directory>`

**directory**
- directory is optional
- if omitted the root directory of your repository is shown.
- the output format and if subdiretories are shown depends on the implementation.

### (s)upload.sh
`upload.sh <source> <destination>`

**source**
- source must be a file on your local file system. Wildcards or paths are not allowed.

**destination**
- destination is optional. 
- if omitted, the root directory of your repository is used.
- destination must be a directory. Append / to make sure.
- rename of files during upload is not suppored.

### (s)delete.sh
`delete.sh <file>`

**file**
- file is mandatory
- specify the absolute path within your repository.
- Wildcards or paths without filename are not allowed.
- There will be no security question.

## Configuration
See sub folders for details.

## Installation

### Installation by hand
There is not installation required. Just copy the scripts into the desired directory and make them executable `chmod 755 *.sh`. Create the `settings.sh` configuration file if required by the implementation.

### Installation via script
To simplify the installation, a simple installation scrip exist.

Just run `curl https://raw.githubusercontent.com/MSSputnik/s3scripts/master/install.sh | sh`

This will install all 4 curl scripts into your local diretory.

The installation scripts supports up to 3 arguments.

Run `curl https://raw.githubusercontent.com/MSSputnik/s3scripts/master/install.sh | sh -s <type> <mode> <path>`

**type**
- Specify which implementation you like to download. Default is `curl`.
- As type use the name of the sub directory (e.g aws)

**mode**

Specify which scripts you need. 
- rw:  Read / Write - get all 4 standard scripts. (Default)
- ro:  Read Only - get get.sh and list.sh
- wo:  Write Only - get upload.sh and delete.sh
- sr:  Settings Read Only - get sget.sh and slist.sh
- sw:  Settings Write Only - get supload.sh and sdelete.sh
- sro: Settings and Standard Read Only - get get.sh, list.sh sget.sh and slist.sh
- swo: Settings and Standard Write Only - get upload.sh, delete.sh, supload.sh and sdelete.sh
- srw: Settings and Standard Read / Write - get all 8 scripts.
- so:  Settings Read / Write - get all 4 settings scripts.

**path**

Specifiy the path where you want to place the scripts. Default is your current directory.
If the path does not exists, it will be created.

