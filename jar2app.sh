#!/usr/bin/env bash

function file_exists {
  if [ ! -f "${1}" ]
  then
    printf "%s not found. Exiting...\n" "${1}"
    exit 1
  fi
}

function file_type_correct {
  if [[ ! "${1}" == *"${2}" ]]
  then
    printf "%s not of *%s. Exiting...\n" "${1}" "${2}"
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

cp -R ./AppRoot "./out/${appname}.app"

chmod +x "./out/${appname}.app/Contents/MacOS/JavaApplicationStub"

defaulticonlocation="./out/${appname}.app/Contents/Resources/AppIconToChange.icns"
read -r -p "Enter App Icon location. Leave blank for default: " appiconlocation
if [ -z "${appiconlocation}" ]
then
  appiconlocation=$defaulticonlocation
else
  file_exists "${appiconlocation}"
  file_type_correct "${appiconlocation}" ".icns"
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
  file_exists "${appjarlocation}"
  file_type_correct "${appjarlocation}" ".jar"
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

read -r -p "Enter the Java main class: " mainclass

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
cd "$oldpwd" || exit 0;

exit 0
