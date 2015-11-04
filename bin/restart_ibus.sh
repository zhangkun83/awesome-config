#!/bin/bash
killall ibus-daemon &> /dev/null
sleep 5
ibus-daemon -d
echo "naughty.notify({text = \"<b>ibus-daemon</b> (re)started\"})" | awesome-client
