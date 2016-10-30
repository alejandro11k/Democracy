#!/bin/bash

if [ $# -ne 2 ]
then
	echo "Please give GPIO start / number of GPIOs"
	exit
fi

GPIO_START=$1
GPIO_END=$((GPIO_START+$2-1))

echo "Exporting GPIO $GPIO_START to $GPIO_END"

gpio_sysfs="/sys/class/gpio"

# export GPIOs
for x in $(seq $GPIO_START $GPIO_END)
do
	if [ ! -d $gpio_sysfs/gpio$x ]
	then
		echo $x > $gpio_sysfs/export
	fi
done

