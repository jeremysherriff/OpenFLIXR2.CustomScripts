#!/bin/bash

cat << EOF >/tmp/msg.tmp
A Plex client is causing more buffering than the system can handle.

EOF

cat /tmp/msg.tmp | sendemail -f openflixr@bgs.co.nz -t alerts@bgs.co.nz -u "PlexPy Alert: Plex Buffering alert" -o tls=no -s 192.168.220.254:25
rm /tmp/msg.tmp



