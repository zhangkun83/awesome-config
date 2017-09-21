#!/bin/bash

killall xscreensaver
xscreensaver -no-splash &

killall compton
compton -c -C -b -r 4 -l -2 -t -2

# Change key repeat rate
xset r rate 220 30
