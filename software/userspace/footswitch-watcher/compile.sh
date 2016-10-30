#!/bin/bash

CROSS_CC=arm-linux-gnueabihf-

${CROSS_CC}gcc -Wall -o footswitch-watcher footswitch-watcher.c

