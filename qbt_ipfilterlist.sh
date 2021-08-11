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

# http://list.iblocklist.com/?list=bt_level1
# http://list.iblocklist.com/?list=bt_level2
# http://list.iblocklist.com/?list=bt_level3
# http://list.iblocklist.com/?list=bt_bogon
URLS=(
http://list.iblocklist.com/?list=cwworuawihqvocglcoss\&fileformat=p2p\&archiveformat=gz
http://list.iblocklist.com/?list=ydxerpxkpcfqjaybcssw\&fileformat=p2p\&archiveformat=gz
http://list.iblocklist.com/?list=gyisgnzbhppbvsphucsw\&fileformat=p2p\&archiveformat=gz
http://list.iblocklist.com/?list=uwnukjqktoggdknzrhgh\&fileformat=p2p\&archiveformat=gz
http://list.iblocklist.com/?list=gihxqmhyunbxhbmgqrla\&fileformat=p2p\&archiveformat=gz
http://list.iblocklist.com/?list=xpbqleszmajjesnzddhv\&fileformat=p2p\&archiveformat=gz
)

wget "${URLS[@]}" --no-verbose -O - | gunzip | LC_ALL=C sort -u | grep -E . > /mnt/downloads/ipfilter.new
mv /mnt/downloads/ipfilter.p2p /mnt/downloads/ipfilter.p2p.old
mv /mnt/downloads/ipfilter.new /mnt/downloads/ipfilter.p2p

echo ""
echo Reloading qBitTorrent IP filter
/usr/bin/wget -q -O - --header="Content-type:application/x-www-form-urlencoded" --post-data="json={\"ip_filter_enabled\":\"false\"}" http://127.0.0.1/qbt/api/v2/app/setPreferences
sleep 2
/usr/bin/wget -q -O - --header="Content-type:application/x-www-form-urlencoded" --post-data="json={\"ip_filter_enabled\":\"true\"}" http://127.0.0.1/qbt/api/v2/app/setPreferences
# tail /opt/docker/qbittorrent/config/data/qBittorrent/logs/qbittorrent.log | grep filter
