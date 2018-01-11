#!/bin/bash
export AWESOME_THEMES_PATH="$HOME/.config/awesome/themes"

# This dumps Lua search paths for debugging
lua -e 'print("LUA MODULES:\n",(package.path:gsub("%;","\n\t")),"\n\nC MODULES:\n",(package.cpath:gsub("%;","\n\t")))'

awesome -c $HOME/.config/awesome/rc.lua "$@"
