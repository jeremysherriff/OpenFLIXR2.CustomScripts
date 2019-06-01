#!/bin/bash
CONF_BASE=/etc/monit/conf.d
SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

INI_FILE=$SCRIPT_PATH/stop_unwanted_apps.ini
DEFAULT_INI_FILE=$SCRIPT_PATH/stop_unwanted_apps.defaultini

if [[ (! -f $INI_FILE) && (-f $DEFAULT_INI_FILE) ]]; then
    cp $DEFAULT_INI_FILE $INI_FILE
fi

if [[ "$1" == "--help" || "$1" == "-?" || "$1" == "-h" ]]; then
    echo ""
    echo "  stop_unwanted_apps.sh [OPTION]"
    echo ""
    echo "  Automates service actions based on entries in $INI_FILE"
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
    exit 0
fi

if [[ "$1" == "-q" ]]; then
    VERBOSE=0
else
    VERBOSE=1
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
    ACTION=$(crudini --get $INI_FILE $s action 2>/dev/null || echo "notdefined")
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
        SERVICENAME=$(crudini --get $INI_FILE $s servicename 2>/dev/null || echo "$s")
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
        SERVICENAME=$(crudini --get $INI_FILE $s servicename 2>/dev/null || echo "$s")
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

