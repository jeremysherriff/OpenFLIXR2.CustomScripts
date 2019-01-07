#!/bin/bash

cat << EOF >/tmp/msg.tmp
The Plex Media Server is up.

EOF

cat /tmp/msg.tmp | sendemail -f openflixr@bgs.co.nz -t alerts@bgs.co.nz -u "PlexPy Alert: Plex Server Up" -o tls=no -s 192.168.220.254:25
rm /tmp/msg.tmp



