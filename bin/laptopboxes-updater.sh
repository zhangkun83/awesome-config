#!/bin/bash
# Updates the power and network status widgets

BATTERY_UTF8="\xf0\x9f\x94\x8b"
POWERPLUG_UTF8="\xf0\x9f\x94\x8c"
BATTERY_STATUS_FILE="/sys/class/power_supply/BAT0/status"
BATTERY_CAPACITY_FILE="/sys/class/power_supply/BAT0/capacity"
AC_FILE="/sys/class/power_supply/AC/online"

function battery_status() {
    local battery_percentage="$(cat $BATTERY_CAPACITY_FILE)"
    local battery_status="$(cat $BATTERY_STATUS_FILE)"
    local battery_status_symbol=""
    if [[ "$battery_status" == "Charging" ]]; then
        battery_status_symbol="+"
    elif [[ "$battery_status" == "Discharging" ]]; then
        battery_status_symbol="-"
    fi

    local powerplug_status_symbol="${POWERPLUG_UTF8}?"
    if [[ -e "$AC_FILE" ]]; then
        if [[ "$(cat $AC_FILE)" == "1" ]]; then
            powerplug_status_symbol="${POWERPLUG_UTF8}"
        else
            powerplug_status_symbol=""
        fi
    fi

    local text="${powerplug_status_symbol}${BATTERY_UTF8}${battery_status_symbol}${battery_percentage}%"
    echo -e "mybatterybox:set_text(\"${text}\")" | awesome-client
}

function network_status() {
    local allstatus="$(nmcli -m multiline con status)"
    local connection="$(echo "$allstatus" | grep '^NAME:' | awk '{print $2}')"
    local device="$(echo "$allstatus" | grep '^DEVICES:' | awk '{print $2}')"

    local alldevicestates="$(nmcli -t --fields DEVICE,STATE device status)"
    local devicestate="$(echo "$alldevicestates" | grep "${device}")"
    local text="${connection}:${devicestate}"
    echo "mynetworkbox:set_text(\"${text}\")" | awesome-client
}

while true; do
    battery_status
    network_status
    sleep 5
done
