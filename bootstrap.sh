#!/bin/bash

source "hosts/vbox.vars"
source "base/0-misc.sh"
source "base/1-base.sh"
source "base/2-partitioning.sh"
source "base/3-mount.sh"
source "base/4-install.sh"
source "base/5-configure.sh"
source "base/6-bootprep.sh"
source "base/7-sysprep.sh"


rintinfo "\n"
printinfo "+ ---------------------------- +"
printinfo "| Jumping into the chroot jail |"
printinfo "+ ---------------------------- +"
mkdir -p /mnt/tmp/chroot
cp sysfiles/resolv.conf /mnt/etc/resolv.conf
cp -r {.,base/,sysfiles/} /mnt/tmp/chroot
mount -t proc /proc /mnt/proc/
mount --rbind /sys /mnt/sys/
mount --rbind /dev /mnt/dev/
echo ${device}
sed 's#DISKDEV#'"${device}"'3#g' sysfiles/grub > /mnt/tmp/chroot/sysfiles/grub



chroot /mnt /usr/bin/bash /tmp/chroot/base/6.1-chroot.sh
chroot /mnt /usr/bin/bash /tmp/chroot/base/7.1-chroot.sh




printinfo "\n"
printinfo "+ --------------------- +"
printinfo "| Unmounting partitions |"
printinfo "+ --------------------- +"
umount /mnt/boot/efi
umount /mnt/boot
sync
umount /mnt/proc/
umount /mnt/sys/
umount /mnt/dev/
umount /mnt
cryptsetup close root

popd > /dev/null




###########################################################################################
###########################################################################################
################                    CONFIG USER SPACE                      ################
###########################################################################################
###########################################################################################

