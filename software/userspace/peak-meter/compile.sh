#!/bin/bash

PATH_TOOLCHAIN=/tmp/
NAME_TOOLCHAIN=morpheus-toolchain.tar.gz
LINK_TOOLCHAIN=http://reds-data.heig-vd.ch/toolchains/${NAME_TOOLCHAIN}
CROSS_CC=${PATH_TOOLCHAIN}arm-morpheus-linux-gnueabihf/bin/arm-morpheus-linux-gnueabihf-


pushd ${PATH_TOOLCHAIN}
if [ ! -e ${NAME_TOOLCHAIN} ]; then
	wget ${LINK_TOOLCHAIN}
fi

tar -zxvf ${NAME_TOOLCHAIN}
popd

${CROSS_CC}gcc peak-meter.c -I./libjack -L./libjack -ljack -lpthread -lrt -Wl,-rpath=libjack/  -o peak-meter
