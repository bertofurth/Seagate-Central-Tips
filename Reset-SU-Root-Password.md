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

The details of this method are explained in a section below.

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

The details of this method are explained in a section below.

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
Here is a list of some popular GUI Open Source ssh clients for Windows. There are
dozens of others available.

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
that the logged in user has the right privelidges to perform this procedure.

    NAS-X:~$ groups
    root users admin
    
If the "groups" command does not show the "root" group then you are not logged
in as an administrator level user, but a normal user.

    NAS-X:~$ groups
    users fred
    
Once you have confirmed that you are logged in to the Seagate Central with 
administrative privelidges, issue the following commands in your ssh
session. These commands plant a startup script in the Seagate Central operating
system that will change the root password to XXXXX at next boot (we'll change this
password later). I'd suggest just copying and pasting these commands a few lines at 
a time in to your ssh session to ensure that no mistakes are made.

    cat << EOF > /etc/rcS.d/S90change-root-pw.sh
    #!/bin/bash
    echo "CHANGING ROOT PASSWORD"
    echo "root:XXXXX" | chpasswd
    pwconv
    cp /etc/passwd /usr/config/backupconfig/etc/passwd
    cp /etc/shadow /usr/config/backupconfig/etc/shadow   
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

## Removing the Hard Drive and Connecting it to Another Computer 
This method is essentially the same concept as the method presented above except
we will be inserting the bootup script manually


GIVE DETAILS ON CHANGING THE PASSWORD FOR AN ADMIN USER AS WELL??


Give a list of the tools needed and then the files that need to be edited. 
(Copy from Data recovery Tip)

Detail Windows Method with Paragon Software - WILL NOTEPAD WORK???


Detail Linux Method using "mount"


Remember to change the password again.

As per the other method delete the boot script.

Note that if the unit does happen to reboot to the backup firmware then the
root password will be reset to the value in the script. Unlikely
to happen.





