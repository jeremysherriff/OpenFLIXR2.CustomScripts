#!/bin/bash

if [[ "$1" == "-v" || "$1" == "--verbose" ]]; then
    MYDEBUG=1
fi

CEILING=3072000
RAM=$(ps -aux | grep -i jackett | grep -v grep | grep -v memoryhog | awk '{print $5}')

if [[ -n $MYDEBUG ]]; then echo "RAM usage is at $RAM bytes"; fi

if [[ -n $RAM ]]; then
    if [[ $RAM -gt $CEILING ]]; then
        if [[ -n $MYDEBUG ]]; then echo "RAM usage is above ceiling, restarting service"; fi
        systemctl restart jackett
    else
        if [[ -n $MYDEBUG ]]; then echo "RAM usage is fine"; fi
    fi
else
    if [[ -n $MYDEBUG ]]; then echo "Could not compute RAM usage, is service running?"; fi
fi

