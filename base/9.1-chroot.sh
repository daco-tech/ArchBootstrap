echo "Creating user accounts"
useradd --create-home --groups users,wheel --shell "/usr/bin/zsh" "USER"
passwd --delete root
passwd --delete "USER"

chown "USER:USER" "/home/USER"

echo "Accounts passwords"
echo "Set root password!"
passwd root
echo "Set USER password!"
passwd "USER"


popd > /dev/null