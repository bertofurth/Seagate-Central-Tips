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
This involves physically removing the Seagate Central's hard drive, connecting it to
an external Windows or Linux system, then editing operating system files. This method
does not require that you know any usernames or passwords on the target unit. However,
it requires that you are able to physically open up the Seagate Central, remove the
hard drive and connect it to an external system via a USB hard drive reader.

Opening up the unit is a little tedious but you can do it if you have a "jewellers"
tool kit for the small screws and a prying tool would also be useful. There are plenty
of videos on the Internet showing the process. 

USB Hard Drive readers (specifically SATA to USB) are fairly cheap (US$30) and easily
available at most computer shops or electronics websites.

### 3) The Firmware Upgrade Method
This method involves manipulating a stock Seagate issue firmware image and generating
replacement firmware that automatically resets the root password to a known value. You
still need to be able to log in to with an administrator level user via the web
management page to initiate the upgrade so this method doesn't really have any
advantages over method 1 if all you want to do is get root access.

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

## "Planting" a Boot Script
### ssh
Secure Shell (ssh) is a means of securely connecting to and managing devices, such as
the Seagate Central, via a network connection. It usually involves accesing a text
based command prompt where commands can be issued to a device to control it and
monitor it's status.

In order to connect to a device via ssh you'll need an ssh client.

#### Windows 10 Inbuilt OpenSSH client
To install the Windows 10 native OpenSSH client see the following URL

https://www.howtogeek.com/336775/how-to-enable-and-use-windows-10s-built-in-ssh-commands/

After making sure the OpenSSH client is installed, open the Windows Command Prompt.
(Hit Windows Key + S and Search for the "Command Prompt" app.) 

Once the Command Prompt window opens issue the "ssh username@NAS-IP-ADDRESS" command
where "username" is the Seagate Central's administrator username and "NAS-IP-ADDRESS"
is your Seagate Central's IP address or hostname. When prompted for a password enter
the administrator user's password. 

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
Here is a list of some popular Open Source ssh clients for Windows. There are dozens 
of others available

Putty :
https://www.chiark.greenend.org.uk/~sgtatham/putty/

Tera Term :
https://ttssh2.osdn.jp/index.html.en

#### Linux ssh
Most Linux distributions generally come with a command line ssh client installed.

It can be easily invoked from the command line as "ssh username@host". In the
following example the username "admin" is used to login to the NAS at IP
address "192.168.1.50"

    berto@rpi ~$ssh admin@192.168.1.50
    The authenticity of host '192.168.1.50 (192.168.1.50)' can't be established.
    DSA key fingerprint is SHA256:pEz2Rl+ZMS3yoPtiH12fpjXdKXAgD9uAUbq5e7DIF+Q.
    This key is not known by any other names
    Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
    Warning: Permanently added '192.168.1.50' (DSA) to the list of known hosts.
    admin@192.168.1.50's password:
    Last login: Tue Aug 16 22:01:23 2022 from 192.168.1.10
    NAS-X:~$

In some cases an error message simmilar to the following may appear because the 
Seagate Central uses an older, less secure version of encryption. Some modern
Linux ssh clients may complain as per the following example.

    berto@rpi ~$ssh admin@192.168.1.50
    Unable to negotiate with 10.0.2.198 port 22: no matching host key type found. Their offer: ssh-rsa,ssh-dss

If this happens then you can configure the Linux ssh client to allow connections
to hosts using the older version of encryption as follows.

    berto@rpi ~$ echo "HostKeyAlgorithms=+ssh-dss" >> ~/.ssh/config

### Create a boot script 

Confirm you're an administrator (group)

Create script

#!/bin/bash -x
echo "root:XXXXXXXXXX" | chpasswd
pwconv
cp /etc/passwd /usr/config/backupconfig/etc/passwd
cp /etc/shadow /usr/config/backupconfig/etc/shadow

Login to the web management system and reboot (or just power cycle the device)



After the reboot login as administrator again then issue 
Edit a boot script that changes the root password

Reboot the unit

su


Change the root password for real (remember all the copy commands)


rm the change on boot script so that the unit doesn't change it again.

Done!!


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





