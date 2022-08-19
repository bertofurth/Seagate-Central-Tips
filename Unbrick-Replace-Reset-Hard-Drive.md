# Unbrick, Replace or Reset Seagate Central Hard Drive
## Summary
This guide covers resetting a Seagate Central hard drive back to factory 
defaults by physically removing the drive from the Seagate Central, then
using an external Linux system to get the drive back to "out of the box"
state. This procedure can be applied to the original hard drive from a
Seagate Central or to a new hard drive.

This procedure can be used where a Seagate Central unit has become 
unresponsive or unusable and the existing drive needs to be reset. That 
is, when a Seagate central has been "bricked". 

It can also be used to replace the hard drive in a Seagate Central or to 
create a temporary hard drive separate from your everyday/production drive
to perform experiments with.

## TLDNR
* Open the Seagate Central and remove the existing/source hard drive
* (Optional) Recover any important user Data from the source hard drive.
* Attach the target hard drive to an external Linux System
* Wipe the existing partition table on the target hard drive
* Create a new Seagate Central style partition table on the target hard drive
* Install Seagate Central firmware on the target hard drive
* (Optional) Configure the unit to grant su / root access
* Disconnect the target hard drive from the external Linux System
* Reinsert the target hard drive back in the Seagate Central

## Warning
This procedure must not be followed blindly. You will need to understand
what you are doing before executing each part because if the procedure is
applied incorrectly, you could end up rendering the system you're using
to perform this procedure inoperative!

The main risk is that you may mistakenly apply the commands in these 
instructions to the wrong hard drive in your Linux system. This may result
in losing data and/or making your system unusable.

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
obviously less convinient than using an external USB connected hard
drive reader.

### Root access on a building Linux System
This procedure depends on being able to manipulate the target hard drive
using a Linux based system. In addition, since the procedure involves mounting 
an external hard drive and manipulating file ownership you'll need root access
on the Linux system as well.

If you only have a Windows system and do not have a Linux system then I can
suggest using a USB based "Live" Linux system such as the ones supplied 
by Debian, OpenSUSE or most other Linux distributions. I personally suggest
either the "OpenSUSE LEAP Rescue CD X86_64" for a console only Linux
system. This Live system uses a fairly small image that allows you
to easily log in as root and install the required Linux utilities. See

https://en.opensuse.org/SDB:Create_a_Live_USB_stick_using_Windows

https://download.opensuse.org/distribution/openSUSE-current/live/

### Required software tools on the building Linux host
#### sfdisk version later than 2.28 (2.37 or later is best)
This procedure makes use of version 2.28 (circa 2016) or later of the
"sfdisk" hard drive partitioning tool. Version 2.37 (circa 2022) or later 
is even better as these more recent versions will partition the disk in a 
slightly more efficient manner. 

This tool should be available on any modern Linux system with software more
recent than 2016 or so. Versions of sfdisk earlier than v2.26 cannot
manipulate the "GPT" style partition table as used by the Seagate Central.

Issue the "sfdisk -v" command as per the following example to
confirm the version of "sfdisk" in your system.

    # sfdisk -v
    sfdisk from util-linux 2.37.4

If versions earlier than 2.26 are used, then an error message similar
to the following may appear while running the sfdisk command

    unrecognized partition table type
    
#### squashfs tools (unsquashfs)    
Ensure that the "unsquashfs" program (part of the "squashfs" /
"squashfs-tools" package) is installed in order to read the Seagate
Central firmware image. Most Linux systems do not natively include this
tool so it will most likely need to be installed.

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

https://github.com/bertofurth/Seagate-Central-Tips/blob/main/Recover_Seagate_Central_Data.md

### Workspace preparation
If not already done, download the files in this project to a new directory 
on your Linux build machine. 

For example, the following **git** command will download the 
files in this project to a new subdirectory called 
Seagate-Central-Tips

    git clone https://github.com/bertofurth/Seagate-Central-Tips
    
Alternately, the following **wget** and **unzip** commands will 
download the files in this project to a new subdirectory called
Seagate-Central-Tips-main

    wget https://github.com/bertofurth/Seagate-Central-Tips/archive/refs/heads/main.zip
    unzip main.zip

Change into this new subdirectory. This will be referred to as 
the base working directory going forward.

     cd Seagate-Central-Tips
     
### Obtain then extract Seagate Central firmware
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

Using the "unzip" command below we open the Seagate Central Firmware zip
archive. Substitute the name of the Seagate Central firmware zip file you
are using when issuing these commands.

    unzip Seagate-HS-update-201509160008F.zip

A corresponding ".img" file should be created. For example

    # unzip Seagate-HS-update-201509160008F.zip
    Archive:  Seagate-HS-update-201509160008F.zip
       inflating: ReadMe.pdf
       inflating: Seagate-HS-update-201509160008F.img

This ".img" file will be used further on in the procedure.

If Seagate ever stop supplying firmware downloads then it is possible
to obtain this ".img" file from a Seagate Central hard drive on partition 5
(Config) under the "firmware" folder.

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
At this point in the procedure we wipe the original partitioning and data on the
target hard drive. (N.B. Advanced users who are comfortable navigating Linux 
parititoning and file systems can optionally try to keep the system's 
configuration and Data by following the Technical Note at the bottom of
this document entitled "Save the Config and Data partitions")

Removing the drive parititoning can be done using the following sfdisk command
(version 2.28 and later). Be sure to replace sdX with the real name of the
target drive. **Warning : This is an extremely dangerous command!! Make sure
to specify the correct target drive name or you might destroy data on your 
computer!!**

    sfdisk --delete /dev/sdX
    
If there are any error messages complaining about "Device or resource busy" or
advising that the system be rebooted, then the hard drive reader should be 
disconnected from the building system and the system should be rebooted.
After the building system has come back up, re-connect the hard drive reader.

Next, run the "lsblk" command again. The target hard drive should now have no
partitions (i.e. sdX1, sdX2, etc). Also note that the name of the target drive 
**may change** after a system reboot.

In the example below we see that the 2.5TB target drive "sda" now has no 
partitions.
 
    # lsblk
    NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
    sda          8:16    0  2.5TB  0 disk
    mmcblk0     179:0    0 119.1G  0 disk
      mmcblk0p1 179:1    0    64M  0 part /boot/efi
      mmcblk0p2 179:2    0   500M  0 part [SWAP]
      mmcblk0p3 179:3    0 118.5G  0 part /

If you are using a hard drive from a Seagate Central then it is advised that
you "zero out" the first 6GiB of the drive. During the devlopment of this
procedure we found that a number of obscure issues can be overcome when
re-partitioning a drive from a Segate central by performing this step.

This can be done using the "dd" command as seen below. Remember to replace
"sdX" with the actual drive name corresponding to the target. **Warning : 
This is an extremely dangerous command!! Make sure to specify the correct
target drive name or you might destroy data on your computer!!**

    dd status=progress bs=1048576 count=6144 if=/dev/zero of=/dev/sdX
        
This command may take a few minutes to complete executing as per the following
example

    # dd status=progress bs=1048576 count=6144 if=/dev/zero of=/dev/sdX
    6144+0 records in
    6144+0 records out
    6442450944 bytes (6.4 GB, 6.0 GiB) copied, 86.7031 s, 74.3 MB/s

### Create a new Seagate Central style partition table
In this section we use the "sfdisk" tool (v2.28 or later, but ideally v2.37 or 
later) to configure the partitions on the Seagate Central and then we format the
partitions. 

A template file in this project called "SC_part_table.txt" can be used
by the sfdisk tool to create the same partition layout on a hard drive as a 
native Seagate Central. This layout allocates all the "free" space at the
end of the drive to the Data partition. (N.B. Advanced users could modify the
partition table by editing this file appropriately. See the technical note at
towards the end of this document.)

The partition table can be applied to drive sdX using the commands below. Remember
to substitute your actual target drive name for sdX. Run partprobe after the
command has executed to force your system to re-read the partition table and the
lsblk command to view the new parititon table.

    cat SC_part_table.txt | sfdisk --force /dev/sdX
    partprobe
    lsblk /dev/sdX

The "lsblk" command should show that the target drive now has 7 partitions as per
the example below.

    # cat SC_part_table.txt | sfdisk --force /dev/sdX
    Checking that no-one is using this disk right now ... OK
    
    Disk /dev/sdX: 149.05 GiB, 160041885696 bytes, 312581808 sectors
    Disk model: XXXXXX-XXXXXX
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 4096 bytes / 33553920 bytes
    
    >>> Script header accepted.
    >>> Script header accepted.
    >>> Script header accepted.
    >>> Created a new GPT disklabel (GUID: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX).
    /dev/sdX1: Created a new partition 1 of type 'Microsoft basic data' and of size 20 MiB.
    /dev/sdX2: Created a new partition 2 of type 'Microsoft basic data' and of size 20 MiB.
    /dev/sdX3: Created a new partition 3 of type 'Microsoft basic data' and of size 1 GiB.
    /dev/sdX4: Created a new partition 4 of type 'Microsoft basic data' and of size 1 GiB.
    /dev/sdX5: Created a new partition 5 of type 'Microsoft basic data' and of size 1 GiB.
    /dev/sdX6: Created a new partition 6 of type 'Linux swap' and of size 1 GiB.
    /dev/sdX7: Created a new partition 7 of type 'Microsoft basic data' and of size 1 GiB.
    /dev/sdX8: Done.
    
    New situation:
    Disklabel type: gpt
    Disk identifier: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
    
    Device       Start      End Sectors Size Type
    /dev/sdX1     2048    43007   40960  20M Microsoft basic data
    /dev/sdX2    43008    83967   40960  20M Microsoft basic data
    /dev/sdX3    83968  2181119 2097152   1G Microsoft basic data
    /dev/sdX4  2181120  4278271 2097152   1G Microsoft basic data
    /dev/sdX5  4278272  6375423 2097152   1G Microsoft basic data
    /dev/sdX6  6375424  8472575 2097152   1G Linux swap
    /dev/sdX7  8472576 10569727 2097152   1G Microsoft basic data
    
    The partition table has been altered.
    Calling ioctl() to re-read partition table.
    Syncing disks.
    # partprobe
    # lsblk /dev/sdX
    NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
    sdX      8:32   0 149.1G  0 disk
      sdb1   8:33   0    20M  0 part
      sdb2   8:34   0    20M  0 part
      sdb3   8:35   0     1G  0 part
      sdb4   8:36   0     1G  0 part
      sdb5   8:37   0     1G  0 part
      sdb6   8:38   0     1G  0 part
      sdb7   8:39   0     1G  0 part

Note that the "Start" and "End" values shown by the "sfdisk" command may be
slightly different depending on the version of sfdisk you are using. The main
thing is that the partitions are the right "Size", "Type" and in the right order.

### Format the partitions
Each partition on the drive must now be formatted using the commands listed
below. Note the file system types (ext2, ext4 and swap) as well as options
("-O" parameter) are designed to exactly match those used on a Seagate Central drive.

Note also that "mkswap" for partition 6 uses a non standard 65536 byte page size
and the first 2 pages are zeroed out first using "dd". This is because the Linux
operating system on a Seagate Central uses a non standard 64K memory page size.

    # Format the Kernel Partitions 1 and 2 using ext2
    mkfs.ext2 -F -L Kernel_1 -O none,ext_attr,resize_inode,dir_index,filetype,sparse_super /dev/sdX1
    mkfs.ext2 -F -L Kernel_2 -O none,ext_attr,resize_inode,dir_index,filetype,sparse_super /dev/sdX2

    # Format the Root Partitions 3 and 4 using ext4
    mkfs.ext4 -F -L Root_File_System -O none,has_journal,ext_attr,resize_inode,dir_index,filetype,extent,flex_bg,sparse_super,large_file,huge_file,uninit_bg,dir_nlink,extra_isize /dev/sdX3
    mkfs.ext4 -F -L Root_File_System -O  none,has_journal,ext_attr,resize_inode,dir_index,filetype,extent,flex_bg,sparse_super,large_file,huge_file,uninit_bg,dir_nlink,extra_isize /dev/sdX4

    # Format the Config and Update Partititons 5 and 7 using ext4
    mkfs.ext4 -F -L Config -O none,has_journal,ext_attr,resize_inode,dir_index,filetype,extent,flex_bg,sparse_super,large_file,huge_file,uninit_bg,dir_nlink,extra_isize /dev/sdX5
    mkfs.ext4 -F -L Update -O none,has_journal,ext_attr,resize_inode,dir_index,filetype,extent,flex_bg,sparse_super,large_file,huge_file,uninit_bg,dir_nlink,extra_isize /dev/sdX7

    # Format Partition 6 as a swap partition
    dd bs=65536 count=2 if=/dev/zero of=/dev/sdX6 
    mkswap -p65536 /dev/sdX6
    
Each of the "mkfs" commands above should generate a status message at the end of the
output similar to the following example. 

    # mkfs.ext4 -F -L .......
    mke2fs 1.46.5 (30-Dec-2021)
    Creating filesystem with XXXXXX Xk blocks and XXXXX inodes
    Filesystem UUID: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
    . . .
    . . .
    Allocating group tables: done
    Writing inode tables: done
    Writing superblocks and filesystem accounting information: done

The "dd" and "mkswap" command output should be similar to the following example.

    # dd bs=65536 count=2 if=/dev/zero of=/dev/sdX6
    2+0 records in
    2+0 records out
    131072 bytes (131 kB, 128 KiB) copied, 0.0024024 s, 54.6 MB/s
    # mkswap -p65536 /dev/sdX6
    mkswap: Using user-specified page size 65536, instead of the system value 4096
    Setting up swapspace version 1, size = 1023.9 MiB (1073676288 bytes)
    no label, UUID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX

At this point the target drive is properly formatted.

Note that we do not create the user Data partition (sdX8) in this procedure. This 
is because the Seagate Central will automatically detect that it is missing and
it will be created as the unit boots up.

Note however, that when a Seagate Central comes "fresh out of the box" a number of
folders under the "Public" folder called "Music", "Photos" and "Videos"
are included. These contain about half a Gigabyte of sample media files. These folders
and sample media files are not automatically recreated using this procedure. If
desired, you can create these folders manually once the Seagate Central is up and
running.

### Install Seagate Central firmware on the target hard drive
In this part of the procedure we populate the target drive partitions with
the required Linux Operating System data as contained by the Seagate Central 
firmware ".img" file.

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
    
The following commands are used to prepare the partitions on the target drive with
the required folder structures and data. Remember to replace the firmware ".img" file
name with the actual firmware image name you are using.

    # Copy the firmware images (Replace .img name with your firmware name)
    mkdir /tmp/SC-Config/firmware
    cp Seagate-HS-update-201509160008F.img /tmp/SC-Config/firmware/
    mkdir /tmp/SC-Update/local
    tar -C /tmp/SC-Update/local/ -zxpf /tmp/SC-Config/firmware/Seagate-HS-update-201509160008F.img
    
    # Install the Primary Kernel
    cp /tmp/SC-Update/local/uImage /tmp/SC-Kernel_1/

    # Install the Secondary Kernel
    cp /tmp/SC-Update/local/uImage /tmp/SC-Kernel_2/
    
    # Install the Primary Root File System
    unsquashfs -f -d /tmp/SC-Root_1/ /tmp/SC-Update/local/rfs.squashfs
    mkdir /tmp/SC-Root_1/shares
    chmod a+x /tmp/SC-Root_1/shares
    touch /tmp/SC-Root_1/etc/nas_shares.conf
    chmod 600 /tmp/SC-Root_1/etc/nas_shares.conf

    # Install the Secondary Root File System
    unsquashfs -f -d /tmp/SC-Root_2/ /tmp/SC-Update/local/rfs.squashfs
    mkdir /tmp/SC-Root_2/shares
    chmod a+x /tmp/SC-Root_2/shares
    touch /tmp/SC-Root_2/etc/nas_shares.conf
    chmod 600 /tmp/SC-Root_2/etc/nas_shares.conf
    
### Optional -  Configure the Seagate Central to grant su / root access   
The following set of **optional** commands will modify the firmware so that
su / root access is enabled for the Seagate Central. This is included here
because recent versions of Seagate Central firmware disable root access by 
default. Root access is useful for doing extra customization and 
troubleshooting on the unit.

This process works by creating a startup script that forces the system's root
password to be set to the value XXXXX just once on first bootup only. (You
can modify this XXXXX value below however we'll be changing the Seagate 
Central's root password properly later in the procedure anyway.)
  
    cat << EOF > /tmp/SC-Root_1/etc/init.d/change-root-pw.sh
    #!/bin/bash
    
    echo "CHANGING ROOT PASSWORD" > /dev/kmsg
    echo "root:XXXXX" | chpasswd
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

### Disconnect the target hard drive from the building Linux System
Once the required data has been placed on the target drive, unmount the partitions.

    umount /tmp/SC-Kernel_1
    umount /tmp/SC-Kernel_2
    umount /tmp/SC-Root_1
    umount /tmp/SC-Root_2
    umount /tmp/SC-Config
    umount /tmp/SC-Update
    
After this point it should be safe to disconnect the hard drive reader from the
building system and remove the target hard drive from the reader.

### Reinstall the target hard drive and boot up the Seagate Central
Reinsert the target hard drive in the Seagate Central by sliding it into
the metal frame and connecting it to the SATA interface.

Note that the plastic lid can be left off the unit during the initial test run
just in case there's a problem and the hard drive needs to be removed again.

Reconnect the Ethernet cable and the power supply then power on the Seagate
Central.

After powering on, the LED status light visible from top of the unit should be
solid amber for about 30 to 40 seconds. Then, the LED will flash green for
another 2 - 3 minutes indicating that the Linux kernel is loading. During this
time you should be able to hear the hard drive operating. Finally,
the LED should turn a solid green indicating that the inital bootup sequence 
is complete. After this the unit needs to be left for another minute or so 
for the system to completely initialize.

### Connect to the Web Management Interface
You can now login to the Seagate Central web management interface where you
will be asked to configure an admin user. After that you will be able to
operate the Seagate Central as normal.

It may not be obvious how to log in to the Seagate Central web management
interface if you don't have the IP address of the unit.

The first method is as per the Seagate Central User Guide. Go into Windows
Explorer, go to "Network" then double click on the new Seagate Central device which
should be called "Seagate-xxxxxx". You can then click on the Public Folder then
select the "Manage Seagate Central" link. This should open your browser to the
device management web page where you can configure the unit.

If you are unable to access this URL for any reason then you should be able to
view the management web page of the newly booted Seagate Central by putting the
default name of the unit into the URL address bar of your browser. The default
name of the unit is "Seagate-xxxxxx" where "xxxxxx" is the last 6 characters of the
unit's MAC address which should be printed on the bottom of the unit's plastic 
cover.

For example, if the Seagate Central's MAC Address is shown on the bottom of the
unit as "0010758ACB4F" then you would browse to

http://seagate-8ACB4F

Another way of discovering the name and IP address of the unit it to run the 
"nmblookup -S '*' " command on a Linux system connected to the same network as the
Seagate Central. (This requires the "samba-client" package to beinstalled on the
system).

This will print out the names and IP addresses of all devices providing SMB file
sharing services on the local network. One of the devices will be called "SEAGATE-xxxxxx"
and the IP address of the unit will be listed. You can then browse to that IP address
to manage the unit. In the following example the unit called SEAGATE-8ACB4F has an
IP address of 192.168.1.58, so you would browse to http://192.168.1.58

    # nmblookup -S '*'
    192.168.1.58 SEAGATE-8ACB4F<00>
    Looking up status of 192.168.1.58
        SEAGATE-8ACB4F  <00> -         B <ACTIVE>
        SEAGATE-8ACB4F  <03> -         B <ACTIVE>
        SEAGATE-8ACB4F  <20> -         B <ACTIVE>
        WORKGROUP       <1e> - <GROUP> B <ACTIVE>
        WORKGROUP       <00> - <GROUP> B <ACTIVE>

### Change the root password properly
If you decided to add the step that modified the root password on first boot, then
it is strongly suggested that you change the root password again at this point.

Login to the Seagate Central via ssh using the administrator username and password 
you configured using the Web Management interface. Issue the "su" command and enter the
XXXXX password (or whatever value you used) to become the root user. Next, issue
the "passwd" command and enter a new password. You will be prompted to enter the
new password twice as per the following example.

    Seagate-8ACB4F:~$ su
    Password: XXXXX
    Seagate-8ACB4F:/Data/admin# passwd
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

## Technical Notes
Below are some technical notes that are only included for the sake of interested
parties. These do not need to be followed.

#### Save the "Config" and "Data" partitions
An alternative to wiping all the user and configuration Data on the Seagate
Central Drive is to just replace the operating system components and save the
system configuration and user Data. This could be done in an initial attempt
to fix a bricked unit. If this attempt failed then you could move on to the
standard procedure involving wiping the whole drive.

This can be done by following the standard procedure above with the following 
modifications.

Skip the sections entitled "Wipe the existing partition table and data on the
target hard drive" and "Create a new Seagate Central style partition table". 

In the section entitled "Format the partitions" only format The Kernel partititons
(1 and 2) and the Root Partititons (3 and 4). Do not format the Config, Update or
Swap partititons (5, 7 and 6).

All of the rest of the procedure can be followed as written. Note that some of
the commands involving partitions 5 and 7 might complain that some directories
or files already exist. These errors can be ignored.

#### Manually create the Data partition
As noted, the Seagate Central will automatically recreate the Data partition and the
associated LVM volume if it detects that they are missing. For this reason it is
not necessary to manually recreate the Data partition in this procedure.

If, however, for some reason you did wish to manually recreate the Data partition
before the unit boots up then it is not difficult to modify the procedure accordingly.

First, the "SC_part_table.txt" file needs to be modified to include a /dev/sdX8 
partition. The file included in this project has a commented out line corresponding
to partititon 8 that can be easily uncommented to include this new partition.

After executing all of the other commands, before removing the target drive from the
building Linux system you can format the Data partition as follows. Note that the "lvm2" 
package will need to be installed on the building system.

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
    
#### Modifying the default partition table
The size of the individual partitions on the Seagate Central drive can be modified
in order to facilitate experimentation. This can be done by simply editing the
appropriate entry in the "SC_part_table.txt" file before it is applied.

For example the sdX3 and sdX4 root file system partitions are each 1GiB by default. 
It might be desirable to increase these to 2GiB to allow extra room for cross
compiled binaries or experimentation.

As another example, partitions sdX5 (Config) and sdX7 (Update) are normally
1GiB in size. These partitions never use more than about 350MiB so it would be safe
to reduce these partititons from 1GiB each to, say, 0.5GiB.

Naturally, the order of the partitions and their file system type (ext2/ext4/swap) 
must not be modified.

#### Troubleshooting error messages during partitioning
Sometimes strange problems with partitioning the target drive can be overcome
by zeroing the first 6 GB of the drive. This will completely clear out any
existing operating system or partitioning data on the target drive that might
interfere with the procedure. 

This can be done using the "dd" command as seen below. Remember to replace 
"sdX" with the actual drive name corresponding to the target. 

    dd status=progress bs=1048576 count=6144 if=/dev/zero of=/dev/sdX
        
This command will take a few minutes to complete executing. 

After the dd command has finished, we suggest disconnecting the hard drive
reader, rebooting the system and then reconnecting the hard drive reader
after the system has rebooted.

After the building system reboots run the "lsblk" command again. The target
hard drive should now have no partitions (i.e. sdX1, sdX2, etc). Also note 
that the name of the drive **may change** after a system reboot.

#### Partition characteristics of an original Seagate Central Drive
Below are the partition characteristics of a "fresh out of the box" 
Seagate Central drive as taken from a Seagate Central 4TB model. This
is for reference purposes only.

    # sfdisk -l /dev/sdb
    Disk /dev/sdb: 3.64 TiB, 4000787030016 bytes, 7814037168 sectors
    Disk model: 000-1F2168
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 4096 bytes / 33553920 bytes
    Disklabel type: gpt
    Disk identifier: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
    
    Device        Start        End    Sectors  Size Type
    /dev/sdb1      2048      43007      40960   20M Microsoft basic data
    /dev/sdb2     43008      83967      40960   20M Microsoft basic data
    /dev/sdb3     83968    2181119    2097152    1G Microsoft basic data
    /dev/sdb4   2181120    4278271    2097152    1G Microsoft basic data
    /dev/sdb5   4278272    6375423    2097152    1G Microsoft basic data
    /dev/sdb6   6375424    8472575    2097152    1G Linux swap
    /dev/sdb7   8472576   10569727    2097152    1G Microsoft basic data
    /dev/sdb8  10569728 7814037134 7803467407  3.6T Linux LVM

Further details of individual file system characteristics are included in
this project in the file called "profile-of-native-SC-disk.txt".  
