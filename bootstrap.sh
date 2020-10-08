#!/bin/bash
./misc.sh

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

