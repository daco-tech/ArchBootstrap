# Prepare User Template /etc/skel
echo "Creating user directories and environment variables"



mkdir -p /mnt/etc/skel/.local/share/dunst/log/



cp -rf dotfiles/.config /mnt/etc/skel/.config


# Set Permissions 
chmod u=rwx "/mnt/etc/skel/.config/polybar/*.sh"