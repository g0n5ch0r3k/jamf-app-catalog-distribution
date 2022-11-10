#!/bin/bash
##################################################
# 
# Jamf - Catalog Software - Distribution Script
# v6
#
# by Stephan Gonschorek
#
# Script creates PLIST Entry which provide the 
# information about, if the App should be installed
# and if its already installed.
# Later Release should support realtim Installation
# status via switfDialog
#
#
##################################################

##################################################
# // TESTING
##################################################
testing=true

##################################################
# 
# // TOOLS ####
#
##################################################
# PlistBuddy
plistbuddy=/usr/libexec/PlistBuddy

##################################################
# 
# // VARIABLES ####
#
##################################################
# $4  - Application Display name (e.g "Google Chrome")
# $5  - Application name (e.g "Google Chrome.app")
# $6  - Application Request state ("install" or "uninstall")
# $7  - RESERVED
# $8  - Preferences file name (Default: "jamf.catalogsoftware.distribution.plist")
# $9  - Preferences path (Default: "/Library/Preferences/")
# $10 - run Silent (true, leave blank for false)

### VARIABLES FOR TESTING
		if [[ $testing == true ]]; then
			four="Discord"
			five="Discord.app"
			six="install"
			seven="/var/tmp/jamf.software.log"
			eight="jamf.catalogsoftware.distribution.plist"
			nine="/Library/Preferences/"
			ten="true"
		else
			four="$4"
			five="$5"
			six="$6"
			seven="$7"
			eight="$8"
			nine="$9"
			ten=${10}
		fi

echo "--> CHECK IF LOG PATH IS EMPTY" >> $seven
		if [[ -z "$seven" ]]; then
			seven="/var/tmp/jamf.software.log"
			echo "NO CUSTOM LOG PATH PROVIDED. USE $seven" >> $seven
		else
			echo "[DISPLAY NAME] $six" >> $seven
		fi
echo "LOG: $seven" >> $seven

##################################################
# // LOG FILE INFOS
##################################################

		echo "##################################################" >> $seven
		echo "TESTING MODE: $testing" >> $seven
		echo "LOG PATH: $seven" >> $seven
		datenow=$(date)
		echo "$datenow" >> "$seven"


##################################################
# 
# // CHECK IF CUSTOM PLIST FILE
#
##################################################

function checkcustomplist(){
	echo "--> CHECK IF CUSTOM PLIST FILE" >> $seven
							if [[ -z "$eight" ]]; then
								plist="jamf.catalogsoftware.distribution.plist"
								echo "[STATE] USE DEFAULT PLIST NAME: $plist" >> $seven
							else
								echo "[STATE] USE CUSTOM PLIST NAME: $eight" >> $seven
								plist="$eight"
							fi
}

##################################################
# 
# // CHECK IF CUSTOM PLIST PATH
#
##################################################

function checkcustomplistpath(){
	echo "--> CHECK IF CUSTOM PLIST PATH" >> $seven
							if [[ -z "$nine" ]]; then
								plistpath="/Library/Preferences/"
								echo "[STATE] USE DEFAULT PLIST PATH: $plistpath" >> $seven
							else
								echo "[STATE] USE CUSTOM PLIST PATH: $nine" >> $seven
								plistpath="$nine"
							fi
}

##################################################
#
# // CHECK IF PLIST EXIST
#
##################################################

function checkplistexist(){
	echo "--> CHECK IF PLIST EXIST" >> $seven
							while ! [[ -f "$plistpath$plist" ]]; do
								sudo $plistbuddy -c "save" $plistpath$plist
							done
	echo "[STATE] $plistpath$plist EXIST" >> $seven
}


		
##################################################
#
# // CHECK APPLICATIONS ARRAY IN PLIST
#
##################################################

function checkapplicationsarray(){
	echo "--> CHECK APPLICATIONS ARRAY IN PLIST" >> $seven
	plistapplicationsarray=$($plistbuddy -c "print :applications" $plistpath$plist || printf '0')
							if [[ $plistapplicationsarray = 0 ]]; then
								echo "[STATE] CREATE APPLICATIONS ARRAY" >> $seven
								sudo $plistbuddy -c "Add :applications array" $plistpath$plist
							else
								echo "[STATE] APPLICATIONS ARRAY EXIST" >> $seven
							fi
}

##################################################
#
# // CHECK LOGGING ARRAY IN PLIST
#
##################################################

function checkloggingarray(){
	echo "--> CHECK INSTALLED ARRAY IN PLIST" >> $seven
	plistinstalledarray=$($plistbuddy -c "print :installed" $plistpath$plist || printf '0')
							if [[ $plistinstalledarray = 0 ]]; then
								echo "[STATE] CREATE INSTALLED ARRAY" >> $seven
								sudo $plistbuddy -c "Add :installed array" $plistpath$plist
							else
								echo "[STATE] INSTALLED ARRAY EXIST" >> $seven
							fi
}

##################################################
# 
# // CHECK IF SOMETHING NOT PROVIDED
#
##################################################

	echo "--> CHECK IF DISPLAY NAME IS EMPTY" >> $seven
							if [[ -z "$four" ]]; then
								echo "[FAILED] Display name is empty. Please enter a value!" >> $seven
								exit 1
							else
								echo "[DISPLAY NAME] $four" >> $seven
							fi
	echo "--> CHECK IF APP NAME IS EMPTY" >> $seven
							if [[ -z "$five" ]]; then
								echo "[FAILED] App name Name is empty. Please enter a value!" >> $seven
								exit 1
							else
								echo "[APP NAME] $five" >> $seven
								appname=${five// /_}
								echo "appname: $appname"
								echo "REPLACE SPACES BY UNDERSCORE" >> $seven
							fi
	echo "--> CHECK IF APP STATE IS EMPTY" >> $seven
							if [[ -z "$six" ]]; then
								echo "[FAILED] App has no request state. Should be true for install or false for uninstall!" >> $seven
								exit 1
							else
								echo "[DISPLAY NAME] $six" >> $seven
							fi

##################################################
#
# // ADD REQUEST STATE TO PLIST
#
##################################################

function addapprequeststate(){
	echo "--> ADD REQUEST STATE TO PLIST" >> $seven
	appinplist=$($plistbuddy -c "print :applications:array:$appname" $plistpath$plist || printf '0')
	echo "--> APPINPLIST STATE: $appinplist"
							if [[ $appinplist = 0 ]]; then
								sudo $plistbuddy -c "Add :applications:array:$appname string $six" $plistpath$plist
								echo "[STATE] ADD $five REQUEST STATE: $six" >> $seven
							else
								echo "[STATE] $five REQUEST STATE IN PLIST: $appinplist" >> $seven
								sudo $plistbuddy -c "set :applications:array:$appname $six" $plistpath$plist
								echo "[STATE] SET $five REQUEST STATE TO: $six" >> $seven
							fi
}

##################################################
#
# // ADD APP INSTALL STATE
#
##################################################

function addappinstallstate(){
	echo "--> ADD INSTALL STATE TO PLIST" >> $seven
							if [[ -d "/Applications/$five" ]]; then
								appinstalled=true
								echo "[STATE] $five IS INSTALLED" >> $seven
							else
								appinstalled=false
								echo "[STATE] $five IS NOT INSTALLED" >> $seven
							fi

echo "--> ADD INSTALL STATE TO PLIST" >> $seven
appinstallstate=$($plistbuddy -c "print :installed:array:$appname" $plistpath$plist || printf '0')
	echo "[STATE] APPINPLIST STATE: $appinstallstate" >> $seven
							if [[ $appinstallstate = 0 ]]; then
								sudo $plistbuddy -c "Add :installed:array:$appname bool $appinstalled" $plistpath$plist
								echo "[STATE] ADD $five REQUEST STATE: $six" >> $seven
							else
								echo "[STATE] $five INSTALL STATE IN PLIST: $appinstallstate" >> $seven
								sudo $plistbuddy -c "set :installed:array:$appname $six" $plistpath$plist
								echo "[STATE] SET $five INSTALL STATE TO: $six" >> $seven
							fi
}

##################################################
#
# // CHECK FOR DIALOG
#
##################################################

echo "--> CHECK FOR DIALOG" >> $seven
echo "[STATE] DIALOG STATE: $ten" >> $seven

if [[ ! $ten = true ]]; then
	echo "[STATE] DIALOG NOT ENABLED" >> $seven
	checkcustomplist
	checkcustomplistpath
	checkplistexist
	checkapplicationsarray
	checkloggingarray
	checkprovidedvalues
	addapprequeststate
	addappinstallstate
	exit 0
fi

##################################################
#
# // CHECK FOR DIALOG INSTALLATION
#
##################################################
echo "--> CHECK FOR DIALOG" >> $seven

# Get the URL of the latest PKG From the Dialog GitHub repo
	dialogURL=$(curl --silent --fail "https://api.github.com/repos/bartreardon/swiftDialog/releases/latest" | awk -F '"' "/browser_download_url/ && /pkg\"/ { print \$4; exit }")
# Expected Team ID of the downloaded PKG
	dialogExpectedTeamID="PWA5E9TQ59"
	
# Check for Dialog and install if not found
							if [ ! -e "/Library/Application Support/Dialog/Dialog.app" ]; then
								echo "Dialog not found. Installing..."
								# Create temporary working directory
								workDirectory=$( /usr/bin/basename "$0" )
								tempDirectory=$( /usr/bin/mktemp -d "/private/tmp/$workDirectory.XXXXXX" )
								# Download the installer package
								/usr/bin/curl --location --silent "$dialogURL" -o "$tempDirectory/Dialog.pkg"
								# Verify the download
								teamID=$(/usr/sbin/spctl -a -vv -t install "$tempDirectory/Dialog.pkg" 2>&1 | awk '/origin=/ {print $NF }' | tr -d '()')
								# Install the package if Team ID validates
								if [ "$dialogExpectedTeamID" = "$teamID" ] || [ "$dialogExpectedTeamID" = "" ]; then
									/usr/sbin/installer -pkg "$tempDirectory/Dialog.pkg" -target /
								else 
									dialogAppleScript
									exitCode=1
									exit $exitCode
								fi
								# Remove the temporary working directory when done
								/bin/rm -Rf "$tempDirectory"  
							else echo "Dialog already found. Proceeding..."
							fi

##################################################
#
# // START DIALOG IF REUQIRED
#
##################################################
echo "--> START DIALOG" >> $seven
	dialogApp="/usr/local/bin/dialog"
	dialog_command_file="/var/tmp/dialog.log"
# Dialog display settings, change as desired
	title="Installing $appname"
	message="Please wait while we download and install $appname. \n This could take up to 15 minutes."

###




###

appinstallstate=$($plistbuddy -c "print :installed:array:$appname" $plistpath$plist || printf '0')
	if [[ ! $appinstallstate = true ]]; then
		echo "[STATE] $appname not installed" >> $seven
				#sudo jamf recon
				
							itemtext1='Prerequisite check'
							itemtext2='Requesting Installation'
							itemtext3='Download and install'
							itemtext4='Update Inventory'
							
							
							function dialog_command(){
								echo "$1"
								echo "$1"  >> $dialog_command_file
							}
							
							# Start Dialog
							
							dialogCMD="$dialogApp -o -p --title \"$title\" \
																--message \"$message\" \
																--icon \"$icon\" \
																--overlayicon SF=arrow.down.circle.fill,palette=white,black,none,bgcolor=none \
																--button1text \"wait\" \
																--button1disabled" \
							
							listitem1="$listitems --listitem '$itemtext1'"
							listitem2="$listitems --listitem '$itemtext2'"
							listitem3="$listitems --listitem '$itemtext3'"
							listitem4="$listitems --listitem '$itemtext4'"
							
							# final command to execute
							dialogCMD="$dialogCMD $listitem1"
							dialogCMD="$dialogCMD $listitem2"
							dialogCMD="$dialogCMD $listitem3"
							dialogCMD="$dialogCMD $listitem4"
							
							echo "$dialogCMD"
							
							eval "$dialogCMD" &
							sleep 2
							
							
							echo "Prerequisite check"  >> $seven
							dialog_command "listitem: $itemtext1: wait"
							sleep 0.1
							dialog_command "listitem: $itemtext2: pending"
							sleep 0.1
							dialog_command "listitem: $itemtext3: pending"
							sleep 0.1
							dialog_command "listitem: $itemtext4: pending"
							# calling functions
									checkcustomplist
									checkcustomplistpath
									checkplistexist
									checkapplicationsarray
									checkloggingarray
							sleep 5
						
							echo "Requesting Installation"  >> $seven
							dialog_command "listitem: $itemtext1: success"
							sleep 0.1
							dialog_command "listitem: $itemtext2: wait"
							# calling functions
									addapprequeststate
									addappinstallstate
							sleep 5		
							
							
							echo "Download and install"  >> $seven
							dialog_command "listitem: $itemtext2: success"
							sleep 0.1
							dialog_command "listitem: $itemtext3: wait"
										while [ ! -d "/Applications/$five" ]
										do
											echo "wait" 
											sleep 3
										done
							
							echo "Update Inventory"  >> $seven
							dialog_command "listitem: $itemtext3: success"
							sleep 0.1
							dialog_command "listitem: $itemtext4: wait"
								sudo jamf recon
							
							echo "Finish"  >> $seven
							dialog_command "listitem: $itemtext4: success"
							sleep 2

							exit 0
else
	echo "[STATE] $appname already installed" >> $seven
	#sudo jamf recon
	exit 0
fi
