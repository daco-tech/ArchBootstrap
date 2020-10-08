export NNN_BMS="0://;1:$VOL1;c:$CODE;j:$JUNK;m:$MOUNT;s:$SYNC;u:$AUR"

config-hids () {
	setxkbmap -option
	setxkbmap -layout pt \
	          -option "lv3:ralt_switch" \
	          -option "eurosign:e" -option "eurosign:5" \
	          -option "caps:escape" \
	          -option "terminate:ctrl_alt_bksp"
	xset r rate 190 70
}
