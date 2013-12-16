#! /bin/sh
### BEGIN INIT INFO
# Provides:          voyage-util
# Short-Description: Voyage Init script
# Required-Start:    $all
# Required-Stop:     $all
# Should-Start:      
# Should-Stop:       
# Default-Start:     2 3 4 5 
# Default-Stop:      0 1 6
### END INIT INFO
#
# skeleton  example file to build /etc/init.d/ scripts.
#       This file should be used to construct scripts for /etc/init.d.
#
#       Written by Miquel van Smoorenburg <miquels@cistron.nl>.
#       Modified for Debian
#       by Ian Murdock <imurdock@gnu.ai.mit.edu>.
#
# Version:  @(#)skeleton  1.9  26-Feb-2001  miquels@cistron.nl
#

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
#DAEMON=/usr/sbin/voyage-util
NAME=voyage-util
DESC=voyage-util

#test -x $DAEMON || exit 0

# Include voyage-util defaults if available
if [ -f /etc/default/voyage-util ] ; then
    . /etc/default/voyage-util
fi

alsa_unmute()
{
	if [ -f /usr/bin/amixer ] && [ -f [ -d /proc/asound ] ; then
	    # fix for multiple cards
            for ID in `cat /proc/asound/card*/id`; do
		amixer -c "$ID" scontrols | sed -e 's/^Simple mixer control//' | while read line; do 
	   	    amixer -c "$ID" sset "$line" unmute;
		done
	    done
	fi
}

start_leds()
{
	if [ $VOYAGE_LEDS = "NO" ] ; then return ; fi
	
	if [ ! -f /etc/voyage.conf ] ; then return ; fi
	. /etc/voyage.conf
	
	case $VOYAGE_PROFILE in
		'WRAP')
            echo heartbeat > /sys/class/leds/wrap\::power/trigger
            echo ide-disk > /sys/class/leds/wrap\::error/trigger
            echo netdev > /sys/class/leds/wrap\:\:extra/trigger
            echo eth0 > /sys/class/leds/wrap\:\:extra/device_name
            echo "link tx rx" > /sys/class/leds/wrap\:\:extra/mode			
			;;
		'ALIX')
			echo heartbeat > /sys/class/leds/alix\:1/trigger
			echo ide-disk > /sys/class/leds/alix\:2/trigger
			echo netdev > /sys/class/leds/alix\:3/trigger
		   	echo eth0 > /sys/class/leds/alix\:3/device_name
   			echo "link tx rx" > /sys/class/leds/alix\:3/mode

			echo "tsc" > /sys/devices/system/clocksource/clocksource0/current_clocksource
			;;
		*)
			;;
	esac
}

case $1 in
	'start')
		echo -n "Remounting / as read-write ... "
		#/bin/mount / -o remount,rw
		/usr/local/sbin/remountrw
		echo "Done."
		if [ -f /voyage.1st ] ; then
				echo "First-time installation "
		        echo -n "Re-generating host ssh keys ... "
				#rm -f /etc/ssh/ssh_host_rsa_key
				#ssh-keygen -q -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' || { echo "Fatal Error: Failed to generate RSA keypair" >&2; exit; }
				#rm -f /etc/ssh/ssh_host_dsa_key
				#ssh-keygen -q -t dsa -f /etc/ssh/ssh_host_dsa_key -N '' || { echo "Fatal Error: Failed to generate DSA keypair" >&2; exit; }
				#depmod -ae

				rm -f /etc/ssh/ssh_host_*_key
				dpkg-reconfigure openssh-server 

				depmod -a
				
				rm -f /voyage.1st
				echo "Done."		
		fi
		
		echo -n "Removing /etc/nologin ... "
		/etc/init.d/rmnologin start
		echo "Done."

		start_leds
		alsa_unmute
		run-parts /lib/voyage-utils

		echo -n "Remounting / as read-only ... "
		/usr/local/sbin/remountro
		echo "Done."		
		;;
	'stop')
		#if [ -f /etc/voyage.conf ] ; then
        #	. /etc/voyage.conf
        #	/usr/local/sbin/remountrw
        #   	for DIR in $VOYAGE_SYSTEM_SYNCDIRS
        #   	do
        #       	echo -n "Synchronizing $DIR ... "
		#		cp -Rp $DIR/* /ro$DIR/
		#		echo "Done."
		#	done
		#	/usr/local/sbin/remountro           	
		#fi

		# Do nothing
		;;
	force-reload|restart)

    	;;
	status)
	
		;;
	*)
	    ;;
esac

