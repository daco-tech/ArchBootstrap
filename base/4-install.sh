# Install base system
# Install Packages
printinfo "Installing System Packages"



printinfo "Generate fstab"

genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
sleep 40

