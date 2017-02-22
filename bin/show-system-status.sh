#!/bin/bash
# Display power and network status in a notification box

function ac_status() {
    echo "<b>Power Supply</b>"
    AC_FILE="/sys/class/power_supply/AC/online"
    if [[ -e "$AC_FILE" ]]; then
        if [[ "$(cat $AC_FILE)" == "1" ]]; then
            echo "AC Power Plugged"
        else
            echo "AC Power Unplugged"
        fi
    else
        echo "$AC_FILE missing"
    fi
}

function battery_status() {
    echo "<b>Battery</b>"
    BATTERY_STATUS_FILE="/sys/class/power_supply/BAT0/status"
    BATTERY_CAPACITY_FILE="/sys/class/power_supply/BAT0/capacity"
    echo "$(cat $BATTERY_STATUS_FILE) $(cat $BATTERY_CAPACITY_FILE)%"
}

function nm_status() {
    echo "<b>Network</b>"
    nmcli -t -f DEVICE,STATE dev status
    echo -n "<b>Current: </b>"
    nmcli -t -f NAME,DEVICES con status
}

echo "naughty.destroy(systemstatusnotification)" | awesome-client

message="$(ac_status)<br><br>$(battery_status)<br><br>$(nm_status)"

# Replace all new lines with <br>
# :a create a label 'a'
# N append the next line to the pattern space
# $! if not the last line, ba branch (go to) label 'a'
# s substitute, /\n/ regex for new line, /<br>/ is the substitution,
#    /g global match (as many times as it can)
# sed will loop through step 1 to 3 until it reach the last line,
# getting all lines fit in the pattern space where sed will substitute
# all \n characters
message="$(sed ':a;N;$!ba;s/\n/<br>/g' <<< "$message")"

# Escape additional characters to make it valid HTML text
message="$(sed 's/&/&amp;/g' <<< "$message")"

echo "systemstatusnotification = naughty.notify({"\
     "text = \"$message\","\
     "position = \"top_right\"})" |\
    awesome-client
