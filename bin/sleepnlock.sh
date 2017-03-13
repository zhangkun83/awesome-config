#!/bin/bash
xscreensaver-command -lock
sleep 2
dbus-send --system --print-reply --dest="org.freedesktop.UPower" \
          /org/freedesktop/UPower org.freedesktop.UPower.Suspend
