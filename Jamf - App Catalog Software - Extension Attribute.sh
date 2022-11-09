#!/bin/bash

##################################################
# 
# Jamf - Catalog Software - Extension attributes
# v4
#
# by Stephan Gonschorek
#
##################################################

# Plist Buddy Path
plistbuddy=/usr/libexec/PlistBuddy
#Preferences file name 
plist="jamf.catalogsoftware.distribution.plist"
#Preferences path
plistpath="/Library/Preferences/"

systemtype=$(uname -m)
echo "Systemtype: $systemtype"
if [[ $systemtype == 'arm64' ]]; then

	apparray=$($plistbuddy "$plistpath$plist" -c "Print :applications:array" | sed 's/^\(.*\) =.*/\1/g' | grep -v "Dict {" | grep -v "}")
	result=$(for app in ${apparray[@]}; do 
	plistapprequested=$($plistbuddy -c "print :applications:array:$app" $plistpath$plist || printf '0')
	appname=${app//_/ }
	echo "$appname = $plistapprequested"; 
done)
else
	result=$(defaults read /Library/Preferences/jamf.catalogsoftware.distribution.plist applications | grep -v "{\|}\|(\|)")
fi

echo "<result>$result</result>"
