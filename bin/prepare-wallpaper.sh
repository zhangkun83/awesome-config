#!/bin/bash
script_path="$(readlink -f "$0")"
script_dir="$(dirname "$script_path")"
parentdir="$(dirname "$script_dir")"
WALLPAPER_SRC_DIR="$parentdir/runtime/wallpapers"
wallpaper=$(ls -1 "$WALLPAPER_SRC_DIR" | shuf | head -1)
if [ -z "$wallpaper" ]; then
    wallpaper="cat-tile.png"
    wallpaper_path="$parentdir/themes/default/$wallpaper"
else
    wallpaper_path="$WALLPAPER_SRC_DIR/$wallpaper"
fi
# If the file name ends with "-tile", it's a tile image
if [[ "$wallpaper" == *-tile.* ]]; then
    option="--bg-tile"
else
    option="--bg-fill"
fi
feh "$option" "$wallpaper_path"
