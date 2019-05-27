#!/bin/bash

cat << EOF >/tmp/msg.tmp
A Plex client is causing more buffering than the system can handle.

EOF

## Externalised email settings
. /opt/custom/notify/email.ini
if [[ $SMTP_AUTH == "yes" ]]; then
	SMTP_USER="-xu $SMTP_USER"
	SMTP_PASS="-xp $SMTP_PASS"
else
	SMTP_USER=
	SMTP_PASS=
fi
if [[ -n $CC_ADDRESS ]]; then
	CC_ADDRESS="-cc $CC_ADDRESS"
fi

MAIL_SUBJECT="PlexPy Alert: Plex Buffering alert"

cat /tmp/msg.tmp | sendemail -f $FROM_ADDRESS -t $TO_ADDRESS $CC_ADDRESS -u $MAIL_SUBJECT -o tls=$USE_TLS -s "$MAIL_SERVER:$MAIL_PORT" $SMTP_USER $SMTP_PASS

rm /tmp/msg.tmp



