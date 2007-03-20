#!/bin/sh

if [ -z $1 ] ; then
	echo "$0 <device>"
	exit
fi

echo "Press ENTER to continue to format flash memory on $1"
read a

DEV=$1
#[ -b $DEV ] && fdisk $DEV < `dirname $0`/fdisk.cmd
[ -b $DEV ] && fdisk $DEV <<EOF
o
n
p
1


a
1
w
EOF
[ -b "$DEV"1 ] && mkfs.ext2 "$DEV"1
[ -b "$DEV"1 ] && tune2fs -c 0 -i 0 "$DEV"1
