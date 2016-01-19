#!/bin/bash
# -x is needed to work in Emacs
ibus-daemon -drx
echo "naughty.notify({text = \"<b>ibus-daemon</b> (re)started\"})" | awesome-client
