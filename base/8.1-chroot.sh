echo "Creating user accounts"


useradd --create-home --groups users,wheel --shell "/usr/bin/zsh" "USER"
passwd --delete root
passwd --delete "USER"

chown "USER:USER" "/home/USER"

echo "Configuring user accounts"

chown "USER:USER" "/tmp/chroot/users/USER/bootstrap.sh"
su -s /bin/bash -c \
	"cd /tmp/chroot/ && . \"/tmp/chroot/users/USER/bootstrap.sh\" --host HOST --user USER" \
	--login USER

echo "Accounts passwords"
echo "Set root password!"
passwd root
echo "Set USER password!"
passwd "USER"
systemctl enable gdm.service

popd > /dev/null