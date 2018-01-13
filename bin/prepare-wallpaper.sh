#!/bin/bash
script_path="$(readlink -f "$0")"
script_dir="$(dirname "$script_path")"
parentdir="$(dirname "$script_dir")"
WALLPAPER_SRC_DIR="$parentdir/runtime/wallpapers"
wallpaper=$(ls -1 "$WALLPAPER_SRC_DIR" | shuf | head -1)
if [ -z "$wallpaper" ]; then
    wallpaper_path="$parentdir/theme/background-foggy-forest-1920x1200.jpg"
else
    wallpaper_path="$WALLPAPER_SRC_DIR/$wallpaper"
fi

feh --bg-scale "$wallpaper_path"
