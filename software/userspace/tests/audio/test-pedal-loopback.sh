#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/config.sh"

SYSFS_ADC="/sys/bus/iio/devices/iio:device0"
SYSFS_DAC="/sys/bus/iio/devices/iio:device1"	# 50k

ADC_READ="$SYSFS_ADC/in_voltage0_raw"
DAC_WRITE="$SYSFS_DAC/out_resistance0_raw"

usage () {
	printf "\nUsage:\n"
	printf "  $0\n"
	printf "\n"
}

if [ $# -ne 0 ]
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

for i in `seq 0 256`
do
	echo $i > $DAC_WRITE
	printf "%d," $i
	sleep 0.01
	cat $ADC_READ
done

