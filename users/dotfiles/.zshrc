# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  #git
  git zsh-syntax-highlighting zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

. "$HOME/.env.sh"
. "$HOME/.bashrc.aux"

[ ! -v NVM_BIN ] && [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -r "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

set_vte_theme () {
	if [ "$TERM" = "linux" ]
	then
		[ -f "$HOME/.cache/wal/colors-tty.sh" ] && \
			. "$HOME/.cache/wal/colors-tty.sh"
		[ -n "$VTFONT" ] && setfont "$VTFONT"
	fi
}
set_vte_theme

export CLICOLOR=1
export EDITOR="nvim"
export HISTSIZE=32768
export HISTFILESIZE=32768
export HISTCONTROL=ignoreboth:ereasedups
export HISTIGNORE="?:??:???:????:?????"
export HISTTIMEFORMAT="%F %T "
export LESSCHARSET=UTF-8
export PATH="$PATH:$HOME/.local/bin"

alias aria2c="aria2c --async-dns=false"
alias beep="tput bel"
alias less="bat"
alias l="exa -1"
alias la="exa -1a"
alias lar="exa -1aR"
alias lh="exa -1ad .??*"
alias ll="exa -lh"
alias lla="exa -ahl"
alias llar="exa -ahlR"
alias llh="exa -adhl .??*"
alias llr="exa -lhR"
alias lr="exa -1R"
alias ls="exa"
alias lsa="exa -ah"
alias n="nvim"
alias q="exit"

clearcache () {
	sync && echo 1 | sudo tee /proc/sys/vm/drop_caches
}

energypolicy () {
	if [ "$1" = "default" ]; then
		bash "$XDG_CONFIG_HOME/.energypolicy.sh" default
	elif [ "$1" = "performance" ]; then
		bash "$XDG_CONFIG_HOME/.energypolicy.sh" performance
	elif [ "$1" = "balanced" ]; then
		bash "$XDG_CONFIG_HOME/.energypolicy.sh" balanced
	elif [ "$1" = "powersave" ]; then
		bash "$XDG_CONFIG_HOME/.energypolicy.sh" powersave
	elif [ -n "$1" ]; then
			echo "Invalid profile $1. Usage: energypolicy [default|performance|balanced|powersave]."
			return
	else
		[ -f "$XDG_CONFIG_HOME/.energypolicy" ] && \
			echo "Current profile is" $(tail -n 1 "$XDG_CONFIG_HOME/.energypolicy") || \
			echo "No profile is currently set. Usage: energypolicy [default|performance|balanced|powersave]"
		return
	fi
}

mkcd () {
	mkdir -p "$1"
	cd "$1"
}

mnt () {
	# 1. List all partitons
	# 2. Grep the ones that aren't mounted
	# 3. Send them to `fzf'
	# 4. Grab de selectd partition
	local part=$(lsblk --list --output NAME,SIZE,FSTYPE,TYPE,MOUNTPOINT | \
		grep 'part[[:space:]]*$' | \
		awk '{printf "/dev/%s %s %s\n",$1,$2,$3}' | \
		fzf | awk '{print $1}')
	[ -z $part ] && return

	# Find the directories at $MOUNT that aren't already used as a mount point.
	# Taken from: https://catonmat.net/set-operations-in-unix-shell
	# local mountpoint=$(comm -23 <(/bin/ls -1Ld $MOUNT/* | sort) \
	# 	<(mount | awk '{print $3}' | sort) | fzf)
	# [ -z $mountpoint ] && return

	local mountpoint="${MOUNT}/mnt$(($(/usr/bin/ls -1 $MOUNT/mnt 2> /dev/null | wc -l) + 1))"
	mkdir -p "$mountpoint"
	sudo mount -o gid=users,fmask=113,dmask=002,flush "$part" "$mountpoint" 2> /dev/null || \
	sudo mount -o flush "$part" "$mountpoint"
	echo "Disk mounted at $mountpoint"
}

mnt-gocrypt () {
	if [ $# -gt 0 ]; then
		[ ! -d "$1"	] && echo "The argument must be a directory." && exit 1
		local mountpoint="${MOUNT}/gocrypt$(($(/usr/bin/ls -1 $MOUNT/gocrypt* 2> /dev/null | wc -l) + 1))"
		mkdir -p "$mountpoint" && \
		gocryptfs -allow_other "$1" "$mountpoint" && \
		echo "Disk mounted at $mountpoint"
	else
		echo "Usage: mnt-gocrypt <cypherdir>"
	fi
}

mnt-vcrypt () {
	if [ -f "$1" ]; then
		local mountpoint="${MOUNT}/vcrypt$(($(/usr/bin/ls -1 $MOUNT/vcrypt* 2> /dev/null | wc -l) + 1))"
		mkdir -p "$mountpoint" && \
		veracrypt --text --keyfiles="" --pim=0 --protect-hidden=no "$1" "$mountpoint" && \
		echo "Disk mounted at $mountpoint"
	else
		echo "Usage: mnt-vcrypt <veracrypt-file>"
	fi
}

random-wallpaper () {
	if [ -n "$DISPLAY" ]; then
		local hour=$(date '+%H')
		local tod=""

		if [ $hour -ge 6 ] && [ $hour -lt 14 ]; then
			tod="06"
		elif [ $hour -ge 14 ] && [ $hour -lt 20 ]; then
			tod="14"
		else
			tod="20"
		fi

		local img=$(ls "$WALLPAPERS/$tod" | shuf -n 1)
		feh --bg-fill "$WALLPAPERS/$tod/$img"
	else
		echo "You're not running a graphical session."
	fi
}

screenshot () {
	if [ -n "$DISPLAY" ]; then
		local filename=$(echo screenshot-$(date '+%Y.%m.%d-%H.%M.%S'))
		maim --hidecursor --nokeyboard --quality 10 --select "$JUNK/$filename".png
		[ -f "$JUNK/$filename".png ] && \
			echo Image written to "$JUNK/$filename".png && \
			notify-send 'Screenshot' "File available at $JUNK/$filename.png"
	fi
}

secrm () {
	if [ $# -gt 0 ]; then
		shred --iterations=1 --random-source=/dev/urandom -u --zero $*
	else
		echo "Usage: secrm <files...>"
	fi
}

select-wallpaper () {
	if [ -n "$DISPLAY" ]; then
		[ -f "$1" ] && feh --bg-fill "$1" && return

		local wallpaper=""
		local hour=$(date '+%H')

		if [ $hour -ge 6 ] && [ $hour -lt 14 ]; then
			wallpaper=$(sxiv -o "$WALLPAPERS/06")
			[ -n "$wallpaper" ] && feh --bg-fill "$wallpaper"
		elif [ $hour -ge 14 ] && [ $hour -lt 20 ]; then
			wallpaper=$(sxiv -o "$WALLPAPERS/14")
			[ -n "$wallpaper" ] && feh --bg-fill "$wallpaper"
		else
			wallpaper=$(sxiv -o "$WALLPAPERS/20")
			[ -n "$wallpaper" ] && feh --bg-fill "$wallpaper"
		fi
	else
		echo "You're not running a graphical session."
	fi
}

shup () {
	[ ! -f "$1" ] && echo "Usage: shup <cmdfile>" && exit 0

	local profile="$1"
	local cmd=""

	while read -r line; do
		line="${line##*( )}"
		[ -n "$line" ] && [ ${line:0:1} != "#" ] && cmd="${cmd} ${line}"
	done < "$profile"

	eval $cmd
}

source-nvm () {
	[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
}

theme () {
	local light_themes_location="$HOME/.local/lib/python3.8/site-packages/pywal/colorschemes/light"
	local dark_themes_location="$HOME/.local/lib/python3.8/site-packages/pywal/colorschemes/dark"
	local light_themes dark_themes
	light_themes="$(ls -1 $light_themes_location | sed "s/.json//" | awk '{print "light - " $0}')"
	dark_themes="$(ls -1 $dark_themes_location | sed "s/.json//" | awk '{print "dark - " $0}')"

	local selection category name
	selection="$(echo -e  "$dark_themes" "\n$light_themes" | fzf)"
	if [ -n "$selection" ]; then
		category="$(echo "$selection" | grep -o '^\S*')"
		name="$(echo "$selection" | grep -o '\S*$')"
		[ "$category" == "dark" ] && wal --theme "$name"
		[ "$category" == "light" ] && wal --theme "$name" -l
		xrdb -merge "$HOME/.Xresources"
		xrdb -merge "$HOME/.cache/wal/colors.Xresources"
		. "$HOME/.local/bin/set-alacritty-colorscheme.sh" &> /dev/null
	fi
}

umnt () {
	# Find the directories at $MOUNT that are already used as a mount point.
	# Taken from: https://catonmat.net/set-operations-in-unix-shell
	# local mountpoint=$(comm -12 <(/bin/ls -1Ld $MOUNT/* | sort) \
	# 	<(mount | awk '{print $3}' | sort) | fzf)
	# [ -z $mountpoint ] && return

  for dir in $(/bin/ls -1Ld $MOUNT/* 2> /dev/null); do
		local mounts="${mounts}\n$(df -h "$dir" | tail -1 | awk -v dir="$dir" '{print dir " -> " $1}')"
	done

	[ -n "$mounts" ] && \
	local mountpoint=$(printf "$mounts" | tail -n +2 | fzf | awk '{print $1}') ||
	echo "No mounted volumes at $MOUNT/"

	if [[ "$mountpoint" =~ vcrypt ]]; then
		veracrypt --text --dismount "$mountpoint"
		rmdir "$mountpoint"
		echo "Unmounted $mountpoint"
	elif [ -n "$mountpoint" ]; then
		sudo umount "$mountpoint"
		rmdir "$mountpoint"
		echo "Unmounted $mountpoint"
	fi
}

vcrypt-create () {
	[ -z "S1" ] || [ -z "$2" ] && \
		echo "Usage: vcrypt-create <path-to-encrypted-file> <size><K|M|G>" && \
		exit 1;

	veracrypt --text --create "$1" --volume-type="normal" --size="$2" --filesystem="exFAT" \
		--encryption="AES" --hash="SHA-512" --pim=0 --keyfiles="" --random-source="/dev/random"
}

export FZF_DEFAULT_COMMAND="fd --exclude '.git/' --hidden --type f"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --exclude '.git/' --hidden --type d"
[[ $- == *i* ]] && . "/usr/share/fzf/completion.zsh" 2> /dev/null
[ -f "/usr/share/fzf/key-bindings.zsh" ] && . "/usr/share/fzf/key-bindings.zsh"

# encgpg: Encrypt stdin with password into a given file
# decgpg: Decrypt given file into a nvim buffer
export GPG_TTY=$(tty)
function encgpg { gpg -c -o "$1"; }
function decgpg { gpg -d "$1" | nvim -i NONE -n -; }

# (needs: pacman -S nnn)
export NNN_PLUG='a:archive;d:fzcd;e:_nvim $nnn*;f:-fzopen;k:-pskill'
e () {
	nnn "$@"
	export NNN_TMPFILE="$XDG_CONFIG_HOME/nnn/.lastd"

	if [ -f "$NNN_TMPFILE" ]; then
		. "$NNN_TMPFILE"
		rm -f "$NNN_TMPFILE" &> /dev/null
	fi

	[ "$TERM" = "linux" ] && set_vte_theme && clear
}
