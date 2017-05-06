#!/bin/bash
get_status() {
  declare -a status=($(pulseaudio-ctl full-status))
  level=${status[0]}
  sink_muted=${status[1]}
  source_muted=${status[2]}
}

unmute() {
  if [ "$sink_muted" == "yes" ]; then
    pulseaudio-ctl mute
  fi
}

get_status

if [ "$1" == "up" ]; then
  pulseaudio-ctl up
  unmute
elif [ "$1" == "down" ]; then
  pulseaudio-ctl down
  unmute
elif [ "$1" == "mute" ]; then
  pulseaudio-ctl mute
fi

get_status

if [ "$sink_muted" == "yes" ]; then
  message="audio: <b>muted</b>"
else
  message="volume: <b>${level}%</b>"
fi

echo "volumenotification = zk.notify(\"$message\", volumenotification)" | awesome-client
