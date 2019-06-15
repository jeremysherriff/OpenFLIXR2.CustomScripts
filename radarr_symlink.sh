#!/bin/bash

# Special processing script for Radarr, to allow torrents to
# continue seeding after import.
# Should be set to fire on Download and Upgrade (but not on rename)

LOGPATH="/var/log/radarr_symlink.log" # May need altering if using a docker container
exec 1> >(tee -a $LOGPATH) 2>&1

PERMPATH="$radarr_moviefile_path"
LINKPATH="$radarr_moviefile_sourcepath"

echo `date "+%Y%m%d-%H%M%S"` "Special processing starting:" "$PERMPATH" "to" "$LINKPATH"

if [[ -f "$LINKPATH" ]]; then
    sleep 1
else
    echo `date "+%Y%m%d-%H%M%S"` "$LINKPATH" "does not exist, exiting"
    exit 1
fi

ORIGFILESIZE=$(stat -c%s "$LINKPATH")
echo `date "+%Y%m%d-%H%M%S"` "ORIGFILESIZE is $ORIGFILESIZE"
PERMFILESIZE=$(stat -c%s "$PERMPATH")

while [[ $PERMFILESIZE != $ORIGFILESIZE ]]; do
#    echo `date "+%Y%m%d-%H%M%S"` "Still waiting for PERMFILESIZE ($PERMFILESIZE) to match ORIGFILESIZE ($ORIGFILESIZE)"
    sleep 2
    PERMFILESIZE=$(stat -c%s "$PERMPATH")
done
echo `date "+%Y%m%d-%H%M%S"` "File sizes match, post-processing appears complete"
sleep 2

if [[ $PERMFILESIZE == $ORIGFILESIZE ]]; then
    echo `date "+%Y%m%d-%H%M%S"` "Removing source file" "$LINKPATH"
    rm "$LINKPATH"
    echo `date "+%Y%m%d-%H%M%S"` "Symlinking dest file" "$PERMPATH" "to" "$LINKPATH"
    ln -s "$PERMPATH" "$LINKPATH"
fi
echo `date "+%Y%m%d-%H%M%S"` "Special processing complete for" "$PERMPATH"

