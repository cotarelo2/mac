#!/bin/sh - 

# Credit to Rich Trouton for developing the initial FV2 Status checking script
#
# Get number of CoreStorage devices. The egrep pattern used later in the script
# uses this information to only report on the first encrypted drive, which should
# be the boot drive.
#
# Rich gives credit to Mike Osterman for identifying this problem in the original version of
# the script and finding a fix for it.
#
# Modified for use with ePO system by Nick Cobb, 2013.

# Change the permissions on /Library/McAfee applicable directories
sudo chmod 777 /Library/McAfee/cma/scratch/
sudo chmod 755 /Library/McAfee/cma/scratch/etc

# set plist directory as variable
secureDir="/usr/local/recoverykeyfailover.plist"
customDir="/Library/McAfee/cma/scratch/CustomProps.xml"

# set the date for timestamp
timeStamp=`date`

# Check if RecoveryKey plist exists - If secureDir runs, it is because FMU
# got a sync failure at encryption enable and this status script is compensating by
# checking using the background escrow process. If customDir is used, then the script
# is syncing correctly and pulling from the customprops.xml file.

if [ -f $secureDir ]; then
	echo "The recovery key file exists."
	echo "Now taking care of business."
	recoveryKey=`defaults read $secureDir RecoveryKey`
# Delete the PLIST file so that future syncs don't read from it
	sudo rm -rf $secureDir
elif [ -f $customDir ]; then
	echo "Custom Props xml is here."
	echo "Grabbing the key."
	recoveryKey=`grep -o "\(\w\{4\}-\)\{5\}\(\w\{4\}\)" /Library/McAfee/cma/scratch/CustomProps.xml`
else
	echo "\nThe Recovery plist was not present in the secure directory."
	echo "The recovery key should have already been uploaded by e2e,"
	echo "but if not there has been an error."
	recoveryKey="n/a"
fi

CORESTORAGESTATUS="/private/tmp/corestorage.txt"
ENCRYPTSTATUS="/private/tmp/encrypt_status.txt"
ENCRYPTDIRECTION="/private/tmp/encrypt_direction.txt"

DEVICE_COUNT=`diskutil cs list | grep -E "^CoreStorage logical volume groups" | awk '{print $5}' | sed -e's/(//'`

EGREP_STRING=""
if [ "$DEVICE_COUNT" != "1" ]; then
EGREP_STRING="^\| *"
fi

osversionlong=`sw_vers -productVersion`
osvers=${osversionlong:3:1}
CONTEXT=`diskutil cs list | grep -E "$EGREP_STRING\Encryption Context" | sed -e's/\|//' | awk '{print $3}'`
ENCRYPTIONEXTENTS=`diskutil cs list | grep -E "$EGREP_STRING\Has Encrypted Extents" | sed -e's/\|//' | awk '{print $4}'`
ENCRYPTION=`diskutil cs list | grep -E "$EGREP_STRING\Encryption Type" | sed -e's/\|//' | awk '{print $3}'`
CONVERTED=`diskutil cs list | grep -E "$EGREP_STRING\Size \(Converted\)" | sed -e's/\|//' | awk '{print $5, $6}'`
SIZE=`diskutil cs list | grep -E "$EGREP_STRING\Size \(Total\)" | sed -e's/\|//' | awk '{print $5, $6}'`

# Checks to see if the OS on the Mac is 10.7 or 10.8.
# If it is not, the following message is displayed without quotes:
# "FileVault 2 Encryption Not Available For This Version Of Mac OS X"

if [[ ${osvers} -lt 7 ]]; then
	encStatus="FileVault 2 Encryption Not Available For This Version Of Mac OS X"
	echo "$encStatus"
# Set ePO custom property for Recovery Key and Encryption Status and Sync
	/Library/McAfee/cma/bin/msaconfig -CustomProps1 "$recoveryKey" -CustomProps2 "$encStatus" -CustomProps3 "$timeStamp"
	sudo /Library/McAfee/cma/bin/cmdagent -P
fi



if [[ ${osvers} -ge 7 ]]; then
diskutil cs list >> $CORESTORAGESTATUS

# If the Mac is running 10.7 or 10.8, but does not have
# any CoreStorage volumes, the following message is
# displayed without quotes:
# "FileVault 2 Encryption Not Enabled"

	if grep -iE 'No CoreStorage' $CORESTORAGESTATUS 1>/dev/null; then
		encStatus="FileVault 2 Encryption Not Enabled"
		echo "$encStatus"
# Set ePO custom property for Recovery Key and Encryption Status and Sync
		/Library/McAfee/cma/bin/msaconfig -CustomProps1 "$recoveryKey" -CustomProps2 "$encStatus" -CustomProps3 "$timeStamp"
		sudo /Library/McAfee/cma/bin/cmdagent -P
	fi

# If the Mac is running 10.7 or 10.8 and has CoreStorage volumes,
# the script then checks to see if the machine is encrypted,
# encrypting, or decrypting.
#
# If encrypted, the following message is
# displayed without quotes:
# "FileVault 2 Encryption Complete"
#
# If encrypting, the following message is
# displayed without quotes:
# "FileVault 2 Encryption Proceeding."
# How much has been encrypted of of the total
# amount of space is also displayed. If the
# amount of encryption is for some reason not
# known, the following message is
# displayed without quotes:
# "FileVault 2 Encryption Status Unknown. Please check."
#
# If decrypting, the following message is
# displayed without quotes:
# "FileVault 2 Decryption Proceeding"
# How much has been decrypted of of the total
# amount of space is also displayed
#
# If fully decrypted, the following message is
# displayed without quotes:
# "FileVault 2 Decryption Complete"
#


	if grep -iE 'Logical Volume Family' $CORESTORAGESTATUS 1>/dev/null; then

# This section does 10.7-specific checking of the Mac's
# FileVault 2 status

		if [ "$CONTEXT" = "Present" ]; then
			if [ "$ENCRYPTION" = "AES-XTS" ]; then
			diskutil cs list | grep -E "$EGREP_STRING\Conversion Status" | sed -e's/\|//' | awk '{print $3}' >> $ENCRYPTSTATUS
				if grep -iE 'Complete' $ENCRYPTSTATUS 1>/dev/null; then
					encStatus="FileVault 2 Encryption Complete" 
					echo "$encStatus"
					# Set ePO custom property for Recovery Key and Encryption Status and Sync
					/Library/McAfee/cma/bin/msaconfig -CustomProps1 "$recoveryKey" -CustomProps2 "$encStatus" -CustomProps3 "$timeStamp"
					sudo /Library/McAfee/cma/bin/cmdagent -P
				else
					if  grep -iE 'Converting' $ENCRYPTSTATUS 1>/dev/null; then
						diskutil cs list | grep -E "$EGREP_STRING\Conversion Direction" | sed -e's/\|//' | awk '{print $3}' >> $ENCRYPTDIRECTION
						if grep -iE 'Forward' $ENCRYPTDIRECTION 1>/dev/null; then
							encStatus="FileVault 2 Encryption Proceeding. $CONVERTED of $SIZE Encrypted" 
							echo "$encStatus"
							# Set ePO custom property for Recovery Key and Encryption Status and Sync
							/Library/McAfee/cma/bin/msaconfig -CustomProps1 "$recoveryKey" -CustomProps2 "$encStatus" -CustomProps3 "$timeStamp"
							sudo /Library/McAfee/cma/bin/cmdagent -P
						else
							encStatus="FileVault 2 Encryption Status Unknown. Please check." 
							echo "$encStatus"
							# Set ePO custom property for Recovery Key and Encryption Status and Sync
							/Library/McAfee/cma/bin/msaconfig -CustomProps1 "$recoveryKey" -CustomProps2 "$encStatus" -CustomProps3 "$timeStamp"
							sudo /Library/McAfee/cma/bin/cmdagent -P
						fi
					fi
				fi
			else
				if [ "$ENCRYPTION" = "None" ]; then
					diskutil cs list | grep -E "$EGREP_STRING\Conversion Direction" | sed -e's/\|//' | awk '{print $3}' >> $ENCRYPTDIRECTION
						if grep -iE 'Backward' $ENCRYPTDIRECTION 1>/dev/null; then
							encStatus="FileVault 2 Decryption Proceeding. $CONVERTED of $SIZE Decrypted" 
							echo "$encStatus"
							# Set ePO custom property for Recovery Key and Encryption Status and Sync
							/Library/McAfee/cma/bin/msaconfig -CustomProps1 "$recoveryKey" -CustomProps2 "$encStatus" -CustomProps3 "$timeStamp"
							sudo /Library/McAfee/cma/bin/cmdagent -P
						elif grep -iE '-none-' $ENCRYPTDIRECTION 1>/dev/null; then
							encStatus="FileVault 2 Decryption Completed" 
							echo "$encStatus"
							# Set ePO custom property for Recovery Key and Encryption Status and Sync
							/Library/McAfee/cma/bin/msaconfig -CustomProps1 "$recoveryKey" -CustomProps2 "$encStatus" -CustomProps3 "$timeStamp"
							sudo /Library/McAfee/cma/bin/cmdagent -P
						fi
				fi
			fi
		fi
	fi
fi
# This section does 10.8-specific checking of the Mac's
# FileVault 2 status

if [ "$ENCRYPTIONEXTENTS" = "Yes" ]; then
	if [ "$ENCRYPTION" = "AES-XTS" ]; then
	diskutil cs list | grep -E "$EGREP_STRING\Fully Secure" | sed -e's/\|//' | awk '{print $3}' >> $ENCRYPTSTATUS
		if grep -iE 'Yes' $ENCRYPTSTATUS 1>/dev/null; then
			encStatus="FileVault 2 Encryption Complete" 
			echo "$encStatus"
			# Set ePO custom property for Recovery Key and Encryption Status and Sync
			/Library/McAfee/cma/bin/msaconfig -CustomProps1 "$recoveryKey" -CustomProps2 "$encStatus" -CustomProps3 "$timeStamp"
			sudo /Library/McAfee/cma/bin/cmdagent -P
		else
			if  grep -iE 'No' $ENCRYPTSTATUS 1>/dev/null; then
				diskutil cs list | grep -E "$EGREP_STRING\Conversion Direction" | sed -e's/\|//' | awk '{print $3}' >> $ENCRYPTDIRECTION
					if grep -iE 'forward' $ENCRYPTDIRECTION 1>/dev/null; then
						encStatus="FileVault 2 Encryption Proceeding. $CONVERTED of $SIZE Encrypted" 
						echo "$encStatus"
						# Set ePO custom property for Recovery Key and Encryption Status and Sync
						/Library/McAfee/cma/bin/msaconfig -CustomProps1 "$recoveryKey" -CustomProps2 "$encStatus" -CustomProps3 "$timeStamp"
						sudo /Library/McAfee/cma/bin/cmdagent -P
					else
						if grep -iE 'backward' $ENCRYPTDIRECTION 1>/dev/null; then
							encStatus="FileVault 2 Decryption Proceeding. $CONVERTED of $SIZE Decrypted" 
							echo "$encStatus"
							# Set ePO custom property for Recovery Key and Encryption Status and Sync
							/Library/McAfee/cma/bin/msaconfig -CustomProps1 "$recoveryKey" -CustomProps2 "$encStatus" -CustomProps3 "$timeStamp"
							sudo /Library/McAfee/cma/bin/cmdagent -P
						elif grep -iE '-none-' $ENCRYPTDIRECTION 1>/dev/null; then
							encStatus="FileVault 2 Decryption Completed" 
							echo "$encStatus"
							# Set ePO custom property for Recovery Key and Encryption Status and Sync
							/Library/McAfee/cma/bin/msaconfig -CustomProps1 "$recoveryKey" -CustomProps2 "$encStatus" -CustomProps3 "$timeStamp"
							sudo /Library/McAfee/cma/bin/cmdagent -P
						fi
					fi
			fi
		fi
	fi
fi
if [ "$ENCRYPTIONEXTENTS" = "No" ]; then
encStatus="FileVault 2 Encryption Not Enabled" 
echo "$encStatus"
# Set ePO custom property for Recovery Key and Encryption Status and Sync
/Library/McAfee/cma/bin/msaconfig -CustomProps1 "$recoveryKey" -CustomProps2 "$encStatus" -CustomProps3 "$timeStamp"
sudo /Library/McAfee/cma/bin/cmdagent -P
fi

# Remove the temp files created during the script

if [ -f /private/tmp/corestorage.txt ]; then
rm /private/tmp/corestorage.txt
fi

if [ -f /private/tmp/encrypt_status.txt ]; then
rm /private/tmp/encrypt_status.txt
fi

if [ -f /private/tmp/encrypt_direction.txt ]; then
rm /private/tmp/encrypt_direction.txt
fi

#Change the permissions back to normal
sudo chmod 700 /Library/McAfee/cma/scratch/
sudo chmod 755 /Library/McAfee/cma/scratch/etc
