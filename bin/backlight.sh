#!/bin/bash
if [ "$1" == "up" ]; then
  xbacklight +10
elif [ "$1" == "down" ]; then
  xbacklight -10
fi

current_level=$(xbacklight)
current_level=$(sed -e 's/\..*$//g' <<< "$current_level")
message="backlight: $current_level%"

echo "backlightnotification = mynotify(\"$message\", backlightnotification)" | awesome-client
