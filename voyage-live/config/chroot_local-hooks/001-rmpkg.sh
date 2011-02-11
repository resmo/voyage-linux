#!/bin/sh

if [ $(dpkg-query --show | cut -f1 | grep "^asterisk$" | wc -l) -gt 0  ] ; then
    echo "($0) Building Voyage ONE.  No remove package"
    exit 0
fi
if [ $(dpkg-query --show | cut -f1 | grep "^mpd$" | wc -l) -gt 0  ] ; then
    echo "($0) Building Voyage MPD.  No remove package"
    exit 0
fi
   
RMPKGS="
libtext-charwidth-perl \
libtext-iconv-perl \
manpages \
aptitude \
liblocale-gettext-perl \
console-data \
console-common \
gcc-4.2-base \
netcat-traditional \
bsdmainutils \
dmidecode \
ed \
groff-base \
info \
libcwidget3 \
libept0 \
libnewt0.52 \
libsigc++-2.0-0c2a \
libxapian15 \
man-db \
nano \
rsyslog \
vim-common \
vim-tiny \
whiptail \
\
"

for PKG in $RMPKGS
do
	echo "*** RMPKG Removing $PKG"
	#apt-get -f -y -q=2 --purge remove $PKG
	apt-get -f -y --purge remove $PKG
done

exit

# libgdbm3  is removed because of voyage-sdk.
# below are harmful

libbz2-1.0 \
libtasn1-3 \
libgcrypt11 \
libopencdk10 \
libgpg-error0 \
libusb-0.1-4 \
hostname \
libldap-2.4-2 \
dhcp3-client \
dhcp3-common \
libgdbm3 \

# below are already removed
apt-utils \
at \
bsdmainutils \
ed \
fdutils \
groff-base \
info \
libtext-wrapi18n-perl \
nano \
tasksel \
tasksel-data \
libcwidget3 \
libsigc++-2.0-0c2a \
kbd \
libconsole \
libdb4.4 \
dmidecode \
libnewt0.52 \
gettext-base \
dialog \
libncursesw5 \
libgpmg1 \
libept0 \
libxapian15 \
vim-tiny \
vim-common \
locales \
liblzo2-2 \
live-initramfs \
live-config \
live-config-sysvinit \
live-boot \
live-boot-initramfs-tools \

