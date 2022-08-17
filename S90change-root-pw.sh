#!/bin/bash
echo "Changing root password" > /dev/kmsg
echo "root:XXXXX" | chpasswd
pwconv
cp /etc/passwd /usr/config/backupconfig/etc/passwd
cp /etc/shadow /usr/config/backupconfig/etc/shadow   
echo "Finished changing root password" > /dev/kmsg
