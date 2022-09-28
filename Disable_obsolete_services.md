# Disable Obsolete and Unneeded Services on the Seagate Central
The Seagate Central comes with a number of services that have become
obselete and with other services that are not useful to everyone

Some of these services continue to utilize CPU and memory even when
they are marked as disabled with the Seagate Central Web Management 
interface!!

Here is a list of services that can be manually disabled in order to
ensure that they do not consume any resources on the Seagate Central. 

Naturally you should not disable any services that you are currently 
using.

The changes will take effect on the next reboot.

The instructions in this procedure assume that you are logged into the
Seagate Central as the root user or that you prepend the "su" command
to all commands.

## Obsolete Services 
Some services on the Seagate Central are no longer functional. These
should be removed as they are not providing any useful functionality.

### Seagate Media Server
This was a service where you could view content on your Seagate Central 
remotely or on your phone by registering an account with Seagate. This was
discontinued as per the notice at

https://www.seagate.com/us/en/support/downloads/seagate-media/

Note, this is different to the Twonky DLNA service that provides access to 
media for player devices on your home network.

Also note that if you upgrade the Linux kernel on your Seagate Central
then you **must** also disable this service otherwise the unit will
hang on boot.

By disabling this service we stop the Seagate Central from spending
cpu and memory resources on something that serves no purpose. In
addition, some users have reported that this service generates thousands of
files containing megabytes of rubbish data in the Public folder. These files
start with the following names.

     bootstrapdb
     media_server_daemon.txt
     messages
     
Run the following commands to disable the Media Server.

    update-rc.d -f media_server_daemon remove
    update-rc.d -f media_server_ui_daemon remove
    update-rc.d -f media_server_allow_scan remove
    update-rc.d -f media_server_default_start remove

Reboot the system to make the changes take effect.

After the reboot, it is suggested to delete all the binaries and files 
associated with the defunct Seagate Media service by running the following 
commands

    rm -rf /media_server/
    find  /etc/ -name "*media_server*" -exec rm {} +

### Tappin remote access service
The Tappin remote access service was a service that allowed users
to remotely access content on their Seagate Central. This service
has been shutdown for some time as per the notice at

https://www.seagate.com/us/en/support/kb/seagate-central-tappin-update-007647en/

Run the following command to disable the Tappin service.

    update-rc.d -f tappinAgent remove
     
Reboot the system to make the changes take effect.

After the reboot, optionally delete all the binaries and files associated
with the defunct Tappin service by running the following commands

    rm -rf /apps/tappin
    find  /etc/ -name "*tappinAgent*" -exec rm {} +

## Other services
Below are listed some services that are still functional but may not be required
in your particular environment. If these services are not being used then 
some system memory and CPU time can be saved by disabling them.

### Facebook archiver
A service where your Seagate Central saves content posted on your
Facebook page.

Run the following command to disable the Facebook archiver.

    update-rc.d -f fbarchived remove

Reinstate this service with the following command.

    update-rc.d media_server_daemon defaults 99
    
### vsFTPd : FTP daemon
FTP and SFTP are file transfer protocols which have waned in popularity
over the last few years. Most modern networks do no make use of these protocols
and instead prefer SAMBA or scp for file transfer.

Run the following command to disable the vsFTPd service

    update-rc.d -f vsftpd remove
     
Reinstate this service with the following command.

    update-rc.d media_server_daemon defaults 20     
    
    