#!/bin/bash

#Morpheus package installation main Path
MORPHEUS_PATH=/home/pi/morpheus
BIN_PATH=/usr/bin
PATH_FILE_CHECK=$MORPHEUS_PATH/.installation_not_done
#Install needed packages


function red_light_error {
	echo 0 > /sys/class/leds/morpheus\:level\:blue/brightness
	echo 31 > /sys/class/leds/morpheus\:level\:red/brightness
	exit -1
}

function aptittude_install {
	echo 0 > /sys/class/leds/morpheus\:level\:blue/brightness
	sleep 0.5
	echo 31 > /sys/class/leds/morpheus\:level\:blue/brightness
	${BIN_PATH}/apt-get update
	if [ $? -ne 0 ]; then 
		red_light_error
	fi

	echo 31 > /sys/class/leds/morpheus\:level\:blue/brightness
	sleep 0.5
	echo 31 > /sys/class/leds/morpheus\:level\:blue/brightness
	${BIN_PATH}/apt-get -y install jackd2
	if [ $? -ne 0 ]; then 
		red_light_error
	fi

	echo 0 > /sys/class/leds/morpheus\:level\:blue/brightness
	sleep 0.5
	echo 31 > /sys/class/leds/morpheus\:level\:blue/brightness
	${BIN_PATH}/apt-get -y install libjack-jackd2-dev
	if [ $? -ne 0 ]; then 
		red_light_error
	fi


	echo 0 > /sys/class/leds/morpheus\:level\:blue/brightness
	sleep 0.5
	echo 31 > /sys/class/leds/morpheus\:level\:blue/brightness
	${BIN_PATH}/apt-get --no-install-recommends install libfluidsynth1=1.1.6-3
	${BIN_PATH}/apt-get --no-install-recommends install fluidsynth=1.1.6-3
	if [ $? -ne 0 ]; then 
		red_light_error
	fi


	echo 0 > /sys/class/leds/morpheus\:level\:blue/brightness
	sleep 0.5
	echo 31 > /sys/class/leds/morpheus\:level\:blue/brightness
	${BIN_PATH}/apt-get -y install a2jmidid
	if [ $? -ne 0 ]; then 
		red_light_error
	fi


	echo 0 > /sys/class/leds/morpheus\:level\:blue/brightness
	sleep 0.5
	echo 31 > /sys/class/leds/morpheus\:level\:blue/brightness
	${BIN_PATH}/apt-get -y install libxml2
	if [ $? -ne 0 ]; then 
		red_light_error
	fi

}


function finished {
	i=0
	while [ $i -lt 2 ];
	do
		echo 31 > /sys/class/leds/morpheus\:level\:blue/brightness
		sleep 1
		echo 0 > /sys/class/leds/morpheus\:level\:blue/brightness
		echo 31 > /sys/class/leds/morpheus\:level\:green/brightness
		sleep 1
		echo 0 > /sys/class/leds/morpheus\:level\:green/brightness
		echo 31 > /sys/class/leds/morpheus\:level\:red/brightness
		sleep 1
		echo 0 > /sys/class/leds/morpheus\:level\:red/brightness

		i=$[$i+1]
	done
}


function install_deb_files {
	if [ -e $MORPHEUS_PATH ]; then
		${BIN_PATH}/gdebi  --option=APT::Get::force-yes=1,APT::Get::Assume-Yes=1 -n  ${MORPHEUS_PATH}/pdextended/pdextended-0.43.3.deb

		if [ $? -ne 0 ]; then
			red_light_error
		fi
	fi
}

function copy_executable_to_bin {
	/bin/cp ${MORPHEUS_PATH}/scripts/instrument_selector ${BIN_PATH}
	if [ $? -ne 0 ]; then 
		red_light_error
	fi
	
}


function check_internet_connectivity {
	if ping -q -c 1 -W 1 8.8.8.8 >/dev/null; then
		echo "IPv4 is up"
	else
		if [ $? -ne 0 ]; then
			 red_light_error
		fi
	fi
}


function write_to_check_file {
	if [ ! -e ${PATH_FILE_CHECK} ]; then
		echo  0 > /sys/class/leds/morpheus\:level\:blue/brightness
		echo  0 > /sys/class/leds/morpheus\:level\:green/brightness
		echo  0 > /sys/class/leds/morpheus\:level\:red/brightness

		exit 0
	fi
}

function setup_services {
	/bin/systemctl enable cirrus_lineout.service
	/bin/systemctl enable cirrus_linein.service
	/bin/systemctl enable jackd.service
	/bin/systemctl enable led_mgr.service 
	/bin/systemctl enable peak_meter.service 
}


function delete_installers {
	/bin/rm -r ${MORPHEUS_PATH}/pdextended
	/bin/rm -r ${MORPHEUS_PATH}/scripts/instrument_selector
	/bin/rm -r ${MORPHEUS_PATH}/first_boot/
	/bin/rm -r ${PATH_FILE_CHECK}
}


function exit_clean {

	echo  0 > /sys/class/leds/morpheus\:level\:blue/brightness
	echo  0 > /sys/class/leds/morpheus\:level\:green/brightness
	echo 31 > /sys/class/leds/morpheus\:level\:red/brightness
	exit -1
}

echo  0 > /sys/class/leds/morpheus\:level\:red/brightness
echo  0 > /sys/class/leds/morpheus\:level\:green/brightness
echo  31 > /sys/class/leds/morpheus\:level\:blue/brightness

trap exit_clean SIGHUP SIGINT SIGTERM SIGILL SIGKILL

write_to_check_file
check_internet_connectivity
aptittude_install
install_deb_files
copy_executable_to_bin
setup_services
finished
delete_installers
exit  0
