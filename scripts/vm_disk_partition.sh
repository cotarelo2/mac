#!/bin/sh

GETDISK=`diskutil list | grep "GB" | grep -v "DeployStudioRuntime" | awk '{print $4}'`
echo "$GETDISK"

diskutil partitionDisk "${GETDISK}" HFS+ Macintosh\ HD 100%

exit 0
