#!/bin/bash
source "base/0-misc.sh"
source "base/1-base.sh"
source "base/2-partitioning.sh"
source "base/3-mount.sh"
source "base/4-install.sh"
source "base/5-configure.sh"
source "base/6-bootprep.sh"

# ChRoot
printinfo "Change root to /mnt"
#arch-chroot /mnt
mkdir -p /mnt/tmp/chroot/
cp -rf sysfiles/ /mnt/tmp/chroot/
cp -f base/6.1-chroot.sh /mnt/tmp/chroot/chroot.sh
mount -t proc /proc /mnt/proc/
mount --rbind /sys /mnt/sys/
mount --rbind /dev /mnt/dev/
cp sysfiles/grub /mnt/tmp/chroot/sysfiles/grub
chroot /mnt /usr/bin/bash /tmp/chroot/chroot.sh

###########################################################################################
###########################################################################################
################                    CONFIG USER SPACE                      ################
###########################################################################################
###########################################################################################

# Quit Chroot and cleanup

printinfo "Cleanup"
umount /mnt/boot/efi
umount /mnt/boot
sync
umount /mnt/proc/
umount /mnt/sys/
umount /mnt/dev/
umount /mnt
cryptsetup close cryptroot

popd > /dev/null
