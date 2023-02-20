#!/usr/bin/python

import sys
import json
import requests
import logging
import argparse

parser=argparse.ArgumentParser()
parser.add_argument('-b','--baseurl', help='Override url to qBitTorrent. Defaults to http://localhost:8080/')
parser.add_argument('-v','--verbose', action="store_true", help='Verbose output for debug')
parser.add_argument('-d','--debug', action="store_true", help='Do not action. Implies -v')
args=parser.parse_args()

# Set up logging - kinda important when deleting stuff!
logFormatter = logging.Formatter("%(asctime)s [%(levelname)-5.5s] %(message)s")
rootLogger = logging.getLogger()
fileHandler = logging.FileHandler("/var/log/clear_qbt_complete.log")
fileHandler.setFormatter(logFormatter)
rootLogger.addHandler(fileHandler)
rootLogger.setLevel(logging.INFO)

debugmode = False
testmode = False
baseurl = 'http://localhost:8080/'
if args.verbose or args.debug:
    debugmode = True
    consoleHandler = logging.StreamHandler(sys.stdout)
    consoleHandler.setFormatter(logFormatter)
    rootLogger.addHandler(consoleHandler)
    rootLogger.setLevel(logging.DEBUG)
if args.debug:
    testmode = True
if args.baseurl:
    baseurl = args.baseurl

logging.debug('baseurl is '+baseurl)

# OK lets do stuff
exitcode = 0
url = 'api/v2/torrents/info?filter=completed'
try:
    response = requests.get(baseurl+url)
    response.raise_for_status()
    data = response.json()
    # Observed status for torrents in 'completed' filter:
    #  uploading - seeding
    #  stalledUP - seeding but stalled
    # >pausedUP  - seeding and manually paused
    #            - seeding and ratio reached but seeding time still to go

    if len(data) == 0:
        logging.debug('No completed torrents to clear')
        if debugmode:
            print('')
        exit(0)
    for tor in data:
        if tor['state'] != 'pausedUP':
            logging.debug('Skipping '+tor['state']+' torrent: '+tor['name'])
            continue
        if tor['category'] == 'radarr' or tor['category'] == 'sonarr' :
            form_data = { 'hashes': str(tor['hash']), 'deleteFiles':'true' }
        else :
            form_data = { 'hashes': str(tor['hash']), 'deleteFiles':'false' }
        url = 'api/v2/torrents/delete'
        logging.info('Clearing '+tor['state']+' torrent: '+tor['name'])
        if not testmode:
            try:
                response = requests.post(baseurl+url,data=form_data)
                response.raise_for_status()
            except requests.exceptions.RequestException as err:
                logging.error(str(err))
                exitcode = 1
    logging.debug('Exiting normally with code '+str(exitcode))
    if debugmode == 1:
        print('')
    exit(exitcode)
except requests.exceptions.RequestException as err:
    logging.error(str(err))
    if debugmode == 1:
        print('')
    exit(1)

