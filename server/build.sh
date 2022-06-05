#!/bin/bash
lightblue=`echo -en "\e[94m"`
normal=`echo -en "\e[0m"`

echo "${lightblue}Build server$normal"

#/home/$USER/git/godot/bin/godot.linuxbsd.tools.64 --path /home/$USER/git/Godot4Net/server --export-debug "Linux/X11"    # --headless
/home/$USER/git/godot/bin/godot.linuxbsd.tools.64 --path /home/$USER/git/Godot4Net/server --export "Linux/X11"    # --headless
