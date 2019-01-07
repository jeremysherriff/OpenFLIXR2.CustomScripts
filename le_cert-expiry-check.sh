#!/bin/bash
# Get ssl-cert-check from https://github.com/Matty9191/ssl-cert-check
# Check that the below script lines use the right cert locations
# and email parameters

RENEWAL_DAYS=14
TMPFILE=`mktemp -t email.XXXXXXXXXX`
ISEXPIRING=false

for CERT in $(ls -1R /etc/letsencrypt/live/*/cert.pem)
do
	/opt/ssl-cert-check/ssl-cert-check -d $CERT -x $RENEWAL_DAYS | grep -i expiring >> $TMPFILE && ISEXPIRING=true
done

if [[ $ISEXPIRING == true ]]; then
	cat $TMPFILE | sendemail -f "OpenFlixr"\<jeremysherriff@gmail.com\> -t jeremy@bgs.co.nz -u "LetsEncrypt cert(s) expire soon" -o tls=no -s 192.168.220.254:25 -q
fi
rm $TMPFILE

