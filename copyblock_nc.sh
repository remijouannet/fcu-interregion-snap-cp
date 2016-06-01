#!/bin/sh

if [ $# -ne 4 ] ; then
    echo "args missing"
    exit 1
fi

BLOCK=$4
SIZE=$3
DESTINATION=$1
DEVDEST=$2
DEVICE="none"
if [ -e /dev/xvdb ] ; then
    DEVPREFIX=/dev/xvd
elif [ -e /dev/vdb ] ; then
    DEVPREFIX=/dev/vd
else
    exit 1
fi

while [ "$DEVICE" = "none" ] ; do
    for dev in b c d e f g h i ; do
        if [ -e $DEVPREFIX$dev ] ; then
            if mkdir /tmp/lock-$dev 2>/dev/null ; then
                touch /tmp/lock-$dev
                LOCK="/tmp/lock-$dev"
                DEVICE="$DEVPREFIX$dev"
                break
            else
                continue
            fi
        fi
    done
done

OFFSET=$((BLOCK*SIZE))
dd if=$DEVICE bs=1048576 count=$SIZE skip=$OFFSET |ssh -o Compression=no -o StrictHostKeyChecking=no -i /root/.ssh/dest.pem root@$DESTINATION "dd of=$DEVDEST bs=1048576 seek=$OFFSET iflag=fullblock"
rmdir $LOCK

