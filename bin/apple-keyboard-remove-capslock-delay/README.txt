This directory contains a solution for the problem that the Apple USB
keyboard has a delay on the Caps Lock key, which becomes very annoying
if it is remapped as Control key.

This solution is copied from this URL:
http://apple.stackexchange.com/questions/81234/how-to-remove-caps-lock-delay-on-apple-macbook-pro-aluminum-keyboard

Take the following steps:

1. gcc -o disable-capslock-delay disable-capslock-delay.c
2. Copy the resulting disable-capslock-delay to /usr/local/bin
3. Add the following lines to /etc/rc.local

HIDDEVICE=$(dmesg | grep Apple | grep Keyboard | grep input0 | tail -1 | sed -e 's/.*hidraw\([[:digit:]]\+\).*/\/dev\/hidraw\1/')

/usr/local/bin/disable-capslock-delay $HIDDEVICE
