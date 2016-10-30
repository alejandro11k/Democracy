#!/bin/bash


#SF2_LOCATION=/home/pi/morpheus/instruments/Ovation2.SF2
#SF2_LOCATION=/home/pi/morpheus/instruments/Ovation2_bis.SF2
SF2_LOCATION=/home/pi/morpheus/instruments/JL_Ibanez_Guitar.sf2
#SF2_LOCATION=/home/pi/morpheus/instruments/ProTrax_Classical_Guitar.sf2
#SF2_LOCATION=/home/pi/morpheus/instruments/JL_Trumpet.sf2
#SF2_LOCATION=/home/pi/morpheus/instruments/piano_0.sf2
#SF2_LOCATION=/home/pi/morpheus/instruments/Guitar18Mando16_ejl.sf2

usage()
{
	echo ""
	echo ""
	echo "usage : ctrlsynth [option]" 
	echo "--start : starts : jackd , ttymidi and fluidsynth"
	echo "--stop  : stops : jackd , ttymidi and fluidsynth"
	echo ""
	echo ""		
	exit -1 
}

start_all()
{
	echo "-------Starting Jack, ttymidi and FluidSynth-------"
	mount -o remount,size=128M /dev/shm
	echo -n performance | tee /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor &>/dev/null
	export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/dbus/system_bus_socket
	jackd -P70 -p16 -t2000 -dalsa -p128 -r44100 -s & 
	sleep 2
    /home/pi/morpheus/tests/audio/ttymidi/ttymidi -s /dev/serial0 -b 38400 &>/dev/null &
	fluidsynth -i -s -j -a jack -m alsa_seq -r 44100 -c 2 -z 128 -g 1.3 -R 0 $SF2_LOCATION &>/dev/null &
    sleep 1
    aconnect 128:0 129:0
	/home/pi/morpheus/scripts/set-passthrough.sh 0
}

stop_all()
{
	echo "-------Stopping Jack, ttymidi and FluidSynth-------"
	pkill fluidsynth >&-  2>&- 
    pkill ttymidi &>/dev/null
	pkill jackd &>/dev/null 
}


if [ "$#" -ne 1 ]; then
	usage
fi

case $1 in

	--start)
		start_all
	;;
	--stop)
		stop_all
	;;
	*)
	usage 
	;;
esac




exit 0
