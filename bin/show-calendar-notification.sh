#!/bin/bash
echo "calendar_notification=zk.notify_monospace(\"Today is <b>$(date '+%A, %B %d')</b>\\n$(cal -h3 | sed ':a;N;$!ba;s/\n/\\n/g')\", calendar_notification)" | awesome-client
