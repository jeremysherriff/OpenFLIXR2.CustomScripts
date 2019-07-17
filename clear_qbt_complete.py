#!/usr/bin/python
import sys
import json
import requests
import logging
import argparse

# Set up logging - kinda important when deleting stuff!
logFormatter = logging.Formatter("%(asctime)s [%(levelname)-5.5s] %(message)s")
rootLogger = logging.getLogger()
fileHandler = logging.FileHandler("/var/log/clear_qbt_complete.log")
fileHandler.setFormatter(logFormatter)
rootLogger.addHandler(fileHandler)
rootLogger.setLevel(logging.INFO)
debugmode = 0
if len(sys.argv) > 1 and ( str(sys.argv[1]) == '-v' or str(sys.argv[1]) == '--verbose' ):
    consoleHandler = logging.StreamHandler(sys.stdout)
    consoleHandler.setFormatter(logFormatter)
    rootLogger.addHandler(consoleHandler)
    rootLogger.setLevel(logging.DEBUG)
    debugmode = 1

testmode = 0
if len(sys.argv) > 1 and ( str(sys.argv[1]) == '-t' or str(sys.argv[1]) == '--test' ):
    consoleHandler = logging.StreamHandler(sys.stdout)
    consoleHandler.setFormatter(logFormatter)
    rootLogger.addHandler(consoleHandler)
    rootLogger.setLevel(logging.DEBUG)
    debugmode = 1
    testmode = 1

if len(sys.argv) > 1 and ( str(sys.argv[1]) == '-?' or str(sys.argv[1]) == '--help' ):
    print('clear_qbt_complete.py [option]')
    print('  Clears "Completed" status torrents from qBitTorrent')
    print('  Connects to "localhost:8080" without credentials')
    print('  Logs output to /var/log/clear_qbt_complete.log')
    print('  By default logs nothing to stdout/stderr to allow use in cron')
    print('')
    print('  Options:')
    print('    -v --verbose : to enable console logging in addition to logfile')
    print('    -t --test    : for test mode (no delete) - implies -v')
    print('')
    exit(0)

if len(sys.argv) > 1 and ( debugmode == 0 ):
    print('clear_qbt_complete.py: Invalid option "'+str(sys.argv[1])+'"')
    exit(1)

if len(sys.argv) > 2:
    print('clear_qbt_complete.py: Invalid option "'+str(sys.argv[2])+'"')
    exit(1)

# qBitTorrent server details, in URL format:
baseurl = 'http://localhost:8080'

# OK lets do stuff
exitcode = 0
url = '/query/torrents?filter=completed'
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
        if debugmode == 1:
            print('')
        exit(0)
    for tor in data:
        if tor['category'] != 'radarr' and tor['category'] != 'sonarr':
            logging.debug('Skipping '+tor['category']+' torrent: '+tor['name'])
            continue
        if tor['state'] != 'pausedUP':
            logging.debug('Skipping '+tor['state']+' torrent: '+tor['name'])
            continue
        logging.info('Clearing '+tor['state']+' torrent: '+tor['name'])
        payload = {'hashes': tor['hash']}
        url = '/command/deletePerm'
        if testmode == 0:
            try:
                response = requests.post(baseurl+url,data=payload)
                response.raise_for_status()
                logging.debug('POST data: '+str(payload))
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

