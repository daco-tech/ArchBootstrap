# Load Variables


# Load PT Keyboard
loadkeys ${_keyboard}

# Update Mirrorlist with Local Country repos


reflector -c ${_mirrorlst_country} -a 6 --sort rate --save /etc/pacman.d/mirrorlist
pacman -Syyy

# Time
timedatectl set-ntp true


