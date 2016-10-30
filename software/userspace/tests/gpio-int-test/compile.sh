#!/bin/bash

CROSS_CC=arm-linux-gnueabihf-

${CROSS_CC}gcc -Wall -o gpio-int-test gpio-int-test.c

