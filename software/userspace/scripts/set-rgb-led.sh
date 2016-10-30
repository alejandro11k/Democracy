#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/config.sh"

SYSFS_LED="/sys/class/leds"

usage () {
	printf "\nUsage:\n"
	printf "  $0 <led> <R> <G> <B>\n"
	printf "\n"
	printf "led:\n"
	printf "  level\n"
	printf "  power\n"
}

led_set_brightness () {
	max_bright=$(cat "$SYSFS_LED/$1/max_brightness")
	echo $(($2*max_bright/255)) > "$SYSFS_LED/$1/brightness"
}

if [ $# -ne 4 ]
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

led_set_brightness "morpheus:$1:red" $2
led_set_brightness "morpheus:$1:green" $3
led_set_brightness "morpheus:$1:blue" $4

