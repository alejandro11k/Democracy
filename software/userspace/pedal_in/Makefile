

CC=gcc -O3
LIBPATH_TC=/home/alex/x-tools/arm-morpheus-linux-gnueabihf/arm-morpheus-linux-gnueabihf
CWD=$(shell pwd)


all: pedal_meter_raw

pedal_meter_raw:
	$(CC)  pedal_meter_raw.c  -lxml2 -Wl,-rpath=libiio/ -o pedal_meter_raw -liio 

clean:
	rm -f pedal_meter_raw


.PHONY:	pedal_meter_raw
