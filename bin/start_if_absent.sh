#!/bin/bash
EXEC=$1
COMMAND=$2

RESULT=$(ps -u $USER | awk '{print $NF}' | fgrep "$1")

if [ -z "$RESULT" ]; then
  $2 &
  echo "naughty.notify({text = \"<b>$2</b> started\", timeout = 30})" | awesome-client
else
  echo "naughty.notify({text = \"<b>$2</b> already running\", timeout = 30})" | awesome-client
fi
