#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/config.sh"

init_footswitch_gpio () {
	# export GPIO
	"$GPIOLIB/gpio-export-range.sh" $FOOTSWITCH1_GPIO 1 &> /dev/null
	"$GPIOLIB/gpio-export-range.sh" $FOOTSWITCH2_GPIO 1 &> /dev/null
	"$GPIOLIB/gpio-export-range.sh" $FOOTSWITCH3_GPIO 1 &> /dev/null
	"$GPIOLIB/gpio-export-range.sh" $FOOTSWITCH4_GPIO 1 &> /dev/null
	# set as input
	"$GPIOLIB/gpio-set-dir-range.sh" $FOOTSWITCH1_GPIO 1 in &> /dev/null
	"$GPIOLIB/gpio-set-dir-range.sh" $FOOTSWITCH2_GPIO 1 in &> /dev/null
	"$GPIOLIB/gpio-set-dir-range.sh" $FOOTSWITCH3_GPIO 1 in &> /dev/null
	"$GPIOLIB/gpio-set-dir-range.sh" $FOOTSWITCH4_GPIO 1 in &> /dev/null
}

usage () {
	printf "\nUsage:\n"
	printf "  $0 [footswitch]\n\n"
	printf "  footswitch: Footswitch's number (1-4) to read. If not given, read all of them."
}

if [ $# -gt 1 ]
then
	printf "Wrong number of arguments!\n"
	usage $0
	exit 1
fi

if [[ $1 == "-h" ]]
then
	usage $0
	exit 0
fi

init_footswitch_gpio

if [[ $# -eq 0 ]]
then
	# Read all
	echo "Footswitch 1"
	"$GPIOLIB/gpio-get-value-range.sh" $FOOTSWITCH1_GPIO 1
	echo "Footswitch 2"
	"$GPIOLIB/gpio-get-value-range.sh" $FOOTSWITCH2_GPIO 1
	echo "Footswitch 3"
	"$GPIOLIB/gpio-get-value-range.sh" $FOOTSWITCH3_GPIO 1
	echo "Footswitch 4"
	"$GPIOLIB/gpio-get-value-range.sh" $FOOTSWITCH4_GPIO 1
	exit 0
fi

case $1 in
	1) "$GPIOLIB/gpio-get-value-range.sh" $FOOTSWITCH1_GPIO 1 ;;
	2) "$GPIOLIB/gpio-get-value-range.sh" $FOOTSWITCH2_GPIO 1 ;;
	3) "$GPIOLIB/gpio-get-value-range.sh" $FOOTSWITCH3_GPIO 1 ;;
	4) "$GPIOLIB/gpio-get-value-range.sh" $FOOTSWITCH4_GPIO 1 ;;
esac

