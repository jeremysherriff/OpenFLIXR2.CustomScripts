#!/bin/bash
CEILING=3072000

LOGFILE=/var/log/memoryhog.log
if [[ "$1" == "-v" || "$1" == "--verbose" ]]; then
    MYDEBUG=1
fi

function info () {
    if [[ -n $MYDEBUG ]]; then echo $1; fi
    echo `date "+%F %r"` [Jackett] $1>> $LOGFILE
}

RAM=$(ps -aux | grep -i jackett | grep -v grep | grep -v memoryhog | awk '{print $5}')

if [[ -n $MYDEBUG ]]; then info "RAM usage is at $RAM bytes"; fi

if [[ -n $RAM ]]; then
    if [[ $RAM -gt $CEILING ]]; then
        if [[ -n $MYDEBUG ]]; then echo "RAM usage is above ceiling, restarting service"; fi
        systemctl try-reload-or-restart jackett
    else
        if [[ -n $MYDEBUG ]]; then info "RAM usage is fine"; fi
    fi
else
    if [[ -n $MYDEBUG ]]; then info "Could not compute RAM usage, is service running?"; fi
fi

