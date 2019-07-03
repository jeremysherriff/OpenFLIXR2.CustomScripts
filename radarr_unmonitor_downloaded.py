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
h.update({ 'X-Api-Key': apikey })
h.update({ 'accept': 'application/json' })

def update(rid):
    rid = str(rid)
    url = baseurl+'/movie/'+rid
    try:
        response = requests.get(url, headers=h)
        response.raise_for_status()
        rdata = response.json()
        time.sleep(0.35)
        rdata.update({ 'monitored': False })
        url = baseurl+'/movie'
        try:
            response = requests.put(url, json=rdata, headers=h)
            response.raise_for_status()
            if arg.verbose:
                print("%s : Downloaded: %s Monitored: True -> False" % (mov['cleanTitle'], str(mov['downloaded'])))
            time.sleep(0.35)
        except requests.exceptions.RequestException as err:
            logging.error(str(err))
            exit(1)
    except requests.exceptions.RequestException as err:
        print(str(err))
        exit(1)

# OK lets do stuff
exitcode = 0
url = baseurl+'/movie'
try:
    response = requests.get(url, headers=h)
    response.raise_for_status()
    data = response.json()
    for mov in data:
        if mov['downloaded'] == True and mov['monitored'] == True:
            update(mov['id'])
except requests.exceptions.RequestException as err:
    print(str(err))
    exit(1)

