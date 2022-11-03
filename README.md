# Jamf - App Catalog Software - Extension Attribute

Extension Attribute will read the "/Library/Preferences/jamf.catalogsoftware.distribution.plist" and push the info to Jamf.

Output will be like:
<result>Slack.app = uninstall
  Discord.app = install
  Google Chrome.app = uninstall</result>

With a SmartGroup you could capture the desired app, state and add the app from the Jamf Catalog to the smart group to enforce a installation

# Jamf - App Catalog Software - Distribution Script.sh

This Script can be used to fill a plist file with a app and a install state (install, uninstall). More features planed, like uninstall and a user notification with the install progress and more details on the logging.

- For testing you can set the value "testing" to true, which will use the values in the script to run the script instead of jamf provided. You can set testing to true also, if your run the script localy.

- Script will check if custom plist file and path is provided and use the infos if provided. Otherwise it will use the default values

- If a reqired field is empty, the script will fail and echo the error of the missing attribute

- The Script will add the app and the install state (install/uninstall) to the plist

Inventory Update will be run at the end to provide plist infos to Jamf to feed the smart groups.
