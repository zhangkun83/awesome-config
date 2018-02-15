#!/bin/bash
#Restart awesome from outside of X11

export DISPLAY=:0
source ~/.dbus/session-bus/$(cat /var/lib/dbus/machine-id)-0
export DBUS_SESSION_BUS_ADDRESS
export DBUS_SESSION_BUS_PID
export DBUS_SESSION_BUS_WINDOWID
echo "awesome.restart()" | awesome-client
