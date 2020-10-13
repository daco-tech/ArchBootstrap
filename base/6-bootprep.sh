# Config InitRamFS
printinfo "Configuring initramfs"
pacstrap -i /mnt mkinitcpio --noconfirm
cp /mnt/etc/mkinitcpio.conf /mnt/etc/mkinitcpio.conf.backup


# Configure Hardware specific
_initramfs_modules="i915 rfkill"
_initramfs_hooks="base udev autodetect keyboard keymap consolefont  modconf block encrypt filesystems keyboard fsck"
sed -i -r "s/^MODULES=\(\)/MODULES=($_initramfs_modules)/" /mnt/etc/mkinitcpio.conf
sed -i -r "s/^HOOKS=(.*)/HOOKS=($_initramfs_hooks)/" /mnt/etc/mkinitcpio.conf
sed -i -r '/#COMPRESSION="lz4"/s/^#*//g' /mnt/etc/mkinitcpio.conf
# The keymap needs to be configured earlier so initramfs uses the correct layout
# for entering the disk decryption password.
mkdir -p /mnt/usr/local/share/kbd/keymaps
{ echo "keycode 58 = Escape";
  echo "altgr keycode 18 = euro";
  echo "altgr keycode 46 = cent"; } > /mnt/usr/local/share/kbd/keymaps/uncap.map
{ echo "keycode 58 = Caps_Lock";
  echo "altgr keycode 18 = euro";
  echo "altgr keycode 46 = cent"; } > /mnt/usr/local/share/kbd/keymaps/recap.map
{ echo "KEYMAP=pt-latin1";
  echo "KEYMAP_TOGGLE=/usr/local/share/kbd/keymaps/uncap.map";
  echo "FONT=ter-116n"; } > /mnt/etc/vconsole.conf

sed -i 's#DEVICE#'"${device}3"'#g' base/6.1-chroot.sh