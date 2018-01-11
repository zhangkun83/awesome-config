#!/bin/bash
export LUA_PATH="$HOME"'/.config/awesome/?.lua'
export LUA_PATH="$LUA_PATH"';;'
export AWESOME_THEMES_PATH="$HOME/.config/awesome/themes"

# This dumps Lua search paths for debugging
lua -e 'print("LUA MODULES:\n",(package.path:gsub("%;","\n\t")),"\n\nC MODULES:\n",(package.cpath:gsub("%;","\n\t")))'

awesome -c $HOME/.config/awesome/rc.lua "$@"
