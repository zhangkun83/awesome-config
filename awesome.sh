#!/bin/bash
export AWESOME_THEMES_PATH="$HOME/.config/awesome/themes"

# This dumps Lua search paths for debugging
lua -e 'print("LUA MODULES:\n",(package.path:gsub("%;","\n\t")),"\n\nC MODULES:\n",(package.cpath:gsub("%;","\n\t")))'

# ck-launch-session makes the nm-applet started by display manager
# operable by the user.
exec ck-launch-session awesome -c $HOME/.config/awesome/rc.lua "$@"
