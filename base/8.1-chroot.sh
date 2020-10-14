printinfo "\n"
printinfo "Creating user accounts"
echo "/usr/bin/bash" >> /etc/shells
echo "/usr/bin/zsh" >> /etc/shells
chsh -s "/usr/bin/zsh"

useradd --create-home --groups users,wheel --shell "/usr/bin/zsh" "${_user}"
passwd --delete root
passwd --delete "${_user}"

chown "${_user}:${_user}" "/home/${_user}"

printinfo "Configuring user accounts"

chown "${_user}:${_user}" "/tmp/chroot/users/${_user}/bootstrap.sh"
su -s /bin/bash -c \
	"cd /tmp/chroot/ && . \"/tmp/chroot/users/${_user}/bootstrap.sh\" --host ${_host} --user ${_user}" \
	--login ${_user}

printinfo "\n"
printinfo "+ ------------------ +"
printinfo "| Accounts passwords |"
printinfo "+ ------------------ +"
printwarn "Set root password!"
passwd root
printwarn "Set ${_user} password!"
passwd "${_user}"

popd > /dev/null