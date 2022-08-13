# Unbrick, Replace or Reset Seagate Central Hard Drive
## Summary
**UNFINISHED**

This guide covers resetting a Seagate Central hard drive back to factory 
defaults by physically removing the drive from the Seagate Central, then
using an external Linux system to get the drive back to "out of the box"
state. This can be done the original hard drive from a Seagate Central 
or with a new hard drive.

This procedure can be used where a Seagate Central unit has become 
unresponsive or unuseable. That is, when a Seagate central has been "bricked". 

It can also be used if you wish to replace the hard drive in a Seagate Central
or to create a temporary hard drive seperate from your everyday/production drive
to perform experiments with.

## TLDNR
* Open the Seagate Central and remove the existing/source hard drive
* (Optional) Recover any important user Data from the source hard drive.
* Attach the target hard drive to an external Linux System
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

Understand that performing this procedure in an unmodified way will completely 
overwrite any data on the target hard drive. 

## Prerequisites
### Be able to open up the Seagate Central
There are many video tutorials showing how to open up a Seagate Central.
Simply search on your favourite video sharing web sites for something
like "Seagate Central Disassembly". 

You'll need a "jewellers" screwdriver kit for the tiny screws and potentially
a flat head pry tool to get the face plate and lid off the unit.

### A USB connected Hard Drive Reader / Adapter
You'll need a USB hard drive reader suitable for a 3.5 inch SATA drive
as used inside the Seagate Central. You can buy these at most electronics
stores or websites for around US$30. 

The alternative is to install the Seagate Central hard drive inside the computer
you're using for the recovery. This assumes that you are using a desktop 
computer with enough room inside to house the extra hard disk. This is 
obviously much more tedious than just using an external hard drive reader.

### Root access on a building Linux System
This procedure depends on being able to manipulate the target hard drive
using a Linux based system. In addition, since the procedure involves mounting 
an external hard drive as well as manipulating file ownership and permissions 
you'll need root access on the Linux system as well.

If you only have a Windows system and do not have a Linux system then I can
suggest using a USB key based "Live" Linux system such as the ones supplied 
by Debian, OpenSUSE or most other Linux distributions. I personally suggest
the "OpenSUSE LEAP Rescue Live CD" as it is a small image that allows you
to easily log in as root and install the required Linux utilities.

### Required software on the building Linux host
This procedure makes use of version 2.26 or later of the "sfdisk" hard drive
partitioning tool. This tool should be available on any modern Linux system 
with software more recent than 2015 or so. Earlier versions cannot
manipulate the "GPT" style partition table as used by the Seagate Central.

Issue the "sfdisk -v" command as per the following example to
confirm the version of "sfdisk" in your system.

    # sfdisk -v
    sfdisk from util-linux 2.37.4

If versions earlier than 2.26 are used then an error messsage similar
to the following may appear while running the sfdisk command

    unrecognized partition table type

Ensure that the system has the "lvm2" and "e2fsprogs" packages installed.
These should already be in place on the majority of modern Linux systems. Issue
the "lvm version", "mkfs.ext2 -V" and "mkfs.ext4 -V" commands to confirm that
these packages are intstalled on your Linux system. No particular version 
of these tools is necessary.

    # lvm version
      LVM version:     2.03.16(2)-git (2022-02-07)
      Library version: 1.03.01-git (2022-02-07)
      Driver version:  4.46.0
      . . .
    # mkfs.ext2 -V
    mke2fs 1.46.5 (30-Dec-2021)
    Using EXT2FS Library version 1.46.5
    
    # mkfs.ext4 -V
    mke2fs 1.46.5 (30-Dec-2021)
    Using EXT2FS Library version 1.46.5
    
Finally, ensure that "unzip" and "unsquashfs" (part of the "squashfs" /
"squashfs-tools" packages) are installed in order to read the Seagate
Central firmware image. No particular version of these tools is 
necessary.

    # unzip -v
    UnZip 6.00 of 20 April 2009, by Info-ZIP.  Maintained by C. Spieler.  Send
    bug reports using http://www.info-zip.org/zip-bug.html; see README for details.
    . . .
    # unsquashfs -v
    unsquashfs version 4.5.1 (2022/03/17)
    copyright (C) 2022 Phillip Lougher <phillip@squashfs.org.uk>    
    
You may need to manually install "unsquashfs" as this is not normally 
included in most Linux systems.

For OpenSUSE

    # zypper add squashfs
     
For Debian

    # apt-get install squashfs-tools
     
## Procedure
### Open the Seagate Central and take out the source Hard Drive
As per the pre-requisites section, search for a video detailing instructions
on opening the Seagate Central and how to pull out the hard drive.
There are dozens of videos on the topic. One example is

https://www.dailymotion.com/video/x6exylx

Once the unit is opened and the four square rubber pads holding the hard
drive in place are unscrewed, the hard drive can be pulled away and 
disconnected from the main circuit board with a moderate amount of force.

## Optional - Recover any important user Data from the source hard drive
If you have not already backed up the user Data contained on the Seagate Central
drive then this is the point at which it should be done.

See the document in this project called **Recover_Seagate_Central_Data.md**
for detailed instructions on how to retrieve Data from a physical hard drive
that has been removed from a Seagate Central.

## Attach the target hard drive to an external Linux System
Login to your Linux system as the root user or prefix each of the commands
listed from this point with "sudo".

Before you connect the target hard drive to the Linux system run the
"lsblk" command to see a list of the drives that are currently connected
to your system. Take a note of their names. They will most likely be named
something along the lines of /dev/sda or /dev/sdb and so forth.

Here is an example taken from a PC running a live USB drive

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
system to in the USB hard drive reader. From this point we will call this drive
the **target** hard drive.

The target drive can either be the original drive from your Seagate Central or a
different hard drive.

Re-run the "lsblk" command to confirm that the next drive has been recognized.

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
      
* Create a new Seagate Central style partition table on the target hard drive

Other tools such as "parted" can be also be used to create the Seagate Central
disk partitions however we use "sfdisk" in this procedure.

* Install Seagate Central firmware on the target hard drive
* Reinsert the target hard drive back in the Seagate Central
### 
### Remove the 

