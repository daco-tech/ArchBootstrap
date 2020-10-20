script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

pushd "$script_path" > /dev/null

source ../misc.sh
source ../hosts/vbox.vars

_hostname=""
_user=""
while [[ $# -gt 0 ]]
do
	case "$1" in
		-h|--host)
			_hostname="$2"
			shift
			shift
			;;
		-u|--user)
			_user="$2"
			shift
			shift
			;;
		*)
			echo "Unknown option: '$1'. Will be ignored."
			shift
			;;
	esac
done
[ -z "$_hostname" ] && echo "Missing mandatory '--host' option." && exit 1
[ -z "$_user" ] && echo "Missing mandatory '--user' option." && exit 1




{ echo "export HOST=\"${_hostname}\"";
  echo "export AUR=\"/media/vol1/aur\"";
  echo "export CODE=\"/media/vol1/code\"";
  echo "export JUNK=\"/media/vol1/junk\"";
  echo "export MOUNT=\"$HOME/mount\"";
  echo "export SYNC=\"/media/vol1/sync\"";
  echo "export WALLPAPERS=\"/media/vol1/sync/wallpapers\"";
  echo "export VOL1=\"/media/vol1\"";
  echo "export CONAN_USER_HOME=\"/media/vol1/.cache\"";
  echo "export NPM_CONFIG_CACHE=\"/media/vol1/.cache/npm\"";
  echo "export NVM_DIR=\"/media/vol1/.cache/nvm\"";
  echo "export XDG_CONFIG_HOME=\"$HOME/.config\"";
  echo "export XDG_DOWNLOAD_DIR=\"/media/vol1/junk\""; } > "$HOME/.env.sh"


. "$HOME/.env.sh"

echo "\n"
echo "+ ------------------- +"
echo "| Installing dotfiles |"
echo "+ ------------------- +"
. install-dotfiles.sh --host-dir ".." --fix-permissions

echo "\n"
echo "+ ------------------------ +"
echo "| Installing user software |"
echo "+ ------------------------ +"
sudo usermod -aG docker ${_user}
sudo mkdir -p /etc/docker
echo -e "{\n\t\"data-root\": \"/media/vol1/.cache/docker\"\n}" | sudo tee /etc/docker/daemon.json

sudo curl -L 'https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/JetBrainsMono.zip' -o JetBrainsMono.zip
unzip JetBrainsMono.zip -d "$HOME/.local/share/fonts/"
fc-cache --force

pip install --user wheel compiledb conan flashfocus grip pynvim pywal

cd "$NVM_DIR";
git clone https://github.com/nvm-sh/nvm.git .
git checkout "v0.35.3"
cd "$script_path"

. "$HOME/.bashrc"
source-nvm
nvm install --lts=erbium
nvm use default erbium

cd "$AUR"
_aur_packages=(brave-bin@master git-delta-bin@master robo3t-bin@master tty-clock@master
               polybar@master postman-bin@master rslsync@master nomachine@master visual-studio-code-bin@master
               spotify@master teams@master slack-desktop@master sublime-text-dev@master )
for pkg in ${_aur_packages[*]}
do
	_name=${pkg%%@*}
	_tag=${pkg##*@}

	git clone https://aur.archlinux.org/"$_name".git && cd "$_name"
	git checkout "$_tag"

	[ "$_name" = "spotify" ] && \
		curl -sS https://download.spotify.com/debian/pubkey.gpg | gpg --import -

	makepkg -sirc --noconfirm --needed

	cd ..
done

git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

cd "$script_path"

nvim +PlugInstall +qa

popd > /dev/null
