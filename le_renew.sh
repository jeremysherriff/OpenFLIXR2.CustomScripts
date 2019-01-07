#!/bin/bash

### Created using commands:
# certbot certonly --webroot -w /var/www/letsencrypt -d openflixr.bgs.co.nz
# certbot certonly --webroot -w /var/www/letsencrypt -d gateway.bgs.co.nz

certbot certificates

#certbot renew --webroot -w /var/www/letsencrypt
certbot renew --nginx

rm /mnt/dev/fullchain_*.p12

openssl pkcs12 -export -out /mnt/dev/fullchain_openflixr.p12 -inkey /etc/letsencrypt/live/openflixr.bgs.co.nz/privkey.pem -in /etc/letsencrypt/live/openflixr.bgs.co.nz/cert.pem -certfile /etc/letsencrypt/live/openflixr.bgs.co.nz/chain.pem
openssl pkcs12 -export -out /mnt/dev/fullchain_gateway.p12 -inkey /etc/letsencrypt/live/gateway.bgs.co.nz/privkey.pem -in /etc/letsencrypt/live/gateway.bgs.co.nz/cert.pem -certfile /etc/letsencrypt/live/gateway.bgs.co.nz/chain.pem

chmod 666 /mnt/dev/fullchain_*.p12
echo P12 certs are now in /mnt/dev/fullchain_*.p12 \\\\diskstation\\temp\\dev\\

