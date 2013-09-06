#!/bin/bash

MIRROR=http://ftp.jp.debian.org/debian

rm -rf ./wheezy-chroot

debootstrap --arch=armhf --variant=minbase --include=wget wheezy ./wheezy-chroot $MIRROR

