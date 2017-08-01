#!/bin/bash
# Make the xfce4-panel to use a dark theme which goes better with the wibox.
# Also include other gtk theme customizations.
GTK2_RC_FILES=/usr/share/themes/Xfce-dusk/gtk-2.0/gtkrc:$HOME/.config/awesome/gtk2rc xfce4-panel &
