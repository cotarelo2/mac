>#EscrowtoEPO (E2E)

#Introduction
EscrowtoEPO is a project born out of the behavioral inconsistency of McAfee's EEMac FDE solution in (my) enterprise. McAfee's EEMac FDE product is somewhat incomplete in its feature-set, specifically requiring an enterprise to blocok software updates to encrypted Macs in order to maintain the integrity of the encryption product. It combines information shared across the Mac Enterprise community of administrators regarding the escrow of FileVault recovery keys to existing enterprise systems. EscrowtoEPO combines two ideas specifically:

1. Christopher Silvertooth's escrow of FileVault recovery keys to Active Directory (and accompanying scripts).
2. Patrick Gallagher's installation (more specifically, the usage of custom properties in ePO) of McAfee's ePO product.
3. My own Syncafee project found at http://github.com/loyaltyarm/mac
4. Rich Trouton's FileVault 2 Status scripts

See the references section for more info on these projects.

#Overview
EscrowtoEPO is an ApplescriptObjC application that allows the a user to enable FileVault 2 full-disk encryption, and provides a mechanism (the application's function) to synchronize the recovery key as a custom machine property back to your McAfee ePO environment. This ensures that the recovery key safely resides on a system built for retaining security policies and other client security information and allows enterprises the ability to leverage Apple's FDE solution. The recovery key used can be individual, which allows the administrator the ability to manage a recovery key that is different for every machine. In environments where users are administrators, once FileVault 2 is enabled users can manage additional users added to the machine via System Preferences. In non-users-as-admins environments, the usage of configuration profiles can assist administrators in deploying encrypted systems in this manner.

#PreRequisites/Requirements
1. McAfee's ePO product (environment infrastructure and client)
2. OS X Mountain Lion 10.8

#Future Enhancements
1. Convert to ObjC/ARC (application currently uses GCC memory management with ASOC)
2. Inclusion of NSPopover element for user information tasks
3. Improved text validation of user input fields--potentially have users validated or read from "dscl task at first launch"

#Acknowledgements and References
1. Documentation of FV2 Encryption configuration options as well as FileVault 2 Status scripts
----Rich Trouton http://derflounder.wordpress.com/
2. FV2 Escrow to AD/OD scripts and workflows/documentation
----Christopher Silvertooth http://musings.silvertooth.us/2012/09/filevault-key-escrow-version-2-0-mountain-lion-only/
3. Get User Details (ePO Custom Properties)
----Patrick Gallagher https://github.com/patgmac/scripts/blob/master/bash/McAfee_getUsersDetails.sh
Thanks guys!

#Version History
1.0
Initial Release

1.1
Application packaged
Addition of FV2 Status scripts assigned as LaunchDaemon to report on the status (RunAtLoad and Once every 24 hours)

#License
Copyright 2013 Nick Cobb (contact - loyaltyarm@gmail.com)

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
       
http://www.apache.org/licenses/LICENSE-2.0\

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
