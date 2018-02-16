#!/bin/sh

#Add user Ubuntu to the sudoers to avoid ask for the passwd
sudo sh -c "echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers"

#Remove boot log and enables splash-screen
sudo cp -a /home/ubuntu/files-to-overwrite/extlinux.conf /boot/extlinux/extlinux.conf
sudo cp -a /home/ubuntu/files-to-overwrite/sysctl.conf /etc/sysctl.conf
sudo chown root:root /boot/extlinux/extlinux.conf
sudo chown root:root /etc/sysctl.conf

#Enables Foreal custom logo splashscreen
sudo mkdir /usr/share/plymouth/themes/foreal-logo/
sudo cp -a /home/ubuntu/foreal-logo.png /usr/share/plymouth/themes/foreal-logo/
sudo cp -a /home/ubuntu/files-to-overwrite/plymouthd.defaults /usr/share/plymouth/plymouthd.defaults
sudo cp -a /home/ubuntu/files-to-overwrite/foreal-logo.plymouth /usr/share/plymouth/themes/foreal-logo/foreal-logo.plymouth
sudo cp -a /home/ubuntu/files-to-overwrite/foreal-logo.script /usr/share/plymouth/themes/foreal-logo/foreal-logo.script
sudo chown root:root /usr/share/plymouth/themes/foreal-logo/foreal-logo.png
sudo chown root:root /usr/share/plymouth/plymouthd.defaults
sudo chown root:root /usr/share/plymouth/themes/foreal-logo/foreal-logo.plymouth
sudo chown root:root /usr/share/plymouth/themes/foreal-logo/foreal-logo.script

#Disable ubuntu desktop and launches QT GUI app
sudo cp -a /home/ubuntu/files-to-overwrite/rc.local /etc/rc.local
sudo chown root:root /etc/rc.local

#Update sources.list to get full access to packages installation
sudo cp -a /home/ubuntu/files-to-overwrite/sources.list /etc/apt/sources.list
sudo chown root:root /etc/apt/sources.list
sudo apt update

#Create the directory that will contain all the media-files of the control-console system
mkdir /home/ubuntu/media-files

