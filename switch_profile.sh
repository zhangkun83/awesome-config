#!/bin/bash
CONFIG_DIR="$HOME/.config/awesome"
mkdir -p "$CONFIG_DIR/runtime"
ln -sf "$CONFIG_DIR/profile_$1.lua" "$CONFIG_DIR/runtime/current_profile.lua"
