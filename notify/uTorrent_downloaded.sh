#!/bin/bash

TMPFILE=`mktemp -t email.XXXXXXXXXX`
cat << EOF >$TMPFILE
Download complete.

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

MAIL_SUBJECT="Downloaded: $1"

cat $TMPFILE | sendemail -f $FROM_ADDRESS -t $TO_ADDRESS $CC_ADDRESS -u $MAIL_SUBJECT -o tls=$USE_TLS -s "$MAIL_SERVER:$MAIL_PORT" $SMTP_USER $SMTP_PASS

rm $TMPFILE

