#!/bin/bash
# Start awesome4 assiming it's installed under $HOME/awesome4 and
# configuration under $HOME/.config/awesome4

export PATH="$HOME/awesome4/bin:$PATH"
export LUA_CPATH=$HOME'/awesome4/lib/lua/5.2/?.so;;'
export LUA_PATH=$HOME'/awesome4/share/lua/5.2/?.lua'
export LUA_PATH="$LUA_PATH"';'"$HOME"'/awesome4/usr/local/share/awesome/lib/?.lua'
export LUA_PATH="$LUA_PATH"';'"$HOME"'/awesome4/usr/local/share/awesome/lib/?/init.lua'
export LUA_PATH="$LUA_PATH"';'"$HOME"'/.config/awesome4/?.lua'
export LUA_PATH="$LUA_PATH"';;'
export AWESOME_THEMES_PATH="$HOME/.config/awesome4/themes"

# This dumps Lua search paths for debugging
lua -e 'print("LUA MODULES:\n",(package.path:gsub("%;","\n\t")),"\n\nC MODULES:\n",(package.cpath:gsub("%;","\n\t")))'

awesome -c $HOME/.config/awesome4/rc.lua "$@"
