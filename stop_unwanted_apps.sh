#!/bin/bash
exec 1> >(tee -a /var/log/stop_unwanted_apps.log) 2>&1
TODAY=$(date)
echo "-----------------------------------------------------"
echo "Date:          $TODAY"
echo "-----------------------------------------------------"

# Stop all the things that don't normally auto-start, as @MediaJunkie is a bit aggressive
# starting everything whether we want it or not.
EXTRAS="sickchill lazylibrarian syncthing couchpotato headphones autosub lidarr mylar homeassistant nzbget qbittorrent ubooquity nzbhydra sabnzbd mopidy"
# EXTRAS="monit sickchill lazylibrarian syncthing@openflixr couchpotato headphones autosub lidarr mylar home-assistant nzbget qbittorrent ubooquity"
for app in $EXTRAS; do
  echo -e "Checking $app.. "
  monit status $app | grep "monitoring status" | grep "Not monitored"
  if [ $? -ne 0 ]; then
      echo " Stopping $app"
      monit stop $app
  fi
  echo ""
done

