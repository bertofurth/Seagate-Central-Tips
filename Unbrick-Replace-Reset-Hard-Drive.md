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
by Debian, OpenSUSE or most other Linux distributions. This will allow you to
temporarily boot Linux on your Windows machine without impacting the data on
your main Windows drive. As per the warning above, be very careful when
running the commands in this document to ensure that you are not applying
them to your system's internal drive containing your Windows partitions!

### Required software on the building Linux host
This procedure makes use of version 2.26 or later of the "sfdisk" hard drive
partitioning tool. This tool should be available on any modern Linux system 
with software more recent than 2015 or so. Earlier versions cannot
manipulate the "GPT" style partition table as used by the Seagate Central.

Issue the "sfdisk -v" command as per the following example to
confirm the version of "sfdisk" in your system.

    # sfdisk -v
    sfdisk from util-linux 2.37.4

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
"sfdisk -l" command to see a list of the drives that are currently connected
to your system. Take a note of their names. They will most likely be named
something along the lines of /dev/sdaX or /dev/sdbX and so forth.


PUT AN EXAMPLE FROM THE LIVE SYSTEM HERE





It is important to note these drive names because you must make sure that
you do not apply any of the dangerous commands below to those existing drives.

Insert the hard drive you wish to install the fresh Segate Central operating
system to in the USB hard drive reader. From this point we will call this drive
the **target** hard drive.

The target drive can either be the original drive from your Seagate Central or a
different hard drive.


Connect the hard drive reader to your Linux system. After giving your Linux system
a few seconds to recognize the newly attached disk, use the "sfdisk -l" command
to list the drives in the system.


* Create a new Seagate Central style partition table on the target hard drive

Other tools such as "parted" can be also be used to create the Seagate Central
disk partitions however we use "sfdisk" in this procedure.

* Install Seagate Central firmware on the target hard drive
* Reinsert the target hard drive back in the Seagate Central
### 
### Remove the 

