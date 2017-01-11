#!/bin/bash
which xbacklight > /dev/null
if [ $? -ne 0 ]; then
  echo "naughty.notify({ preset = naughty.config.presets.critical,"\
    "  text = \"xbacklight not installed\"})" | awesome-client
  exit 1
fi

if [ "$1" == "up" ]; then
  xbacklight +10
elif [ "$1" == "down" ]; then
  xbacklight -10
fi

current_level=$(xbacklight)
current_level=$(sed -e 's/\..*$//g' <<< "$current_level")
message="backlight: $current_level%"

echo "naughty.destroy(backlightnotification)" | awesome-client
echo "backlightnotification = naughty.notify({"\
  "text = \"$message\","\
  "position = \"bottom_right\"})" |\
  awesome-client
