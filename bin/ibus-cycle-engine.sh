#!/bin/bash

get_current_engine() {
  current_engine=$(ibus engine) ||\
    (echo "naughty.notify({ preset = naughty.config.presets.critical,"\
    "  text = \"Failed to query ibus engine\"})" | awesome-client)
  if [ -z "$current_engine" ]; then
    exit 1
  fi
  echo $current_engine
}

declare -a ENGINES=('xkb:us::eng' 'pinyin')
NUM_ENGINES=${#ENGINES[@]}
CURRENT_ENGINE=$(get_current_engine) || exit 1

let LAST_INDEX=NUM_ENGINES-1
INDEX=0
while [ $INDEX -lt $LAST_INDEX ]; do
  if [ "$CURRENT_ENGINE" == ${ENGINES[$INDEX]} ]; then
    break
  fi
  let INDEX+=1
done
let INDEX+=1
if [ $INDEX -gt $LAST_INDEX ]; then
  INDEX=0
fi

ibus engine ${ENGINES[$INDEX]}
CURRENT_ENGINE=$(get_current_engine) || exit 1
echo "naughty.notify({text = \"ibus: <b>$CURRENT_ENGINE</b>\","\
  "position = \"bottom_right\", timeout = 1})" |\
  awesome-client
