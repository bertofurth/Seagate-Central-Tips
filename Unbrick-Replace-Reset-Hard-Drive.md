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
    
You may need to manually install "unsquashfs" and "lvm2" as these are not always
included in most Linux systems.

For OpenSUSE

    # zypper add squashfs lvm2
     
For Debian

    # apt-get install squashfs-tools lvm2
     
## Procedure
### Open the Seagate Central and take out the source Hard Drive
As per the pre-requisites section, search for a video detailing instructions
on opening the Seagate Central and how to pull out the hard drive.
There are dozens of videos on the topic. One example is

https://www.dailymotion.com/video/x6exylx

Once the unit is opened and the four square rubber pads holding the hard
drive in place are unscrewed, the hard drive can be pulled away and 
disconnected from the main circuit board with a moderate amount of force.

### Optional - Recover any important user Data from the source hard drive
If you have not already backed up the user Data contained on the Seagate Central
drive then this is the point at which it should be done.

See the document in this project called **Recover_Seagate_Central_Data.md**
for detailed instructions on how to retrieve Data from a physical hard drive
that has been removed from a Seagate Central.

### Attach the target hard drive to an external Linux System
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
     
In the commands shown from this point the hard drive we wish to prepare
will be called **sdX**. You will need to modify the commands to match
the appriate drive letter in your system.

### Wipe the existing partition table on the target hard drive
This step is not normally required when partitioning and formatting a
drive however while developing this procedure we found a number of obscure
problems occured unless this step was followed. This was particularly the
case when a drive from a Seagate Central was the target as opposed to
a new drive being the target.

The first 6 GB of the drive should be overwritten with zeros to completely
clear any operating system data and partitioning. The easiest way to do
that is with the following "dd" command as per the example below. Remember 
to replace sdX with the drive name corresponding to the target. **Warning : 
This is an extremely dangerous command. Make sure to specify the correct
/dev/sdX target drive name or you might destroy data on your computer.**

    # dd if=/dev/zero of=/dev/sdX status=progress bs=1048576 count=6144
    
After executing this command, physically disconnect the USB hard drive reader
from the building system, reboot the system, then once the system has rebooted
reconnect the hard drive reader again. This step may appear unintuitive or 
sloppy however, in the process of developing this procedure a reboot at this
point fixed a number of obscure problems.

After the system reboots and the hard drive has been reconnected run the
"lsblk" command again to re-identify the target hard drive. The target
hard drive should now have no partitions (eg sdX1, sdX2, etc). Also note
that the name of the drive may well change after a system reboot.

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
native Seagate Central hard drive. 

The partiton table can be applied to drive sdX using the commands below. Remember
to substitute your actual target drive name for sdX. Run partprobe after the
command has executed to force your system to re-read the partition table.

    # cat SC_part_table.txt | sfdisk --force /dev/sdX
    # partprobe
    
Here is an example of the command output of the sfdisk command. 
    
    # cat SC_part_table.txt | sfdisk --force /dev/sdX
    Checking that no-one is using this disk right now ... OK

    Disk /dev/sdX: 149.05 GiB, 160041885696 bytes, 312581808 sectors
    Disk model: 00AVJS-63WNA0
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 4096 bytes / 33553920 bytes

    >>> Script header accepted.
    >>> Script header accepted.
    >>> Script header accepted.
    >>> Script header accepted.
    >>> Created a new GPT disklabel (GUID: F5526D62-EA0C-154D-8E51-DD308EA1B2D3).
    /dev/sdX1: Created a new partition 1 of type 'Microsoft basic data' and of size 20 MiB.
    /dev/sdX2: Created a new partition 2 of type 'Microsoft basic data' and of size 20 MiB.
    /dev/sdX3: Created a new partition 3 of type 'Microsoft basic data' and of size 1 GiB.
    /dev/sdX4: Created a new partition 4 of type 'Microsoft basic data' and of size 1 GiB.
    /dev/sdX5: Created a new partition 5 of type 'Microsoft basic data' and of size 1 GiB.
    /dev/sdX6: Created a new partition 6 of type 'Linux swap' and of size 1 GiB.
    /dev/sdX7: Created a new partition 7 of type 'Microsoft basic data' and of size 1 GiB.
    /dev/sdX8: Created a new partition 8 of type 'Linux LVM' and of size 144 GiB.
    /dev/sdX9: Done.
    
    New situation:
    Disklabel type: gpt
    Disk identifier: F5526D62-EA0C-154D-8E51-DD308EA1B2D3
    
    Device        Start       End   Sectors  Size Type
    /dev/sdX1      2048     43007     40960   20M Microsoft basic data
    /dev/sdX2     43008     83967     40960   20M Microsoft basic data
    /dev/sdX3     83968   2181119   2097152    1G Microsoft basic data
    /dev/sdX4   2181120   4278271   2097152    1G Microsoft basic data
    /dev/sdX5   4278272   6375423   2097152    1G Microsoft basic data
    /dev/sdX6   6375424   8472575   2097152    1G Linux swap
    /dev/sdX7   8472576  10569727   2097152    1G Microsoft basic data
    /dev/sdX8  10569728 312581774 302012047  144G Linux LVM

    The partition table has been altered.
    Calling ioctl() to re-read partition table.
    Syncing disks.
        
Each partition on the drive must now be formatted using the commands listed
below. Note the file system options specified with the "-O" parameter are
designed to exactly match those used on a Seagate Central drive.
Also note that the "mkswap" and the last "mkfs.ext4" command use
a non standard 65536 byte page size because the Linux operating system on 
a Seagate Central uses a non standard 64K memory page size.

    # Partitions 1 and 2 use ext2
    mkfs.ext2 -F -O none,ext_attr,resize_inode,dir_index,filetype,sparse_super /dev/sdX1
    mkfs.ext2 -F -O none,ext_attr,resize_inode,dir_index,filetype,sparse_super /dev/sdX2

    # Partitions 3, 4, 5 and 7 use ext4
    mkfs.ext4 -F -O none,has_journal,ext_attr,resize_inode,dir_index,filetype,extent,flex_bg,sparse_super,large_file,huge_file,uninit_bg,dir_nlink,extra_isize /dev/sdX3
    mkfs.ext4 -F -O none,has_journal,ext_attr,resize_inode,dir_index,filetype,extent,flex_bg,sparse_super,large_file,huge_file,uninit_bg,dir_nlink,extra_isize /dev/sdX4
    mkfs.ext4 -F -O none,has_journal,ext_attr,resize_inode,dir_index,filetype,extent,flex_bg,sparse_super,large_file,huge_file,uninit_bg,dir_nlink,extra_isize /dev/sdX5
    mkfs.ext4 -F -O none,has_journal,ext_attr,resize_inode,dir_index,filetype,extent,flex_bg,sparse_super,large_file,huge_file,uninit_bg,dir_nlink,extra_isize /dev/sdX7

    # Partition 6 is a swap partition
    mkswap -p65536 /dev/sdX6
    
    # Parititon 8 (The Data partition) uses Logical Volume Manager (LVM)
    pvcreate -ff /dev/sdX8
    pvscan --cache
    vgcreate vg1 /dev/sdX8
    vgscan
    lvcreate -l +100%FREE vg1 -n lv1
    lvscan    
    mkfs.ext4 -F -b 65536 -L Data -O none,has_journal,ext_attr,resize_inode,dir_index,filetype,extent,flex_bg,sparse_super,large_file,huge_file,uninit_bg,dir_nlink,extra_isize -m0 /dev/vg1/lv1



* Install Seagate Central firmware on the target hard drive



unzip Seagate-HS-update-201509160008F.zip
mount /dev/sdb7 /mnt/sdb7
mkdir /mnt/sdb7/local


mount /dev/sdb5 /mnt/sdb5
mkdir /mnt/sdb5/firmware
cp Seagate-HS-update-201509160008F.img /mnt/sdb5/firmware/


tar -C /mnt/sdb7/local/ -zxpf /mnt/sdb5/firmware/Seagate-HS-update-201509160008F.img


# For primary kernel
mount /dev/sdb3 /mnt/sdb3
unsquashfs -f -d /mnt/sdb3/ /mnt/sdb7/local/rfs.squashfs


# INSERT ROOT PW SETTING STARTUP SCRIPT
# FIX THIS

cat << EOF > /mnt/sdb3/etc/rcS.d/S96change-root-pw.sh
#!/bin/bash

echo "CHANGING ROOT PASSWORD"
echo "root:seagate123" | chpasswd
pwconv
cp /etc/passwd /usr/config/backupconfig/etc/passwd
cp /etc/shadow /usr/config/backupconfig/etc/shadow

EOF
chmod u+x /mnt/sdb3/etc/rcS.d/S96change-root-pw.sh

cat << EOF > /mnt/sdb3/etc/rcS.d/S97disable-change-root-pw.sh
#!/bin/bash

chmod a-x /etc/rcS.d/S96change-root-pw.sh

EOF
chmod u+x /mnt/sdb3/etc/rcS.d/S97disable-change-root-pw.sh

mkdir /mnt/sdb3/shares
chmod a+x /mnt/sdb3/shares
touch /mnt/sdb3/etc/nas_shares.conf
chmod 600 /mnt/sdb3/etc/nas_shares.conf

mount /dev/sdb1 /mnt/sdb1
cp /mnt/sdb7/local/uImage /mnt/sdb1/


# For backup kernel

mount /dev/sdb4 /mnt/sdb4
unsquashfs -f -d /mnt/sdb4/ /mnt/sdb7/local/rfs.squashfs

cp /mnt/sdb3/etc/nas_shares.conf /mnt/sdb4/etc/


#
# Only do these if you want the backup kernel to reset
# the root password if it ever boots up. Might not be a
# bad idea since the backup kernel will only boot up
# in the case of a complete failure of the main kernel
# or if the unit fails to boot properly 4 times in a row.
#
cp /mnt/sdb3/etc/rcS.d/S96change-root-pw.sh /mnt/sdb4/etc/rcS.d/
cp /mnt/sdb3/etc/rcS.d/S97disable-change-root-pw.sh /mnt/sdb4/etc/rcS.d/

mkdir /mnt/sdb4/shares
chmod a+x /mnt/sdb4/shares

mount /dev/sdb2 /mnt/sdb2
cp /mnt/sdb7/local/uImage /mnt/sdb2/


umount /mnt/sdb1
umount /mnt/sdb2
umount /mnt/sdb3
umount /mnt/sdb4
umount /mnt/sdb5
umount /mnt/sdb7




* Reinsert the target hard drive back in the Seagate Central
### 
### Remove the 

