
# Configure Grub Boot
printinfo "\n"
printinfo "Installing and configuring GRUB"
grub-install --target=x86_64-efi --efi-directory="/boot/efi" --bootloader-id=arch_grub --recheck && sync
cp /etc/default/grub /etc/default/grub.backup
sed -i -r "s#/dev/sda3#'$(vol_id --uuid /dev/sda3)'#" sysfiles/grub
cp sysfiles/grub /etc/default/grub
chmod u=rw,g=r,o=r /etc/default/grub

curl "https://github.com/daco-tech/poly-dark/archive/master.zip" -L -o /tmp/polydark.zip
unzip /tmp/polydark.zip -d /tmp
rm /tmp/poly-dark-master/install.sh
mv /tmp/poly-dark-master /boot/grub/themes/polydark

grub-mkconfig -o /boot/grub/grub.cfg