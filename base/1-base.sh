# Load PT Keyboard
loadkeys pt-latin1

# Update Mirrorlist with Local Portugal repos
pacman -Syy --noconfirm reflector
reflector -c Portugal -a 6 --sort rate --save /etc/pacman.d/mirrorlist
pacman -Syyy

# Time
timedatectl set-ntp true


