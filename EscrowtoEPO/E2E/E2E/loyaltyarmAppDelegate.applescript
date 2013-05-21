--
--  loyaltyarmAppDelegate.applescript
--  E2E
--
--  Created by Nick on 4/27/13.
--  Copyright (c) 2013 Nick. All rights reserved.
--

script loyaltyarmAppDelegate
	property parent : class "NSObject"
        
    -- property declarations for user interface items and references
    property userValue : missing value
    property userEntry : missing value
    property passValue : missing value
    property passEntry : missing value
    property fvStatus : missing value
    property recoveryKey : missing value
    property spinnerBro : missing value
    property theWindow : missing value
    
    -- property declaration for recovery plist directory
    property secureDir : missing value
    property plistDir : missing value
    property appDir : missing value
    property vaultMaster : missing value
    property vaultCert : missing value
    
    -- property declarations for ePO sync tasks, displays, and references
    property epoFile : missing value
    property epoLog : {}
    property epoAC : missing value
    property epoTable : missing value
    property epoScroll : missing value
    property theKey : missing value
    
    -- property declaration for application bundle
    property pathToMe : "NSString"
    
    on applicationWillFinishLaunching_(aNotification)
		-- Insert code here to initialize your application before any files are opened
        set epoFile to "/Library/McAfee/cma/scratch/etc/log"
        try
            do shell script "chmod 777 /Library/McAfee/cma/scratch/" with administrator privileges
            on error
            log "EscrowtoEPO (launching) is unable to change permissions for " & epoFile
        end try
        try
            do shell script "chmod 755 /Library/McAfee/cma/scratch/etc/" with administrator privileges
            on error
            log "EscrowtoEPO (launching) is unable to change permissions for " & epoFile
        end try
        tell current application's class "NSBundle"
            tell its mainBundle()
                set pathToMe to resourcePath() as string
            end tell
        end tell
        -- Begin check for /Library/YourCompany folder
        tell current application
            set appDir to "/Library/YourCompany"
            set plistDir to "/Library/YourCompany/recoverykey.plist"
            set secureDir to "/usr/local/recoverykeyfailover.plist"
            try
                do shell script "mkdir " & appDir with administrator privileges
                on error
                log "There was an error creating the YourCompany folder. This usually occurs because it already exists."
            end try
        end tell
        -- Begin check for FileVault Master Keychain
        tell current application
            set vaultMaster to "/Library/Keychains/FileVaultMaster.keychain" as POSIX file
        end tell
        try
            tell application "Finder"
                if exists file vaultMaster then
                    tell current application's NSAlert to set theAlert to alloc()'s init()
                    tell theAlert
                        setMessageText_("EscrowtoEPO Found a Problem")
                        setInformativeText_("A FileVaultMaster keychain file exists in /Library/Keychains/. Please remove this file before attempting to enable encryption with E2E.")
                        addButtonWithTitle_("OK")
                        setAlertStyle_(2)
                        set theResult to runModal()
                    end tell
                end if
            end tell
            log "E2E found " & vaultMaster & ". Please remove this file to continue."
            on error
            log "E2E did not seem to find a FVMaster Keychain file. Proceeding with care."
        end try
        -- Begin check for FileVault Master Certificate
        tell current application
            set vaultCert to "/Library/Keychains/FileVaultMaster.cer" as POSIX file
        end tell
        try
            tell application "Finder"
                if exists file vaultCert then
                    tell current application's NSAlert to set theAlert to alloc()'s init()
                    tell theAlert
                        setMessageText_("EscrowtoEPO Found a Problem")
                        setInformativeText_("A FileVaultMaster certificate exists in /Library/Keychains/. Please remove this file before attempting to enable encryption with E2E.")
                        addButtonWithTitle_("OK")
                        setAlertStyle_(2)
                        set theResult to runModal()
                    end tell
                end if
            end tell
            log "E2E found " & vaultCert & ". Please remove this file to continue."
        on error
            log "E2E did not seem to find a FVMaster Cert file. Again, we are proceeding with care."
        end try
	end applicationWillFinishLaunching_
    
    on regButton_(sender)
        tell application "Safari"
            activate
            make new document
            open location "http://yourcompany.registrationpage.com/"
        end tell
    end regButton_
    
    on encryptButton_(sender)
        -- CHECK TO MAKE USERNAME AND PASSWORD FIELDS REQUIRED
        log "User attempted to enable encryption for -- " & (stringValue() of userEntry)
        set userValue to userEntry's stringValue()
        set passValue to passEntry's stringValue()
        -- IF NO USERNAME ENTERED THEN ERROR AND FAILURE
        if userValue's |length|() is 0 then
            log "No username was entered."
            tell current application's NSAlert to set theAlert to alloc()'s init()
            tell theAlert
                setMessageText_("EscrowtoEPO Encountered An Error")
                setInformativeText_("You must enter a username.")
                addButtonWithTitle_("OK")
                setAlertStyle_(2)
                set theResult to runModal()
            end tell
            theWindow's displayIfNeeded()
            my fvStatus's setTextColor_(current application's NSColor's redColor)
            my fvStatus's setStringValue_("You must enter a username!")
            -- IF NO PASSWORD ENTERED THEN ERROR AND FAILURE
        else if passValue's |length|() is 0 then
            log "No password was entered."
            tell current application's NSAlert to set theAlert to alloc()'s init()
            tell theAlert
                setMessageText_("EscrowtoEPO Encountered An Error")
                setInformativeText_("You must enter a password.")
                addButtonWithTitle_("OK")
                setAlertStyle_(2)
                set theResult to runModal()
            end tell
            theWindow's displayIfNeeded()
            my fvStatus's setTextColor_(current application's NSColor's redColor)
            my fvStatus's setStringValue_("You must enter a password!")
        else
            spinnerBro's startAnimation_(spinnerBro)
            theWindow's displayIfNeeded()
            my fvStatus's setTextColor_(current application's NSColor's blackColor)
            my fvStatus's setStringValue_("Attempting to enable full disk encryption...")
            -- ALERT TO VERIFY MACHINE HAS BEEN REGISTERED BEFORE PROCEEDING
            tell current application's NSAlert to set theAlert to alloc()'s init()
            tell theAlert
                setMessageText_("CAUTION: Registration is required!")
                setInformativeText_("Registration for encryption is required before proceeding. If you have already registered this computer, you may select Continue below.")
                addButtonWithTitle_("Register")
                addButtonWithTitle_("Continue")
                addButtonWithTitle_("Cancel")
                setAlertStyle_(2)
                set theButton to runModal()
            end tell
            if theButton as integer = current application's NSAlertFirstButtonReturn as integer then
                log "User selected Register"
                spinnerBro's stopAnimation_(spinnerBro)
                regButton_(me)
            else if theButton as integer = current application's NSAlertSecondButtonReturn as integer then
                log "User selected Continue"
                try
                    log "Encryption being enabled for user -- " & (stringValue() of userEntry)
                    -- Do shell script to enable encryption
                    do shell script "/usr/bin/fdesetup enable -user " & (stringValue() of userEntry) & " -password " & (stringValue() of passEntry) & " -outputplist > " & plistDir with administrator privileges
                    current application's NSThread's sleepForTimeInterval_(1)
                    theWindow's displayIfNeeded()
                    my fvStatus's setTextColor_(current application's NSColor's blackColor)
                    my fvStatus's setStringValue_("Getting recovery key...")
                    current application's NSThread's sleepForTimeInterval_(2)
                    -- Task to read the Recovery Key
                    tell current application's NSPipe to set outPipe to pipe()
                    set outFileHandle to outPipe's fileHandleForReading()
                    tell current application's NSTask to set theTask to alloc()'s init()
                    tell theTask
                        setLaunchPath_("/usr/bin/defaults")
                        setArguments_({"read", plistDir, "RecoveryKey"})
                        setStandardOutput_(outPipe)
                        |launch|()
                    end tell
                    tell outFileHandle to set theData to readDataToEndOfFile()
                    set theResult to current application's NSString's alloc()'s initWithData_encoding_(theData, current application's NSUTF8StringEncoding)
                    set theKey to theResult as text
                    if theTask's terminationStatus() as integer is not 0 then set theResult to "There was an error"
                    my recoveryKey's setStringValue_(theKey)
                    if theResult = "There was an error" then
                        theWindow's displayIfNeeded()
                        my fvStatus's setTextColor_(current application's NSColor's redColor)
                        my fvStatus's setStringValue_("There was an error enabling encryption!")
                    else
                        theWindow's displayIfNeeded()
                        my fvStatus's setTextColor_(current application's NSColor's blackColor)
                        my fvStatus's setStringValue_("Recovery Key active, initiating the sync process...")
                        -- INSERT THE COMMAND FOR TASKS HANDLER TO SET CUSTOM PROP/SYNC/DELETE
                        encSuccess_(me)
                        theWindow's displayIfNeeded()
                        my fvStatus's setTextColor_(current application's NSColor's blackColor)
                        my fvStatus's setStringValue_("Encryption has now been enabled! Please restart the computer.")
                        spinnerBro's stopAnimation_(spinnerBro)
                        tell current application's NSAlert to set theAlert to alloc()'s init()
                        tell theAlert
                            setMessageText_("EscrowtoEPO Requires A Restart!")
                            setInformativeText_("Please restart the computer to enable encryption.")
                            addButtonWithTitle_("OK")
                            setAlertStyle_(2)
                            set theResult to runModal()
                        end tell
                    end if
                on error
                    log "There was an error during this attempt. Check to make sure an existing account's credentials were used on this machine, and that they were entered correctly. Also check to make sure that the /Library/YourCompany folder is present, and that FileVault is not already enabled and needing a restart. Contact your administrator for more information on these steps."
                    theWindow's displayIfNeeded()
                    my fvStatus's setTextColor_(current application's NSColor's redColor)
                    my fvStatus's setStringValue_("An error occurred during this attempt!")
                    spinnerBro's stopAnimation_(spinnerBro)
                    tell current application's NSAlert to set theAlert to alloc()'s init()
                    tell theAlert
                        setMessageText_("EscrowtoEPO Encountered An Error")
                        setInformativeText_("EscrowtoEPO was unable to perform the task requested. Refer to the logs in Console for troubleshooting, or contact your system administrator.")
                        addButtonWithTitle_("OK")
                        setAlertStyle_(2)
                        set theResult to runModal()
                    end tell
                end try
            else if theButton as integer = current application's NSAlertThirdButtonReturn as integer then
                log "User Cancelled Encryption"
                theWindow's displayIfNeeded()
                my fvStatus's setTextColor_(current application's NSColor's redColor)
                my fvStatus's setStringValue_("User Cancelled Encryption")
                spinnerBro's stopAnimation_(spinnerBro)
            end if
        end if
    end encryptButton_
    
    -- Error-checked Processes to Set Recovery Key as Custom Property, Sync, Remove the Recovery plist file
    on encSuccess_(sender)
        theWindow's displayIfNeeded()
        my fvStatus's setTextColor_(current application's NSColor's blackColor)
        my fvStatus's setStringValue_("Preparing data for sync...")
        current application's NSThread's sleepForTimeInterval_(1)
        try
            -- Set the FV2 Recovery Key as an EPO custom property
            tell current application's NSPipe to set outPipe to pipe()
            set outFileHandle to outPipe's fileHandleForReading()
            tell current application's NSTask to set theTask to alloc()'s init()
            tell theTask
                setLaunchPath_("/Library/McAfee/cma/bin/msaconfig")
                setArguments_({"-CustomProps1", theKey})
                setStandardOutput_(outPipe)
                |launch|()
            end tell
            tell outFileHandle to set theData to readDataToEndOfFile()
            set taskResult to current application's NSString's alloc()'s initWithData_encoding_(theData, current application's NSUTF8StringEncoding)
            if theTask's terminationStatus() as integer is not 0 then set taskResult to "There was an error"
            if taskResult = "There was an error" then
                do shell script "cp -R " & plistDir & " " & secureDir with administrator privileges
                theWindow's displayIfNeeded()
                current application's NSThread's sleepForTimeInterval_(1)
                log "There was an error setting the recovery key as a custom property. The ePO agent may need to be re-installed."
                tell current application's NSAlert to set theAlert to alloc()'s init()
                tell theAlert
                    setMessageText_("EscrowtoEPO Encountered An Error")
                    setInformativeText_("EscrowtoEPO was unable to perform the escrow task because of a problem with the ePO agent. The key has been securely exported.")
                    addButtonWithTitle_("OK")
                    setAlertStyle_(2)
                    set theResult to runModal()
                end tell
                syncButton_(me)
                theWindow's displayIfNeeded()
                my fvStatus's setTextColor_(current application's NSColor's blackColor)
                my fvStatus's setStringValue_("Finalizing the process...")
                current application's NSThread's sleepForTimeInterval_(1)
                do shell script "rm -rf " & plistDir with administrator privileges
            else
                theWindow's displayIfNeeded()
                my fvStatus's setTextColor_(current application's NSColor's blackColor)
                my fvStatus's setStringValue_("Synchronizing with the server...")
                -- Perform a Collect and Send Properties sync to send the key to the EPO server
                syncButton_(me)
                -- Remove the Recovery plist from the machine for security
                theWindow's displayIfNeeded()
                my fvStatus's setTextColor_(current application's NSColor's blackColor)
                my fvStatus's setStringValue_("Finalizing the process...")
                current application's NSThread's sleepForTimeInterval_(1)
                do shell script "rm -rf " & plistDir with administrator privileges
            end if
        on error
            theWindow's displayIfNeeded()
            my fvStatus's setTextColor_(current application's NSColor's redColor)
            my fvStatus's setStringValue_("An error occurred during the sync!")
            tell current application's NSAlert to set theAlert to alloc()'s init()
            tell theAlert
                setMessageText_("EscrowtoEPO Encountered An Error")
                setInformativeText_("EscrowtoEPO was unable to perform the escrow task as requested. Refer to the logs in Console for troubleshooting, or contact your system administrator.")
                addButtonWithTitle_("OK")
                setAlertStyle_(2)
                set theResult to runModal()
            end tell
            log "An error here indicates something happened during the escrow process. It could be the ePO agent's fault, given this point in the application."
        end try
    end encSuccess_
    
    on alertDone_(theResult)
        log theResult
    end alertdone_
    
    on syncButton_(sender)
        log "User selected Synchronize"
        spinnerBro's startAnimation_(spinnerBro)
        theWindow's displayIfNeeded()
        fvStatus's setTextColor_(current application's NSColor's blackColor)
        fvStatus's setStringValue_("Initiating sync with the server...")
        try
            tell current application
                do shell script "/Library/McAfee/cma/bin/cmdagent  -P" with administrator privileges
            end tell
            current application's NSThread's sleepForTimeInterval_(3)
            try
                -- Load ePO Log File
                log "Collect and Send - Loading ePO Log"
                set unixpath to "/Library/McAfee/cma/scratch/etc/log"
                set UTF8StringEncoding to current application's NSUTF8StringEncoding
                set {txt, theError} to current application's NSString's stringWithContentsOfFile_encoding_error_(unixpath, UTF8StringEncoding, reference)
                if txt = missing value then
                    log theError
                    spinnerBro's stopAnimation_(spinnerBro)
                else
                    set newlineCharacterSet to current application's NSCharacterSet's newlineCharacterSet()
                    set textParagraphs to txt's componentsSeparatedByString_("\n")
                    set my epoLog to textParagraphs
                    epoAC's rearrangeObjects()
                    epoTable's scrollRowToVisible_(epoAC's arrangedObjects()'s |count|() - 1)
                    theWindow's displayIfNeeded()
                    fvStatus's setTextColor_(current application's NSColor's blackColor)
                    fvStatus's setStringValue_("Synchronize task complete!")
                end if
            end try
            spinnerBro's stopAnimation_(spinnerBro)
            on error
            log "Collect and Send - Error Occurred"
            tell current application's NSAlert to set theAlert to alloc()'s init()
            tell theAlert
                setMessageText_("EscrowtoEPO Encountered An Error")
                setInformativeText_("EscrowtoEPO was unable to perform the task requested. Refer to the logs in Console for troubleshooting, or contact your system administrator.")
                addButtonWithTitle_("OK")
                setAlertStyle_(2)
                set theResult to runModal()
            end tell
            spinnerBro's stopAnimation_(spinnerBro)
        end try
    end syncButton_
	
	on applicationShouldTerminate_(sender)
		-- Insert code here to do any housekeeping before your application quits
        try
            do shell script "chmod 755 /Library/McAfee/cma/scratch/etc/" with administrator privileges
        on error
            log "EscrowtoEPO (terminating) is unable to change permissions for " & epoFile
        end try
        try
            do shell script "chmod 700 /Library/McAfee/cma/scratch/" with administrator privileges
        on error
            log "EscrowtoEPO (terminating) is unable to change permissions for " & epoFile
        end try
		return current application's NSTerminateNow
	end applicationShouldTerminate_
	
end script