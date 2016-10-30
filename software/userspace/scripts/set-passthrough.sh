#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/config.sh"

init_passthrough_gpio () {
	#echo "Passthrough GPIO: $PASSTHROUGH_GPIO"
	# export GPIO
	"$GPIOLIB/gpio-export-range.sh" $PASSTHROUGH_GPIO 1 &> /dev/null
	# set as output
	"$GPIOLIB/gpio-set-dir-range.sh" $PASSTHROUGH_GPIO 1 out &> /dev/null
}

usage () {
	printf "\nUsage:\n"
	printf "  $0 <enable-passthrough>\n"
	printf "\n"
	printf "enable-passthrough:\n"
	printf " -1 -> Toggle passthrough state\n"
	printf "  0 -> Passthrough is disabled (audio is going in/out of Cirrus)\n"
	printf "  1 -> Passthrough is enabled (guitar in goes to amp out)\n"
}

if [ $# -ne 1 ]
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

if [ ! -f "/sys/class/gpio/gpio$PASSTHROUGH_GPIO/value" ]
then
	init_passthrough_gpio
fi

if [ $1 -eq 1 ]
then
	# Enable passthrough mode (GPIO = 0)
	"$GPIOLIB/gpio-set-value-range.sh" $PASSTHROUGH_GPIO 1 0
elif [ $1 -eq 0 ]
then
	# Disable passthrough mode (GPIO = 1)
	"$GPIOLIB/gpio-set-value-range.sh" $PASSTHROUGH_GPIO 1 1
elif [ $1 -eq -1 ]
then
	# Toggle
	STATE=$($GPIOLIB/gpio-get-value-range.sh $PASSTHROUGH_GPIO 1)
	STATE=$((STATE^1))
	"$GPIOLIB/gpio-set-value-range.sh" $PASSTHROUGH_GPIO 1 $STATE &> /dev/null
	if [ $STATE -eq 0 ]
	then
		echo "Bypass is ON"
	else
		echo "Bypass is OFF"
	fi
fi

