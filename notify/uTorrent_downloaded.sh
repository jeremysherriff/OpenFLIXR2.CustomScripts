#!/bin/bash

TMPFILE=`mktemp -t email.XXXXXXXXXX`
cat << EOF >$TMPFILE
Download complete.

EOF

cat $TMPFILE | sendemail -f "OpenFlixr"\<jeremysherriff@gmail.com\> -t jeremy@bgs.co.nz -u "Downloaded: $1" -o tls=no -s 192.168.220.254:25 -q
rm $TMPFILE

