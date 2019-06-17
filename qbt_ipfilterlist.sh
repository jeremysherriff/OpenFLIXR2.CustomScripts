#!/bin/bash
if [[ $1 == "-v" ]]; then
	exec 1> >(tee -a /var/log/ipfilter.log) 2>&1
else
	exec 1>> /var/log/ipfilter.log 2>&1
fi

TODAY=$(date)
echo "-----------------------------------------------------"
echo "Date:          $TODAY"

set -e

URLS=(
http://list.iblocklist.com/?list=bt_level1
http://list.iblocklist.com/?list=bt_level2
http://list.iblocklist.com/?list=bt_level3
http://list.iblocklist.com/?list=bt_bogon
)

wget "${URLS[@]}" -O - | gunzip | LC_ALL=C sort -u >"/home/mediabox/.config/qBittorrent/ipfilter.p2p"
chown --reference=/home/mediabox/.config/qBittorrent/ /home/mediabox/.config/qBittorrent/ipfilter.p2p
ISACTIVE=$(systemctl is-active qbittorrent)
if [[ $ISACTIVE == "active" ]]; then
	echo Reloading qBitTorrent
	systemctl restart qbittorrent
fi
