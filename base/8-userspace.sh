printinfo "Users Setup and Personalization"

# Prepare User Template /etc/skel
echo "Creating user directories and environment variables"
mkdir "/mnt/etc/skel/.ssh"
mkdir -p "/mnt/etc/skel/.config/fontconfig"
mkdir -p "/mnt/etc/skel/.local/share/xorg"
mkdir -p "/mnt/etc/skel/.local/share/fonts"
mkdir -p "/mnt/etc/skel/mount"

mkdir -p \
	"/mnt/etc/skel/.local/bin" \
	"/mnt/etc/skel/.local/share/dunst" \
	"/mnt/etc/skel/.local/share/polybar" \
	"/mnt/etc/skel/.local/share/picom" \
	"/mnt/etc/skel/.gnupg/" \
	"/mnt/etc/skel/.config/alacritty" \
	"/mnt/etc/skel/.config/bspwm" \
	"/mnt/etc/skel/.config/ctags" \
	"/mnt/etc/skel/.config/dunst" \
	"/mnt/etc/skel/.config/fontconfig" \
	"/mnt/etc/skel/.config/git" \
	"/mnt/etc/skel/.config/gtk-3.0" \
	"/mnt/etc/skel/.config/nnn/plugins" \
	"/mnt/etc/skel/.config/nvim/nerdtree_plugin" \
	"/mnt/etc/skel/.config/polybar" \
	"/mnt/etc/skel/.config/pulse" \
	"/mnt/etc/skel/.config/rslsync" \
	"/mnt/etc/skel/.config/sxhkd"

touch "/mnt/etc/skel/.hushlogin"

# Copy DotFiles

cp users/dotfiles/.bashrc "/mnt/etc/skel/"
cp users/dotfiles/.bash_login "/mnt/etc/skel/"
cp users/dotfiles/.zshrc "/mnt/etc/skel/"
cp users/dotfiles/.zlogin "/mnt/etc/skel/"
cp users/dotfiles/.tmux.conf "/mnt/etc/skel/"
cp users/dotfiles/.xinitrc "/mnt/etc/skel/"
cp users/dotfiles/gpg.conf "/mnt/etc/skel/.gnupg/"
cp users/dotfiles/set-alacritty-colorscheme.sh "/mnt/etc/skel/.local/bin/"
cp users/dotfiles/ssh.conf "/mnt/etc/skel/.ssh/config"
cp users/dotfiles/.ctags "/mnt/etc/skel/.config/ctags/default.ctags"
cp users/dotfiles/bspwmrc "/mnt/etc/skel/.config/bspwm/"
chmod u=rwx "/mnt/etc/skel/.config/bspwm/bspwmrc"
cp users/dotfiles/coc-settings.json "/mnt/etc/skel/.config/nvim/"
cp users/dotfiles/fonts.conf "/mnt/etc/skel/.config/fontconfig/"
cp users/dotfiles/git.conf "/mnt/etc/skel/.config/git/config"
cp users/dotfiles/gtk3.ini "/mnt/etc/skel/.config/gtk-3.0/settings.ini"
cp users/dotfiles/init.vim "/mnt/etc/skel/.config/nvim/"
cp users/dotfiles/mimeapps.list "/mnt/etc/skel/.config/"
cp users/dotfiles/openInNewTab.vim "/mnt/etc/skel/.config/nvim/nerdtree_plugin"
cp users/dotfiles/picom.conf "/mnt/etc/skel/.config/"
cp users/dotfiles/polybar.sh "/mnt/etc/skel/.config/polybar/start.sh"
chmod u=rwx "/mnt/etc/skel/.config/polybar/start.sh"
cp users/dotfiles/redshift.conf "/mnt/etc/skel/.config/"
cp users/dotfiles/sxhkdrc "/mnt/etc/skel/.config/sxhkd/"
cp users/dotfiles/terminate-session.sh "/mnt/etc/skel/.config/polybar/"
cp "users/dotfiles/.bashrc" "/mnt/etc/skel/.bashrc.aux"
cp "users/dotfiles/.pam_environment" "/mnt/etc/skel/"
cp "users/dotfiles/.Xresources" "/mnt/etc/skel/"
cp "users/dotfiles/.energypolicy.sh" "/mnt/etc/skel/.config/"
cp "users/dotfiles/alacritty.yml" "/mnt/etc/skel/.config/alacritty/"
cp "users/dotfiles/brave-flags.conf" "/mnt/etc/skel/.config/"
cp "users/dotfiles/dunstrc" "/mnt/etc/skel/.config/dunst/"
cp "users/dotfiles/polybar.conf" "/mnt/etc/skel/.config/polybar/config"

# Copy plugins

cp users/plugins/nnn/* "/mnt/etc/skel/.config/nnn/plugins/"
chmod u+x "/mnt/etc/skel/.config/nnn/plugins/"
cp users/plugins/polybar/fsusage.sh "/mnt/etc/skel/.local/bin/polybar-fsusage.sh"
cp users/plugins/polybar/iotop.sh "/mnt/etc/skel/.local/bin/polybar-iotop.sh"
cp users/plugins/polybar/mem.sh "/mnt/etc/skel/.local/bin/polybar-mem.sh"
cp users/plugins/polybar/mic.sh "/mnt/etc/skel/.local/bin/polybar-mic.sh"
cp users/plugins/polybar/thermal.sh "/mnt/etc/skel/.local/bin/polybar-thermal.sh"
gcc users/plugins/polybar/polytimer.c -Wall -Wextra -O3 -march=native -o "/mnt/etc/skel/.local/bin/polytimer"
cp users/plugins/tmux/gitstat.sh "/mnt/etc/skel/.local/bin/tmux-gitstat.sh"
chmod u+x "/mnt/etc/skel/.local/bin/tmux-gitstat.sh"
