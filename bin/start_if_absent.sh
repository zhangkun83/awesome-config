#!/bin/bash
EXEC="$1"
shift

RESULT=$(ps -u $USER | awk '{print $NF}' | fgrep "$EXEC")

if [ -z "$RESULT" ]; then
  $@ &
  echo "start_if_absent: $EXEC started"
else
  echo "start_if_absent: $EXEC already running"
fi
