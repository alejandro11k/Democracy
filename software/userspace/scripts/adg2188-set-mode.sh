#!/bin/bash

# --- Matrix connections for the 4 modes ---
#
# Passive TRS (Tip expression)
# ============================
# (In R)  X0-Y0 (+5V)
# (In T)  X1-Y1 (ADC)
# (Out R) X4-Y4 (10k A) or Y6 (50k A)
# (Out T) X5-Y5 (10k W) or Y7 (50k W)
#
# Passive TRS (Ring expression)
# ============================
# (In R)  X0-Y1 (ADC)
# (In T)  X1-Y0 (+5V)
# (Out R) X4-Y5 (10k W) or Y7 (50k W)
# (Out T) X5-Y4 (10k A) or Y6 (50k A)
#
# Passive TS
# ==========
# (In T)  X1-Y0 (+5V)
# (In T)  X1-Y1 (ADC)
# (Out T) X5-Y5 (10k W) or Y7 (50k W)
#
# Active
# ======
# (In T)  X1-Y1 (ADC)
# (Out T) X5-Y5 (10k W) or Y7 (50k W)
# (+5V)   X6-Y4 (10k A) or Y6 (50k A)

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/config.sh"

init_reset_gpio () {
	# export GPIO
	"$GPIOLIB/gpio-export-range.sh" $ADG2188_RESET_GPIO 1 &> /dev/null
	# set as output
	"$GPIOLIB/gpio-set-dir-range.sh" $ADG2188_RESET_GPIO 1 out &> /dev/null
}

reset_chip () {
	# toggle reset
	"$GPIOLIB/gpio-set-value-range.sh" $ADG2188_RESET_GPIO 1 0 &> /dev/null
	sleep 0.01
	"$GPIOLIB/gpio-set-value-range.sh" $ADG2188_RESET_GPIO 1 1 &> /dev/null
}

set_passive_trs_tip_10k () {
	echo "Setting mode: Passive TRS (tip expression) 10K"
	# close selected switches
	$ADG2188_DRIVER 0 0 1
	$ADG2188_DRIVER 1 1 1
	$ADG2188_DRIVER 4 4 1
	$ADG2188_DRIVER 5 5 1
}

set_passive_trs_tip_50k () {
	echo "Setting mode: Passive TRS (tip expression) 50K"
	# close selected switches
	$ADG2188_DRIVER 0 0 1
	$ADG2188_DRIVER 1 1 1
	$ADG2188_DRIVER 4 6 1
	$ADG2188_DRIVER 5 7 1
}

set_passive_trs_ring_10k () {
	echo "Setting mode: Passive TRS (ring expression) 10K"
	$ADG2188_DRIVER 0 1 1
	$ADG2188_DRIVER 1 0 1
	$ADG2188_DRIVER 4 5 1
	$ADG2188_DRIVER 5 4 1
}

set_passive_trs_ring_50k () {
	echo "Setting mode: Passive TRS (ring expression) 50K"
	$ADG2188_DRIVER 0 1 1
	$ADG2188_DRIVER 1 0 1
	$ADG2188_DRIVER 4 7 1
	$ADG2188_DRIVER 5 6 1
}

set_passive_ts_10k () {
	echo "Setting mode: Passive TS 10K"
	$ADG2188_DRIVER 1 0 1
	$ADG2188_DRIVER 1 1 1
	$ADG2188_DRIVER 5 5 1
}

set_passive_ts_50k () {
	echo "Setting mode: Passive TS 50K"
	$ADG2188_DRIVER 1 0 1
	$ADG2188_DRIVER 1 1 1
	$ADG2188_DRIVER 5 7 1
}

set_active_10k () {
	echo "Setting mode: Active 10K"
	$ADG2188_DRIVER 1 1 1
	$ADG2188_DRIVER 5 5 1
	$ADG2188_DRIVER 6 4 1
}

set_active_50k () {
	echo "Setting mode: Active 50K"
	$ADG2188_DRIVER 1 1 1
	$ADG2188_DRIVER 5 7 1
	$ADG2188_DRIVER 6 6 1
}

usage () {
	printf "\nUsage:\n"
	printf "  $0 <mode> <digipot>\n"
	printf "\n"
	printf "mode:\n"
	printf "  1 -> Passive TRS (tip expression)\n"
	printf "  2 -> Passive TRS (ring expression)\n"
	printf "  3 -> Passive TS\n"
	printf "  4 -> Active\n\n"
	printf "digipot:\n"
	printf " 10 -> Use the 10k potentiometer\n"
	printf " 50 -> Use the 50k potentiometer\n"
}

if [ $# -ne 2 ]
then
	printf "Wrong number of arguments!\n"
	usage $0
	exit 1
fi

if [ $1 == "-h" ]
then
	usage $0
	exit 0
fi

if [[ $1 -lt 1 || $1 -gt 4 ]]
then
	printf "Unkown mode %d\n" $1
	usage $0
	exit 2
fi

init_reset_gpio
reset_chip

if [ $2 -eq 10 ]
then
	case $1 in
		1) set_passive_trs_tip_10k ;;
		2) set_passive_trs_ring_10k ;;
		3) set_passive_ts_10k ;;
		4) set_active_10k ;;
	esac
elif [ $2 -eq 50 ]
then
	case $1 in
		1) set_passive_trs_tip_50k ;;
		2) set_passive_trs_ring_50k ;;
		3) set_passive_ts_50k ;;
		4) set_active_50k ;;
	esac
else
	printf "Digipot must be either 10 or 50\n"
	usage $0
	exit 3
fi
