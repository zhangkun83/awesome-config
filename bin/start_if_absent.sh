#!/bin/bash
EXEC=$1
COMMAND=$2

RESULT=$(ps -u $USER | awk '{print $NF}' | fgrep "$1")

if [ -z "$RESULT" ]; then
  $2 &
  echo "naughty.notify({text = \"<b>$2</b> started\"})" | awesome-client
else
  echo "naughty.notify({text = \"<b>$2</b> already running\"})" | awesome-client
fi
