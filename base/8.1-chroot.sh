
source ../hosts/vbox.vars

echo "Creating user accounts"


useradd --create-home --groups users,wheel --shell "/usr/bin/zsh" "[USER]"
passwd --delete root
passwd --delete "[USER]"

chown "[USER]:[USER]" "/home/[USER]"

printinfo "Configuring user accounts"

chown "[USER]:[USER]" "/tmp/chroot/users/[USER]/bootstrap.sh"
su -s /bin/bash -c \
	"cd /tmp/chroot/ && . \"/tmp/chroot/users/[USER]/bootstrap.sh\" --host [HOST] --user [USER]" \
	--login [USER]

printinfo "\n"
printinfo "+ ------------------ +"
printinfo "| Accounts passwords |"
printinfo "+ ------------------ +"
printwarn "Set root password!"
passwd root
printwarn "Set [USER] password!"
passwd "[USER]"

popd > /dev/null