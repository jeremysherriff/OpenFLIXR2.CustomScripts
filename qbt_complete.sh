#!/bin/bash

# Check if two parameters are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <param1> <param2>" &2
    echo "  param1 = %N: Torrent name"
    echo "  param2 = %L: Category"
    exit 1
fi

# Assign the parameters to variables
param1="$1" # %N Torrent Name
param2="$2" # %L Category

sleep 1

if [[ "$param2" == "smut" ]]; then
    echo "Triggering Plex library rescan for Library 8" >2
    curl --no-progress-meter http://192.168.220.24:32400/library/sections/8/refresh?X-Plex-Token=myBPhC8zHrJeg9HsnaRh
fi

if [[ "$param2" == "adult" ]]; then
    echo "Triggering Plex library rescan for Library 7" >2
    curl --no-progress-meter http://192.168.220.24:32400/library/sections/7/refresh?X-Plex-Token=myBPhC8zHrJeg9HsnaRh
fi

