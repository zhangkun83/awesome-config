#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# xsecurelock will cause Xorg to consume high CPU if compton is
# running, possibly due to xsecurelock trying to cover the overlay
# window.  The CPU hog can be resolved by XSECURELOCK_NO_COMPOSITE=1,
# but it may allow notifications to show on top of the lock, thus is
# not recommended.  Here we kill compton if lock is success, and
# restart it when the screen is unlocked (xsecurelock is blocking).
XSECURELOCK_FONT=-misc-fixed-medium-r-normal--20-200-75-75-c-100-iso8859-1 XSECURELOCK_WANT_FIRST_KEYPRESS=1 xsecurelock -- $DIR/disable-composition.sh
$DIR/enable-composition.sh
