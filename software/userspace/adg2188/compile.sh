#!/bin/bash

CROSS_CC=arm-linux-gnueabihf-

${CROSS_CC}gcc -o adg2188 adg2188.c main.c

