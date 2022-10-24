# Reset the SU / Root Password on a Seagate Central
## Summary
Early versions of Seagate Central firmware allow administrator level users to gain
su / root access on the device, however the latest versions of stock firmware
deliberately disable su / root access by setting the root password to an unknown 
value.

Root access on the Seagate Central is useful for troubleshooting issues and
for performing custom modifications.

This document describes the two most convenient methods to regain root access
on your Seagate Central. It also mentions two other more complicated methods
that are described in other documents.
 
### 1) "Planting" a Boot Script (Easy)
This method involves logging in to the unit via ssh as an administrator level user,
then creating a bootup script that will reset the root password to a known value on
the next system reboot. This method requires that you know at least one administrator 
level username and password combination for the Seagate Central.

When you set up the unit initially, you would have been asked to supply a username
and password that would act as the administrator of the unit. This is the username 
and password you can use with this method. 

The details of this method are explained in a section below.

### 2) Removing the Hard Drive and Connecting it to Another Computer (Moderate)
This involves physically removing the Seagate Central's hard drive, connecting it to
an external Windows or Linux system, then editing operating system files. This method
does not require that you know any usernames or passwords on the target unit. However,
it requires that you are able to physically open up the Seagate Central, remove the
hard drive and connect it to an external system via a USB hard drive reader.

Opening up the unit is a little tedious but you can do it if you have a "jewellers"
tool kit for the small screws and a prying tool would also be useful. 

USB Hard Drive readers (specifically SATA to USB) are fairly cheap (US$30) and easily
available at most computer shops or electronics websites.

The details of this method are explained in a section below (but the procedure is 
quite tedious. If you try it and it doesn't work then let me know.)

### 3) The Firmware Upgrade Method
This method involves manipulating a stock Seagate issue firmware image and generating
replacement firmware that automatically resets the root password to a known value. You
need access to an external Linux system to create the replacement firmware and you
need to be able to log in to the Seagate Central web management page as an administrator
to initiate the upgrade.

You would only use this method if you were planning on installing customized firmware
on the Seagate Central. This method is documented in the "Seagate Central Samba"
project at

https://github.com/bertofurth/Seagate-Central-Samba

### 4) Data Recovery then Full System Wipe
This involves removing the hard drive from the unit, connecting it to an external
Linux system (not Windows), recovering the user Data on the unit, then performing 
a full system wipe and reinstallation. 

This would be the preferred method if the unit has somehow become unresponsive or
unreliable. This method is described in the "Unbrick-Replace-Reset-Hard-Drive.md" 
document in this project at

https://github.com/bertofurth/Seagate-Central-Tips/blob/main/Unbrick-Replace-Reset-Hard-Drive.md

## Method 1 : "Planting" a Boot Script
### ssh to the Seagate Central
Secure Shell (ssh) is a means of securely connecting to and managing devices, such as
the Seagate Central, via a network connection. It usually involves accessing a text
based command prompt where commands can be issued to a device to control it and
monitor it's status.

In order to connect to the Seagate Central via ssh you'll need an ssh client.

#### Windows 10 Inbuilt OpenSSH client
To install the Windows 10 native OpenSSH client see the following URL

https://www.howtogeek.com/336775/how-to-enable-and-use-windows-10s-built-in-ssh-commands/

To summarize the procedure

Go to Settings -> Apps then under "Apps & Features" click on “Optional Features"

Assuming the "OpenSSH Client" is not already in the list of "Installed Features"
click on "Add a feature", search for "ssh", then install the "OpenSSH Client"

After making sure the OpenSSH client is installed, open the Windows Command Prompt.
(Hit Windows Key + S and Search for the "Command Prompt" app.) 

Once the Command Prompt window opens issue the "ssh username@NAS-IP-ADDRESS" command
where "username" is the Seagate Central's administrator username and "NAS-IP-ADDRESS"
is your Seagate Central's IP address or hostname. When prompted for a password, enter
the administrator user's password. The first time you connect to a particular host
you will be asked to confirm that you wish to connect. Simply type "yes".

In the following example the administrator username is "admin" and the NAS IP address
is "192.168.1.50".

    Microsoft Windows [Version 10.0.19044.1826]
    (c) Microsoft Corporation. All rights reserved.

    C:\Users\berto>ssh admin@192.168.1.50
    The authenticity of host '192.168.1.50 (192.168.1.50)' can't be established.
    RSA key fingerprint is SHA256:D/BaZ7yDHFRNcrkVUTYMYHJIDpe3KEHPRX2Pb/4aHdZ.
    Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
    Warning: Permanently added '192.168.1.50' (RSA) to the list of known hosts.
    admin@192.168.1.50's password:
    Last login: Tue Aug 16 21:38:43 2022 from 192.168.1.10
    NAS-X:~$

#### Other Windows ssh clients
Here is a list of some popular Open Source GUI ssh clients for Windows. There are
dozens of other ssh clients for Windows available.

Putty :
https://www.chiark.greenend.org.uk/~sgtatham/putty/

Tera Term :
https://ttssh2.osdn.jp/index.html.en

#### Linux ssh client
Most Linux distributions generally come with a command line ssh client installed.

It can be easily invoked from the terminal command line as "ssh username@host". In
the following example the username "admin" is used to login to the NAS at IP
address "192.168.1.50"

    berto@rpi ~$ssh admin@192.168.1.50
    The authenticity of host '192.168.1.50 (192.168.1.50)' can't be established.
    DSA key fingerprint is SHA256:pEz2Rl+ZMS3yoPfiH12fpjXdKXAgD9uAUbq5e7DIF+Q.
    This key is not known by any other names
    Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
    Warning: Permanently added '192.168.1.50' (DSA) to the list of known hosts.
    admin@192.168.1.50's password:
    Last login: Tue Aug 16 22:01:23 2022 from 192.168.1.10
    NAS-X:~$

In some cases, an error message may appear because the Seagate Central uses an 
older, less secure version of encryption. Some modern Linux ssh clients may complain
as per the following example.

    berto@rpi ~$ssh admin@192.168.1.50
    Unable to negotiate with 192.168.1.50 port 22: no matching host key type found. Their offer: ssh-rsa,ssh-dss

If this happens then you can configure the Linux ssh client to allow connections
to hosts using the older version of encryption as follows.

    berto@rpi ~$ echo "HostKeyAlgorithms=+ssh-dss" >> ~/.ssh/config

### Create a boot script 
Once you have logged in to the Seagate Central via ssh, confirm that you are
logged in as an administrator level user by issuing the "groups" command.

This command shows which groups the logged in user belongs to. One of
the groups should be "root" as per the following example. This confirms
that the logged in user has the right privileges to perform this procedure.

    NAS-X:~$ groups
    root users admin
    
If the "groups" command does not show the "root" group then you are not logged
in as an administrator level user, but a normal user.

    NAS-X:~$ groups
    users fred
    
Once you have confirmed that you are logged in to the Seagate Central with 
administrative privileges, issue the following commands in your ssh
session. These commands plant a startup script in the Seagate Central operating
system that will change the root password to XXXXX at next boot (we'll change this
password later). I'd suggest just copying and pasting these commands a few lines at 
a time in to your ssh session to ensure that no mistakes are made.

    cat << EOF > /etc/rcS.d/S90change-root-pw.sh
    #!/bin/bash
    echo "Changing root password" > /dev/kmsg
    echo "root:XXXXX" | chpasswd
    pwconv
    cp /etc/passwd /usr/config/backupconfig/etc/passwd
    cp /etc/shadow /usr/config/backupconfig/etc/shadow   
    echo "Finished changing root password" > /dev/kmsg
    EOF
    
    chmod 770 /etc/rcS.d/S90change-root-pw.sh

Once these commands have been executed, login to the Seagate Central Web Management
page and reboot the unit (Settings -> Setup -> System -> Restart). You can of course
just reboot the unit by power cycling it, but it's always better to reboot a system
gracefully.

As the unit reboots your ssh session should be disconnected.

### Log in as root
After a few minutes when the unit has rebooted, try to re-establish the ssh session
with the same username and password as before.

Once the ssh session is established issue the "su" command to try to
gain root access to the unit. The password should be XXXXX. For example

    NAS-X:~$ su
    Password: XXXXX
    NAS-X:/Data/admin# 

The "#" prompt indicates that you are now logged in as the root user.

### Change the root password properly
It is strongly suggested that you change the root password again at this point.

The procedure is as follows. Issue the "passwd" command to enter a new password.
You will be prompted to enter the new password twice as per the following example.

    NAS-X:/Data/admin# passwd
    Enter new UNIX password: mypassword1234
    Retype new UNIX password: mypassword1234
    passwd: password updated successfully

After changing the root password with the "passwd" command you must enter the 
following sequence of commands to ensure that the changed password survives a 
reboot. This is unique to the Seagate Central and isn't required on most other
Linux based systems. You must remember to do this in future if you ever change
the root password on the Seagate Central again.

    cp /etc/passwd /usr/config/backupconfig/etc/passwd
    cp /etc/shadow /usr/config/backupconfig/etc/shadow

### Disable the boot script
Now that you have su / root access to the unit we must disable the bootup script
that changes the root password at each system boot. If we fail to perform this
step then the next time the system reboots the root password will be reset
back to XXXXX.

This can be done with the following command

    rm /etc/rcS.d/S90change-root-pw.sh
    
You now have su / root access on your Seagate Central!

## Method 2 : Removing the Hard Drive and Connecting it to Another Computer 

** NOTE : THIS METHOD IS EXTREMELY TEDIOUS. I HAVEN'T BOTHERED FULLY REFINING
AND TESTING IT BECAUSE IT'S SO INVOLVED AND CONVOLUTED. I STRONGLY SUGGEST USING
METHOD 1. IF FOR SOME REASON YOU HAVE TO USE THIS METHOD THEN LET ME KNOW IF
IT WORKS OR DOESN'T WORK. **

This method involves mounting the Seagate Central hard drive on an external
computer and manually modifying a bootup script to change the root password
to a known value. This method is a quite a bit more complicated than the
method above and much more prone to error, so please only use this method 
if you are really unable to use method 1.

### Open the Seagate Central and Take out the Hard Drive
As per the pre-requisites section, search for a video detailing instructions
on opening the Seagate Central and how to pull out the hard drive. You'll
need a "jewellers" screwdriver kit and potentially a pry tool to open the
plastic case. There are dozens of videos on the topic. One example is

https://www.dailymotion.com/video/x6exylx

Once the unit is opened and the four square rubber pads are unscrewed from the 
sides of the internal metal frame, the hard drive can be pulled away and 
disconnected from the main circuit board with a moderate amount of force.

### Connect the Hard Drive to an external USB Hard Drive Reader
The hard drive in a Seagate Central is a 3.5 inch drive with a SATA interface. Use 
a hard drive adapter / reader that can connect to this kind of hard disk. Most
hard disk readers available as of the writing of this document in 2022 can connect 
to this type of drive because it's currently the most common type of hard drive in
the world. I'd also recommend getting a USB 3.0 or later capable reader because
the extra speed of a more modern USB interface will make file transfers a lot
faster.

Some examples of suitable hard drive readers are seen at the following
links.

https://flexgate.me/best-hard-drive-reader/

https://geekymag.com/best/hard-drive-reader/

At this point you may either follow the "Windows Specific Instructions" or the
"Linux Specific Instructions".

### Windows Specific Instructions
If you are performing this procedure using a Windows based system then here
are the instructions to follow. These instructions assume you are using
an up to date version of Windows 10.

#### Install and run "Linux File Systems for Windows by Paragon Software"
Before you connect the hard drive reader to your PC, install the
"Linux File Systems for Windows by Paragon Software" tool available
from

https://www.paragon-software.com/home/linuxfs-windows/

This tool from Paragon lets Windows read data from a variety of different 
kinds of Linux file systems. There are other tools available such as
Windows subsystem for Linux (WSL) however the Paragon tool seems to be
the most powerful and easy to use.

This tool is available as a 10 day free trial version. Hopefully that
will be enough time to perform this procedure.

Download and install the tool as normal but when the 
"Product Activation" screen appears tick the "Start 10-Day Trial."
option rather than the default "Activate" option which requires that you've
bought a license.

I would recommend purchasing a full license if you feel you might need
to perform this sort of task again. In my view the software is very
reasonably priced for the functionality it provides.

After the software is installed, run it. Once activated it should 
automatically scan all the drives connected to your system.

I would then highly recommend changing the default behaviour of the program
so that it does not automatically mount partitions and so that it mounts them
as read-only by default. This can be done by clicking on the three horizonal
lines menu item to the right of "Sign in", then clicking on "Settings" then
turning "Mount automatically" to "Off" and setting "Mount volumes in"
to "Read-only". This will ensure that Windows does not accidentally overwrite
critical data on the Seagate Central drive or any other Linux drive that you
connect to your system.

#### Connect the hard drive reader to your Windows PC
**Please read and understand this entire section before connecting the 
hard drive reader to your PC**

When you connect the USB drive reader containing the Seagate Central
drive to your Windows system, you *may* be prompted with a series of 
messages similar to the following

    You need to format the disk in drive X: before you can use it.

    Do you want to format it?

It is **essential** that you click on "Cancel" for all of these messages. Do
not let Windows format these drives!

You may also see notifications similar to the following

    Autoplay
    
    Local Disk X:
    
    Select and chose what happens with removable drive X:

Do not click on those notifications. Just ignore them.

If you accidentally let Windows format any of these drives then it will be extremely 
difficult to retrieve the data on them. Note that it would not be *impossible*
to retrieve the data but doing so is way beyond the scope of this document.

#### Mount the Root partitions
After the hard drive reader is connected to the PC, the Paragon Software tool 
should recognize the newly inserted drive.

If you scroll down through the list of recognized partitions on the left hand side of
the app window, you should see two 1GB partitions called "Root_File_System". These are
the 2 partitions we are interested in. 

If you have configured the Paragon tool so that it does not automatically mount
new drives then at this point you can click on the first of the "Root_File_System"
partitions to select it, then click on the "Mount" option at the top of the window 
to assign the drive a letter for access by the Windows system. Make sure to select
"Read-write" so that we can write data to the partition. Also select "Set the
default ownership and permissions of the mounted volume" to User = 0, Group = 0,
and Permissions = 770. Then click on "Mount". Do the same for the other
"Root_File_System" and mount it as well.

#### Create the bootup script
In this part of the procedure we edit one of the startup scripts on the Seagate
Central hard drive and add a section that changes the root password. 

This part of the procedure depends on using a recent version of the Notepad
editor (2019 or later). This is due to an issue related to End of Line (EOL)
characters. If you'd like to read more about this issue then here is an insightful
article.

Introducing extended line endings support in Notepad : 
https://devblogs.microsoft.com/commandline/extended-eol-in-notepad/

Open the first of the root partitions in Windows Explorer and navigate to 
the /etc/init.d/ directory. There should be a file in that directory called
"procps.sh" Note that you may need to select "View" -> "File Name Extentions" 
in Windows Explorer to see the ".sh" suffix. This file is executed as part of 
the startup sequence on the Seagate Central. It's not a particularly important
startup file so if it gets damaged it won't significantly affect to operation
of the unit. (It actually does nothing!!)

This file needs to be opened using the Notepad editor. To ensure that the file is
opened by Notepad and not a different text editor, right click on the file, select 
"Open with..." and in the dialog that appears select "Notepad".

Do not use a different text editor such as Microsoft Word or Wordpad. This is related
to the EOL issue that was discussed above.

When the file is opened you should see the initial contents which will look as
follows

    #!/bin/sh
    
    SYSCTL_CONF="/etc/sysctl.conf"
    if [ -f "${SYSCTL_CONF}" ]; then
            /sbin/sysctl -q -p "${SYSCTL_CONF}"
    fi

Confirm that in the bottom right hand corner of the Notepad window you see a
status indicator that says "Unix (LF)". This is vitally important. This means that
Notepad has recognized that this file is going to be used on a Unix system and 
Notepad will generate End of Line (EOL) characters accordingly.

If the status box says "Windows (CRLF)" or there's no such status box then something
has gone wrong and you must not proceed with editing the file. 

Once the file has been opened and you've confirmed "Unix (LF)" is displayed, some
extra commands can be added to the end of the file as follows.

    #!/bin/sh
        
    SYSCTL_CONF="/etc/sysctl.conf"
    if [ -f "${SYSCTL_CONF}" ]; then
            /sbin/sysctl -q -p "${SYSCTL_CONF}"
    fi
    
    echo "Changing root password" > /dev/kmsg
    echo "root:XXXXX" | chpasswd
    pwconv
    cp /etc/passwd /usr/config/backupconfig/etc/passwd
    cp /etc/shadow /usr/config/backupconfig/etc/shadow   
    echo "Finished changing root password" > /dev/kmsg
    
Save the file and exit from Notepad.

Now you must repeat this process for the /etc/init.d/procps.sh file on
the other Root_File_System partition that has been mounted by the Paragon
software.

Once **both** of these files have been edited then **both** of the partitions
should be unmounted in the Paragon Software tool.

At this point proceed to the section entitled "Reinstall the target hard drive and 
boot up the Seagate Central"

### Linux specific instructions
If you are performing this procedure using a Linux based system then here
are the instructions to follow. 

#### Attach the Seagate Central hard drive to you Linux System
Login to your Linux system as the root user or prefix each of the commands
listed from this point with "sudo".

Before you connect the target hard drive to the Linux system, run the
"lsblk" command to see a list of the drives that are currently connected
to your system. Take a note of their names. They will most likely be named
something along the lines of /dev/sda or /dev/sdb and so forth.

Here is an example taken from a PC running a live USB Linux distribution

    # lsblk
    NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
    loop0    7:0    0 542.4M  1 loop /run/overlay/squashfs_container
    loop1    7:1    0   3.3G  1 loop /run/overlay/rootfsbase
    sda      8:0    0 931.5G  0 disk
      sda1   8:1    0 132.4M  0 part
      sda2   8:2    0 148.9G  0 part
      sda3   8:3    0   992K  0 part
      sda4   8:4    0     1K  0 part
      sda5   8:5    0     2G  0 part
      sda6   8:6    0 780.5G  0 part
    sdb      8:16   1  14.5G  0 disk
      sdb1   8:17   1 622.5M  0 part /run/overlay/live
      sdb2   8:18   1    20M  0 part
      sdb3   8:19   1  13.8G  0 part /run/overlay/overlayfs
    sr0     11:0    1  1024M  0 rom

Here is an example from a Raspberry PI 4B

    # lsblk
    NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
    mmcblk0     179:0    0 119.1G  0 disk
      mmcblk0p1 179:1    0    64M  0 part /boot/efi
      mmcblk0p2 179:2    0   500M  0 part [SWAP]
      mmcblk0p3 179:3    0 118.5G  0 part /

Insert the Seagate Central hard drive in the USB hard drive reader and attach
it to your external Linux system.

After about 20 seconds re-run the "lsblk" command to confirm that the Seagate
Central drive has been recognized.

In the example below we have inserted a 4TB Seagate Central drive into a PC. Note
that the new drive is called "sdc" and contains a number of pre-existing Seagate
Central partitions.

    # lsblk
    NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
    loop0    7:0    0 542.4M  1 loop /run/overlay/squashfs_container
    loop1    7:1    0   3.3G  1 loop /run/overlay/rootfsbase
    sda      8:0    0 931.5G  0 disk
      sda1   8:1    0 132.4M  0 part
      sda2   8:2    0 148.9G  0 part
      sda3   8:3    0   992K  0 part
      sda4   8:4    0     1K  0 part
      sda5   8:5    0     2G  0 part
      sda6   8:6    0 780.5G  0 part
    sdb      8:16   1  14.5G  0 disk
      sdb1   8:17   1 622.5M  0 part /run/overlay/live
      sdb2   8:18   1    20M  0 part
      sdb3   8:19   1  13.8G  0 part /run/overlay/overlayfs
    sdc      8:32   0   3.6T  0 disk
      sdc1   8:33   0    20M  0 part
      sdc2   8:34   0    20M  0 part
      sdc3   8:35   0     1G  0 part
      sdc4   8:36   0     1G  0 part
      sdc5   8:37   0     1G  0 part
      sdc6   8:38   0     1G  0 part
      sdc7   8:39   0     1G  0 part
      sdc8   8:40   0   3.6T  0 part    
    sr0     11:0    1  1024M  0 rom

### Mount the Seagate Central Root File Systems

Replace "sdX" with the Seagate Central's hard drive name (probably sdb or sdc)

    mkdir /tmp/SC-Root_1 /tmp/SC-Root_2 
    mount /dev/sdX3 /tmp/SC-Root_1
    mount /dev/sdX4 /tmp/SC-Root_2

### Modify the /etc/init.d/procps.sh file
Edit the /etc/init.d/procps.sh file on each partiton using nano or your favourite
text editor. This is an unimportant startup file that we will modify to piggyback
our root password changing commands. This startup file won't be missed if it gets
destroyed.

    nano /tmp/SC-Root_1/etc/init.d/procps.sh

The props.sh file will initially look like this.

    #!/bin/sh
    
    SYSCTL_CONF="/etc/sysctl.conf"
    if [ -f "${SYSCTL_CONF}" ]; then
            /sbin/sysctl -q -p "${SYSCTL_CONF}"
    fi

Add the extra password modification commands as seen below so that procps.sh
looks like this

    #!/bin/sh
        
    SYSCTL_CONF="/etc/sysctl.conf"
    if [ -f "${SYSCTL_CONF}" ]; then
            /sbin/sysctl -q -p "${SYSCTL_CONF}"
    fi
    
    echo "Changing root password" > /dev/kmsg
    echo "root:XXXXX" | chpasswd
    pwconv
    cp /etc/passwd /usr/config/backupconfig/etc/passwd
    cp /etc/shadow /usr/config/backupconfig/etc/shadow   
    echo "Finished changing root password" > /dev/kmsg
    
Save the file.

Make sure to also edit the file on the second root partition as well

     nano /tmp/SC-Root_2/etc/init.d/procps.sh

After both files have been modified unmount both the root file systems.

     umount /tmp/SC-Root_1
     umount /tmp/SC-Root_2
          
### Reinstall the target hard drive and boot up the Seagate Central
Disconnect the USB Hard Drive reader from your external system and remove
the Seagate Central drive from the reader. Reinsert the hard drive back in the
Seagate Central by sliding it into the metal frame and connecting it to the
SATA interface.

Note that the plastic lid can be left off the unit during the initial test run
just in case there's a problem and the hard drive needs to be removed again.

Reconnect the Ethernet cabling and the power cable then power on the unit.

The LED status light on the unit should blink green for a few minutes and then
go solid to indicate the Linux kernel has loaded properly. 

### Change the root password properly
After waiting another few minutes login to the Seagate Central via ssh using
any valid username and password (it doesn't have to be an administrator). Issue 
the "su" command and enter the XXXXX password. Next, issue the "passwd" command
and enter a new password. You will be prompted to enter the new password twice 
as per the following example.

    NAS-X:~$ su
    Password: XXXXX
    NAS-X:/Data/admin# passwd
    Enter new UNIX password: mypassword1234
    Retype new UNIX password: mypassword1234
    passwd: password updated successfully

After changing the root password with the "passwd" command you must enter the 
following sequence of commands to ensure that the changed password survives a 
reboot. This is unique to the Seagate Central and isn't required on most other
Linux based systems. You must remember to do this in future if you ever change
the root password on the Seagate Central again.

    cp /etc/passwd /usr/config/backupconfig/etc/passwd
    cp /etc/shadow /usr/config/backupconfig/etc/shadow

### Reset the /etc/init.d/procps.sh file
Now delete all the password modification stuff from props.sh. The following sed
command will remove the extra lines that we added to procps.sh and get the
file back to it's original state.

    sed -i '/root/Q' /etc/init.d/procps.sh

** Note that the procps.sh file on the backup partition will still contain the
root password changing commands so if the unit ever needs to fail over to the
backup kernel (only if something goes catastrophically wrong), the root password
will be reset back to XXXXX. **


