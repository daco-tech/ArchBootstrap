#!/bin/bash
source "./misc.sh"

timedatectl set-ntp true

# Partitioning


yesno "Possible Data Loss! Do you want to continue?"





pacman -S --noconfirm dialog

devicelist=$(lsblk -dplnx size -o name,size | grep -Ev "boot|rpmb|loop" | tac)
device=$(dialog --stdout --menu "Select installation disk" 0 0 0 ${devicelist}) || exit 1

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
cryptsetup --verbose luksFormat "${device}3" && sleep 1
cryptsetup open "${device}3" root && sleep 1
mkfs.f2fs -O encrypt -f /dev/mapper/root && sleep 1



# Mount Root Partition
printinfo "\n"
printinfo "Mounting partitions"
mount /dev/mapper/root /mnt && sleep 1

mkdir -p /mnt/boot
mount "${device}2" /mnt/boot
mkdir -p /mnt/boot/efi
mount "${device}1" /mnt/boot/efi


# Update Mirrors
printinfo "Updating mirrors list"
cp sysfiles/mirrorlist /etc/pacman.d/mirrorlist


# Config InitRamFS
printinfo "Configuring initramfs"
pacstrap -i /mnt mkinitcpio --noconfirm
cp /mnt/etc/mkinitcpio.conf /mnt/etc/mkinitcpio.conf.backup


# Configure Hardware specific
_initramfs_modules="i915 rfkill"
_initramfs_hooks="base autodetect udev keyboard keymap consolefont encrypt modconf block filesystems"
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



# Install Packages
printinfo "Installing Pacman packages"

_pkgs_base=(base intel-ucode linux-lts linux-firmware)
_pkgs_drivers=(intel-media-driver libva mesa ntfs-3g vulkan-intel
               xf86-video-intel)
_pkgs_sys=(avahi bash bluez coreutils dhcpcd efibootmgr exfat-utils f2fs-tools
           fakeroot findutils fish fscrypt gptfdisk grub iwd lz4 pacman parted
           patch pulseaudio rng-tools sudo xz zip zsh zstd)
_pkgs_tools=(archiso aria2 bash-completion bat bc bluez-utils cbatticon cpupower croc curl
             entr exa fd ffmpeg firejail fwupd fzf gawk gnupg gocryptfs htop
             intel-gpu-tools intel-undervolt iotop libva-utils lshw lsof man
             neovim nmap nnn openbsd-netcat openssh p7zip pbzip2 pigz powertop
             progress ripgrep svt-av1 svt-hevc svt-vp9 tig time tmux tree unzip
             usleep which)
_pkgs_dev=(autoconf automake binaryen binutils bison clang cmake ctags diffutils
           docker docker-compose edk2-ovmf gcc gcc8 gcc9 gdb git go go-tools
           lldb m4 make ninja openssl-1.0 perf pkgconf python python-pip 
           spirv-llvm-translator spirv-headers spirv-tools
           strace tokei vulkan-extra-layers vulkan-icd-loader vulkan-mesa-layers
           vulkan-tools vulkan-validation-layers wabt zig)
_pkgs_x11=(bspwm dunst picom sxhkd xorg-server xorg-xinit xorg-xinput xorg-xprop
           xorg-xrandr xorg-xset xorg-xsetroot xsel)
_pkgs_fonts=(noto-fonts noto-fonts-emoji terminus-font ttf-font-awesome
             ttf-jetbrains-mono)
_pkgs_apps=(alacritty arandr feh firefox libreoffice-still maim meld mesa-demos
            mpv nomacs obs-studio pavucontrol pcmanfm-gtk3 rofi redshift
            slock sxiv veracrypt wireshark-qt)

pacman -Syy
pacstrap -i /mnt ${_pkgs_base[*]} ${_pkgs_drivers[*]} ${_pkgs_sys[*]} \
	${_pkgs_tools[*]} ${_pkgs_dev[*]}  ${_pkgs_x11[*]} ${_pkgs_fonts[*]} \
	${_pkgs_apps[*]} --needed --noconfirm

# Generate fstab
printinfo "Configure fstab"
#genfstab -U /mnt >> /mnt/etc/fstab
cp sysfiles/fstab /mnt/etc/fstab
chmod u=r,g=r,o=r /mnt/etc/fstab

# Copy config files
printinfo "Copy configuration files"

cp sysfiles/resolv.conf /mnt/etc/resolv.conf


# ChRoot
printinfo "Change root to /mnt"
#arch-chroot /mnt
mkdir -p /mnt/tmp/chroot/
cp -f ./chroot.sh /mnt/tmp/chroot/chroot.sh
mount -t proc /proc /mnt/proc/
mount --rbind /sys /mnt/sys/
mount --rbind /dev /mnt/dev/
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
cryptsetup close root

popd > /dev/null
