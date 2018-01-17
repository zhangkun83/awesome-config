#!/bin/bash

killall xscreensaver
xscreensaver -no-splash &

killall compton
compton -c -b -r 3 -l -5 -t -5 --backend glx --glx-no-stencil --glx-no-rebind-pixmap

# Change key repeat rate
xset r rate 220 30

killall urxvtd
urxvtd -q -o -f
