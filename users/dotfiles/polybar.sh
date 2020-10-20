#!/usr/bin/env bash

killall -q polybar
killall -q cbatticon

# Wait until the process has been terminated
while pgrep -u $UID -x polybar > /dev/null; do sleep 1; done

export HGL_ICON="$(echo -e "\uf252 ")"
export CPU_ICON="$(echo -e "\uf5dc ")"
export CPU_ICON="$(echo -e "\uf5dc ")"
export MEM_ICON="$(echo -e "\uf538 ")"
export KBD_ICON="$(echo -e "\uf11c ")"
export WIF_ICON="$(echo -e "\uf1eb")"
export TMP_ICON="$(echo -e "\uf2c8 ")"
export ETH_ICON="$(echo -e "\uf796 ")"
export EXG_ICON="$(echo -e "\uf362 ")"
export HDD_ICON="$(echo -e "\uf0a0 ")"
export CAL_ICON="$(echo -e "\uf073")"
export MUT_ICON="$(echo -e "\uf6a9")"
export BOL_ICON="$(echo -e "\uf0e7 ")"
export PWR_ICON="$(echo -e "\uf011")"
export LCD_ICON="$(echo -e "\uf185")"
export VOL_L_ICON="$(echo -e "\uf026")"
export VOL_M_ICON="$(echo -e "\uf027")"
export VOL_H_ICON="$(echo -e "\uf028")"

[ ! -p "$HOME/.local/share/polybar/polytimer-fifo" ] &&
	mkfifo "$HOME/.local/share/polybar/polytimer-fifo"

polybar main &> "$HOME/.local/share/polybar/main.log" &
cbatticon &
