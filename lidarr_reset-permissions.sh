#!/bin/bash

myuser=$(systemctl cat lidarr | grep User | awk -F '=' '{print $2}')
mygroup=$(systemctl cat lidarr | grep Group | awk -F '=' '{print $2}')

if [[ -z $myuser ]]
then
  echo Couldn\'t get User info, exiting
  exit 1
else
  echo User is $myuser
fi

if [[ -z $mygroup ]]
then
  echo Couldn\'t get Group info, exiting
  exit 1
else
  echo Group is $mygroup
fi

echo Resetting owner for /opt/Lidarr
chown -R $myuser:$mygroup /opt/Lidarr
echo Resetting owner for /home/openflixr/.config/Lidarr
chown -R $myuser:$mygroup /home/openflixr/.config/Lidarr
echo Resetting permissions for /home/openflixr/.config/Lidarr
chmod -R 777 /home/openflixr/.config/Lidarr

