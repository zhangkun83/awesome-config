#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

killall xscreensaver
xscreensaver -no-splash &

#killall compton
#compton -c -b -r 3 -l -5 -t -5 --backend glx --glx-no-stencil --glx-no-rebind-pixmap

# Change key repeat rate
xset r rate 220 30

$DIR/start_if_absent.sh urxvtd urxvtd -q -o -f
