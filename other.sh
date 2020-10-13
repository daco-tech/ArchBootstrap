



# Generate fstab
printinfo "Configure fstab"
#genfstab -U /mnt >> /mnt/etc/fstab
sed -i -r "s#/dev/sda3#'$(vol_id --uuid /dev/sda3)'#" sysfiles/fstab
cp sysfiles/fstab /mnt/etc/fstab
chmod u=r,g=r,o=r /mnt/etc/fstab