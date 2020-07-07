#!/usr/bin/python

import sys
import argparse
import json
import requests
import time
import syslog

parser = argparse.ArgumentParser(description='Radarr: Mark downloaded media as UnMonitored')
parser.add_argument(
    '-v',
    '--verbose',
    action='store_true',
    help='Show progress. Output is normally silent for crontab usage.'
)
arg = parser.parse_args()

syslog.syslog('Radarr unmonitor switch for downloaded content has started')
if arg.verbose:
    print('Radarr unmonitor switch for downloaded content has started')

# Radarr server details, in URL format:
baseurl = 'http://localhost:7878/radarr/api'
apikey = '7adac404150c46e79263df70e31d7ad2'

h = dict()
#h.update({ 'X-Api-Key': apikey })
h.update({ 'accept': 'application/json' })

def unmonitor(rid):
    rid = str(rid)
    url = baseurl+'/movie/'+rid+'?apikey='+apikey
    try:
        if arg.verbose:
            print("      Getting movie data with url %s" % url)
        response = requests.get(url, headers=h)
        response.raise_for_status()
        rdata = response.json()
        time.sleep(0.2)
        rdata.update({ 'monitored': False })
        url = baseurl+'/movie/'+rid+'?apikey='+apikey
        try:
            if arg.verbose:
                print("      Updating movie data with url %s" % url)
            response = requests.put(url, json=rdata, headers=h)
            response.raise_for_status()
            if arg.verbose:
                print("      %s : Downloaded: %s Monitored: True -> False" % (mov['cleanTitle'], str(mov['downloaded'])))
            time.sleep(0.2)
        except requests.exceptions.RequestException as err:
            print(str(err))
            syslog.syslog("Updating movie data with url %s" % url)
            syslog.syslog('ERROR: '+str(err))
            syslog.syslog('ERROR: Check Radarr logs for more info')
            #exit(1)
    except requests.exceptions.RequestException as err:
        print(str(err))
        syslog.syslog("Getting movie data with url %s" % url)
        syslog.syslog('ERROR: '+str(err))
        #exit(1)

# OK lets do stuff
exitcode = 0
url = baseurl+'/movie'+'?apikey='+apikey
try:
    if arg.verbose:
        print("Getting movie list with url %s" % url)
    response = requests.get(url, headers=h)
    response.raise_for_status()
    data = response.json()
    for mov in data:
        if mov['downloaded'] == True and mov['monitored'] == True:
            if arg.verbose:
                print("    Unmonitoring %s" % mov['cleanTitle'])
            unmonitor(mov['id'])
except requests.exceptions.RequestException as err:
    print(str(err))
    syslog.syslog("Getting movie list with url %s" % url)
    syslog.syslog('FATAL: '+str(err))
    exit(1)

