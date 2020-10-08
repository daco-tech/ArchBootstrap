#!/bin/bash
source "./misc.sh"

timedatectl set-ntp true

# Partitioning
printinfo "Partitioning Arch Linux"

yesno "Possible Data Loss! Do you want to continue?"
pacman -S --noconfirm dialog

devicelist=$(lsblk -dplnx size -o name,size | grep -Ev "boot|rpmb|loop" | tac)
device=$(dialog --stdout --menu "Select installation disk" 0 0 0 ${devicelist}) || exit 1
parted --script "${device}" -- mklabel gpt \
  mkpart ESP fat32 1Mib 129MiB \
  set 1 boot on \
  mkpart primary linux-swap 129MiB 2177MiB \
  mkpart primary ext4 2177MiB 100%
mkfs.ext4 "${device}3"
mkswap "${device}2"

# Mount Root Partition
printinfo "Mount Root Partition ${device}3"
mount "${device}3" /mnt
printinfo "Turn on Swap"
swapon "${device}2"
printinfo "Mount EFI Partition ${device}1"
mkdir -p /mnt/efi
mount "${device}1" /mnt/efi

# Update Mirrors
printinfo "Updating mirrors list"
cp sysfiles/mirrorlist /etc/pacman.d/mirrorlist
pacman -Syyu

# Install Essential Packages
printinfo "Running pacstrap on the root mount"
pacstrap /mnt base linux linux-firmware --noconfirm

# Generate fstab
printinfo "Generate fstab"
genfstab -U /mnt >> /mnt/etc/fstab
#genfstab -U /mnt/efi >> /mnt/etc/fstab
