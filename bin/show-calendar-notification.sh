#!/bin/bash
echo "calendar_notification=mynotifymonospace(\"Today is <b>$(date '+%A, %B %d')</b>\\n$(cal -h3 | sed ':a;N;$!ba;s/\n/\\n/g')\", calendar_notification)" | awesome-client
