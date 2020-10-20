# vim:ft=sh

[ ! -d "~/.cache/wal" ] && wal --theme base16-chalk
xrdb -merge "~/.Xresources"
xrdb -merge "~/.cache/wal/colors.Xresources"
xsetroot -cursor_name left_ptr

/usr/bin/env /usr/bin/bash --login -c "config-hids"
exec bspwm -c "~/.config/bspwm/bspwmrc"
