#!/bin/bash
exec 1> >(tee -a /var/log/stop_unwanted_apps.log) 2>&1
TODAY=$(date)
echo "-----------------------------------------------------"
echo "Date:          $TODAY"
echo "-----------------------------------------------------"

# Stop all the things that don't normally auto-start, as @MediaJunkie is a bit aggressive
# starting everything whether we want it or not.
EXTRAS="monit sickchill lazylibrarian syncthing@openflixr couchpotato headphones autosub lidarr mylar home-assistant nzbget qbittorrent ubooquity"
for app in $EXTRAS; do
  echo -ne "Checking $app.. "
  systemctl is-enabled $app 2>/dev/null
  if [ $? -ne 0 ]; then
    echo -ne " and is currently.. "
    systemctl is-active $app 2>/dev/null
    if [ $? -eq 0 ]; then
      echo " Stopping $app"
      systemctl stop $app
    fi
  fi
  echo ""
done

