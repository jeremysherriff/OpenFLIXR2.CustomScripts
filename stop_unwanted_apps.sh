#!/bin/bash
CONF_BASE=/etc/monit/conf.d
INIFILE=~root/stop_unwanted_apps.ini

if [[ "$1" == "--help" || "$1" == "-?" || "$1" == "-h" ]]; then
    echo ""
    echo "  stop_unwanted_apps.sh [OPTION]"
    echo ""
    echo "  Automates service actions based on entries in $INIFILE"
    echo "  Services are those defined in Monit service files in $CONF_BASE"
    echo "      -?     : This help"
    echo "      -l     : List out all the Monit services detected on this system"
    echo "      -q     : Quiet"
    echo ""
    echo "  Only one option can be specified due to my poor coding skills :)"
    echo ""
    exit 1
fi

if [[ ! -d $CONF_BASE ]]; then
    echo ""
    echo "ERROR: Monit config files not found in expected location: $CONF_BASE"
    echo ""
    exit 1
fi

if [[ "$1" == "-l" ]]; then
    echo ""
    echo "Listing Monit service definitions in $CONF_BASE:"
    cd $CONF_BASE
    for s in *; do
        echo "  $s"
    done
    echo ""
    exit 2
fi

if [[ "$1" == "-q" ]]; then
    VERBOSE=0
else
    VERBOSE=1
fi

if [[ ! -f $INIFILE ]]; then
    echo ""
    echo "$INIFILE does not exist - Creating with defaults"
    echo ""
    cat << EOF >$INIFILE
# Actions should be one of;
#  start       Start service now
#  autostart   Start service and set to start on boot
#  stop        Stop service now
#  disable     Stop service now, and disable start-on-boot
#  ignore      Leave service as-is

# Any other action word, or not specifying an action, ignores the service and skips any action.
# Similarly, any Monit service without a section is ignored.

# If the Monit definition file has a different name to the formal systemctl service,
# use the servicename directive to override it.

# Example:
# [syncthing]
# action=disable
# servicename=syncthing@openflixr

EOF

    cd $CONF_BASE
    for s in *; do
        if [[ "$s" == "localhost" || "$s" == "nfs" || "$s" == "ssh" || "$s" == "cron" || "$s" == "ntp" || "$s" == "_localsetup" ]]; then
            echo "    Skipping $s as it is a system component"
            continue
        fi
        echo "    Adding $s"
        echo "[$s]">>$INIFILE
        echo "action=ignore">>$INIFILE
        case $s in
          hass)
            echo "servicename=home-assistant">>$INIFILE
            ;;
          sabnzbd)
            echo "servicename=sabnzbdplus">>$INIFILE
            ;;
          syncthing)
            echo "servicename=syncthing@openflixr">>$INIFILE
            ;;
          nzbhydra)
            echo "servicename=nzbhydra2">>$INIFILE
            ;;
          pihole)
            echo "servicename=pihole-FTL">>$INIFILE
            ;;
          plexms)
            echo "servicename=plexmediaserver">>$INIFILE
            ;;
          utserver)
            echo "servicename=utorrent-server">>$INIFILE
            ;;
        esac
        echo "">>$INIFILE
    done
    echo ""
    echo "*****************************************************************"
    echo "Created default ini at $INIFILE"
    echo "All actions have been set to 'ignore' initially."
    echo "Please review and edit this file before running the script again."
    echo "*****************************************************************"
    echo ""
    exit 2
fi

debug () {
  if [[ $VERBOSE == 1 ]]; then
    echo "$*"
  fi
}

exec 1> >(tee -a /var/log/stop_unwanted_apps.log) 2>&1
TODAY=$(date)
debug "-----------------------------------------------------"
debug "Date:          $TODAY"
debug "-----------------------------------------------------"

cd $CONF_BASE
for s in *; do
    debug "Evaluating Monit service $s:"
    ACTION=$(crudini --get $INIFILE $s action 2>/dev/null || echo "notdefined")
    debug "  Requested action is $ACTION"

    case $ACTION in 
      start)
        debug "    Actioning 'monit start' on $s"
        monit start $s
        debug ""
      ;;
      stop)
        debug "    Actioning 'monit stop' on $s"
        monit stop $s
        debug ""
      ;;
      autostart)
        debug "    Actioning 'monit start' on $s"
        monit start $s
        SERVICENAME=$(crudini --get $INIFILE $s servicename 2>/dev/null || echo "$s")
        if [[ "$SERVICENAME" != "$s" ]]; then
            debug "  Overriding service name as $SERVICENAME"
        fi
        debug "    Actioning 'systemctl enable' on $SERVICENAME"
        systemctl enable $SERVICENAME 2>/dev/null
        debug ""
      ;;
      disable)
        debug "    Actioning 'monit stop' on $s"
        monit stop $s
        SERVICENAME=$(crudini --get $INIFILE $s servicename 2>/dev/null || echo "$s")
        if [[ "$SERVICENAME" != "$s" ]]; then
            debug "  Overriding service name as $SERVICENAME"
        fi
        debug "    Actioning 'systemctl disable' on $SERVICENAME"
        systemctl disable $SERVICENAME 2>/dev/null
        debug ""
      ;;
      *)
        debug "    Ignoring definition $s"
        debug ""
      ;;
    esac
done

