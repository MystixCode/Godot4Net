#!/bin/bash
lightblue=`echo -en "\e[94m"`
normal=`echo -en "\e[0m"`

echo "${lightblue}Build client$normal"

#/home/$USER/git/godot/bin/godot.linuxbsd.tools.64 --path /home/$USER/git/Godot4Net/client --export-debug "Linux/X11"    # --headless
/home/$USER/git/godot/bin/godot.linuxbsd.tools.64 --path /home/$USER/git/Godot4Net/client --export "Linux/X11"    # --headless
