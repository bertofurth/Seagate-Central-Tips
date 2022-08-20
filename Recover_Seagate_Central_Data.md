# Recover Data from a Seagate Central Hard Drive
If you have a Seagate Central that has stopped functioning then it may 
be necessary to manually extract the data stored on the Central's
internal hard drive. This document discusses how to accomplish this
using either a Windows 10 based system and software from Paragon or using
a Linux system. We then discuss some deeper technical reasons why recovering
data from a Seagate Central hard drive is particularly complicated and talk 
about the Seagate Central drive partitioning scheme.

## TLDNR - Windows
* Connect the Seagate Central hard drive to a USB hard drive reader 
* Install and run "Linux File Systems for Windows by Paragon Software" on your Windows PC.
* Put the Paragon tool into "Read-only" mode.
* Connect the drive reader to your Windows machine
* **DO NOT LET WINDOWS FORMAT OR WRITE TO THE DRIVE**
* Take note of the assigned drive letter for the Data partition
* Copy the required data to another device using Windows Explorer

## TLDNR - Linux
* Connect the Seagate Central hard drive to a USB hard drive reader
* Install the "lvm" and "e2fsprogs" packages on your Linux system
* Connect the drive reader to your Linux system
* Use the lvdisplay command to identify the Data parition LVM path
* Mount the Data partition with the fuse2fs tool

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

### Enough disk space to store the recovered files
Seagate Central hard drive capacities vary from 2000GB to 5000GB depending on the 
model. Make sure you have somewhere to store all the data you want to extract from
the Seagate Central before you start this procedure. 

## Note and Warning
If you are not very technically literate, or you are not confident about 
following this procedure, then you can simply pay an expert to recover the data 
from your old non working Seagate Central. Simply search for Data or Hard Drive 
recovery services in your area. 

This is something you should consider if the data you're retrieving is 
particularly important and if you're not very confident with computers.

That being said, as long as you follow the procedure described in this document
it's highly unlikely that you'll make things worse! You can always give this
procedure a try and if it fails, call the professional service to help you out.
Feel free to pass this document along to them to facilitate their work.

**The key is to make sure that you don't let Windows format the Seagate Central
hard drive or write anything to the Seagate Central hard drive.** If you make
sure to follow this important guideline then everything should be fine.

## Procedure for Windows
### Open the Seagate Central and Take out the Hard Drive
As per the pre-requisites section, search for a video detailing instructions
on opening the Seagate Central and how to pull out the hard drive.
There are dozens of videos on the topic. One example is

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

### Install and run "Linux File Systems for Windows by Paragon Software"
Before you connect the hard drive reader to your PC, install the
"Linux File Systems for Windows by Paragon Software" tool available
from

https://www.paragon-software.com/home/linuxfs-windows/

This tool from Paragon lets Windows read data from a variety of different 
kinds of Linux file systems.

This tool is available as a 10 day free trial version. Hopefully that
will be enough time to extract the data from your Seagate Central
hard drive.

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
critical data on the Seagate Central drive.

### Connect the hard drive reader to your Windows PC
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

## Mount the Data partition
After the hard drive reader is connected to the PC, the Paragon Software tool 
should show the new drives being recognized.

If you scroll down through the list of recognized partitions on the left hand side of
the app window, down the bottom under a section titled "lvm1" you should see the very
large 1500 to 5000 GB partition called "Data". This is the partition we are interested
in. 

If you have configured the Paragon tool so that it does not automatically mount
new drives then at this point you can click on the "Data" partition to select it,
then click on the "Mount" option at the top of the window to assign the drive
a letter for access by the Windows system. Take note of the drive letter being assigned
to the partition.

Ignore the other smaller partitions recognized by the tool as these only contain files
associated with the Seagate Central's Linux operating system and should not contain
any user data.

### Copy the Data using Windows Explorer
Use Windows Explorer to navigate to the Data partition drive letter assigned
above.

You may need to click on the "This PC" icon in the left hand part of the
Windows Explorer window to see all the new drives created by the Paragon
tool. Click on the "Data" drive to view the contents of the drive. It should
have a capacity in the order of 2 to 5 TB.

After clicking on the "Data" drive you should see all the user data folders
on the Seagate Central. 
 
You can ignore the following directories because they only contain Seagate Central
operating system specific data which will not likely be of interest.

    .GoFlexData
    .uploads
    anonftp
    dbd
    lost+found
    mt-daapd
    twonky
    TwonkyData

Also ignore any directories with the ".tm" suffix at the end

In many cases everything of interest will be under the "Public" directory 
but obviously you should check the other user directories for any relevant
data files.

This data can be copied over to a different location as per the normal copying
process using Windows Explorer. In most cases I'd expect that you have another
very large external hard drive connected to your PC. Be aware that it can take
a long time (days) to copy Terabytes of information between USB devices, especially
if you're using a slower USB 2.0 style interface.

Note again, that the "Trial" version of the Paragon Software only works properly
for 10 days after installation. For this reason I recommend that you copy the 
data over quickly so that you can ensure it's all retrieved before the software
expires.

## Procedure for Linux
Mounting a Seagate Central Data partition under Linux is not as straight forward
as issuing the "mount" command for the appropriate partiton. This is because
the Data partition is formatted using a 64K page size. See the Technical Discussion
section below for more details.

If normal mounting procedures are followed in Linux then an error message
of the following kind may appear at the command line and in the system logs.

    root# mount /dev/vg1/lv1 /mnt/tmp
    mount: /mnt/tmp: wrong fs type, bad option, bad superblock on /dev/mapper/vg1-lv1, missing codepage or helper program, or other error.

    EXT4-fs (dm-0): bad block size 65536

The easiest way to deal with this issue is to mount the partition using the
fuse2fs utility which is part of the e2fsprogs package.

The other, far less convenient alternative is to recompile the system's kernel
to use a 64K page size (CONFIG_PAGE_SIZE_64K). This is not recommended as this
would make memory allocation on your system less efficient.

The brief procedure for mounting a Seagate Central Data volume using fuse2fs is
as follows. Note that all of the following commands must be executed as the root 
user or with the "sudo" prefix.

First, make sure that the system has the "lvm2" and "e2fsprogs" packages installed. 
For example, in Debian use the command

    apt install lvm2 e2fsprogs

Next, connect the USB drive reader containing the Seagate Central drive to the
Linux system.

Generate a list of available LVM partitions by running the "lvdisplay" command.
Take a note of the LV Path corresponding to the Seagate Central data partition.
Be careful if you have other LVM partitions active in your system to identify
the correct partition path. In the example below the LV Path is /dev/vg1/lv1

    root# lvdisplay
    --- Logical volume ---
    LV Path                /dev/vg1/lv1
    LV Name                lv1
    VG Name                vg1
    LV UUID                PD3ZH2-GVlS-FRjB-XB3G-Pm3q-2VKQ-2D3hB7
    LV Write Access        read/write
    LV Creation host, time ,
    LV Status              available
    # open                 0
    LV Size                2.72 TiB
    Current LE             714106
    Segments               1
    Allocation             inherit
    Read ahead sectors     auto
    - currently set to     256
    Block device           253:0

Once the LV Path is discovered, mount the partition using the fuse2fs program
as per the following example. In this example we are mounting the logical 
partition /dev/vg1/lv1 at the mount point /mnt/tmp (Use an existing directory
in your system as the mount point). Note that the volume can be mounted as
read-only by adding the "-o ro" flag to the end of the command.

    root# fuse2fs /dev/vg1/lv1 /mnt/tmp
    /dev/vg1/lv1: recovering journal
    /dev/vg1/lv1: Writing to the journal is not supported.
    Orphans detected; running e2fsck is recommended.
    root# cd /mnt/tmp
    root# ls    
    admin  admin.tm  anonftp  dbd  lost+found  mt-daapd  Public  twonky  TwonkyData


At this point the volume will be mounted at the specified directory (in this case 
/mnt/tmp) and the data in the partition should be available for copying as normal. 

Once you've finished using the parititon the volume can be unmounted as per the
normal umount command as seen in the example below

    root# umount /mnt/tmp



## Technical discussion
### Reasons why a Seagate Central Data partition is hard to access
There are 3 things that make retrieving data from a Seagate Central hard drive
difficult.

1) ext4 Linux file system :
The Seagate Central Data partition is formatted using the ext4 file system which is
not natively readable by Windows. Third party tools such as the Paragon Software
mentioned in this document are generally needed.

2) Logical Volume Management (LVM) :
The Data partition on a Seagate Central is organized as a Linux Volume Group (VG) using
Logical Volume Management (LVM). This means that some third party Windows software
that can read ext4 partitions, still cannot read the Data volume. This also makes
mounting the partition under Linux a little less straight forward.

3) 64K partition page size :
The Data partition on a Seagate Central is formatted using a non standard 64K page size. 
Many Windows based ext4 disk reading utilities can only read partitions formatted 
using the standard 4K page size. In fact, many Linux distributions will also have
difficulty mounting such a volume. This is because Linux can only natively mount ext4 
volumes that use a page size no greater than the system memory page size which is
typically set at 4K. 

The "Linux File Systems for Windows by Paragon Software" seems to be able to 
overcome all of these limitations.

We tested a number of other ext4 for Windows software packages and they were unable
to read the Seagate Central Data partition for at least one of the above reasons.
These other applications included "Ext2FSD", "Diskinternals Linux Reader" and
"Ext2Read (AKA Ext2explore)".

If you happen to know of any other software for Windows besides the Paragon tool
that can access the Seagate Central Data partition then please log an issue
in this project and let us know. 

### The Layout of the Seagate Central Hard Drive
The Seagate Central Hard drive contains a number of different partitions.

Here we should the output of the "fdisk -l" command run on a Linux
machine with the Seagate Central drive connected using a USB
hard drive reader.

    # fdisk -l
    Disk /dev/sda: 2.73 TiB, 3000592982016 bytes, 5860533168 sectors
    Disk model: 003-1F216N
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 4096 bytes / 33553920 bytes
    Disklabel type: gpt
    Disk identifier: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
    
    Device        Start        End    Sectors  Size Type
    /dev/sda1      2048      43007      40960   20M Microsoft basic data
    /dev/sda2     43008      83967      40960   20M Microsoft basic data
    /dev/sda3     83968    2181119    2097152    1G Microsoft basic data
    /dev/sda4   2181120    4278271    2097152    1G Microsoft basic data
    /dev/sda5   4278272    6375423    2097152    1G Microsoft basic data
    /dev/sda6   6375424    8472575    2097152    1G Linux swap
    /dev/sda7   8472576   10569727    2097152    1G Microsoft basic data
    /dev/sda8  10569728 5860533134 5849963407  2.7T Linux LVM
    
    
    Disk /dev/mapper/vg1-lv1: 2.72 TiB, 2995177652224 bytes, 5849956352 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 4096 bytes / 33553920 bytes

Note that on your system "/dev/sdX" may be a different letter depending on what
other devices are active in your system.

# sda1 and sda2 : 20M boot partitions
These partitions contain the Linux kernel for the Seagate central system
in a file called "uImage". 

The kernel will be loaded from one or the other of these partitions depending
on which one is active. That is, one of them is active and the other acts
as a backup however it is not straightforward to determine which partition
is currently active unless the Seagate Central is up and running.

# sda3 and sda4 : 1G Root file system
These partitions contain the root file system which has all the important
Linux operating system executables and configuration files for the Seagate
Central. Again, one of these partitions is active and the other is a backup. 

The files in these partitions may be useful to manipulate if the operating
system needs to be modified. However take note that modifying the files in
the /etc configuration directory may not be effective because of the 
backup configuration partiton (see below)

# sda5 : 1G backup config partition
This partition contains a backup of the main configuration elements of the
Seagate Central Linux operating system. This partition is mounted at
/usr/config/backupconfig on the Seagate Central.

When the Seagate Central boots up all of the files in this partition, 
particularly those under the /etc, are copied over the ones on the root
partition. So this means that any changes you wish to make to files
in the /etc configuration directory have to also be made in the corresponding
/etc directory on this partition.

# sda6 : 1G Linux swap partition
This is the Linux swap partition which is used to extend the system's 
memory resources to the disk when RAM is getting low. This can usually be
ignored and must not be modified.

# sda7 : 1G Update partition
This partition is used during firmware upgrades.

# sda8 : Large Linux LVM partition
This partition contains the Data partition Volume Group. It cannot be
mounted directly but instead the Logical Volume within it must be
mounted.

The name of the Data partition logical volume is seen at the end of
the fdisk -l command output. In this case /dev/mapper/vg1-lv1. As per
the Procedure for Linux section this partition uses a 64K page size
and as such may need to be mounted using the fuse2fs tool rather than
the standard mount command.

