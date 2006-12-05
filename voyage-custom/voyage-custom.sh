#!/bin/sh

EXEC_DIR=$PWD/`dirname $0`
RUN_DIR=$PWD
BUILD_DIR=$PWD/.tmp
	
if [ -z "$1" ] || [ -z "$2" ]; then
	echo "Usage:"
	#echo "	`basename $0` <voyage distro dir> <custom profile dir> [distro target directory]"
	echo "	`basename $0` <voyage distro dir> <custom profile dir> "
	exit 1
fi

VOYAGE_DIR="$1"
CUSTOM_DIR="$2"
TARGET_DIR="$BUILD_DIR"/voyage-`basename $CUSTOM_DIR`

DIST_DIR="$RUN_DIR"/`basename "$TARGET_DIR"`
if [ ! -z $3 ]; then
	DIST_DIR="$RUN_DIR"/`basename "$3"`
fi

if [ -d "$BUILD_DIR" ] ; then rm -rf "$BUILD_DIR" ; fi
mkdir -p "$BUILD_DIR"

if [ -d "$TARGET_DIR" ] ; then rm -rf "$TARGET_DIR" ; fi
mkdir -p "$TARGET_DIR"

# setting absolute path
CURDIR=$PWD
cd $VOYAGE_DIR; VOYAGE_DIR=$PWD; cd $CURDIR
cd $CUSTOM_DIR; CUSTOM_DIR=$PWD; cd $CURDIR
cd $TARGET_DIR; TARGET_DIR=$PWD; cd $CURDIR
# 

MOUNT_PROC_SH=/usr/local/sbin/mount-proc.sh

run_preinstall()
{
	echo "### Running pre-install scripts "
	echo ""
}

run_postinstall()
{
	echo "### Running post-install scripts "
	echo ""
	
	###################################################################
	# Running post.d
	#cp -rp "$CUSTOM_DIR/scripts/post.d" "$TARGET_DIR/"
	for CMD in $CUSTOM_DIR/scripts/post.d/*
	do
		if [ "`basename $CMD`" == "CVS" ] ; then continue; fi
		echo "### 	Running chroot command : $CMD"
	    chmod +x "$CMD"
	    cd "$TARGET_DIR/../"
	    export TARGET_DIR
	    export RUN_DIR
	    $CUSTOM_DIR/scripts/post.d/`basename $CMD`
	done
	
	rm -rf "$TARGET_DIR/post.d"
}


Chroot ()
{
	# Execute commands in chroot
	chroot "${TARGET_DIR}" /usr/bin/env -i HOME="/root" DEBIAN_FRONTEND="noninteractive" \
		TERM="${TERM}" PATH="/usr/sbin:/usr/local/sbin:/usr/bin:/sbin:/bin" \
		ftp_proxy="${LIVE_FTPPROXY}" http_proxy="${LIVE_HTTPPROXY}" ${1}
}

Chroot_MountProc ()
{
	if [ -f ${TARGET_DIR}/${MOUNT_PROC_SH} ] ;
	then
		# Execute commands in chroot
		chroot "${TARGET_DIR}" /usr/bin/env -i HOME="/root" DEBIAN_FRONTEND="noninteractive" \
			TERM="${TERM}" PATH="/usr/sbin:/usr/local/sbin:/usr/bin:/sbin:/bin" \
			ftp_proxy="${LIVE_FTPPROXY}" http_proxy="${LIVE_HTTPPROXY}" ${MOUNT_PROC_SH} ${1}
	else
		echo "No ${MOUNT_PROC_SH}, call Chroot() instead"
		Chroot "${1}"
	fi
}

run_chroot()
{
	echo "### Running chroot scripts "
	echo ""
	###################################################################
	# Running patch-cmd.d
	cp -rp "$CUSTOM_DIR/scripts/chroot.d" "$TARGET_DIR/"
	for CMD in $TARGET_DIR/chroot.d/*
	do
		if [ "`basename $CMD`" == "CVS" ] ; then continue; fi
		echo "### 	Running chroot command : $CMD"
	    chmod +x "$CMD"
	    Chroot "/chroot.d/`basename $CMD`"
	done
	
	rm -rf "$TARGET_DIR/chroot.d"
}


run_apt_conf()
{
	FILE="$CUSTOM_DIR/conf/apt.conf"
	if [ ! -f "$FILE" ] ; then echo "$FILE not found. "; return ; fi
	
	echo "### Running apt.conf"
	
	cd "$BUILD_DIR"
	
	if [ ! -f "$TARGET_DIR"/etc/resolv.conf ] ; then
		echo "resolv.conf not found.  Copy from /etc/resolv.conf"
		cp /etc/resolv.conf "$TARGET_DIR"/etc/
	fi
	
	rm -f "$TARGET_DIR"/var/lib/apt/lists/*_Packages
	rm -f "$TARGET_DIR"/var/lib/apt/lists/*_Release
	Chroot "apt-get update"
	#Chroot "$MOUNT_PROC_SH apt-get -y -q=1 upgrade"
	Chroot_MountProc "apt-get -y -q=1 upgrade"
	
	# backup current sources.list
	SRC_LIST="$TARGET_DIR"/etc/apt/sources.list 
	SRC_LIST_BAK="$SRC_LIST".bak
	cp $SRC_LIST $SRC_LIST_BAK
	while read LINE
	do
		LINE=`echo $LINE | sed -e 's/#.*$//g' -e '/^$/d' `
	
		if [ ! -z "$LINE" ] ; then 
			CMD=`echo $LINE | cut -d "=" -f 1`
			VALUE=`echo $LINE | cut -d "=" -f 2 | sed -e 's/\"//g'`
			
			if [ $CMD == "DEB_REPOS" ] ; then
				if [ ! "$VALUE" == "" ] ; then
					echo "Using $VALUE"
					echo $VALUE >> $SRC_LIST
					Chroot "apt-get update"
				fi
			elif [ $CMD == "DEB_PKGS" ] ; then
				if [ ! -z "$VALUE" ] ; then
					for PKG in $VALUE
					do
						PKG=`echo $PKG | tr -d "\b\f\n\r\t[:blank:]"`
						echo "apt-get installing "$PKG""
						#Chroot "$MOUNT_PROC_SH apt-get -y -q=2 install $PKG"
						Chroot_MountProc "apt-get -y -q=2 install $PKG"
					done
				fi
				rm -f $SRC_LIST
			fi
		fi
	done < $FILE
	
	mv $SRC_LIST_BAK $SRC_LIST 
	Chroot "apt-get update"
	
	echo ""
}

run_dpkg_install()
{
	FILE="$CUSTOM_DIR/conf/dpkg-i.lst"
	
	if [ ! -f "$FILE" ] ; then echo "$FILE not found. "; return ; fi
	
	echo "### Running dpkg-i.lst"
	cd "$BUILD_DIR"
	
	while read LINE
	do
		LINE=`echo $LINE | sed -e 's/#.*$//g' -e '/^$/d' `
	
		if [ ! -z "$LINE" ] ; then 
			DPKG=`basename $LINE`
			Chroot "wget $LINE"
			Chroot "dpkg -i $DPKG"
			Chroot "rm -f $DPKG"
		fi
	done < $FILE

	
	echo ""
}

run_dpkg_remove()
{
	FILE="$CUSTOM_DIR/conf/dpkg-r.lst"
	if [ ! -f "$FILE" ] ; then echo "$FILE not found. "; return ; fi
	
	echo "### Running dpkg-r.lst"
	
	cd "$BUILD_DIR"
	
	while read LINE
	do
		LINE=`echo $LINE | sed -e 's/#.*$//g' -e '/^$/d' `
	
		if [ ! -z "$LINE" ] ; then 
			#Chroot "$MOUNT_PROC_SH apt-get -f -y -q=2 remove $LINE"
			Chroot_MountProc "apt-get -f -y -q=2 --purge remove $LINE"
		fi
	done < $FILE
	
	echo ""
}

run_rm()
{
	FILE="$CUSTOM_DIR/conf/rm.lst"
	if [ ! -f "$FILE" ] ; then echo "$FILE not found. "; return ; fi
	
	echo "### Running rm.lst"
	
	while read LINE
	do
		LINE=`echo $LINE | sed -e 's/#.*$//g' -e '/^$/d' `
		
		if [ ! "$LINE" == "" ] ; then 
			echo "Removing file(s) $LINE"
			
			RM_FILES="$TARGET_DIR"/"$LINE"
			for RM_FILE in $RM_FILES
			do
				if [ -f "$RM_FILE" ] ; then 
					#echo "  Removing file $RM_FILE"
					rm -f "$RM_FILE"
				fi
				if [ -d "$RM_FILE" ] ; then
					#echo "  Removing directory $RM_FILE"				
					rm -rf "$RM_FILE"
				fi
			done
			
		fi
	done < $FILE
		
	echo ""
}

run_tmpfs()
{
	FILE="$CUSTOM_DIR/conf/tmpfs.lst"
	if [ ! -f "$FILE" ] ; then echo "$FILE not found. "; return ; fi
	
	echo "### Running tmpfs.lst"
	echo ""
}

run_kernel_conf()
{
	FILE="$CUSTOM_DIR/conf/kernel.conf"
	if [ ! -f "$FILE" ] ; then echo "$FILE not found. "; return ; fi
	
	. "$CUSTOM_DIR/conf/kernel.conf"
	
	echo "### Running kernel.conf"

	if [ -z $KERNEL_DEB ] ; then return ; fi

	# Remove lilo
	Chroot "apt-get -y -q=2 remove lilo"
	
	# Copy kernel deb and modules debs
	cp "$CUSTOM_DIR/files/$KERNEL_DEB" "$TARGET_DIR"
	for PKG in $MODULE_DEB
	do
		cp "$CUSTOM_DIR/files/$PKG" "$TARGET_DIR"
	done
	
	# Install kernel deb and module debs
	Chroot "dpkg -i $KERNEL_DEB"
	for PKG in $MODULE_DEB
	do
		Chroot "dpkg -i $PKG"
	done

	# Get kernel version from KERNEL_DEB
	KVERS=`ls -rt "$TARGET_DIR"/lib/modules/ | head -1`

	# Copy module file to /lib/modules
	for FILE in $MODULE_FILE
	do
		cp "$CUSTOM_DIR/files/$FILE" "$TARGET_DIR/lib/modules/$KVERS/"
	done
		
	# Generate module dependencies
	Chroot "depmod -ae $KVERS -F /boot/System.map-$KVERS"
	
	# Install lilo back
	Chroot "apt-get install lilo"

	# remove files to chroot directory
	Chroot "rm -f $KERNEL_DEB $MODULE_FILE"
	for PKG in $MODULE_DEB
	do
		Chroot "rm -f $PKG"
	done
	

	echo ""
}

run_overlay_fs()
{
	FILE="$CUSTOM_DIR/overlay_fs"
	if [ ! -d "$FILE" ] ; then echo "$FILE not found. "; return ; fi
	
	echo "### Running overlay_fs"

	COUNT=`cp -vRp "$FILE"/* "$TARGET_DIR" | wc -l`
	
	for LINE in `find $FILE/`; do
		LINE2=`echo $LINE|sed -e "s#$FILE##"`		
		chown root:root "$TARGET_DIR"/"$LINE2"
	done
	
	find "$TARGET_DIR" -name "CVS" -exec rm -rf '{}' ';'
	
	echo ""
	echo "$COUNT file(s) copied"
	echo ""
}

##################################################
# Program start here
#
if [ -d "$TARGET_DIR" ] ; then rm -rf "$TARGET_DIR" ; fi

if [ -d "$VOYAGE_DIR" ] ; then
	### This is a distribution directory
	echo ""
	echo "### Using Voyage distribution directory $VOYAGE_DIR"
	echo ""
	
	cp -Rp $VOYAGE_DIR "$BUILD_DIR"
	mv "$BUILD_DIR"/`basename $VOYAGE_DIR` "$TARGET_DIR"
elif [ -f "$VOYAGE_DIR" ] ; then
	### This is a distribution tarball
	echo "### Using Voyage distribution file $VOYAGE_DIR"
	echo ""
	
	cd "$BUILD_DIR"
	tar --numeric-owner -zxf $VOYAGE_DIR
	
	mv "$BUILD_DIR"/`tar -ztf $VOYAGE_DIR | head -n 1` "$TARGET_DIR"
	
else
	echo "voyage distribution file $VOYAGE_DIR not found"
	exit 1
fi

##################################################
# copy /etc/resolv.conf
#
if [ -f "$TARGET_DIR"/ro/etc/resolv.conf ] ; then
	cp /etc/resolv.conf "$TARGET_DIR"/ro/etc/resolv.conf
fi 

##################################################
# copy ro to rw
#

if [ -d "$TARGET_DIR"/ro/ ] ; then
	cp -r "$TARGET_DIR"/ro/* "$TARGET_DIR"/rw
fi

export DEBIAN_FRONTEND=noninteractive

run_preinstall

run_apt_conf
run_dpkg_remove
run_dpkg_install

run_rm
run_tmpfs

run_kernel_conf

run_overlay_fs

run_chroot

run_postinstall

##################################################
# remove stuff
#
#exit 
Chroot "rm -rf /var/cache/bootstrap"
Chroot "apt-get clean"
for i in $(find $TARGET_DIR/var/lib/apt/lists -type f \( -name \*Packages -o -name \*Sources \) 2>/dev/null); do  :>"$i"; done
Chroot "dpkg --clear-avail"
rm -f "$TARGET_DIR"/var/cache/apt/*.bin
Chroot "apt-cache gencaches > /dev/null"
Chroot "remove.docs"

##################################################
# at last, remove rw
#
if [ -d "$TARGET_DIR"/rw ] ; then
	cp -r "$TARGET_DIR"/rw/* "$TARGET_DIR"/ro
	rm -rf "$TARGET_DIR"/rw/*
fi

if [ -d "$DIST_DIR" ] ; then rm -rf "$DIST_DIR" ; fi
mv "$TARGET_DIR" "$DIST_DIR"
rm -rf "$BUILD_DIR"

### exit
exit

##################################################
# Build Live CD
#
	
	LIVE_DIR="`dirname $DIST_DIR`/`basename $DIST_DIR`-live"
	
	if [ -d "$LIVE_DIR" ] ; then rm -rf "$LIVE_DIR" ; fi

	# Create directory
	mkdir -p "${LIVE_DIR}"/casper
	mkdir -p "${LIVE_DIR}"/isolinux
	
	# Creating rootfs
	mksquashfs "${DIST_DIR}" "${LIVE_DIR}"/casper/filesystem.squashfs


	# Copying kernel
	cp "${DIST_DIR}"/boot/vmlinuz-* "${LIVE_DIR}"/vmlinuz
	cp "${DIST_DIR}"/boot/initrd.img-* "${LIVE_DIR}"/initrd.gz

	# Install syslinux
	cp /usr/lib/syslinux/isolinux.bin "${LIVE_DIR}"/isolinux

	# Configure syslinux
cat > "${LIVE_DIR}"/isolinux/isolinux.cfg << EOF
DEFAULT /vmlinuz
APPEND append initrd=/initrd.gz boot=casper
TIMEOUT 500
EOF

	# Creating image
	mkisofs -o "${LIVE_DIR}"/../`basename ${LIVE_DIR}`.iso -r -J -l \
		-b isolinux/isolinux.bin -c isolinux/boot.cat \
		-no-emul-boot -boot-load-size 4 -boot-info-table "${LIVE_DIR}"
		