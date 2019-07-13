#!/usr/bin/env bash

############################################################
# Script Name  : jar2app.sh                                #
# Description  : Create a Mac app from a simple Jar file.  #
# Args         :                                           #
# Author       : megaspaz                                  #
# Email        : megaspaz2k7@gmail.com                     #
# Copyright    : (c) 2019                                  #
############################################################

function valid_file_input {
  if [ ! -f "${1}" ] || [[ ! "${1}" == *"${2}" ]]
  then
    printf "%s not found or not of *%s filetype. Exiting...\n" "${1}" "${2}"
    exit 1
  fi
}

oldpwd=$(pwd)

cd "$(dirname "$0")" || exit 1;

read -r -p "Enter App's name. Leave blank for default App name [AppRoot]: " appname
if [ -z "${appname}" ]
then
  appname="AppRoot"
fi

if [ -d "./out/${appname}.app" ]
then
  printf "%s.app already exists! Overwriting...\n" "${appname}"
  rm -rf "./out/${appname}.app"
fi

read -r -p "Enter the App's version. Leave blank [1.0.1]: " appversion
if [ -z "${appversion}" ]
then
  appversion="1.0.1"
fi

printf "Generating %s.app skeleton...\n" "${appname}"
cp -R ./AppRoot "./out/${appname}.app"
chmod +x "./out/${appname}.app/Contents/MacOS/JavaApplicationStub"
printf "Done generating %s.app skeleton...\n" "${appname}"

defaulticonlocation="./out/${appname}.app/Contents/Resources/AppIconToChange.icns"
read -r -p "Enter App Icon location. Leave blank for default: " appiconlocation
if [ -z "${appiconlocation}" ]
then
  appiconlocation=$defaulticonlocation
else
  valid_file_input "${appiconlocation}" ".icns"
  rm -f "${defaulticonlocation}"
  cp "${appiconlocation}" "$(dirname "$defaulticonlocation")/."
fi
appicon="$(basename "$appiconlocation")"

defaultjarlocation="./out/${appname}.app/Contents/Java/change_me.runnable.jar"
read -r -p "Enter App Jar location. Leave blank for default: " appjarlocation
if [ -z "${appjarlocation}" ]
then
  appjarlocation=$defaultjarlocation
else
  valid_file_input "${appjarlocation}" ".jar"
  rm -f "${defaultjarlocation}"
  cp "${appjarlocation}" "$(dirname "$defaultjarlocation")/."
fi
appjar="$(basename "$appjarlocation")"
appjarnameonly=${appjar%".jar"}

read -r -p "Enter the Java version. Leave blank [1.8]: " javaversion
if [ -z "${javaversion}" ]
then
  javaversion="1.8"
fi

read -r -p "Enter copyright year. Leave blank for current year [$(date +'%Y')]: " copyrightyear
if [ -z "${copyrightyear}" ]
then
  copyrightyear="$(date +'%Y')"
fi

mainclass=""
until [ ! -z "${mainclass}" ]
do
  read -r -p "Enter the Java main class: " mainclass
done

printf "Setting up Info.plist...\n"

infofile="./out/${appname}.app/Contents/Info.plist"
sed -i -e "s/#{CHANGE_ME.RUNNABLE_NO_X}/$appjarnameonly/g" "${infofile}"
sed -i -e "s/#{COPYRIGHT_YEAR}/$copyrightyear/g" "${infofile}"
sed -i -e "s/#{APP_ICON_TO_CHANGE}/$appicon/g" "${infofile}"
sed -i -e "s/#{APP_NAME}/$appname/g" "${infofile}"
sed -i -e "s/#{VERSION}/$appversion/g" "${infofile}"
sed -i -e "s/#{MAIN_CLASS}/$mainclass/g" "${infofile}"
sed -i -e "s/#{JAVA_VERSION}/$javaversion/g" "${infofile}"
sed -i -e "s/#{CHANGE_ME.RUNNABLE}/$appjar/g" "${infofile}"

printf "Removing temp files...\n"
rm -f "./out/${appname}.app/Contents/Info.plist-e"

printf "Done. Goodbye.\n"
cd "$oldpwd" || exit 1;

exit 0
