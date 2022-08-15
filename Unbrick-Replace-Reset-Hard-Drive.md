# Unbrick, Replace or Reset Seagate Central Hard Drive
## Summary

# WARNING! UNFINISHED!!! UNTESTED!!! # 

This guide covers resetting a Seagate Central hard drive back to factory 
defaults by physically removing the drive from the Seagate Central, then
using an external Linux system to get the drive back to "out of the box"
state. This procedure can be applied to the original hard drive from a
Seagate Central or to a new hard drive.

This procedure can be used where a Seagate Central unit has become 
unresponsive or unuseable. That is, when a Seagate central has been "bricked". 

It can also be used if you wish to replace the hard drive in a Seagate Central
or to create a temporary hard drive seperate from your everyday/production drive
to perform experiments with.

## TLDNR
* Open the Seagate Central and remove the existing/source hard drive
* (Optional) Recover any important user Data from the source hard drive.
* Attach the target hard drive to an external Linux System
* Wipe the existing partition table on the target hard drive
* Create a new Seagate Central style partition table on the target hard drive
* Install Seagate Central firmware on the target hard drive
* Reinsert the target hard drive back in the Seagate Central

## Warning
This procedure must not be followed blindly. You will need to understand
what you are doing before executing each part because if the procedure is
applied incorrectly, you could end up rendering the system you're using
to perform this procedure inoperative!

The main risk is that you may mistakenly apply the commands in these 
instructions to the wrong hard drive in your Linux system. This may result
in losing data and/or making your system unuseable.

Also, understand that performing this procedure as written will overwrite
the data on the target hard drive.

## Prerequisites
### Be able to open up the Seagate Central
There are many video tutorials showing how to open up a Seagate Central.
Simply search on your favourite video sharing web sites for something
like "Seagate Central Disassembly". 

You'll need a "jewellers" screwdriver kit for the tiny screws and potentially
a flat head pry tool to get the face plate and lid off the unit.

I note here that I have never managed to open up a Seagate Central without
cracking a little bit of the plastic cover, so don't feel too bad if you
do too!

### A USB connected Hard Drive Reader / Adapter
You'll need a USB hard drive reader suitable for a 3.5 inch SATA drive
as used inside the Seagate Central. You can buy these at most electronics
stores or websites for around US$30. I would strongly suggest using a
USB 3.0 or later capable reader as this will be much faster than a USB 2.0
style device.

The alternative is to install the target hard drive inside the computer
you're using for the recovery. This assumes that you are using a desktop 
computer with a spare SATA port to house the extra hard disk. This is 
obviously much more tedious than just using an external USB connected hard
drive reader.

### Root access on a building Linux System
This procedure depends on being able to manipulate the target hard drive
using a Linux based system. In addition, since the procedure involves mounting 
an external hard drive and manipulating file ownership you'll need root access
on the Linux system as well.

If you only have a Windows system and do not have a Linux system then I can
suggest using a USB based "Live" Linux system such as the ones supplied 
by Debian, OpenSUSE or most other Linux distributions. I personally suggest
the "OpenSUSE LEAP Rescue CD" as it is a small image that allows you
to easily log in as root and install the required Linux utilities. See

https://en.opensuse.org/SDB:Create_a_Live_USB_stick_using_Windows
https://download.opensuse.org/distribution/openSUSE-current/live/

### Required software tools on the building Linux host
#### sfdisk version later than 2.26
This procedure makes use of version 2.26 or later of the "sfdisk" hard drive
partitioning tool. This tool should be available on any modern Linux system 
with software more recent than 2015 or so. Earlier versions cannot
manipulate the "GPT" style partition table as used by the Seagate Central.

Issue the "sfdisk -v" command as per the following example to
confirm the version of "sfdisk" in your system.

    # sfdisk -v
    sfdisk from util-linux 2.37.4

If versions earlier than 2.26 are used, then an error messsage similar
to the following may appear while running the sfdisk command

    unrecognized partition table type
    
#### squashfs tools (unsquashfs)    
Ensure that the "unsquashfs" program (part of the "squashfs" /
"squashfs-tools" package) is installed in order to read the Seagate
Central firmware image. 

    # unsquashfs -v
    unsquashfs version 4.5.1 (2022/03/17)
    copyright (C) 2022 Phillip Lougher <phillip@squashfs.org.uk>    
    . . .

#### unzip 
Most modern Linux systems will come with the "unzip" tool included but some 
may require it to be manually installed.

    # unzip -v
    UnZip 6.00 of 20 April 2009, by Info-ZIP.  Maintained by C. Spieler.  Send
    bug reports using http://www.info-zip.org/zip-bug.html; see README for details.
    . . .

#### e2fsprogs
The vast majority of modern Linux systems already have the "e2fsprogs" package
installed.

Issue the "mkfs.ext2 -V" and "mkfs.ext4 -V" commands to confirm that the
required programs are present on your building Linux system. 

    # mkfs.ext2 -V
    mke2fs 1.46.5 (30-Dec-2021)
    Using EXT2FS Library version 1.46.5
    
    # mkfs.ext4 -V
    mke2fs 1.46.5 (30-Dec-2021)
    Using EXT2FS Library version 1.46.5
    
#### Examples of how to install new packages
You may need to manually install "unzip" and "unsquashfs" as these are 
not always included in many Linux systems.

For OpenSUSE

    # zypper add unzip squashfs
     
For Debian / Ubuntu

    # apt-get install unzip squashfs-tools
     
## Procedure
### Open the Seagate Central and take out the original Hard Drive
As per the pre-requisites section, search for a video detailing instructions
on opening the Seagate Central and how to pull out the hard drive.
There are dozens of videos on the topic. One example is

https://www.dailymotion.com/video/x6exylx

Once the unit is opened and the four square rubber pads holding the hard
drive in place are unscrewed, the hard drive can be pulled away and 
disconnected from the main circuit board with a moderate amount of force.

### Optional - Recover any important user Data from the source hard drive
If you have not already backed up the user Data contained on the original
Seagate Central drive then this is the point at which it should be done.

See the document in this project called **Recover_Seagate_Central_Data.md**
for detailed instructions on how to retrieve user Data from a physical hard 
drive that has been removed from a Seagate Central.

### Workspace preparation
If not already done, download the files in this project to a new directory 
on your Linux build machine. 

For example, the following **git** command will download the 
files in this project to a new subdirectory called 
Seagate-Central-Samba

    git clone https://github.com/bertofurth/Seagate-Central-Samba.git
    
Alternately, the following **wget** and **unzip** commands will 
download the files in this project to a new subdirectory called
Seagate-Central-Samba-main

    wget https://github.com/bertofurth/Seagate-Central-Tips/archive/refs/heads/main.zip
    unzip main.zip

Change into this new subdirectory. This will be referred to as 
the base working directory going forward.

     cd Seagate-Central-Tips
     
### Obtain Seagate Central firmware
As of the writing of this document a Seagate Central firmware zip
file can be downloaded from the Seagate website by going to the
following URL and entering your Seagate Central's serial number.

https://www.seagate.com/us/en/support/external-hard-drives/network-storage/seagate-central/#downloads

The serial number can be found on the bottom of your Seagate
Central's case, via the web management interface on the
"Settings -> Setup -> About" page, or via the ssh command line by
issuing the "serialno.sh" command.

The serial number should be in a format similar to "NA6SXXXX".

The latest firmware zip file available as of the writing of this 
document is Seagate-HS-update-201509160008F.zip

Copy this file to the base working directory on the build host. 

If Seagate ever stop supplying firmware downloads then it is possible
to obtain Seagate Central firmware by using content on partitions 5
and/or 7 of a Seagate Central hard drive. 

Also note, that it is possible to use a modified firmware image as
generated by the Seagate-Central-Samba project at

https://github.com/bertofurth/Seagate-Central-Samba/blob/main/README_FIRMWARE_UPGRADE_METHOD.md

### Attach the target hard drive to the building Linux System
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

Insert the hard drive you wish to install the fresh Segate Central operating
system to in the USB hard drive reader and attach it to the building system. 
From this point we will call this drive the **target** hard drive.

The target drive can either be the original drive from your Seagate Central that
you wish to reset, or a different hard drive.

After about 20 seconds re-run the "lsblk" command to confirm that the target
drive has been recognized.

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

In the following example a "fresh" 2.5TB hard drive is added to the Raspberry Pi
and is assigned drive name "sda"

    # lsblk
    NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
    sda           8:48   0   2.5T  0 disk
      sda1        8:49   0   2.5T  0 part  
    mmcblk0     179:0    0 119.1G  0 disk
      mmcblk0p1 179:1    0    64M  0 part /boot/efi
      mmcblk0p2 179:2    0   500M  0 part [SWAP]
      mmcblk0p3 179:3    0 118.5G  0 part /
     
In the commands shown from this point, the target hard drive we wish to prepare
will be called **sdX**. You will need to modify the commands to use the actual
drive name of the target hard drive in your system (probably "sdb" or "sdc").

### Wipe the existing partition table and data on the target hard drive
This step is not normally required when partitioning and formatting a
drive however while developing this procedure we found that pre-erasing
the drive helped to avoid a number of obscure problems. This was particularly
the case when a drive from a Seagate Central was the target as opposed to
a new drive being the target.

The first 6 GB of the drive should be overwritten with zeros to completely
clear any operating system data and partitioning. This is done using the "dd"
command as seen below. Remember to replace "sdX" with the actual drive name 
corresponding to the target. **Warning : This is an extremely dangerous 
command!! Make sure to specify the correct target drive name or you
might destroy data on your computer!!**

    dd status=progress bs=1048576 count=6144 if=/dev/zero of=/dev/sdX
    
This command will take a few minutes to complete executing. 

After the commands completes run the "partprobe" command followed by the
"lsblk" command again. The target hard drive should now have no partitions 
(i.e. sdX1, sdX2, etc). Also note that the name of the drive **may change**
after a system reboot.

     partprobe
     lsblk

In the example below we see that the 2.5TB target drive "sda" now has no 
partitions.
 
    # lsblk
    NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
    sda          8:16    0  2.5TB  0 disk
    mmcblk0     179:0    0 119.1G  0 disk
      mmcblk0p1 179:1    0    64M  0 part /boot/efi
      mmcblk0p2 179:2    0   500M  0 part [SWAP]
      mmcblk0p3 179:3    0 118.5G  0 part /

### Create a new Seagate Central style partition table on the target hard drive
In this section we use the "sfdisk" tool (version later than 2.26) to
configure the partitions on the Seagate Central and then we format the
partitions. 

A template file in this project called "SC_part_table.txt" can be used
by the sfdisk tool to create the same partition layout on a hard drive as a 
native Seagate Central. This layout allocates all the "free" space at the
end of the drive to the Data partition. (N.B. Advanced users could modify the
partition table by editing this file appropriately.)

The partiton table can be applied to drive sdX using the commands below. Remember
to substitute your actual target drive name for sdX. Run partprobe after the
command has executed to force your system to re-read the partition table.

    cat SC_part_table.txt | sfdisk --force /dev/sdX
    partprobe
    
Each partition on the drive must now be formatted using the commands listed
below. Note the file system options specified with the "-O" parameter are
designed to exactly match those used on a Seagate Central drive.

Also note that the "mkswap" for partition 6 and the "mkfs.ext4" command
for the data partition use a non standard 65536 byte page size. This is because
the Linux operating system on a Seagate Central uses a non standard 64K memory
page size.

    # Partitions 1 and 2 use ext2
    mkfs.ext2 -F -L Kernel_1 -O none,ext_attr,resize_inode,dir_index,filetype,sparse_super /dev/sdX1
    mkfs.ext2 -F -L Kernel_2 -O none,ext_attr,resize_inode,dir_index,filetype,sparse_super /dev/sdX2

    # Partitions 3, 4, 5 and 7 use ext4
    mkfs.ext4 -F -L Root_File_System -O none,has_journal,ext_attr,resize_inode,dir_index,filetype,extent,flex_bg,sparse_super,large_file,huge_file,uninit_bg,dir_nlink,extra_isize /dev/sdX3
    mkfs.ext4 -F -L Root_File_System -O none,has_journal,ext_attr,resize_inode,dir_index,filetype,extent,flex_bg,sparse_super,large_file,huge_file,uninit_bg,dir_nlink,extra_isize /dev/sdX4
    mkfs.ext4 -F -L Config -O none,has_journal,ext_attr,resize_inode,dir_index,filetype,extent,flex_bg,sparse_super,large_file,huge_file,uninit_bg,dir_nlink,extra_isize /dev/sdX5
    mkfs.ext4 -F -L Update -O none,has_journal,ext_attr,resize_inode,dir_index,filetype,extent,flex_bg,sparse_super,large_file,huge_file,uninit_bg,dir_nlink,extra_isize /dev/sdX7

    # Partition 6 is a swap partition
    mkswap -p65536 /dev/sdX6
    
At this point the target drive is properly formatted.

### Install Seagate Central firmware on the target hard drive
In this part of the procedure we populate the target drive partitions with
the required Linux Operating System data as taken from a Seagate Central 
Firmware zip archive.

Each partition on the target drive must first be mounted on the building 
system. Here, we create some temporary mount points under the /tmp directory
to mount these partitions.

    mkdir /tmp/SC-Kernel_1 /tmp/SC-Kernel_2 /tmp/SC-Root_1 /tmp/SC-Root_2 /tmp/SC-Config /tmp/SC-Update

Next we mount the partitions 

    mount /dev/sdX1 /tmp/SC-Kernel_1
    mount /dev/sdX2 /tmp/SC-Kernel_2
    mount /dev/sdX3 /tmp/SC-Root_1
    mount /dev/sdX4 /tmp/SC-Root_2
    mount /dev/sdX5 /tmp/SC-Config
    mount /dev/sdX7 /tmp/SC-Update
    
Using the commands below we unzip the Seagate Central Firmware zip file to generate
a corresponding ".img" file. Substitute the name of the Seagate Central firmware
archive you are using when issuing these commands.

    unzip Seagate-HS-update-201509160008F.zip

The following commands are used to prepare the partitions on the target drive with
the required folder structures and data.

    # The firmware images
    mkdir /tmp/SC-Config/firmware
    cp Seagate-HS-update-201509160008F.img /tmp/SC-Config/firmware/
    mkdir /tmp/SC-Update/local
    tar -C /tmp/SC-Update/local/ -zxpf /tmp/SC-Config/firmware/Seagate-HS-update-201509160008F.img
    
    # The Primary Kernel
    cp /tmp/SC-Update/local/uImage /tmp/SC-Kernel_1/

    # The Secondary Kernel
    cp /tmp/SC-Update/local/uImage /tmp/SC-Kernel_2/
    
    # The Primary Root File System
    unsquashfs -f -d /tmp/SC-Root_1/ /tmp/SC-Update/local/rfs.squashfs
    mkdir /tmp/SC-Root_1/shares
    chmod a+x /tmp/SC-Root_1/shares
    touch /tmp/SC-Root_1/etc/nas_shares.conf
    chmod 600 /tmp/SC-Root_1/etc/nas_shares.conf

    # The Secondary Root File System
    unsquashfs -f -d /tmp/SC-Root_2/ /tmp/SC-Update/local/rfs.squashfs
    mkdir /tmp/SC-Root_2/shares
    chmod a+x /tmp/SC-Root_2/shares
    touch /tmp/SC-Root_2/etc/nas_shares.conf
    chmod 600 /tmp/SC-Root_2/etc/nas_shares.conf
    
 The following set of optional commands will modify the firmware so that it
 changes the system root password to the value XXXXXXXXXX on first boot. Note
 that this is not necessary if you are already using self generated firmware 
 that already does this. We strongly suggest that you modify the XXXXXXXXXX
 password below to a different value of your chosing.
 
    cat << EOF > /tmp/SC-Root_1/etc/init.d/change-root-pw.sh
    #!/bin/bash
    
    echo "CHANGING ROOT PASSWORD"
    echo "root:XXXXXXXXXX" | chpasswd
    pwconv
    cp /etc/passwd /usr/config/backupconfig/etc/passwd
    cp /etc/shadow /usr/config/backupconfig/etc/shadow

    EOF
    
    chmod 700 /tmp/SC-Root_1/etc/init.d/change-root-pw.sh
    ln -s ../init.d/change-root-pw.sh /tmp/SC-Root_1/etc/rcS.d/S90change-root-pw.sh

    cat << EOF > /tmp/SC-Root_1/etc/init.d/disable-change-root-pw.sh
    #!/bin/bash
    
    update-rc.d -f change-root-pw.sh remove
    
    EOF
    
    chmod u+x /tmp/SC-Root_1/etc/init.d/disable-change-root-pw.sh
    ln -s ../init.d/disable-change-root-pw.sh /tmp/SC-Root_1/etc/rcS.d/S91disable-change-root-pw.sh

    cp /tmp/SC-Root_1/etc/init.d/change-root-pw.sh /tmp/SC-Root_2/etc/init.d/
    ln -s ../init.d/change-root-pw.sh /tmp/SC-Root_2/etc/rcS.d/S90change-root-pw.sh
    cp /tmp/SC-Root_1/etc/init.d/disable-change-root-pw.sh /tmp/SC-Root_2/etc/init.d/
    ln -s ../init.d/disable-change-root-pw.sh /tmp/SC-Root_2/etc/rcS.d/S91disable-change-root-pw.sh


Once the required data has been placed on the target drive, unmount the partitions.

    umount /tmp/SC-Kernel_1
    umount /tmp/SC-Kernel_2
    umount /tmp/SC-Root_1
    umount /tmp/SC-Root_2
    umount /tmp/SC-Config
    umount /tmp/SC-Update
    
After this point it should be safe to disconnect the hard drive reader from the
building system and remove the target hard drive from the reader.

Note that we do not create the user Data partition (sdX8) in this procedure. This 
is because the Seagate Central will automatically detect that it is missing and
it will be created as the unit boots up.

Note however, that when a Seagate Central comes "fresh out of the box" a number of
folders under the Public folder called "Music", "Photos" and "Videos"
are included. These contain about half a Gigabyte of sample media files. These folders
and sample media files are not automatically recreated using this procedure. If
desired, you can create these folders manually once the Seagate Central is up and
running.

### Reinstall the target hard drive and boot up the Seagate Central
Reinsert the target hard drive in the Seagate Central by sliding it into
the metal frame and connecting it to the SATA interface.

Note that the plastic lid can be left off the unit during the initial test run
just in case there's a problem and the hard drive needs to be removed again.

Reconnect the Ethernet cabling and the power cable and power on the unit.

The LED status light on the unit should blink green for a few minutes and then
go solid to indicate the Linux kernel has loaded properly.

It can take about 3 more minutes for the unit to boot up properly on first boot
because it takes extra time to recreate the Data partition and other configuration
files. After waiting, try to connect to the unit via the Web Management interface.

### Connect to the Web Management Interface
You can now log in to the Seagate Central by opening Windows Explorer, going to
"Network Neighborhood" then double clicking on the new Seagate Central device which
should be called "Seagate-xxxxxx". You can then click on the Public Folder then
select the "Manage Seagate Central" link. This should open your browser to the
device management web page where you can configure the unit.

If you are unable to access this URL for any reason then you should be able to
view the management web page of the newly booted Seagate Central by putting the
default name of the unit into the URL address bar of your browser. The default
name of the unit is "Seagate-xxxxxx" where "xxxxxx" is the last 6 digits of the
unit's MAC address which can be seen on the bottom of the unit.

For example, if the unit's MAC Address is listed on the bottom of the unit as
"0010758ACB4F" then you would browse to

http://seagate-8ACB4F

Another way of discovering the name and IP address of the unit it to run the 
"nmblookup -S '*' " command on a Linux system connected to the same network at the
Seagate Central. (This requires the "samba-client" package is installed).

This will print out the names and IP addresses of all devices providing SMB file
sharing services on the local network. One of the devices will be called "SEAGATE-xxxxxx"
and the IP address of the unit will be listed. You can then browse to that IP address
to manage the unit. In the following example the unit called SEAGATE-8ACB4E has an
IP address of 192.168.1.58.

    # nmblookup -S '*'
    10.0.2.58 SEAGATE-8ACB4E<00>
    Looking up status of 192.168.1.58
        SEAGATE-8ACB4E  <00> -         B <ACTIVE>
        SEAGATE-8ACB4E  <03> -         B <ACTIVE>
        SEAGATE-8ACB4E  <20> -         B <ACTIVE>
        WORKGROUP       <1e> - <GROUP> B <ACTIVE>
        WORKGROUP       <00> - <GROUP> B <ACTIVE>

        MAC Address = 00-00-00-00-00-00


## Technical Notes
Below are some technical notes that are only included for the sake of interested
parties. 

#### Manually create the Data partition
As noted, the Seagate Central will automatically recreate the Data partition and the
associated LVM volumes if it detects that it is missing. If, however, for some reason
you wish to manually create this Data partition before the unit boots up then it is not 
difficult to modify the procedure accordingly.

First, the "SC_part_table.txt" file needs to be modified to include a /dev/sdX8 
partition. The file included in this project has a commented out line that can 
be uncommented to include this new partition.

Apply all the partition creation and formating instructions above but then at the end
also create format the data partition as follows. Note that the lvm2 package will need
to be installed on the building system.

    # Partition 8 (The Data partition) uses Logical Volume Manager (lvm2)
    pvcreate -ff /dev/sdX8
    pvscan --cache
    vgcreate vg1 /dev/sdX8
    vgscan
    lvcreate -l +100%FREE vg1 -n lv1
    lvscan    
    mkfs.ext4 -F -b 65536 -L Data -O none,has_journal,ext_attr,resize_inode,dir_index,filetype,extent,flex_bg,sparse_super,large_file,huge_file,uninit_bg,dir_nlink,extra_isize -m0 /dev/vg1/lv1
    
Note that the Data partition uses a 65536 byte page size. If desired the page size
can be left at the default of 4096 bytes. This means that the partition will be more
easily readable by other Linux systems however it will be less efficient when operating
on the Seagate Central which natively uses a 64K memory page size.
    
