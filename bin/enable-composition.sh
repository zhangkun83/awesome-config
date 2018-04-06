#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

$DIR/start_if_absent.sh compton compton -c -b -r 3 -l -5 -t -5 --backend xrender
