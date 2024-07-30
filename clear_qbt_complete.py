#!/usr/bin/python

import sys
import json
import requests
import logging
import argparse

parser=argparse.ArgumentParser()
parser.add_argument('-c','--category', help='Torrent category to clear.\n If not specified, all torrents are cleared.\n Use \"nocategory\" for torrents with no category assigned.')
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
category = 'everything'
baseurl = 'http://localhost:8080/'

consoleHandler = logging.StreamHandler(sys.stdout)
consoleHandler.setFormatter(logFormatter)
rootLogger.addHandler(consoleHandler)
rootLogger.setLevel(logging.ERROR)

if args.verbose or args.debug:
    debugmode = True
    rootLogger.setLevel(logging.DEBUG)
if args.debug:
    testmode = True
if args.category:
    category = args.category
if args.baseurl:
    baseurl = args.baseurl

logging.debug('category is '+category)
logging.debug('baseurl is '+baseurl)

if category == 'nocategory' :
    category = ''

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
            logging.debug('Skipping torrent with state '+tor['state']+': '+tor['name'])
            continue

        if tor['category'] == '' :
            cat_name = '(empty)'
        else :
            cat_name = tor['category']

        if category != 'everything' and tor['category'] != category :
            logging.debug('Skipping torrent with category '+cat_name+': '+tor['name'])
            continue

        # Torrents handled via the *arrs can have data deleted, otherwise preserve torrent content
        if tor['category'][-3:] == "arr" :
            form_data = { 'hashes': str(tor['hash']), 'deleteFiles':'true' }
            logging.debug('Planning to clear torrent and data: '+tor['name'])
        else :
            form_data = { 'hashes': str(tor['hash']), 'deleteFiles':'false' }
            logging.debug('Planning to clear torrent but leave data: '+tor['name'])

        url = 'api/v2/torrents/delete'
        logging.info('Clearing '+tor['state']+' torrent with category '+cat_name+': '+tor['name'])
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

