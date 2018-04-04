#!/bin/bash
EXEC="$1"
shift

RESULT=$(ps -u $USER -o command | grep -F "$EXEC" | grep -v '\(^grep \)\|\(start_if_absent\.sh \)')

if [ -z "$RESULT" ]; then
  $@ &
  echo "start_if_absent: $EXEC started"
else
  echo "start_if_absent: $EXEC already running"
fi
