#!/bin/bash

W()
{
	echo "*** $1"
}

Usage()
{
	echo "Usage: `basename $0` <create|destroy|status> <file>" >&2
	echo ""
	echo "  create - relocate <file> to $RO_DIR and make <file> a symlink to $RW_DIR"
	echo "  destroy - delete <file> if it is a symlink to $RW_DIR and exists in $RO_DIR"
	echo "  status - check the status of <file>"
}

if [ -z $2 ] ; then
	W "<file> is missing"
	Usage
	exit 1
fi

if [ "${2:0:1}" != "/" ] ; then
	W "$2 is not starting with "/""
	exit 1	
fi

RO_DIR=/ro
#RW_DIR=/lib/init/rw
RW_DIR=/tmp

create()
{
	FILE=$(dirname $1)/$(basename $1)

	if [ -L $FILE ] ; then
		W "$FILE is already a symlink."
		return
	fi

    if [ ! -f $FILE ] && [ ! -d $FILE ] ; then 
		W "$FILE not found, please make sure $FILE exist."
		return
	fi

	DIR="$RO_DIR"`dirname $FILE`
    if [ ! -d "$DIR" ] ; then 
		echo "creating new directory $DIR"
		mkdir -p $DIR 
	fi

	echo "Relocate $FILE to "$RO_DIR""$FILE""
    mv "$FILE" "$DIR"/ 

    echo "Making symlink $FILE to "$RW_DIR""$FILE""
    ln -sf "$RW_DIR""$FILE" "$FILE"

}

destroy()
{
	FILE=$1

	if [ ! -L $FILE ] ; then
		W "$FILE is not a symlink."
		return
	fi

	echo "Removing $FILE."
	rm "$FILE"

	echo "Restoring "$RO_DIR""$FILE" to "$FILE"."
	mv "$RO_DIR""$FILE" `dirname "$FILE"`
}

case "$1" in
	create)
		create $2
		;;
	destroy)
		destroy $2
		;;
	status)
		status $2
		;;
	*)
		Usage
		exit 1
		;;
esac

