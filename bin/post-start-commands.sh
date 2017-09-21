#!/bin/bash

killall xscreensaver
xscreensaver -no-splash &

killall compton
compton -c -b -r 5 -l -7 -t -7

# Change key repeat rate
xset r rate 220 30
