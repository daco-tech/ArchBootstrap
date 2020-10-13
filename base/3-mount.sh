# Mount Root Partition
printinfo "\n"
printinfo "Mounting partitions"
mount /dev/mapper/root /mnt && sleep 1

mkdir -p /mnt/boot
mount "${device}2" /mnt/boot
mkdir -p /mnt/boot/efi
mount "${device}1" /mnt/boot/efi

# Show Disks
printinfo "Show disk setup"
lsblk
pause 10

