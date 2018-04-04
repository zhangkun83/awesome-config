#!/bin/bash
# Lock the screen when idle
IDLE_TIME_MS=300000
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
while :
do
    if [[ "$(xprintidle)" -gt $IDLE_TIME_MS ]] ; then
        "$DIR"/lock.sh
    fi
    sleep 10
done
