#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SD_CARD_BIN="$DIR/sd-card"
SD_CARD_BOOT_BIN="$SD_CARD_BIN/boot"
SD_CARD_ROOTFS_BIN="$SD_CARD_BIN/rootfs"

KERNEL_DIR="$DIR/linux-kernel"
KERNEL_ZIMAGE="$KERNEL_DIR/arch/arm/boot/zImage"
KERNEL_DT_DIR="$KERNEL_DIR/arch/arm/boot/dts"
KERNEL_DTB="$KERNEL_DT_DIR/bcm2710-rpi-3-b.dtb"
KERNEL_DTBO_CIRRUS="$KERNEL_DT_DIR/overlays/rpi-cirrus-wm5102.dtbo"
KERNEL_DTBO_MORPHEUS="$KERNEL_DT_DIR/overlays/rpi-morpheus.dtbo"

USERSPACE_EXEC="$DIR/userspace"
USERSPACE_DST="/home/pi/morpheus"

RASPBIAN_VERSION="2016-05-10-raspbian-jessie"
RASPBIAN_MORPHEUS="2016-07-25-raspbian-morpheus"

MOUNT_BOOT="$DIR/tmp_boot"
MOUNT_ROOTFS="$DIR/tmp_rootfs"

FAST=0
IMAGE_FULL=0

function usage {
	echo
	echo "Usage: $(basename "$0") [-f] [-i] <SD card device name>"
	echo "       e.g  '$(basename "$0") /dev/sdb'"
	echo
	echo "  -f   Fast: skip writing the base image (Raspbian OS)"
	echo "  -i   Full Image install "
}

# param1: drive
function mount_all {
	mkdir -p $MOUNT_BOOT
	mkdir -p $MOUNT_ROOTFS
	mount ${1}1 $MOUNT_BOOT
	mount ${1}2 $MOUNT_ROOTFS
}

function umount_all {
	umount ${1}* >& /dev/null
	rm -rf $MOUNT_BOOT
	rm -rf $MOUNT_ROOTFS
}

# Make sure only root runs this script
if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root or with sudo!"
	exit 1
fi

# Parse input args
OPTIND=1
while getopts "h?fi" opt; do
	case "$opt" in
	h|\?)
		usage
		exit 0
		;;
	f)
		FAST=1
		;;
	i)
		IMAGE_FULL=1
	esac
done
shift $((OPTIND-1))
[ "$1" = "--" ] && shift

# Check arguments
if [ $# -eq 1 ]
then
	DRIVE=$1
else
	usage
	exit 1
fi
#Check if fast was enable and full image too
if [ "$FAST" -eq "$IMAGE_FULL" ] ; then
	echo "Cannot set -f and -i, they are exclusives"
	usage
fi


if [ "$DRIVE" = "/dev/sda" ] ; then
	echo "You do not probably want to erase your drive $DRIVE..."
	exit 1
fi

unset LANG

sudo partprobe $DRIVE

if [ $? -ne 0 ]
then
	echo "Cannot find drive, make sure it is the right device"
	exit 1
fi

# unmount SD card
sudo umount ${DRIVE}* >& /dev/null

echo ""
echo "-------------------------------------------------------------------------"
echo "         Creating SD Card for Morpheus Board on ${DRIVE}"
echo "-------------------------------------------------------------------------"
echo ""

# ask confirmation
read -p "Do you rely want to erase the drive ${DRIVE}? [yN] ? " -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
	echo "Aborting..."
	exit 2
fi

if [ $IMAGE_FULL -eq 1 ]
then

	if [ ! -f "$RASPBIAN_MORPHEUS.img" ]
	then
		echo " -> Dowloading Morpheus image" 
		"wget http://reds-data.heig-vd.ch/morpheus/$RASPBIAN_MORPHEUS.img"

	fi

	echo "-> Copying Morpheus image to the card. This will take a while..."
	dd bs=4M if="$RASPBIAN_MORPHEUS.img" of=${DRIVE} &> /dev/null

	echo "-> Synchronizing I/O operations on SD card..."
	sync
	# done
	umount_all $DRIVE

	echo ""
	echo "SD card successfully created for $DRIVE !"
	DISPLAY=:0 notify-send "SD Done"
	beep

	exit 0
fi

if [ $FAST -eq 0 ]
then
	# download + install base image
	if [ ! -f "$RASPBIAN_VERSION.img" ]
	then
		echo "-> Dowloading Raspbian OS"
		wget "https://downloads.raspberrypi.org/raspbian/images/raspbian-2016-05-13/$RASPBIAN_VERSION.zip"
		unzip "$RASPBIAN_VERSION.zip"
	else
		echo "-> Local copy of Raspbian OS found"
	fi
	echo "-> Copying Raspbian OS to the card. This will take a while..."
	dd bs=4M if="$RASPBIAN_VERSION.img" of=${DRIVE} &> /dev/null

	# re-read the partition table
	sleep 1
	partprobe $DRIVE
	sleep 1
	
	#resize part 2 assuming this is rootfs
	echo ",+" | sudo  sfdisk -N 2 ${DRIVE} --force
else
	echo "-> Skipping the install of Raspbian OS"
fi




# temp mount points
mount_all $DRIVE

# populate 'boot' partition
echo ""
echo "-> Copying files into boot partition..."
# -> precompiled stuff
cp -r --backup=numbered "$SD_CARD_BOOT_BIN"/* "$MOUNT_BOOT"
# -> custom kernel (must be compiled beforehand)
#if [ -f "$KERNEL_ZIMAGE" ]
#then
#	"$KERNEL_DIR/scripts/mkknlimg" "$KERNEL_ZIMAGE" "$BOOT_DIR/kernel-morpheus.img" &> /dev/null
#else
#	echo "!! Default Morpheus kernel installed (no zImage found in $KERNEL_ZIMAGE)"
#fi
#cp --backup=numbered "$KERNEL_DTB" "$MOUNT_BOOT"
#cp --backup=numbered "$KERNEL_DTBO_CIRRUS" "$MOUNT_BOOT/overlays/"
#cp --backup=numbered "$KERNEL_DTBO_MORPHEUS" "$MOUNT_BOOT/overlays/"

# copy userspace stuff
echo ""
echo "-> Copying userspace files..."
# modules, /etc, ...
cp -r "$SD_CARD_ROOTFS_BIN"/* "$MOUNT_ROOTFS/"
# uncompress modules
pushd "$MOUNT_ROOTFS/lib/modules/" &> /dev/null
tar -xf morpheus-modules.tar.gz
chown -R 0:0 *
popd &> /dev/null
# morpheus stuff
install -d "$MOUNT_ROOTFS/$USERSPACE_DST"
cp -r  "$USERSPACE_EXEC"/* "$MOUNT_ROOTFS/$USERSPACE_DST/"
touch "$MOUNT_ROOTFS/$USERSPACE_DST/.installation_not_done"
chown -R 1000:1000 "$MOUNT_ROOTFS/$USERSPACE_DST/"

echo "-> Done!"

# sync
echo ""
echo "-> Synchronizing I/O operations on SD card..."
sync

# done
umount_all $DRIVE

echo ""
echo "SD card successfully created for $DRIVE !"
DISPLAY=:0 notify-send "SD Done"
beep

