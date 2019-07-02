#!/bin/bash

# Special processing script for Radarr, to allow torrents to
# continue seeding after import.
# Should be set to fire on Download and Upgrade (but not on rename)

LOGPATH="/var/log/radarr/symlink.log" # May need altering if using a docker container
exec 1> >(tee -a $LOGPATH) 2>&1

PERMPATH="$radarr_moviefile_path"
LINKPATH="$radarr_moviefile_sourcepath"
RID="$radarr_movie_id"

echo `date "+%Y%m%d-%H%M%S"` "-----------------------------------------------"
echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "Special processing starting for" "$radarr_movie_title"
echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "radarr_eventtype     :" "$radarr_eventtype"
echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "radarr_isupgrade     :" "$radarr_isupgrade"
echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "radarr_moviefile_id  :" "$radarr_moviefile_id"
echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "radarr_movie_path    :" "$radarr_movie_path"
echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "radarr_moviefile_path:" "$radarr_moviefile_path"
echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "radarr_moviefile_relativepath"
echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "                     :" "$radarr_moviefile_relativepath"
echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "radarr_moviefile_sourcepath"
echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "                     :" "$radarr_moviefile_sourcepath"
echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "radarr_moviefile_sourcefolder"
echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "                     :" "$radarr_moviefile_sourcefolder"

#Debug: Are we too quick?
sleep 2

if [[ -f "$LINKPATH" ]]; then
    sleep 1
else
    echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "$LINKPATH" "does not exist, exiting"
    echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "Grabbing some troubleshooting info:"
    echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "TorrentComplete dir:"
    ls -al "/mnt/downloads/torrentcomplete/radarr/"
    echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "Source dir:"
    ls -al "$LINKPATH"
    echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "Destination dir:"
    ls -al "$PERMPATH"
    exit 1
fi

ORIGFILESIZE=$(stat -c%s "$LINKPATH")
PERMFILESIZE=$(stat -c%s "$PERMPATH")
echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "ORIGFILESIZE: $ORIGFILESIZE"
echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "PERMFILESIZE: $PERMFILESIZE"

COUNT=0
while [[ $PERMFILESIZE != $ORIGFILESIZE ]]; do
    sleep 2
    PERMFILESIZE=$(stat -c%s "$PERMPATH")
    echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "PERMFILESIZE: $PERMFILESIZE"
done
echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "File sizes match, post-processing appears complete"
sleep 1

if [[ $PERMFILESIZE == $ORIGFILESIZE ]]; then
    echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "Removing source file" "$LINKPATH"
    rm "$LINKPATH"
    echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "Running command: ln -s" \'"$PERMPATH"\' \'"$LINKPATH"\'
    ln -s "$PERMPATH" "$LINKPATH"
fi
echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "Special processing complete for" "$radarr_movie_title"

