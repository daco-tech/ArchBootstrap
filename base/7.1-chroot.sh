# Set mirror list permissions
chmod u=rw,g=r,o=r /etc/pacman.d/mirrorlist

# Setup regional settings
rm -rf /etc/localtime
ln -sf /usr/share/zoneinfo/${_zoneinfo} /etc/localtime

sed -i -r '/#en_US.UTF-8 UTF-8/s/^#*//g' /etc/locale.gen # Default
sed -i -r '/#'"${_locale}"'/s/^#*//g' /etc/locale.gen # Configured
locale-gen


{ echo "LANG=${_os_lang}";
  echo "LC_ALL=${_os_lang}";
  echo "LC_CTYPE=${_regional_settings}";
  echo "LC_MEASUREMENT=${_regional_settings}";
  echo "LC_MONETARY=${_regional_settings}";
  echo "LC_NUMERIC=${_regional_settings}";
  echo "LC_TELEPHONE=${_regional_settings}";
  echo "LC_TIME=${_regional_settings}"; } > /etc/locale.conf

echo "KEYMAP=${_keyboard}" > /etc/rc.conf

# Configure DNS and Hostname

echo "$_hostname" > /etc/hostname
{ echo -e "127.0.0.1\tlocalhost";
  echo -e "::1\tlocalhost";
  echo -e "127.0.0.1\t${_hostname}.localdomain\t${_hostname}"; } > /etc/hosts


# Configure lan interface DNS
if [ -z "${_nw_lan_interface}" ]
then
      echo "LAN Interface not present!"
else
      {
        echo "";
        echo "interface ${_nw_lan_interface}";
        echo "${_dns}"; } >> /etc/dhcpcd.conf
fi

# Configure wlan interface DNS
if [ -z "${_nw_wlan_interface}" ]
then
      echo "WLAN Interface not present!"
else
      {
        echo "";
        echo "interface ${_nw_wlan_interface}";
        echo "${_dns}"; } >> /etc/dhcpcd.conf
        systemctl enable iwd.service
fi

# Configure other services
systemctl enable avahi-daemon.service
systemctl enable bluetooth.service
systemctl enable dhcpcd.service
systemctl enable docker.service
systemctl enable fstrim.timer
#systemctl enable intel-undervolt.service
systemctl enable rngd.service
#systemctl enable sshd.service






cp /usr/share/doc/avahi/ssh.service /etc/avahi/services
sed -i 's/hosts:.*/hosts: files mymachines myhostname mdns_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] dns/' /etc/nsswitch.conf

cp /tmp/chroot/sysfiles/bluetooth.conf /etc/bluetooth/main.conf
cp /tmp/chroot/sysfiles/intel-undervolt.conf /etc/
mkdir -p /etc/iwd && cp /tmp/chroot/sysfiles/iwd.conf /etc/iwd/main.conf
#cp /tmp/chroot/sysfiles/xorg.conf /etc/X11/xorg.conf.d/

#chmod u=rw,g=r,o=r /etc/bluetooth/main.conf /etc/intel-undervolt.conf \
#	/etc/iwd/main.conf /etc/X11/xorg.conf.d/xorg.conf

cp /etc/makepkg.conf /etc/makepkg.conf.backup
sed -i -r 's/^CFLAGS=".*"/CFLAGS="-march=native -O3 -pipe -fno-plt"/' /etc/makepkg.conf
sed -i -r 's/^CXXFLAGS=".*"/CXXFLAGS="-march=native -O3 -pipe -fno-plt"/' /etc/makepkg.conf
sed -i -r "s/^#MAKEFLAGS=\".*\"/MAKEFLAGS=\"-j$(nproc)\"/" /etc/makepkg.conf
sed -i -r 's/^COMPRESSGZ=\(.*\)/COMPRESSGZ=(pigz -c -f -n)/' /etc/makepkg.conf
sed -i -r 's/^COMPRESSBZ2=\(.*\)/COMPRESSBZ2=(pbzip2 -c -f)/' /etc/makepkg.conf
sed -i -r 's/^COMPRESSXZ=\(.*\)/COMPRESSXZ=(xz -c -z --threads=0 -)/' /etc/makepkg.conf
sed -i -r 's/^COMPRESSZST=\(.*\)/COMPRESSZST=(zstd -c -z -q --threads=0 -)/' /etc/makepkg.conf

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
sed -i -r 's/#Port 22/Port 1337/' /etc/ssh/sshd_config
sed -i -r '/#HostKey \/etc\/ssh\/ssh_host_ed25519_key/s/^#*//g' /etc/ssh/sshd_config
sed -i -r '/#PasswordAuthentication yes/s/^#*//g' /etc/ssh/sshd_config
sed -i -r '/#PermitEmptyPasswords no/s/^#*//g' /etc/ssh/sshd_config
echo -e "\nAllowUsers\t${_user}" >> /etc/ssh/sshd_config

cp /etc/sudoers /etc/sudoers.backup
{ echo "Defaults timestamp_timeout=10";
  echo "Defaults:%wheel targetpw";
  echo -e "%wheel\tALL=(ALL) ALL";
  echo "Cmnd_Alias CPUPWR = /usr/bin/cpupower";
  echo "Cmnd_Alias IGPUFREQ = /usr/bin/intel_gpu_frequency";
  echo "Cmnd_Alias IGPUTOP = /usr/bin/intel_gpu_top";
  echo "Cmnd_Alias IOTOP = /usr/bin/iotop";
  echo "Cmnd_Alias KBDR = /usr/bin/kbdrate";
  echo "Cmnd_Alias MNT = /usr/bin/mount";
  echo "Cmnd_Alias PS = /usr/bin/ps";
  echo "Cmnd_Alias UMNT = /usr/bin/umount";
  echo "root ALL=(ALL) ALL";
  echo "${_user} ALL=(ALL) NOPASSWD: CPUPWR,IGPUFREQ,IGPUTOP,IOTOP,KBDR,MNT,PS,UMNT"; } \
	> /etc/sudoers
chown -c root:root /etc/sudoers
chmod -c 0440 /etc/sudoers

sed -i -r 's/#SystemMaxUse=/SystemMaxUse=256M/' /etc/systemd/journald.conf
sed -i -r 's/#user_allow_other/user_allow_other/' /etc/fuse.conf
echo "vm.vfs_cache_pressure=90" >> /etc/sysctl.d/99-swappiness.conf

echo "/usr/bin/bash" >> /etc/shells
echo "/usr/bin/zsh" >> /etc/shells
chsh -s "/usr/bin/zsh"