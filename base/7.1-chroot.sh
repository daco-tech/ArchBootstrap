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
