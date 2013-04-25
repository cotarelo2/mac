#Syncafee

#Introduction
Syncafee seeks to aid Mac administrators deploying McAfee's ePO/FDE-(EEMac) products to client Apple computers OS Version 10.7 or above. Syncafee provides the client (or less-experienced Mac user) with an all-inclusive interface by which to deploy/assist/troubleshoot with command-line management tasks. The ePO and FDE products supplied by McAfee deploy separately, and provide only command-line functionality for performing synchronization tasks to the server. Moreover, the FDE (EEMac) product is deployed through the synchronization and server-queuing of ePO policy to encrypt the hard disk of a client Mac.

#Overview
When troubleshooting with a user/customer or onsite technician, there is little way to determine the status of a client machine's communication status without an interface to examine both log files (ePO and EEMac) and perform ePO synchronization tasks. Syncafee attempts to solve this problem by eliminating the command-line work performed by your user/customers. No icons for the UI have been included to allow contributors or users of the project to implement their own UI look and feel.

#PreRequisites/Requirements
McAfee ePO Agent installed
McAfee Endpoint Encryption for Mac (EEMac)
OS X Lion (10.7)
OS X Mountain Lion (10.8)

#Future Enhancements
Better idle handling of tasks
Real-time sync of log files as sync tasks are performed
Convert to ObjC/ARC
Inclusion of NSPopover element to provide further details for the log file status indicator or other UI elements.
Improve 'Restart McAfee Services' task

#Acknowledgements and References
ePO Packaging Tutorial 
- Clif Hirtle https://docs.google.com/document/d/1fKThl5TbH20SHAfgzwUKGhVqO9AguUqzExLSMloSkuE/edit?usp=sharing
Special thanks to Shane Stanley and Stefan Klieme

#Version History
1.0 
Initial Release

#License
Copyright 2013 Nick Cobb

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0\

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
