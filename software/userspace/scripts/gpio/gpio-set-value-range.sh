#!/bin/bash

if [ $# -ne 3 ]
then
	echo "Please give GPIO start / number of GPIOs and [0/1]"
	exit
fi

GPIO_START=$1
GPIO_END=$((GPIO_START+$2-1))

echo "Seting GPIO $GPIO_START to $GPIO_END as $3"

gpio_sysfs="/sys/class/gpio"

# export GPIOs
for x in $(seq $GPIO_START $GPIO_END)
do
	if [ -d $gpio_sysfs/gpio$x ]
	then
		echo $3 > $gpio_sysfs/gpio$x/value
	fi
done

