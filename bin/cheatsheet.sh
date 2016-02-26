#!/bin/bash
script_path="$(readlink -f "$0")"
script_dir="$(dirname "$script_path")"
parentdir="$(dirname "$script_dir")"
xterm -geometry 66x52+600+200 -fa 'Monospace' -fs 11 -e "less $parentdir/cheatsheet.txt"
