--
--  loyaltyarmAppDelegate.applescript
--  Syncafee
--
--  Created by Nick on 3/17/13.
--  Copyright (c) 2013 Nick. All rights reserved.
--

script loyaltyarmAppDelegate
	property parent : class "NSObject"
    
    -- property for the main window
    property mainWindow : missing value
    
    -- property declaration for logs as variables (receiving text from log files) passed through array controller to table views ie., array content
    property epoLog : {}
    property encLog : {}
    
    -- property declaration for array controllers
    property epoAC : missing value
    property encAC : missing value
    
    -- property declaration for progress indicators
    property spinnerBoy : missing value
    
    -- property declaration for log scrollviews
    property epoScroll : missing value
    property encScroll : missing value
    
    -- property declaration for log tableviews
    property epoTable : missing value
    property encTable : missing value
    
    -- property declaration for status indicators
    property epoOrb : missing value
    property encOrb : missing value
    property epoStatus : missing value
    property encStatus : missing value
    property epoFile : missing value
    property encFile : missing value
    property epoManager : missing value
    property encManager : missing value
    
    -- property declaration for application bundle
    property pathToMe : "NSString"
	
	on applicationWillFinishLaunching_(aNotification)
		-- Insert code here to initialize your application before any files are opened
        tell current application's class "NSBundle"
            tell its mainBundle()
                set pathToMe to resourcePath() as string
            end tell
        end tell
        
        -- Set Log Files as variables for NSFileManager checkFiles repeated tasks below applicationWillFinishLaunching
        set epoManager to current application's NSFileManager's defaultManager()
        set epoFile to "/Library/McAfee/cma/scratch/etc/log" as string
        current application's NSTimer's scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_(300, me, "checkEpo:", missing value, 1)
        
        set encManager to current application's NSFileManager's defaultManager()
        set encFile to "/Library/Logs/McAfee Endpoint Encryption.log" as string
        current application's NSTimer's scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_(300, me, "checkEnc:", missing value, 1)
        
        -- Change File Permissions on ePO Log File so it can be read by Syncafee
        try
            do shell script "chmod 777 /Library/McAfee/cma/scratch/" with administrator privileges
            on error
            log "Syncafee is unable to change permissions for " & epoFile
        end try
        try
            do shell script "chmod 777 /Library/McAfee/cma/scratch/etc/" with administrator privileges
            on error
            log "Syncafee is unable to change permissions for " & epoFile
        end try
        -- Tasks to check the presence of the log files
        checkEpo_(me)
        checkEnc_(me)
        -- Tasks to show the logs files if they are present
        if epoStatus = 1 then
            try
                epoREF_(me)
                on error
                log "Error Showing the ePO Log File - Startup"
                tell current application's NSAlert to set theAlert to alloc()'s init()
                tell theAlert
                    setMessageText_("Error Showing the Log File")
                    setInformativeText_("Syncafee got an error showing the ePO log file on startup.")
                    addButtonWithTitle_("OK")
                    setAlertStyle_(1)
                    set theResult to runModal()
                end tell
            end try
            else
            log "ePO log file could not be refreshed at startup. Please install or troubleshoot."
        end if
        if encStatus = 1 then
            try
                encREF_(me)
                on error
                log "Error Showing the Enc Log File - Startup"
                tell current application's NSAlert to set theAlert to alloc()'s init()
                tell theAlert
                    setMessageText_("Error Showing the Log File")
                    setInformativeText_("Syncafee got an error showing the Enc log file on startup.")
                    addButtonWithTitle_("OK")
                    setAlertStyle_(1)
                    set theResult to runModal()
                end tell
            end try
            else
            log "Enc log file could not be refreshed at startup. Please install or troubleshoot."
        end if
	end applicationWillFinishLaunching_
    
    --
    --
    --
    --
    --
    --
    -- Begin Handlers
    -- Check for ePO Log File Task...Runs every 5 minutes...sets status image for ePO Log File
    on checkEpo_(sender)
        log "Performing 5 minute ePO Log File Check"
        set var1 to epoManager's fileExistsAtPath_(epoFile)
        if var1 as integer = 1 then
            log "ePO Log File found"
            set epoStatus to 1
            else
            log "No ePO Log File Found"
            set epoStatus to 0
        end if
        if epoStatus = 1 then
            set imageName to current application's NSImageNameStatusAvailable
            else if epoStatus = 0 then
            set imageName to current application's NSImageNameStatusUnavailable
            else
            set imageName to current application's NSImageNameStatusPartiallyAvailable
        end if
        epoOrb's setImage_(current application's NSImage's imageNamed_(imageName))
    end checkEpo_
    
    -- Check for Enc Log File Task...Runs every 5 minutes...sets status image for Enc Log File
    on checkEnc_(sender)
        log "Performing 5 minute Enc Log File Check"
        set var1 to encManager's fileExistsAtPath_(encFile)
        if var1 as integer = 1 then
            log "Enc Log File found"
            set encStatus to 1
            else
            log "No Enc Log File Found"
            set encStatus to 0
        end if
        if encStatus = 1 then
            set imageName to current application's NSImageNameStatusAvailable
            else if epoStatus = 0 then
            set imageName to current application's NSImageNameStatusUnavailable
            else
            set imageName to current application's NSImageNameStatusPartiallyAvailable
        end if
        encOrb's setImage_(current application's NSImage's imageNamed_(imageName))
    end checkEnc_
    
    on alertDone_(theResult)
        log theResult
    end alertdone_
    -- End Handlers
    --
    --
    --
    --
    --
	--
    -- Begin Toolbar Items
    -- Launch ePO Package Installer
    on pkgButton_(sender)
        log "User Pressed Install button"
        tell current application's NSAlert to set theAlert to alloc()'s init()
        tell theAlert
            setMessageText_("Please Choose The Installation To Perform:")
            setInformativeText_("Click the button below to select the software to install on this machine.")
            addButtonWithTitle_("ePO Agent")
            addButtonWithTitle_("VirusScan")
            addButtonWithTitle_("Cancel")
            set theResult to runModal()
        end tell
        if theResult as integer = current application's NSAlertFirstButtonReturn as integer then
            log "User selected ePO Install"
            try
                set epoPkg to current application's NSBundle's mainBundle()'s pathForResource_ofType_("ePO", "mpkg")
                set ws to current application's NSWorkspace's sharedWorkspace()
                tell ws to openFile_withApplication_(epoPkg, "Installer")
                on error
                tell current application's NSAlert to set theAlert to alloc()'s init()
                tell theAlert
                    setMessageText_("Syncafee Encountered An Install Error")
                    setInformativeText_("Syncafee was unable to perform the task requested. Refer to the logs in Console for troubleshooting, or contact your system administrator.")
                    addButtonWithTitle_("OK")
                    setAlertStyle_(2)
                    set theResult to runModal()
                end tell
            end try
        else if theResult as integer = current application's NSAlertSecondButtonReturn as integer then
            log "User selected VirusScan option"
            try
                set virusPkg to current application's NSBundle's mainBundle()'s pathForResource_ofType_("Virusscan", "mpkg")
                set ws to current application's NSWorkspace's sharedWorkspace()
                tell ws to openFile_withApplication_(virusPkg, "Installer")
            on error
                tell current application's NSAlert to set theAlert to alloc()'s init()
                tell theAlert
                    setMessageText_("Syncafee Encountered An Install Error")
                    setInformativeText_("Syncafee was unable to perform the task requested. Refer to the logs in Console for troubleshooting, or contact your system administrator.")
                    addButtonWithTitle_("OK")
                    setAlertStyle_(2)
                    set theResult to runModal()
                end tell
            end try
            else if theResult as integer = current application's NSAlertThirdButtonReturn as integer then
            log "User Cancelled Installation"
        end if
    end pkgButton_
    
    -- Launch Laptop Encryption Registration Page
    on regButton_(sender)
        tell application "Safari"
            activate
            make new document
            open location "www.mycompany.com/registration"
        end tell
    end regButton_
    
    -- Collect and Send Properties Button
    on collectButton_(sender)
        log "User selected Collect and Send Properties"
        spinnerBoy's startAnimation_(spinnerBoy)
        try
            tell current application
                do shell script "/Library/McAfee/cma/bin/cmdagent  -P" with administrator privileges
            end tell
            current application's NSThread's sleepForTimeInterval_(5)
            try
                -- Load ePO Log File
                log "Collect and Send - Loading ePO Log"
                set unixpath to "/Library/McAfee/cma/scratch/etc/log"
                set UTF8StringEncoding to current application's NSUTF8StringEncoding
                set {txt, theError} to current application's NSString's stringWithContentsOfFile_encoding_error_(unixpath, UTF8StringEncoding, reference)
                if txt = missing value then
                    log theError
                    spinnerBoy's stopAnimation_(spinnerBoy)
                    else
                    set newlineCharacterSet to current application's NSCharacterSet's newlineCharacterSet()
                    set textParagraphs to txt's componentsSeparatedByString_("\n")
                    set my epoLog to textParagraphs
                    epoAC's rearrangeObjects()
                    epoTable's scrollRowToVisible_(epoAC's arrangedObjects()'s |count|() - 1)
                end if
            end try
            try
                -- Load Enc Log File
                log "Collect and Send - Loading Enc Log"
                set encpath to "/Library/Logs/McAfee Endpoint Encryption.log"
                set UTF8StringEncoding to current application's NSUTF8StringEncoding
                set {txt, theError} to current application's NSString's stringWithContentsOfFile_encoding_error_(encpath, UTF8StringEncoding, reference)
                if txt = missing value then
                    log theError
                    spinnerBoy's stopAnimation_(spinnerBoy)
                    else
                    set newlineCharacterSet to current application's NSCharacterSet's newlineCharacterSet()
                    set textParagraphs to txt's componentsSeparatedByString_("\n")
                    set my encLog to textParagraphs
                    encAC's rearrangeObjects()
                    encTable's scrollRowToVisible_(encAC's arrangedObjects()'s |count|() - 1)
                end if
            end try
            spinnerBoy's stopAnimation_(spinnerBoy)
            on error
            log "Collect and Send - Error Occurred"
            tell current application's NSAlert to set theAlert to alloc()'s init()
            tell theAlert
                setMessageText_("Syncafee Encountered An Error")
                setInformativeText_("Syncafee was unable to perform the task requested. Refer to the logs in Console for troubleshooting, or contact your system administrator.")
                addButtonWithTitle_("OK")
                setAlertStyle_(2)
                set theResult to runModal()
            end tell
            spinnerBoy's stopAnimation_(spinnerBoy)
        end try
    end collectButton_
    
    -- Enforce Policies Button
    on enforceButton_(sender)
        log "User selected Enforce Policies"
        spinnerBoy's startAnimation_(spinnerBoy)
        try
            tell current application
                do shell script "/Library/McAfee/cma/bin/cmdagent  -E" with administrator privileges
            end tell
            current application's NSThread's sleepForTimeInterval_(5)
            try
                -- Load ePO Log File
                log "Enforce - Loading ePO Log"
                set unixpath to "/Library/McAfee/cma/scratch/etc/log"
                set UTF8StringEncoding to current application's NSUTF8StringEncoding
                set {txt, theError} to current application's NSString's stringWithContentsOfFile_encoding_error_(unixpath, UTF8StringEncoding, reference)
                if txt = missing value then
                    log theError
                    spinnerBoy's stopAnimation_(spinnerBoy)
                    else
                    set newlineCharacterSet to current application's NSCharacterSet's newlineCharacterSet()
                    set textParagraphs to txt's componentsSeparatedByString_("\n")
                    set my epoLog to textParagraphs
                    epoAC's rearrangeObjects()
                    epoTable's scrollRowToVisible_(epoAC's arrangedObjects()'s |count|() - 1)
                end if
            end try
            try
                -- Load Enc Log File
                log "Enforce - Loading Enc Log"
                set encpath to "/Library/Logs/McAfee Endpoint Encryption.log"
                set UTF8StringEncoding to current application's NSUTF8StringEncoding
                set {txt, theError} to current application's NSString's stringWithContentsOfFile_encoding_error_(encpath, UTF8StringEncoding, reference)
                if txt = missing value then
                    log theError
                    spinnerBoy's stopAnimation_(spinnerBoy)
                    else
                    set newlineCharacterSet to current application's NSCharacterSet's newlineCharacterSet()
                    set textParagraphs to txt's componentsSeparatedByString_("\n")
                    set my encLog to textParagraphs
                    encAC's rearrangeObjects()
                    encTable's scrollRowToVisible_(encAC's arrangedObjects()'s |count|() - 1)
                end if
            end try
            spinnerBoy's stopAnimation_(spinnerBoy)
            on error
            log "Enforce Policies - Error Occurred"
            tell current application's NSAlert to set theAlert to alloc()'s init()
            tell theAlert
                setMessageText_("Syncafee Encountered An Error")
                setInformativeText_("Syncafee was unable to perform the task requested. Refer to the logs in Console for troubleshooting, or contact your system administrator.")
                addButtonWithTitle_("OK")
                setAlertStyle_(2)
                set theResult to runModal()
            end tell
            spinnerBoy's stopAnimation_(spinnerBoy)
        end try
    end enforceButton_
    
    -- Check New Policies Button
    on checkButton_(sender)
        log "User selected Check New Policies"
        spinnerBoy's startAnimation_(spinnerBoy)
        try
            tell current application
                do shell script "/Library/McAfee/cma/bin/cmdagent  -C" with administrator privileges
            end tell
            current application's NSThread's sleepForTimeInterval_(5)
            try
                -- Load ePO Log File
                log "Check - Loading ePO Log"
                set unixpath to "/Library/McAfee/cma/scratch/etc/log"
                set UTF8StringEncoding to current application's NSUTF8StringEncoding
                set {txt, theError} to current application's NSString's stringWithContentsOfFile_encoding_error_(unixpath, UTF8StringEncoding, reference)
                if txt = missing value then
                    log theError
                    spinnerBoy's stopAnimation_(spinnerBoy)
                    else
                    set newlineCharacterSet to current application's NSCharacterSet's newlineCharacterSet()
                    set textParagraphs to txt's componentsSeparatedByString_("\n")
                    set my epoLog to textParagraphs
                    epoAC's rearrangeObjects()
                    epoTable's scrollRowToVisible_(epoAC's arrangedObjects()'s |count|() - 1)
                end if
            end try
            try
                -- Load Enc Log File
                log "Check - Loading Enc Log"
                set encpath to "/Library/Logs/McAfee Endpoint Encryption.log"
                set UTF8StringEncoding to current application's NSUTF8StringEncoding
                set {txt, theError} to current application's NSString's stringWithContentsOfFile_encoding_error_(encpath, UTF8StringEncoding, reference)
                if txt = missing value then
                    log theError
                    spinnerBoy's stopAnimation_(spinnerBoy)
                    else
                    set newlineCharacterSet to current application's NSCharacterSet's newlineCharacterSet()
                    set textParagraphs to txt's componentsSeparatedByString_("\n")
                    set my encLog to textParagraphs
                    encAC's rearrangeObjects()
                    encTable's scrollRowToVisible_(encAC's arrangedObjects()'s |count|() - 1)
                end if
            end try
            spinnerBoy's stopAnimation_(spinnerBoy)
            on error
            log "Check Policies - Error Occurred"
            tell current application's NSAlert to set theAlert to alloc()'s init()
            tell theAlert
                setMessageText_("Syncafee Encountered An Error")
                setInformativeText_("Syncafee was unable to perform the task requested. Refer to the logs in Console for troubleshooting, or contact your system administrator.")
                addButtonWithTitle_("OK")
                setAlertStyle_(2)
                set theResult to runModal()
            end tell
            spinnerBoy's stopAnimation_(spinnerBoy)
        end try
    end checkButton_
    
    -- Forward Events Button
    on forwardButton_(sender)
        log "User selected Forward Events"
        spinnerBoy's startAnimation_(spinnerBoy)
        try
            tell current application
                do shell script "/Library/McAfee/cma/bin/cmdagent  -F" with administrator privileges
            end tell
            current application's NSThread's sleepForTimeInterval_(5)
            try
                -- Load ePO Log File
                log "Forward - Loading ePO Log"
                set unixpath to "/Library/McAfee/cma/scratch/etc/log"
                set UTF8StringEncoding to current application's NSUTF8StringEncoding
                set {txt, theError} to current application's NSString's stringWithContentsOfFile_encoding_error_(unixpath, UTF8StringEncoding, reference)
                if txt = missing value then
                    log theError
                    spinnerBoy's stopAnimation_(spinnerBoy)
                    else
                    set newlineCharacterSet to current application's NSCharacterSet's newlineCharacterSet()
                    set textParagraphs to txt's componentsSeparatedByString_("\n")
                    set my epoLog to textParagraphs
                    epoAC's rearrangeObjects()
                    epoTable's scrollRowToVisible_(epoAC's arrangedObjects()'s |count|() - 1)
                end if
            end try
            try
                -- Load Enc Log File
                log "Forward - Loading Enc Log"
                set encpath to "/Library/Logs/McAfee Endpoint Encryption.log"
                set UTF8StringEncoding to current application's NSUTF8StringEncoding
                set {txt, theError} to current application's NSString's stringWithContentsOfFile_encoding_error_(encpath, UTF8StringEncoding, reference)
                if txt = missing value then
                    log theError
                    spinnerBoy's stopAnimation_(spinnerBoy)
                    else
                    set newlineCharacterSet to current application's NSCharacterSet's newlineCharacterSet()
                    set textParagraphs to txt's componentsSeparatedByString_("\n")
                    set my encLog to textParagraphs
                    encAC's rearrangeObjects()
                    encTable's scrollRowToVisible_(encAC's arrangedObjects()'s |count|() - 1)
                end if
            end try
            spinnerBoy's stopAnimation_(spinnerBoy)
            on error
            log "Forward Events - Error Occurred"
            tell current application's NSAlert to set theAlert to alloc()'s init()
            tell theAlert
                setMessageText_("Syncafee Encountered An Error")
                setInformativeText_("Syncafee was unable to perform the task requested. Refer to the logs in Console for troubleshooting, or contact your system administrator.")
                addButtonWithTitle_("OK")
                setAlertStyle_(2)
                set theResult to runModal()
            end tell
            spinnerBoy's stopAnimation_(spinnerBoy)
        end try
    end forwardButton_
    
    on restartButton_(sender)
        log "User selected Restart Services Button"
        spinnerBoy's startAnimation_(spinnerBoy)
        try
            do shell script "/Library/StartupItems/cma/cma restart" with administrator privileges
            current application's NSThread's sleepForTimeInterval_(4)
            epoREF_(me)
            spinnerBoy's stopAnimation_(spinnerBoy)
            on error
            log "McAfee cma StartupItem not detected"
            tell current application's NSAlert to set theAlert to alloc()'s init()
            tell theAlert
                setMessageText_("McAfee Startup Services not detected")
                setInformativeText_("Syncafee encountered a problem while attempting to perform a restart of the McAfee services. Refer to the logs in Console for troubleshooting, or contact your system administrator.")
                addButtonWithTitle_("OK")
                setAlertStyle_(2)
                set theResult to runModal()
            end tell
        end try
        spinnerBoy's stopAnimation_(spinnerBoy)
    end restartButton_
    -- End Toolbar Buttons
    --
    --
    --
    --
    --
    -- Begin Window View Buttons and Interface Items
    -- Export the ePO Log File for Troubleshooting or Email to Administrator
    on exportEpo_(sender)
        log "User Selected Export ePO Log Button"
        spinnerBoy's startAnimation_(spinnerBoy)
        if epoStatus = 1 then
            current application's NSThread's sleepForTimeInterval_(2)
            try
                do shell script "cp -R /Library/McAfee/cma/scratch/etc/log ~/Desktop"
                tell current application's NSAlert to set theAlert to alloc()'s init()
                tell theAlert
                    setMessageText_("ePO Log Export Successful")
                    setInformativeText_("The ePO log was successfully exported to the desktop.")
                    addButtonWithTitle_("OK")
                    setAlertStyle_(1)
                    set theResult to runModal()
                end tell
                spinnerBoy's stopAnimation_(spinnerBoy)
                on error
                log "Error Exporting ePO Log File"
                tell current application's NSAlert to set theAlert to alloc()'s init()
                tell theAlert
                    setMessageText_("Error Exporting ePO Log File")
                    setInformativeText_("Syncafee was unable to export the ePO Log File. Refer to the logs in Console for troubleshooting, or contact your system administrator.")
                    addButtonWithTitle_("OK")
                    setAlertStyle_(2)
                    set theResult to runModal()
                end tell
                spinnerBoy's stopAnimation_(spinnerBoy)
            end try
            else
            log "Error Exporting ePO Log File - File Not Found"
            tell current application's NSAlert to set theAlert to alloc()'s init()
            tell theAlert
                setMessageText_("Error Exporting ePO Log File - File Not Found")
                setInformativeText_("Syncafee was unable to export the ePO Log File. Refer to the logs in Console for troubleshooting, or contact your system administrator.")
                addButtonWithTitle_("OK")
                setAlertStyle_(2)
                set theResult to runModal()
            end tell
            spinnerBoy's stopAnimation_(spinnerBoy)
        end if
    end exportEpo_
    
    -- Refresh the ePO Log Manually
    on epoREF_(sender)
        log "User selected ePO Log File Manual Refresh"
        spinnerBoy's startAnimation_(spinnerBoy)
        try
            current application's NSThread's sleepForTimeInterval_(2)
            set unixpath to "/Library/McAfee/cma/scratch/etc/log"
            set UTF8StringEncoding to current application's NSUTF8StringEncoding
            set {txt, theError} to current application's NSString's stringWithContentsOfFile_encoding_error_(unixpath, UTF8StringEncoding, reference)
            if txt = missing value then
                log theError
                log "Refresh ePO Log Manually - Error Occurred"
                tell current application's NSAlert to set theAlert to alloc()'s init()
                tell theAlert
                    setMessageText_("Syncafee Encountered An Error")
                    setInformativeText_("Syncafee was unable to perform the task requested. Refer to the logs in Console for troubleshooting, or contact your system administrator.")
                    addButtonWithTitle_("OK")
                    setAlertStyle_(2)
                    set theResult to runModal()
                end tell
                spinnerBoy's stopAnimation_(spinnerBoy)
                else
                set newlineCharacterSet to current application's NSCharacterSet's newlineCharacterSet()
                set textParagraphs to txt's componentsSeparatedByString_("\n")
                set my epoLog to textParagraphs
                epoAC's rearrangeObjects()
                epoTable's scrollRowToVisible_(epoAC's arrangedObjects()'s |count|() - 1)
            end if
        end try
        spinnerBoy's stopAnimation_(spinnerBoy)
    end epoREF_
    
    -- Export the Enc Log File for Troubleshooting or Email to Administrator
    on exportEnc_(sender)
        log "User Selected Export Enc Log Button"
        spinnerBoy's startAnimation_(spinnerBoy)
        if encStatus = 1 then
            current application's NSThread's sleepForTimeInterval_(2)
            try
                do shell script "cp -R '/Library/Logs/McAfee Endpoint Encryption.log' ~/Desktop"
                tell current application's NSAlert to set theAlert to alloc()'s init()
                tell theAlert
                    setMessageText_("Encryption Log Export Successful")
                    setInformativeText_("The encryption log was successfully exported to the desktop.")
                    addButtonWithTitle_("OK")
                    setAlertStyle_(1)
                    set theResult to runModal()
                end tell
                spinnerBoy's stopAnimation_(spinnerBoy)
                on error
                log "Error Exporting Enc Log File"
                tell current application's NSAlert to set theAlert to alloc()'s init()
                tell theAlert
                    setMessageText_("Error Exporting Enc Log File")
                    setInformativeText_("Syncafee was unable to export the Encryption Log File. Refer to the logs in Console for troubleshooting, or contact your system administrator.")
                    addButtonWithTitle_("OK")
                    setAlertStyle_(2)
                    set theResult to runModal()
                end tell
                spinnerBoy's stopAnimation_(spinnerBoy)
            end try
            else
            log "Error Exporting Enc Log File - File Not Found"
            tell current application's NSAlert to set theAlert to alloc()'s init()
            tell theAlert
                setMessageText_("Error Exporting Enc Log File - File Not Found")
                setInformativeText_("Syncafee was unable to export the Encryption Log File. Refer to the logs in Console for troubleshooting, or contact your system administrator.")
                addButtonWithTitle_("OK")
                setAlertStyle_(2)
                set theResult to runModal()
            end tell
            spinnerBoy's stopAnimation_(spinnerBoy)
        end if
    end exportEnc_
    
    -- Refresh the Encryption Log Manually
    on encREF_(sender)
        log "User selected Enc Log File Manual Refresh"
        spinnerBoy's startAnimation_(spinnerBoy)
        try
            current application's NSThread's sleepForTimeInterval_(2)
            set encpath to "/Library/Logs/McAfee Endpoint Encryption.log"
            set UTF8StringEncoding to current application's NSUTF8StringEncoding
            set {txt, theError} to current application's NSString's stringWithContentsOfFile_encoding_error_(encpath, UTF8StringEncoding, reference)
            if txt = missing value then
                log theError
                log "Refresh Enc Log Manually - Error Occurred"
                tell current application's NSAlert to set theAlert to alloc()'s init()
                tell theAlert
                    setMessageText_("Syncafee Encountered An Error")
                    setInformativeText_("Syncafee was unable to perform the task requested. Refer to the logs in Console for troubleshooting, or contact your system administrator.")
                    addButtonWithTitle_("OK")
                    setAlertStyle_(2)
                    set theResult to runModal()
                end tell
                spinnerBoy's stopAnimation_(spinnerBoy)
                else
                set newlineCharacterSet to current application's NSCharacterSet's newlineCharacterSet()
                set textParagraphs to txt's componentsSeparatedByString_("\n")
                set my encLog to textParagraphs
                encAC's rearrangeObjects()
                encTable's scrollRowToVisible_(encAC's arrangedObjects()'s |count|() - 1)
            end if
        end try
        spinnerBoy's stopAnimation_(spinnerBoy)
    end encREF_
    
    on helpButton_(sender)
    end helpButton_
    
	on applicationShouldTerminate_(sender)
		-- Insert code here to do any housekeeping before your application quits 
		return current application's NSTerminateNow
	end applicationShouldTerminate_
	
end script