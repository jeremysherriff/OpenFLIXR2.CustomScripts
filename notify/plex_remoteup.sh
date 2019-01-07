#!/bin/bash

cat << EOF >/tmp/msg.tmp
The Plex remote access is up.

EOF

cat /tmp/msg.tmp | sendemail -f openflixr@bgs.co.nz -t alerts@bgs.co.nz -u "PlexPy Alert: Plex Remote Access is Up" -o tls=no -s 192.168.220.254:25
rm /tmp/msg.tmp



