#
#	The routines within this file are designed for use with the
#	Voyage Linux Distribution, and may be freely copied under the
#	terms given in file 'License'.
#
#	Copyright (C) 2006 William Brack <wbrack@mmm.com.hk>
#
#

# We define some functions to make the mainline code cleaner
#
#	Function update_modules
#	Uses VOYAGE_SYSTEM_MODULES to generate a list of modules to
#	be loaded during system boot
#	Params:	$1 - root directory of target
#
update_modules() {
	local saveifs modline moduleslist nameonly modopts modoptslist
	saveifs=$IFS
	IFS=";"
	moduleslist="
#
# These lines generated automatically by `basename $0`,
# parsing VOYAGE_SYSTEM_MODULES from Profile: $VOYAGE_PROFILE
# on `date`
#
"
	modoptslist=$moduleslist	# copy header

	# echo "Profile: $VOYAGE_PROFILE"
	# echo "system-modules: $VOYAGE_SYSTEM_MODULES; "
	for modline in $VOYAGE_SYSTEM_MODULES; do
		rmspace=`echo $modline | sed -e "s/^ *//"`
		nameonly=`echo $rmspace | cut -d' ' -f1`
		modopts=`echo $rmspace | sed -e "s/$nameonly//" \
		    | sed -e "s/^ *//"`
		# echo "modline: $modline"
		# echo "rmspace: $rmspace"
		# echo "nameonly: $nameonly"
		moduleslist="$moduleslist\n$nameonly"
		# modprobe doesnt like empty options
		[ -n "$modopts" ] && \
		    modoptslist="$modoptslist\noptions $modopts"
	done
	IFS=$saveifs

	echo -e "$moduleslist" >> $1/etc/modules
	echo -e "$modoptslist" >> $1/etc/modprobe.d/$VOYAGE_PROFILE.conf
}

#
#	Function update_inittab()
#	Modifies /etc/inittab to take account of whether or not
#	there is a serial console
#	Params: $1 - location of the root directory for input file
#		$2 - location of the root directory for the result
#	Result: 
#
update_inittab() {
  if [ $VOYAGE_SYSTEM_CONSOLE == serial ]; then
    cmd1="/^[0-9]:/ s/^/#/"
    cmd2="s/^#T0:/T0:/;s/ttyS0 .*00/ttyS0 ${VOYAGE_SYSTEM_SERIAL}/"
  else
    cmd1="/^#[0-9]:/ s/^#//"
    cmd2="s/^T0:/#T0:/"
  fi
  cat $1/etc/inittab | sed -e "$cmd1" | sed -e "$cmd2" > \
    $2/etc/inittab
}

#
#	Function update_pcmcia()
#	Sets the target system to take account of whether or not
#	there is pcmcia hardware present
#	Params:	$1 - root directory of target
#
update_pcmcia() {
  check_yn $VOYAGE_SYSTEM_PCMCIA
  if [ $? -le 0 ]; then
    echo "Removing pcmcia from update-rc.d" >&2
    chroot $1 update-rc.d -f pcmcia remove >&2
  fi
}

#
#	Function remove_dnsmasq_pxe()
#	Remove line containing dnsmasq.pxe.conf in /etc/dnsmasq.more.conf
#	Params:	$1 - root directory of target
#
remove_dnsmasq_pxe() {
  if [ -n $1 ] && [ -f $1/etc/dnsmasq.more.conf ] ; then
  	sed -i "$1/etc/dnsmasq.more.conf" -e "/dnsmasq.pxe.conf/ D"   >&2
    echo "Removing dnsmasq.pxe.conf in /etc/dnsmasq.more.conf" >&2    
  fi
}

#
#	Function reconfig_resolvconf()
#	reconfigure resolvconf package
#	Params:	$1 - root directory of target
#
reconfig_resolvconf() {
    PKG=$(cat $1/voyage.dpkg.list |grep resolvconf)
    if  [ ! -z "$PKG" ] ; then
        echo "Reconfiguring resolvconf"
        chroot $1 sh -c "DEBIAN_FRONTEND=noninteractive dpkg-reconfigure resolvconf"
    fi

}

