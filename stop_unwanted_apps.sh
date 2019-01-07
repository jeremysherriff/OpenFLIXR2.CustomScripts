#!/bin/bash
exec 1> >(tee -a /var/log/userscript.log) 2>&1
TODAY=$(date)
echo "-----------------------------------------------------"
echo "Date:          $TODAY"
echo "-----------------------------------------------------"

# Remove OpenFlixr's normal Lets Encrypt update
if [ -f /etc/cron.weekly/letsrenew.sh ]; then
  rm /etc/cron.weekly/letsrenew.sh
fi

# Stop all the things that don't normally auto-start, as @MediaJunkie is a bit aggressive
# starting everything whether we want it or not.
echo ""
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

# Self-installed package updates
echo "SSL Cert Check:"
cd /opt/ssl-cert-check
git reset --hard
git pull
echo ""
 
chmod +x /home/openflixr/scripts/module-updates/*
run-parts -v /home/openflixr/scripts/module-updates

