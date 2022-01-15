#!/bin/bash

# Special processing script for Radarr, to allow torrents to
# continue seeding after import.
# Should be set to fire on Download and Upgrade (but not on rename)

LOGPATH="/var/log/radarr/copy_subs.log" # May need altering if using a docker container
exec 1> >(tee -a $LOGPATH) 2>&1
RID="$radarr_movie_id"

# RID="TESTING"
# radarr_movie_path="/volume1/Downloads2/Movies/No Time to Die (2021)"
# radarr_moviefile_path="/volume1/Downloads2/Movies/No Time to Die (2021)/No Time to Die (2021).mp4"
# radarr_moviefile_relativepath="No Time to Die (2021).mp4"
# radarr_moviefile_sourcepath="/volume1/temp/mediabox/scratch/torrentcomplete/radarr/No.Time.To.Die.2021.1080p.WEBRip.x264-RARBG/No.Time.To.Die.2021.1080p.WEBRip.x264-RARBG.mp4"
# radarr_moviefile_sourcefolder="/volume1/temp/mediabox/scratch/torrentcomplete/radarr/No.Time.To.Die.2021.1080p.WEBRip.x264-RARBG"

echo `date "+%Y%m%d-%H%M%S"` "-----------------------------------------------"
echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "Subtitle copying starting for" "$radarr_movie_title"
echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "radarr_eventtype     :" "$radarr_eventtype"
echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "radarr_isupgrade     :" "$radarr_isupgrade"
echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "radarr_download_id   :" "$radarr_download_id"
echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "radarr_moviefile_id  :" "$radarr_moviefile_id"
echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "radarr_movie_path    :" "$radarr_movie_path"
echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "radarr_moviefile_path:" "$radarr_moviefile_path"
echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "radarr_moviefile_relativepath"
echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "                     :" "$radarr_moviefile_relativepath"
echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "radarr_moviefile_sourcepath"
echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "                     :" "$radarr_moviefile_sourcepath"
echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "radarr_moviefile_sourcefolder"
echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "                     :" "$radarr_moviefile_sourcefolder"

if [[ "$radarr_eventtype" == "Test" ]]; then
	echo `date "+%Y%m%d-%H%M%S"` "Test mode - exit with success"
	exit 0
fi

SUBS=0
if [[ -d "${radarr_moviefile_sourcefolder}/subs" ]]; then
    SUBS=1
    SUBPATH="${radarr_moviefile_sourcefolder}/subs"
fi
if [[ -d "${radarr_moviefile_sourcefolder}/Subs" ]]; then
    SUBS=1
    SUBPATH="${radarr_moviefile_sourcefolder}/Subs"
fi

if [[ $SUBS != 1 ]]; then
	echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "Subs folder not found."
	exit 0
fi

echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "Subs folder exists at $SUBPATH"
BASENAME=`echo "${radarr_moviefile_relativepath%.*}"`

echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "Subs folder directory listing:"
ls -l "$SUBPATH/"

# 2 = English
# 3 = English Hearing-Impaired [HI/SDH]
# 4 = English Foreign-only/forced
# We only really care about the forced subs (#4 in RARBG folders)
if [[ -f "$SUBPATH/4_English.srt" ]]; then
	echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "Found English Forced subs"
	echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "Copying $SUBPATH/4_English.srt to $radarr_movie_path/${BASENAME}.en.forced.srt"
	cp "$SUBPATH/4_English.srt" "$radarr_movie_path/${BASENAME}.en.forced.srt"
fi
# Take the standard English stuff as well, as these "included" subs will be better than anything we download
# and might be needed if the Forced subs were not included.
# Fall back to the Hearing Impaired subs if the standard English ones aren't there.
if [[ -f "$SUBPATH/2_English.srt" ]]; then
	echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "Found English subs"
	echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "Copying $SUBPATH/2_English.srt to $radarr_movie_path/${BASENAME}.en.srt"
	cp "$SUBPATH/2_English.srt" "$radarr_movie_path/${BASENAME}.en.srt"
elif [[ -f "$SUBPATH/3_English.srt" ]]; then
	echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "Found English (Hearing-Impaired) subs"
	echo `date "+%Y%m%d-%H%M%S"` "[$RID]" "Copying $SUBPATH/3_English.srt to $radarr_movie_path/${BASENAME}.en.sdh.srt"
	cp "$SUBPATH/3_English.srt" "$radarr_movie_path/${BASENAME}.en.sdh.srt"
fi

