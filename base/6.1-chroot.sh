

# Configure Grub Boot
grub-install --target=x86_64-efi --efi-directory="/boot/efi" --bootloader-id=arch_grub --recheck && sync

cp /tmp/chroot/sysfiles/grub /etc/default/grub
chmod u=rw,g=r,o=r /etc/default/grub

mkdir -p /tmp/
curl "https://github.com/daco-tech/poly-dark/archive/master.zip" -L -o /tmp/polydark.zip
unzip /tmp/polydark.zip -d /tmp
rm /tmp/poly-dark-master/install.sh
mv /tmp/poly-dark-master /boot/grub/themes/polydark
sed -i 's#DISK_UUID#'"$(blkid -o value -s UUID /dev/sda3)"'#g' sysfiles/grub > /etc/default/grub
cat /tmp/chroot/sysfiles/grub

grub-mkconfig -o /boot/grub/grub.cfg

# Recreate InitRam
#mkinitcpio -p linux