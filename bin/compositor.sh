#!/bin/bash
if [[ "$1" == "true" ]]; then
  compton --backend glx --paint-on-overlay --glx-no-stencil --vsync opengl-swc --shadow-exclude "! name~=''" -b
else
  killall compton
fi
