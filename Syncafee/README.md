>#Syncafee

#Introduction
Syncafee seeks to aid Mac administrators deploying McAfee's ePO/FDE-(EEMac) products to client Apple computers OS Version 10.7 or above. Syncafee provides the client (or less-experienced Mac user) with an all-inclusive interface by which to deploy/assist/troubleshoot with command-line management tasks. The ePO and FDE products supplied by McAfee deploy separately, and provide only command-line functionality for performing synchronization tasks to the server. Moreover, the FDE (EEMac) product is deployed through the synchronization and server-queuing of ePO policy to encrypt the hard disk of a client Mac.

#Overview
When troubleshooting with a user/customer or onsite technician, there is little way to determine the status of a client machine's communication status without an interface to examine both log files (ePO and EEMac) and perform ePO synchronization tasks. Syncafee attempts to solve this problem by eliminating the command-line work performed by your users or customers. No icons for the UI have been included to allow contributors or users of the project to implement their own UI look and feel.

#PreRequisites/Requirements
1. McAfee ePO Agent installed
2. McAfee Endpoint Encryption for Mac (EEMac)
3. OS X Lion (10.7)
4. OS X Mountain Lion (10.8)
5. http://cobbservations.wordpress.com/2013/09/03/syncafee-2/

#Future Enhancements
1. Better idle handling of tasks
2. Real-time sync of log files as sync tasks are performed
3. Convert to ObjC/ARC
4. Inclusion of NSPopover element to provide further details for the log file status indicator or other UI elements.
5. Improve 'Restart McAfee Services' task

#Acknowledgements and References
1. ePO Packaging Tutorial -- Clif Hirtle -- https://docs.google.com/document/d/1fKThl5TbH20SHAfgzwUKGhVqO9AguUqzExLSMloSkuE/edit?usp=sharing
2. Special thanks to Shane Stanley and Stefan Klieme

#Version History
1.0 
Initial Release
1.1
Added reversal of permissions

#License
Copyright 2013 Nick Cobb

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0\

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
