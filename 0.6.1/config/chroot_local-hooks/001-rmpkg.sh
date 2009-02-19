#!/bin/sh

RMPKGS="at \
bsdmainutils \
ed \
fdutils \
groff-base \
info \
libtext-charwidth-perl \
libtext-wrapi18n-perl \
libtext-iconv-perl \
manpages \
nano \
aptitude \
tasksel \
tasksel-data \
liblocale-gettext-perl \
libcwidget3 \
libsigc++-2.0-0c2a \
console-data \
console-common \
kbd \
libconsole \
apt-utils \
libgnutls13 \
libdb4.4 \
dmidecode \
gcc-4.2-base \
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
netcat-traditional \
liblzo2-2 \
dhcp3-client \
dhcp3-common \
"

for PKG in $RMPKGS
do
	echo "*** RMPKG Removing $PKG"
	apt-get -f -y -q=2 --purge remove $PKG
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
