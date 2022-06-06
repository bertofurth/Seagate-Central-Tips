# Recover Data from a Seagate Central Hard Drive
If you have a Seagate Central that has stopped functioning then it may 
be necessary to manually extract the data stored on the Central's
internal hard drive. This document discusses how to accomplish this
using a Windows 10 based system and software from Paragon. We also discuss
some technical reasons why recovering data from a Seagate Central hard
drive is particularly complicated, even in a Linux environment. We then
present some very brief instructions on how to mount the Seagate Central 
drive under Linux.

In summary, because of the peculiarities of the Seagate Central drive format,
it's much easier to do data recovery using Windows than Linux.


# Unfinished!! NOT READY FOR USE!!!






## TLDNR 

* Remove the hard drive from the Seagate Central
* Connect the hard drive to an external USB hard drive reader 
* Install and run "Linux File Systems for Windows by Paragon Software" on your Windows PC.
* Put the Paragon tool into "Read-only" mode.
* Connect the drive reader to your Windows machine
* **DO NOT LET WINDOWS FORMAT OR WRITE TO THE DRIVE**
* Take note of the assigned drive letter for the Data partition
* Copy the required data to another device using Windows Explorer

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

The alternative is to install the Seagate Central hard drive inside your Windows 
computer. This assumes that you are using a desktop computer with enough room 
inside to house the extra hard disk. This is obviously much more tedious than 
just using an external hard drive reader.

### Enough disk space to store the recovered files
Seagate Central hard drive capacities vary from 2000GB to 5000GB depending on the 
model. Make sure you have somewhere to store all the data you want to extract from
the Seagate Central before you start this procedure. 

## Note and Warning
If you are not very technically literate, or you are not confident about 
following this procedure then you can simply pay an expert to recover the data 
from your old non working Seagate Central. Simply search for Data or Hard Drive 
recovery services in your area. 

This is something you should consider if the data you're retrieving is 
particularly important or if you're not very confident with computers.

That being said, as long as you follow the procedure described in this document
it's highly unlikely that you'll make things worse! You can always give this
procedure a try and if it fails, call the professional service to help you out.
Feel free to pass this document along to them to facilitate their work.

**The key is to make sure that you don't let Windows format the Seagate Central
hard drive or write anything to the Seagate Central hard drive.** If you make
sure to follow this important guideline then everything should be fine.

## Procedure
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

I would then highly recommend changing the default behavior of the program
so that it does not automatically mount partitions and so that it mounts them
as read-only by default. This can be done by clicking on the three horizonal lines menu
item to the right of "Sign in", then clicking on "Settings" then turning 
"Mount automatically" to "Off" and setting "Mount volumes in"
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
large 2000 to 5000 GB partition called "Data". This is the partition we are interested
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


## Postscript - Details for Professionals
There are 3 things that make retrieving data from a Seagate Central hard drive
difficult.

1) ext4 Linux file system
The Seagate Central Data partition is formatted using the ext4 file system which is
not natively readable by Windows. Third party tools such as the Paragon Software
mentioned in this document are generally needed.

2) Logical Volume Management (LVM)
The Data parition on a Seagate Central is organized as a Linux Volume Group (VG) using
Logical Volume Management (LVM). This means that some third party Windows software
that can read ext4 partitions, still cannot read the Data volume. This also makes
mounting the partition under Linux a little less straight forward.

3) 64K partition page size 
The Data partition on a Seagate Central is formatted using a non standard 64K page size. 
Many Windows based ext4 disk reading utilities can only read partitions formatted 
using the standard 4K page size. In fact, many Linux distributions will also have
difficulty mounting such a volume. This is because Linux can only natively mount ext4 
volumes that use a page size no greater than the system memory page size which is
typically set at 4K. 

The "Linux File Systems for Windows by Paragon Software" seemed to be able to 
overcome all of these limitations.

We tested a number of other ext4 for Windows software pacakges and they were unable
to read the Seagate Central Data partition for at least one of the above reasons.
These other applications included

Ext2FSD
Diskinternals Linux Reader
Ext2Read (AKA Ext2explore)

If you happen to know of any other software for Windows besides the Paragon tool
that can access the Seagate Central Data partition then please log an issue
in this project and let us know. 

## Mounting a Seagate Central hard drive under Linux
For the reasons listed above, mounting an externally attached Seagate Central hard
drive under Linux is not straight forward. The main obstacle to overcome is the
64K page size for the Data partition.

In summary, mounting such a volume under Linux requires that you recomile your
system's kernel to use a 64K page size so that it becomes capable of reading the
Data partition. By default, most Linux distributions use a 4K page size.

Recompiling the Linux Kernel for your specific Linux distribution is beyond the
scope of this document however for most major distributions many guides can be found.

The key is to ensure the CONFIG_PAGE_SIZE_64K option is set when the kernel
is recompiled.



Check getconf PAGESIZE


List with fdisk -l


How to mount data partition with vg commands

From there they can be copied.













