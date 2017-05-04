#!/bin/bash

get_current_engine() {
  current_engine=$(ibus engine) || exit 1
  if [ -z "$current_engine" ]; then
    exit 1
  fi
  echo $current_engine
}

declare -a ENGINES=('xkb:us::eng' 'pinyin')
declare -a ENGINE_SYMBOLS=('英' '拼')
NUM_ENGINES=${#ENGINES[@]}
let LAST_INDEX=NUM_ENGINES-1

function get_current_index() {
  local index=0
  local current_engine=$(get_current_engine)
  while [[ $index -lt $LAST_INDEX ]]; do
    if [[ "$current_engine" == ${ENGINES[$index]} ]]; then
      break
    fi
    let index+=1
  done
  echo $index
}

if [ "$#" -lt 1 ]; then
  INDEX=$(get_current_index)
  let INDEX+=1
  if [ $INDEX -gt $LAST_INDEX ]; then
    INDEX=0
  fi
else
  INDEX=$1
fi

ibus engine ${ENGINES[$INDEX]}
current_index=$(get_current_index) || exit 1
echo "myibusbox:set_text(\"${ENGINE_SYMBOLS[$current_index]}\")" | awesome-client
