#!/bin/bash
##################################################
# 
# Jamf - Catalog Software - Distribution Script
# v4
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
testing=false

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
if [[ $testing == true ]]; then
	four="Google Chrome"
	five="Google Chrome.app"
	six="uninstall"
	seven=/var/tmp/jamf.software.log
	eight="jamf.catalogsoftware.distribution.plist"
	nine="/Library/Preferences/"
	ten="$10"
else
	four="$4"
	five="$5"
	six="$6"
	seven="$7"
	eight="$8"
	nine="$9"
	ten="$10"
fi

# // CHECK IF LOG SPECIFIED
#date > $eventlog
if [[ -z "$seven" ]]; then
	eventlog=/var/tmp/jamf.software.log
	echo "[STATE] USE DEFAULT LOG PATH: $eventlog"
else
	echo "[STATE] USE CUSTOM LOG PATH: $seven"
fi

##################################################
# // CHECK IF CUSTOM PLIST FILE >> $log
##################################################
echo "TESTING MODE: $testing"
echo "LOG PATH: $log"

##################################################
# 
# // CHECK IF CUSTOM PLIST FILE
#
##################################################
echo "CHECK IF CUSTOM PLIST FILE"
if [[ -z "$eight" ]]; then
	plist="jamf.catalogsoftware.distribution.plist"
	echo "[STATE] USE DEFAULT PLIST NAME: $plist"
else
	echo "[STATE] USE CUSTOM PLIST NAME: $eight"
	plist="$eight"
fi

##################################################
# 
# // CHECK IF CUSTOM PLIST PATH
#
##################################################
echo "CHECK IF CUSTOM PLIST PATH"
if [[ -z "$nine" ]]; then
	plistpath="/Library/Preferences/"
	echo "[STATE] USE DEFAULT PLIST PATH: $plistpath"
else
	echo "[STATE] USE CUSTOM PLIST PATH: $nine"
	plistpath="$nine"
fi

##################################################
#
# // CHECK IF PLIST EXIST
#
##################################################
echo "CHECK IF PLIST EXIST"
		while ! [[ -f "$plistpath$plist" ]]; do
			sudo $plistbuddy -c "save" $plistpath$plist
		done
		echo "[STATE] $plistpath$plist EXIST"
		
##################################################
#
# // CHECK APPLICATIONS ARRAY IN PLIST
#
##################################################
echo "CHECK APPLICATIONS ARRAY IN PLIST"
plistapplicationsarray=$($plistbuddy -c "print :applications" $plistpath$plist || printf '0')
		if [[ $plistapplicationsarray = 0 ]]; then
				echo "[STATE] CREATE APPLICATIONS ARRAY"
			sudo $plistbuddy -c "Add :applications array" $plistpath$plist
				
		else
				echo "[STATE] APPLICATIONS ARRAY EXIST"
		fi

##################################################
# 
# // CHECK IF SOMETHING NOT PROVIDED
#
##################################################
echo "CHECK IF DISPLAY NAME IS EMPTY"
if [[ -z "$four" ]]; then
	echo "[FAILED] Display name is empty. Please enter a value!"
	exit 1
fi
echo "CHECK IF APP NAME IS EMPTY"
if [[ -z "$five" ]]; then
	echo "[FAILED] App name Name is empty. Please enter a value!"
	exit 1
else
	appname=${five// /_}
	echo "REPLACE SPACES BY UNDERSCORE"
fi
echo "CHECK IF APP STATE IS EMPTY"
if [[ -z "$six" ]]; then
	echo "[FAILED] App has no request state. Should be true for install or false for uninstall!"
	exit 1
fi

##################################################
#
# // ADD REQUEST STATE TO PLIST
#
##################################################
echo "ADD REQUEST STATE TO PLIST"
appinplist=$($plistbuddy -c "print :applications:array:$appname" $plistpath$plist || printf '0')
echo "APPINPLIST STATE: $appinplist"
		if [[ $appinplist = 0 ]]; then
				sudo $plistbuddy -c "Add :applications:array:$appname string $six" $plistpath$plist
				echo "[STATE] ADD $five REQUEST STATE: $six"
		else
				echo "[STATE] $five REQUEST STATE IN PLIST: $appinplist"
			sudo $plistbuddy -c "set :applications:array:$appname $six" $plistpath$plist
				echo "[STATE] SET $five REQUEST STATE TO: $six"
		fi

##################################################
#
# // Inventory Update
#
##################################################

sudo jamf recon