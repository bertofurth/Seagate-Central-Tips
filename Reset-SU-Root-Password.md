# Reset the SU / Root Password on a Seagate Central

# WARNING : UNFINISHED! UNTESTED! 

## Summary
Early versions of Seagate Central firmware allow admin users to gain su / root
access on the device, however the latest versions of stock firmware deliberately
disable su / root access by setting the root password to a random value.

Root access is only useful on the Seagate Central if you plan on performing
custom modifications on the unit. Otherwise it isn't really a neccessity.

Here is an overview of the methods we describe in this document to get root access
back on your Seagate Central. 

### 1) "Planting" a Boot Script (Easy)
This method involves logging in to the unit via ssh as an admin user then creating
a bootup script that will reset the root password to a known value on the next
system reboot. This method requires that you know at least one administrator level 
username and password combination that works. 

When you set up the unit initially, you would have been asked to supply a username
and password that would act as the administrator of the unit. This is the username 
and password you can use with this method. 

Put another way, if you know what username and password to use to login to the web 
management page of your Seagate Central and you see the "Settings" tab then you can
use that username / password combination with this method.

### 2) Removing the Hard Drive and Connecting it to Another Computer (Moderate)
This involves physically removing the unit's hard drive, connecting it to an external
Windows or Linux system, then editing operating system files. This method does not
require that you know any usernames or passwords on the target unit. However, it requires
that you are willing to physically open up the Seagate Central, remove the hard drive 
and connect it to an external system via a USB hard drive reader.

Operning up the unit is a little tedious but you can do it if you have a "jewllers"
tool kit for the small screws and there are plenty of videos on the Internet showing
the process. 

USB Hard Drive readers (specifically SATA to USB) are fairly cheap (US$30) and easily
available at most "computer" shops or electronics websites.

### 3) The Firmware Upgrade Method
This method involves manipulating a stock Seagate issue firmware image and generating
replacement firmware that automatically resets the root password to a known value. You
still need to be able to log in to with an administrator level user via the web
management page to initiate the upgrade so this method doesn't really have any
advantages over method 1 if all you want to do is get root access.

This method is documented in the "Seagate Central Samba" project at

https://github.com/bertofurth/Seagate-Central-Samba

### 4) Data Recovery then Full System Wipe.
This involves removing the hard drive from the unit, connecting it to an external
Linux system (not Windows) recovering the user Data on the unit, then performing 
a full system wipe and reinstallation. This would be the preferred method if the
unit has somehow become unresponsive or unreliable. This method involves physically
removing the hard drive and connecting it to an external Linux system. 

This method is described in the "Unbrick-Replace-Reset-Hard-Drive.md" document
in this project at

https://github.com/bertofurth/Seagate-Central-Tips/blob/main/Unbrick-Replace-Reset-Hard-Drive.md


## "Planting" a Boot Script
How to login via ssh
Maybe include details of easy to use Windows ssh clients

Edit a boot script that changes the root password

Reboot the unit

Change the root password for real (remember all the copy commands)

rm the change on boot script so that the unit doesn't change it again.



## Removing the Hard Drive and Connecting it to Another Computer 

Give a list of the tools needed and then the files that need to be edited. 
(Copy from Data recovery Tip)

Detail Windows Method with Paragon Software

Detail Linux Method using "mount"


Remember to change the password again.

As per the other method delete the boot script.

Note that if the unit does happen to reboot to the backup firmware then the
root password will be reset to the value in the script. Unlikely
to happen.





