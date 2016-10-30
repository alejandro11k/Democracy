#!/bin/bash

if [ $# -ne 2 ]
then
	echo "Please give GPIO start / number of GPIOs"
	exit
fi

GPIO_START=$1
GPIO_END=$((GPIO_START+$2-1))

gpio_sysfs="/sys/class/gpio"

# read GPIOs
for x in $(seq $GPIO_START $GPIO_END)
do
	if [ -d $gpio_sysfs/gpio$x ]
	then
		cat $gpio_sysfs/gpio$x/value
	fi
done

