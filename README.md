# Seagate-Central-Tips
Tips for optimizing and fixing common problems on the Seagate
Central NAS device.

This document is a collection of suggestions, optimizations and 
configuration changes I've made on my own Seagate Central NAS
device to make it more useable as well as some procedures that attempt
to fix commonly encountered problems. Many of these instructions 
assume you have su/root access to your Seagate Central.

Please also refer to the following associated projects
for further information about enhancing the Seagate Central
with new software.

### Seagate-Central-Samba
https://github.com/bertofurth/Seagate-Central-Samba

A replacement Samba server for the Seagate Central that fixes
the severe security issues with the old SMBv1.0 protocol and allows
modern security conscious clients like Windows 10 to connect
seamlessly to the Seagate Central. This project also provides
an easy method to restore su/root access on a Seagate Central
device.
 
### Seagate-Central-Slot-In-v5.x-Kernel
https://github.com/bertofurth/Seagate-Central-Slot-In-v5.x-Kernel

A "slot in" modern kernel that allows the Seagate Central to
use modern Linux operating system features such as SMP, IPv6
and support for more modern services.

### Seagate-Central-Utils
https://github.com/bertofurth/Seagate-Central-Utils

Instructions for building and installing a variety of new tools
and services on the Seagate Central.

### Seagate-Central-Toolchain
https://github.com/bertofurth/Seagate-Central-Toolchain

Generate a cross compilation toolchain that allows a fast building
host to compile new software for the Seagate Central.

## Allow multiple users to access a Samba share
By default, only the user who is the owner of a network share is
allowed to access it. It might be useful for multiple users 
to be able to access particular shares.

This can be accomplished by manually editing the text configuration
file that governs samba configuration for individual users
"/usr/private/user_smb_conf/.overall_share"

This file contains sections starting with "[username]" that
control the parameters for each user share. For example, for
user "fred" we have

    [fred]
    map read only = no
    comment = syncthing
    valid users = "fred"
    writable = yes
    write list = fred
    path = /shares/fred

We can allow user "ginger" to also be granted access to this folder
by adding her username to the "valid users" option as follows. Note
that we have **removed the double quotes**. 

    [fred]
    ...
    valid users = fred ginger
    ...
    
After this change is made the newly modified
"/usr/private/user_smb_conf/.overall_share" file need to be copied
over to the Seagate Central backup configuration directory in order 
for the change to survive a system reboot.

    cp /usr/private/user_smb_conf/.overall_share /usr/config/backupconfig/usr/private/user_smb_conf/.overall_share
    
An optional but useful step is to run the "testparm" command which will
confirm that the changes you have made are compatible with the samba
service. Any erroneous entries will be noted by the output of this
command. 
    
    testparm
    
Finally, the samba service needs to be reloaded for the changes to
take effect. This can be done by rebooting the unit or by running the
following command.

    /etc/init.d/samba reload
    

## Stop particular users from logging in via ssh.
It may be that you have user accounts on the Seagate Central that have
no legitimate reason to establish ssh sessions to the Seagate Central.

For example, if you have installed a new service on the Seagate Central
as part of the **Seagate-Central-Utils** project you may have a user
account that is only associated with a particular daemon and would
never actually need to login to the unit.

If this is the case then it might be wise to change the shell for such
a user to "/bin/false" as per the following example

    # chsh -s /bin/false myuser
    Changing shell for myuser.
    Warning: "/bin/false" is not listed in /etc/shells.
    Shell changed.
          
Note, if you get an error message "setpwnam: File exists" then this
can be overcome by deleting "/etc/ptmp" and running the chsh command
again.

## Storage Usage pie chart not correct.
Sometimes after making significant system changes you may notice
that the disk usage pie chart displayed in the Seagate Central
Web Management interface is wildly incorrect or displays confusing
information.

This can be caused by the cache containing the per user disk usage
results becoming corrupted.

This cache can be cleared with the following command.

    rm /var/lib/usage.cache

The process that calculates disk usage for the pie chart is scheduled
to run at 3am each morning or if the Web Management interface is
opened and the cache is empty. You can manually invoke the process with
the following command.

    /usr/bin/get_usage_info.sh --update_cache
    
Note that the process of calculating disk usage can take a very long
time and is quite CPU intensive because the entire directory tree of
the Data volume needs to be probed.

## USB Hubs
While USB hubs work with the Seagate Central to allow you to
connect multiple storage devices and even other types of USB
devices, they are not very reliable if they are "unpowered".

While testing the USB Video camera functionality as seen at

https://github.com/bertofurth/Seagate-Central-Slot-In-v5.x-Kernel/blob/main/README_USB_DEVICE_MODULES.md

and

https://github.com/bertofurth/Seagate-Central-Utils/blob/main/motion/README-motion.md

I found that USB cameras connected to an unpowered hub would sometimes
reset unexpectedly, but when they were directly connected to the 
Seagate Central there were no problems.

## User home directory security problem
By default on the Seagate Central, user's home directories are 
writeable by every other user!

This means that one user "fred" can login to the Seagate Central via
ssh and not only view all of the files belonging to another user "ginger",
he can change and delete them as well!

To setup the home directory of "ginger" so that other users can read
the contents of it but not change it, issue the following command as root.

    chmod 755 ~ginger
     
Further to that, if you do not wish other users to be able to even
see what's in the home directory belonging to "fred" then the following
command can be issued as root.

    chmod 700 ~fred
    
Some administrators prefer to use mode "711" since some servers need to
be able to traverse some user's directories but not read the contents.

## Admin user home directory creation bug
Recent versions of Seagate Central firmware have an annoying but not 
catastrophic bug whereby when an administrator level user is created, the
home directory for that user is set to /home/username. 

While using /home as the base for home directories is normal on standard
Linux systems, it is not workable on a Seagate Central. This is because when
a Seagate Central is upgraded, the root partition (which houses the /home
directories) is completely wiped out!

The result of this is that when an admin level user logs in via ssh after
a firmware upgrade they are greeted with an error message similar to the
following.

    Could not chdir to home directory /home/admin: No such file or directory

In addition, any data they may have stored in the home directory is lost!
(In actual fact, the old home directory will be stored on the "backup" root
partition however it will be tedious to retrieve.)

Instead, it is much better to have a home directory on the Data partition
as normal users do. For this reason I would strongly reccommend that you
manually change the home directory associated with all admin level users
with the following style of "usermod" command. Remember to run the "cp"
command shown to ensure the changes hold after a system reboot.

     usermod -d /Data/admin admin
     usermod -d /Data/admin2 admin2
     cp /etc/passwd /usr/config/backupconfig/etc/

## Other cross compiled tools
I have installed the following useful tools that I haven't explicitly
generated cross compilation instructions for

### DDH - Directory Differential hTool (Rust)
A tool that efficiently finds duplicate files.

https://github.com/darakian/ddh

Use the same Rust cross compilation procedure as the "diskus" tool
in the **Seagate-Central-Utils** project.

Being able to quickly find duplicates throughout a complicated 
directory structure is a great way to save disk space. Being able to
do this on the Seagate Central itself is much faster than running a
tool like "Anti-Twin" or "Duplicate Detector" on a network connected
PC.


