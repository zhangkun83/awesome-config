#!/bin/bash
CONFIG_DIR="$(pwd)"
mkdir -p "$CONFIG_DIR/runtime"
ln -sf "$CONFIG_DIR/profile_$1.lua" "$CONFIG_DIR/runtime/current_profile.lua"
