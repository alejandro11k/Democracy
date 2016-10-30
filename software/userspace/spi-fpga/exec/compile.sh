#!/bin/bash

CROSS_CC=arm-linux-gnueabihf-

${CROSS_CC}gcc -o spi-fpga spi-fpga.c

