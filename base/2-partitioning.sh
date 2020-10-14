# Partitioning


yesno "Possible Data Loss! Do you want to continue?"





devicelist=$(lsblk -dplnx size -o name,size | grep -Ev "boot|rpmb|loop" | tac)
device=$(dialog --stdout --menu "Select installation disk" 0 0 0 ${devicelist}) || exit 1
device="${device}${partition_append}"

printinfo "Erasing storage disks"
sgdisk --zap-all "${device}" && sleep 2

printinfo "Partitioning Arch Linux"

parted "${device}" mklabel gpt && sleep 1

_starts_at=1
_ends_at=$((1 + 384)) # 384MiB EFI partition
parted "${device}" mkpart primary "${_starts_at}MiB" "${_ends_at}MiB" set 1 esp on && sleep 1

_starts_at=${_ends_at}
_ends_at=$((${_ends_at} + 384)) # 384MiB boot partition
parted "${device}" mkpart primary "${_starts_at}MiB" "${_ends_at}MiB" && sleep 1

_starts_at=${_ends_at} # All remaining space as a root partition 
parted "${device}" mkpart primary "${_starts_at}MiB" "100%" && sleep 1

# Format Partitions
printinfo "\n"
printinfo "Formatting ${device} partitions and setting up LUKS encrypted partition"
mkfs.fat -F32 "${device}1" && sleep 1
mkfs.f2fs -f "${device}2" && sleep 1
cryptsetup -y -v luksFormat "${device}3" && sleep 1
cryptsetup open "${device}3" root && sleep 1
mkfs.f2fs -O encrypt -f /dev/mapper/root && sleep 1