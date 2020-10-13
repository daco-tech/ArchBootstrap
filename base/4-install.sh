# Install base system
# Install Packages
printinfo "Installing System Packages"

_pkgs_base=(base intel-ucode linux linux-firmware)
_pkgs_drivers=(intel-media-driver libva mesa ntfs-3g vulkan-intel
               xf86-video-intel)
_pkgs_sys=(avahi bash bluez coreutils dhcpcd efibootmgr exfat-utils f2fs-tools
           fakeroot findutils fish fscrypt gptfdisk grub iwd lz4 pacman parted
           patch pulseaudio rng-tools sudo xz zip zsh zstd cups)
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
pacstrap -i /mnt ${_pkgs_base[*]} ${_pkgs_drivers[*]} ${_pkgs_sys[*]} --needed --noconfirm #\
	#${_pkgs_tools[*]} ${_pkgs_dev[*]}  ${_pkgs_x11[*]} ${_pkgs_fonts[*]} \
	#${_pkgs_apps[*]} 

genfstab -U /mnt >> /mnt/etc/fstab

