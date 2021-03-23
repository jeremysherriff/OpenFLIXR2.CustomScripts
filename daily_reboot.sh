#!/bin/bash
if [[ -f /var/run/reboot-required ]]; then
	/usr/bin/sendemail -f tvbox@bgs.co.nz -t alerts@bgs.co.nz -s 192.168.220.9:25 -o tls=no -u "TVBox reboot" -o message-file=/var/run/reboot-required.pkgs -o message-content-type=text -q
	/sbin/shutdown -r +5 2>&1 | logger -t reboot
fi

