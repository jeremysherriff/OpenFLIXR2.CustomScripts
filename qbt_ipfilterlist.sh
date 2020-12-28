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

wget "${URLS[@]}" --no-verbose -O - | gunzip | LC_ALL=C sort -u>"/mnt/downloads/ipfilter.p2p"
# if [[ $(systemctl is-active qbittorrent) == "active" || $(systemctl is-active qbittorrent-nox) == "active" ]]; then
	echo ""
	echo Reloading qBitTorrent IP filter
	/usr/bin/wget -q -O - --header="Content-type:application/x-www-form-urlencoded" --post-data="json={\"ip_filter_enabled\":\"false\"}" http://127.0.0.1:8080/api/v2/app/setPreferences
	sleep 2
	/usr/bin/wget -q -O - --header="Content-type:application/x-www-form-urlencoded" --post-data="json={\"ip_filter_enabled\":\"true\"}" http://127.0.0.1:8080/api/v2/app/setPreferences
	sleep 2
	 tail /opt/docker/qbittorrent/config/data/qBittorrent/logs/qbittorrent.log | grep filter
# fi
