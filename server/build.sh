#!/bin/bash

GODOT_PATH=/home/$USER/Git/godot
GODOT_BIN=$GODOT_PATH/bin/godot.linuxbsd.tools.64

#build
#$GODOT_BIN --path ./server --export "Linux/X11"
$GODOT_BIN --path ./server --export-debug "Linux/X11"    # --headless

#run it
#--headless --debug --print-fps
#$GODOT_BIN --path ./server --verbose --headless
