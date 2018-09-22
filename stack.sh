#!/bin/bash -e
set -e

grep stackstorage /etc/fstab && echo Already mounted && exit 1

read -p "Please provide disk name https://YOUR-DISK-NAME.stackstorage.com:" DISKNAME
read -p "Please provide username:" USERNAME
read -p "Please provide password:" PWD

# https://www.transip.nl/knowledgebase/artikel/239-stack-externe-back-up-voor-gebruiken/
apt install -y davfs2
usermod -aG davfs2 $USER
mkdir -p /stack
mkdir -p ~/.davfs2
cp /etc/davfs2/secrets ~/.davfs2/secrets
chown $USER ~/.davfs2/secrets
chmod 600 ~/.davfs2/secrets
echo "https://$DISKNAME.stackstorage.com/remote.php/webdav/ $USERNAME $PWD" >> ~/.davfs2/secrets
echo "https://$DISKNAME.stackstorage.com/remote.php/webdav/ /stack davfs user,rw,noauto 0 0" >> /etc/fstab

echo Completed $0

