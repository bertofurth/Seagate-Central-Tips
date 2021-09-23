# Seagate-Central-Tips
Tips for optimizing the Seagate Central NAS device.

This is a collection of suggestions, optimizations and 
configuration changes I've made on my own Seagate Central NAS
device to make it more useable. Most of these instructions 
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
    
After this change is made the newly modifed
"/usr/private/user_smb_conf/.overall_share" file need to be copied
over to the Seagate Central backup configuration directory in order 
for the change to survive a system reboot.

    cp /usr/private/user_smb_conf/.overall_share /usr/config/backupconfig/usr/private/user_smb_conf/.overall_share
    
An optional but useful step is to run the "testparm" command which will
confirm that the changes you have made are compatible with the samba
service. Any erroneous entries will be noted by the output of this
command. 
    
    testparm
    
Finally, the samba service needs to be commanded to reload the modified
configuration in order for the changes to take effect.

    /etc/init.d/samba reload
    

## Stop particular users from loging in with ssh.
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


## Disable unneeded services
The Seagate Central comes with a number of services that are not
useful to everyone. 

Some of these services continue to utilize CPU and memory even when
they are marked as disabled with the Seagate Central Web Management 
interface!!

Here is a list of services I've manually disabled in order to ensure
that they do not consume any resources on the Seagate Central. 

Naturally you should not disable any services that you are currently 
using.

The changes will take effect on the next reboot.

### Tappin remote access service
The Tappin remote access service was a service that allowed users
to remotely access content on their Seagate Central. This service
has been shutdown for some time as per the notice at

https://www.seagate.com/au/en/support/kb/seagate-central-tappin-update-007647en/

Run the following command to disable the Tappin service.

     update-rc.d -f tappinAgent remove
     
Reinstate this service with the following command (but why would you??)

     update-rc.d tappinAgent defaults 85

### Seagate Media Server
A service where you can view content on your Seagate Central remotely
by registering an account with Seagate. Note this is different to the
DLNA service that provides access to media for player devices on your
home network.

Run the following commands to disable the Media Server.

    update-rc.d -f media_server_daemon remove
    update-rc.d -f media_server_ui_daemon remove
    update-rc.d -f media_server_allow_scan remove
    update-rc.d -f media_server_default_start remove

Reinstate this service with the following commands.

    update-rc.d media_server_daemon defaults 19 
    update-rc.d media_server_ui_daemon defaults 69 
    update-rc.d media_server_allow_scan defaults 98 
    update-rc.d media_server_default_start defaults 99
    
### Facebook archiver
A service where your Seagate Central saves content posted on your
Facebook page.

Run the following command to disable the Facebook archiver.

    update-rc.d -f fbarchived remove

Reinstate this service with the following command.

    update-rc.d media_server_daemon defaults 99

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

## Other cross compiled tools
I have installed the following useful tools that I haven't explicitly
generated cross compilation instructions for

### DDH - Directory Differential hTool (Rust)
A tool that efficiently finds duplicate files.

https://github.com/darakian/ddh

Use the same Rust cross compilation procedure as the "diskus" tool
in the **Seagate-Central-Utils** project.

Being able to quickly find duplicates throughut a complicated 
directory structure is a great way to save disk space. Being able to
do this on the Seagate Central itself is much faster than running a
tool like "Anti-Twin" or "Duplicate Detector" on a network connected
PC.


