#!/bin/bash

# this script was made to format a 3TB (2.7) USB HDD

lsblk

export TO_FORMAT_DRIVE=/dev/sda
wipefs -a $TO_FORMAT_DRIVE

parted $TO_FORMAT_DRIVE mklabel gpt
parted $TO_FORMAT_DRIVE mkpart primary ext4 1MiB   225GB  name 1 parents
parted $TO_FORMAT_DRIVE mkpart primary ext4 225GB  450GB  name 2 brother
parted $TO_FORMAT_DRIVE mkpart primary ext4 450GB  675GB  name 3 sister
parted $TO_FORMAT_DRIVE mkpart primary ext4 675GB  900GB  name 4 friend
parted $TO_FORMAT_DRIVE mkpart primary ext4 900GB  1125GB name 5 business
parted $TO_FORMAT_DRIVE mkpart primary ext4 1125GB 1350GB name 6 backup
parted $TO_FORMAT_DRIVE mkpart primary ext4 1350GB 1575GB name 7 test
parted $TO_FORMAT_DRIVE mkpart primary      1575GB 1800GB name 8 shared
parted $TO_FORMAT_DRIVE mkpart primary      1800GB 100%   name 9 local

# The last two partitions are to be editable locally
# therefor we use exfat, since it is more widely supported
# if the NAS SoC were to fail, people can still use the USB HDD normally

mkfs.ext4  -L mom     $TO_FORMAT_DRIVE\1
mkfs.ext4  -L martijn $TO_FORMAT_DRIVE\2
mkfs.ext4  -L colette $TO_FORMAT_DRIVE\3
mkfs.ext4  -L spare1  $TO_FORMAT_DRIVE\4
mkfs.ext4  -L spare2  $TO_FORMAT_DRIVE\5
mkfs.ext4  -L backup  $TO_FORMAT_DRIVE\6
mkfs.ext4  -L test    $TO_FORMAT_DRIVE\7
mkfs.exfat -n shared  $TO_FORMAT_DRIVE\8
mkfs.exfat -n local   $TO_FORMAT_DRIVE\9

mkdir -p /mnt/parents
mkdir -p /mnt/martijn
mkdir -p /mnt/colette
mkdir -p /mnt/spare1
mkdir -p /mnt/spare2
mkdir -p /mnt/backup
mkdir -p /mnt/test
mkdir -p /mnt/local
mkdir -p /mnt/shared
chmod -R 755 /mnt
chmod 777 /mnt/shared
chmod 777 /mnt/local

# now we setup a folder for the samba,
# sharing the family dirs but not the test, backup and spares
mkdir -p /shared
chmod 755 /shared
ln -s /mnt/parents /shared/parents
ln -s /mnt/martijn /shared/martijn
ln -s /mnt/colette /shared/colette
ln -s /mnt/shared /shared/sander
ln -s /mnt/local /shared/local

cat << EOF >> /etc/fstab
LABEL=mom     /mnt/parents ext4  defaults,nofail  0  2
LABEL=martijn /mnt/martijn ext4  defaults,nofail  0  2
LABEL=colette /mnt/colette ext4  defaults,nofail  0  2
LABEL=spare1  /mnt/spare1  ext4  defaults,nofail  0  2
LABEL=spare2  /mnt/spare2  ext4  defaults,nofail  0  2
LABEL=backup  /mnt/backup  ext4  defaults,nofail  0  2
LABEL=test    /mnt/test    ext4  defaults,nofail  0  2

LABEL=shared  /mnt/shared  exfat defaults,nofail,uid=armbian,gid=armbian,fmask=000,dmask=000  0  0
LABEL=local   /mnt/local   exfat defaults,nofail,uid=armbian,gid=armbian,fmask=000,dmask=000  0  0
EOF

systemctl daemon-reload
mount -a

fdisk -l
lsblk -f

