#!/bin/bash
#exec 1> >(tee -a /var/log/userscript.log) 2>&1
TODAY=$(date)
echo "-----------------------------------------------------"
echo "Date:          $TODAY"
echo "-----------------------------------------------------"

### Update custom scripts
echo Update custom scripts
cd /opt/custom
git pull

### Remove OpenFlixr's normal Lets Encrypt update
#echo Remove LetsEncrypt from cron.daily
#if [ -f /etc/cron.weekly/letsrenew.sh ]; then
#  rm /etc/cron.weekly/letsrenew.sh
#fi

### Stop all the things that shouldn't be running
echo Stop unwanted apps
/opt/custom/stop_unwanted_apps.sh

echo Run all updater scripts
chmod +x /opt/custom/updater/*
run-parts -v /opt/custom/updater

