#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

$DIR/enable-composition.sh

# Change key repeat rate
xset r rate 220 30

$DIR/start_if_absent.sh urxvtd urxvtd -q -o -f
$DIR/start_if_absent.sh nm-applet nm-applet
$DIR/start_if_absent.sh lock_when_idle.sh $DIR/lock_when_idle.sh
