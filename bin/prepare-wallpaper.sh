#!/bin/bash
script_path="$(readlink -f "$0")"
script_dir="$(dirname "$script_path")"
parentdir="$(dirname "$script_dir")"
WALLPAPER_PATH="$parentdir/runtime/current-wallpaper.jpg"
WALLPAPER_SRC_DIR="$parentdir/runtime/wallpapers"
wallpaper=$(ls -1 "$WALLPAPER_SRC_DIR" | shuf | head -1)
unlink "$WALLPAPER_PATH"
if [ -n "$wallpaper" ]; then
  ln -sf "$WALLPAPER_SRC_DIR/$wallpaper" "$WALLPAPER_PATH"
else
  ln -sf "$parentdir/theme/background-foggy-forest-1920x1200.jpg" "$WALLPAPER_PATH"
fi
