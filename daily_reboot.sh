#!/bin/bash
if [[ ! -f /opt/custom/notify/email.ini ]]; then
        echo ""
        echo "Mail settings not defined!"
        echo "Please review and edit /opt/custom/notify/email.ini"
        cp /opt/custom/notify/.email.ini.dist /opt/custom/notify/email.ini
        echo ""
        echo "Also check your dependencies:"
        echo "  apt install crudini sendemail"
        exit 2
fi

if [[ ! -f /var/run/reboot-required ]]; then
	exit 0
fi

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

/usr/bin/sendemail -f $FROM_ADDRESS -t $TO_ADDRESS $CC_ADDRESS -u "`hostname` reboot" -o tls=$USE_TLS -s "$MAIL_SERVER:$MAIL_PORT" $SMTP_USER $SMTP_PASS -o message-file=/var/run/reboot-required.pkgs -o message-content-type=text -q

/sbin/shutdown -r +5 2>&1 | logger -t reboot
exit 1
