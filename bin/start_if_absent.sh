#!/bin/bash
EXEC=$1
COMMAND=$2

RESULT=$(ps -u $USER | awk '{print $NF}' | fgrep "$1")

if [ -z "$RESULT" ]; then
  $2 &
fi
