#!/bin/bash
# Put laptop to sleep if the lid is closed
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
while :
do
    if [[ "$(cat /proc/acpi/button/lid/LID/state)" == *closed* ]] ; then
        "$DIR"/sleepnlock.sh
    fi
    sleep 5
done
