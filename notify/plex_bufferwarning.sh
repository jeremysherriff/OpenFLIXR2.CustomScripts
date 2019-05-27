#!/bin/bash

cat << EOF >/tmp/msg.tmp
A Plex client is causing more buffering than the system can handle.

EOF

## Externalised email settings
if [[ $(crudini --get /opt/custom/notify/email.ini Email SMTP_AUTH | awk '{print $1}') == "yes" ]]; then
        SMTP_USER="-xu $(crudini --get /opt/custom/notify/email.ini Email SMTP_USER)"
        SMTP_PASS="-xp $(crudini --get /opt/custom/notify/email.ini Email SMTP_PASS)"
fi
if [[ -n $(crudini --get /opt/custom/notify/email.ini Email CC_ADDRESS) ]]; then
        CC_ADDRESS="-cc $(crudini --get /opt/custom/notify/email.ini Email CC_ADDRESS)"
fi

FROM_ADDRESS=$(crudini --get /opt/custom/notify/email.ini Email FROM_ADDRESS)
TO_ADDRESS=$(crudini --get /opt/custom/notify/email.ini Email TO_ADDRESS)
USE_TLS=$(crudini --get /opt/custom/notify/email.ini Email USE_TLS | awk '{print $1}')
MAIL_SERVER=$(crudini --get /opt/custom/notify/email.ini Email MAIL_SERVER)
MAIL_PORT=$(crudini --get /opt/custom/notify/email.ini Email MAIL_PORT)
if [[ -n $DISPLAY_NAME ]]; then
        FROM_ADDRESS="$DISPLAY_NAME<$FROM_ADDRESS>"
fi

MAIL_SUBJECT="PlexPy Alert: Plex Buffering alert"

cat /tmp/msg.tmp | sendemail -f $FROM_ADDRESS -t $TO_ADDRESS $CC_ADDRESS -u $MAIL_SUBJECT -o tls=$USE_TLS -s "$MAIL_SERVER:$MAIL_PORT" $SMTP_USER $SMTP_PASS

rm /tmp/msg.tmp



