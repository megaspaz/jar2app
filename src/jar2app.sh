#!/usr/bin/env bash

oldpwd=`pwd`

cd "$(dirname "$0")"

read -p "Enter App's name. Leave blank for default App name [AppRoot]: " appname
if [ -z "${appname}" ]
then
  appname="AppRoot"
fi

if [ -d "../bin/${appname}.app" ]
then
  echo "${appname}.app already exists! Overwriting..."
  rm -rf "../bin/${appname}.app"
fi

read -p "Enter the App's version. Leave blank [1.0.1]: " appversion
if [ -z "${appversion}" ]
then
  appversion="1.0.1"
fi

cp -R ../AppRoot "../bin/${appname}.app"

chmod +x "../bin/${appname}.app/Contents/MacOS/JavaApplicationStub"

defaulticonlocation="../bin/${appname}.app/Contents/Resources/AppIconToChange.icns"
read -p "Enter App Icon location. Leave blank for default: " appiconlocation
if [ -z "${appiconlocation}" ]
then
  appiconlocation=$defaulticonlocation
else
  rm -f "${defaulticonlocation}"
  cp "${appiconlocation}" "$(dirname "$defaulticonlocation")/."
fi
appicon="$(basename "$appiconlocation")"

defaultjarlocation="../bin/${appname}.app/Contents/Java/change_me.runnable.jar"
read -p "Enter App Jar location. Leave blank for default: " appjarlocation
if [ -z "${appjarlocation}" ]
then
  appjarlocation=$defaultjarlocation
else
  rm -f "${defaultjarlocation}"
  cp "${appjarlocation}" "$(dirname "$defaultjarlocation")/."
fi
appjar="$(basename "$appjarlocation")"
appjarnameonly=${appjar%".jar"}

read -p "Enter the Java version. Leave blank [1.8]: " javaversion
if [ -z "${javaversion}" ]
then
  javaversion="1.8"
fi

read -p "Enter copyright year. Leave blank for current year [$(date +'%Y')]: " copyrightyear
if [ -z "${copyrightyear}" ]
then
  copyrightyear="$(date +'%Y')"
fi

read -p "Enter the Java main class: " mainclass

echo "Setting up Info.plist..."

infofile="../bin/${appname}.app/Contents/Info.plist"
sed -i -e "s/#{CHANGE_ME.RUNNABLE_NO_X}/$appjarnameonly/g" "${infofile}"
sed -i -e "s/#{COPYRIGHT_YEAR}/$copyrightyear/g" "${infofile}"
sed -i -e "s/#{APP_ICON_TO_CHANGE}/$appicon/g" "${infofile}"
sed -i -e "s/#{APP_NAME}/$appname/g" "${infofile}"
sed -i -e "s/#{VERSION}/$appversion/g" "${infofile}"
sed -i -e "s/#{MAIN_CLASS}/$mainclass/g" "${infofile}"
sed -i -e "s/#{JAVA_VERSION}/$javaversion/g" "${infofile}"
sed -i -e "s/#{CHANGE_ME.RUNNABLE}/$appjar/g" "${infofile}"

echo "Removing temp files..."
rm -f "../bin/${appname}.app/Contents/Info.plist-e"

echo "Done. Goodbye."
cd "$oldpwd"

exit 0
