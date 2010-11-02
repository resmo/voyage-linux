#!/bin/sh

DISTRO="voyage"
MOUNT_PROC_SH=/usr/local/sbin/mount-proc.sh

# define squashfs options here
export MKSQUASHFS_OPTIONS="-b 1048576"

# define linux packages here for different editions
VOYAGE_LINUX_PACKAGES="linux-image-2.6.32 madwifi-modules-2.6.32"
#ONE_LINUX_PACKAGES="linux-image-2.6.32 madwifi-modules-2.6.32 batman-adv-modules-2.6.32 batmand-gateway-modules-2.6.32 dahdi-modules-2.6.32"
ONE_LINUX_PACKAGES="linux-image-2.6.33.7-rt29 madwifi-modules-2.6.33.7-rt29 batman-adv-modules-2.6.33.7-rt29 batmand-gateway-modules-2.6.33.7-rt29 dahdi-modules-2.6.33.7-rt29"
MPD_LINUX_PACKAGES="linux-image-2.6.33.7-rt29 madwifi-modules-2.6.33.7-rt29 alsa-modules-2.6.33.7-rt29"

if [ $(uname -m) == "x86_64" ] ; then
	ARCH="_amd64"
	lh config -a amd64
fi

Chroot ()
{
    # Execute commands in chroot
    chroot "${1}" /usr/bin/env -i HOME="/root" DEBIAN_FRONTEND="noninteractive" \
        TERM="${TERM}" PATH="/usr/sbin:/usr/local/sbin:/usr/bin:/sbin:/bin" \
        ftp_proxy="${LIVE_FTPPROXY}" http_proxy="${LIVE_HTTPPROXY}" ${2}
}

Chroot_MountProc ()
{
    if [ -f ${1}/${MOUNT_PROC_SH} ] ;
    then
        # Execute commands in chroot
        chroot "${1}" /usr/bin/env -i HOME="/root" DEBIAN_FRONTEND="noninteractive" \
			 TERM="${TERM}" PATH="/usr/sbin:/usr/local/sbin:/usr/bin:/sbin:/bin" \
            ftp_proxy="${LIVE_FTPPROXY}" http_proxy="${LIVE_HTTPPROXY}" ${MOUNT_PROC_SH} ${2}
    else
        echo "No ${MOUNT_PROC_SH}, call Chroot() instead"
        Chroot "${1}" "${2}"
    fi
}

BuildTar()
{
	lh clean
	lh config -b tar --chroot-filesystem plain -p voyage --linux-packages="$VOYAGE_LINUX_PACKAGES"
	lh build

	Chroot_MountProc binary/live/filesystem.dir "apt-get -y remove --purge busybox live-initramfs"
	Chroot_MountProc binary/live/filesystem.dir "apt-get -y autoremove --purge"
	rm -f binary/live/filesystem.dir/boot/*.bak
	
	if [ -d binary/live/filesystem.dir ] ; then
		mv binary/live/filesystem.dir binary/live/$DISTRO-current$ARCH
		tar -jcf $DISTRO-current$ARCH.tar.bz2 -C binary/live/	$DISTRO-current$ARCH/. 
		mv binary/live/$DISTRO-current$ARCH binary/live/filesystem.dir
	else
		echo "binary/live/filesystem.dir not found!"
	fi
}

BuildImg()
{
	lh clean
	lh config -b usb-hdd --binary-filesystem fat16 --chroot-filesystem squashfs -p voyage-cd --linux-packages="$VOYAGE_LINUX_PACKAGES"
	lh build

	if [ -f binary.img ] ; then
		mv binary.img $DISTRO-current$ARCH.img
	else
		echo "binary.img not found!"
	fi
}

BuildISO()
{
	lh clean
	lh config -b iso --chroot-filesystem squashfs -p voyage-cd --linux-packages="$VOYAGE_LINUX_PACKAGES"
	lh build
	
	if [ -f binary.iso ] ; then
		mv binary.iso $DISTRO-current$ARCH.iso
	else
		echo "binary.iso not found!"
	fi
}

BuildSDK()
{
	lh clean
	lh config -b iso --chroot-filesystem squashfs -p voyage-sdk --linux-packages="$VOYAGE_LINUX_PACKAGES"
	lh build
	
	if [ -f binary.iso ] ; then
		mv binary.iso $DISTRO-sdk$ARCH.iso
	else
		echo "binary.iso not found!"
	fi
}

BuildOne()
{
	lh clean
	lh config -b tar --chroot-filesystem plain -p voyage-one --linux-packages="$ONE_LINUX_PACKAGES"
	lh build

	Chroot_MountProc binary/live/filesystem.dir "apt-get -y remove --purge busybox live-initramfs"
	Chroot_MountProc binary/live/filesystem.dir "apt-get -y autoremove --purge"
	rm binary/live/filesystem.dir/boot/*.bak
	
	if [ -d binary/live/filesystem.dir ] ; then
		mv binary/live/filesystem.dir binary/live/$DISTRO-one-current$ARCH
		tar -jcf $DISTRO-one-current$ARCH.tar.bz2 -C binary/live/	$DISTRO-one-current$ARCH/. 
		mv binary/live/$DISTRO-one-current$ARCH binary/live/filesystem.dir
	else
		echo "binary/live/filesystem.dir not found!"
	fi
}

BuildOneCD()
{
	lh clean
	lh config -b iso --chroot-filesystem squashfs -p voyage-one-cd --linux-packages="$ONE_LINUX_PACKAGES"
	lh build
	
	if [ -f binary.iso ] ; then
		mv binary.iso $DISTRO-one-current$ARCH.iso
	else
		echo "binary.iso not found!"
	fi
}

#
# $1 - package list name (e.g. voyage-one-cd)
# $2 - distro name (e.g. one, mpd)
# $3 - linux packages 
#
BuildDistro()
{
	lh clean
	lh config -b tar --chroot-filesystem plain -p $1 --linux-packages="$3"
	lh build

	Chroot_MountProc binary/live/filesystem.dir "apt-get -y remove --purge busybox live-initramfs"
	Chroot_MountProc binary/live/filesystem.dir "apt-get -y autoremove --purge"
	rm binary/live/filesystem.dir/boot/*.bak
	
	if [ -d binary/live/filesystem.dir ] ; then
		mv binary/live/filesystem.dir binary/live/$DISTRO-$2-current$ARCH
		tar -jcf $DISTRO-$2-current$ARCH.tar.bz2 -C binary/live/	$DISTRO-$2-current$ARCH/. 
		mv binary/live/$DISTRO-$2-current$ARCH binary/live/filesystem.dir
	else
		echo "binary/live/filesystem.dir not found!"
	fi
}

#
# $1 - package list name (e.g. voyage-one-cd)
# $2 - distro name (e.g. one, mpd)
# $3 - linux packages
#
BuildCD()
{
	lh clean
	lh config -b iso --chroot-filesystem squashfs -p $1 --linux-packages="$3"
	lh build
	
	if [ -f binary.iso ] ; then
		mv binary.iso $DISTRO-$2-current$ARCH.iso
	else
		echo "binary.iso not found!"
	fi
}

for TYPE in $1; do
	case "$TYPE" in
		img)
			BuildImg
		;;
		tar)
			BuildTar
		;;
		iso)
			BuildISO
		;;
		sdk)
			BuildSDK
		;;
		onecd)
			BuildCD voyage-one-cd one "$ONE_LINUX_PACKAGES"
			#BuildOneCD
		;;
		one)
			BuildDistro voyage-one one "$ONE_LINUX_PACKAGES"
			#BuildOne
		;;
		mpdcd)
			BuildCD voyage-mpd-cd mpd "$MPD_LINUX_PACKAGES"
		;;
		mpd)
			BuildDistro voyage-mpd mpd "$MPD_LINUX_PACKAGES"
		;;
		test)
			Chroot_MountProc binary/live/filesystem.dir "apt-get -y remove busybox live-initramfs"
			Chroot_MountProc binary/live/filesystem.dir "apt-get -y autoremove"
		;;
		*)
			echo "unknown build type $TYPE"
		;;
	esac
done

