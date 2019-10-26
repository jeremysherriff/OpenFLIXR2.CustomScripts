#!/usr/bin/python
import sys
import json
import requests
import argparse
import time
import syslog

syslog.syslog('Radarr missing movie search started')

parser = argparse.ArgumentParser(description='Radarr: Initiate missing movie search')
parser.add_argument(
    '-v',
    '--verbose',
    action='store_true',
    help='Monitor status until task ends'
)
args = parser.parse_args()

# Radarr server details, in URL format:
baseurl = 'http://localhost:8989/sonarr/'
apikey = '5b00a64dc14a477b84dc8fae1f994776'

h = dict()
h.update({ 'X-Api-Key': apikey })
h.update({ 'accept': 'application/json' })

d = dict()
d.update({ 'name': 'missingEpisodeSearch' })
#d.update({ 'filterKey': 'status' })
#d.update({ 'filterValue': 'released' })

url = baseurl+'api/command'
response = requests.post(url, json=d, headers=h)
if args.verbose == True:
    print('Web response: '+str(response.status_code))
    count=1

while args.verbose:
    response = requests.get(url, headers=h)
    data = response.json()
    if len(data) == 0:
        break
    for task in data:
        if count >= 4:
            print("%s : %s" % (task['name'], task['state']))
            count=0
    time.sleep(0.6666)
    count+=1

if args.verbose == True:
    print('Search task complete')
