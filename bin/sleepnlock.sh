#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
"$DIR/lock.sh" &
sleep 2
systemctl suspend -i
