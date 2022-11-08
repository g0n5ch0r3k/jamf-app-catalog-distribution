# Jamf - App Catalog Software - Extension Attribute

Extension Attribute will read the "/Library/Preferences/jamf.catalogsoftware.distribution.plist" and push the info to Jamf.

![alt text](https://github.com/g0n5ch0r3k/jamf-app-catalog-distribution/blob/18dd3fadfb16cc309925b4807f48677364099e56/images/extension_attribute_1.JPG)

Output will be like:
'< result>Slack.app = uninstall
  Discord.app = install
  Google Chrome.app = uninstall</result>'

![alt text](https://github.com/g0n5ch0r3k/jamf-app-catalog-distribution/blob/18dd3fadfb16cc309925b4807f48677364099e56/images/extension_attribute_2.JPG)

With a SmartGroup you could capture the desired app, state and add the app from the Jamf Catalog to the smart group to enforce a installation

# Jamf - App Catalog Software - Distribution Script.sh

This Script can be used to fill a plist file with a app and a install state (install, uninstall).

$4 Display name

$5 Application name

$6 Request state (install or uninstall) --> uninstall will be added later

$7 customize the Log File

$8 and $9 customize the plist

$10 enabled swiftDialog (Will be changed to progress bar in later release)

![alt text](https://github.com/g0n5ch0r3k/jamf-app-catalog-distribution/blob/18dd3fadfb16cc309925b4807f48677364099e56/images/script_1.JPG)

- Script will check if custom plist file and path is provided and use the infos if provided. Otherwise it will use the default values

- If a reqired field is empty, the script will fail and echo the error of the missing attribute
- Actually required is "Display name, App name and request state"

- The Script will add the app and the install state (install/uninstall) to the plist


# Add the Policy to Self Service 

![alt text](https://github.com/g0n5ch0r3k/jamf-app-catalog-distribution/blob/18dd3fadfb16cc309925b4807f48677364099e56/images/script_policy_2.JPG)

# Smart Groups

Create the needed smart groups for the apps and assign this groups to the app catalog app.

![smart_groups_1](https://github.com/g0n5ch0r3k/jamf-app-catalog-distribution/blob/18dd3fadfb16cc309925b4807f48677364099e56/images/smart_groups_1.JPG]

![smart_groups_2](https://github.com/g0n5ch0r3k/jamf-app-catalog-distribution/blob/18dd3fadfb16cc309925b4807f48677364099e56/images/smart_groups_2.JPG]

# App catalog

Add the app to the smart group.

![sapp catalog](https://github.com/g0n5ch0r3k/jamf-app-catalog-distribution/blob/2987ba3a7fa2e27510437fbe20f564553218c243/images/app_catalog_1.JPG]

# TESTING

- For testing you can set the value "testing" in the script to true, which will use the values in the script to run the script instead of jamf provided values. You can set testing to true also, if your run the script localy.
