#!/bin/bash
lightblue=`echo -en "\e[94m"`
normal=`echo -en "\e[0m"`

echo "${lightblue}Run server$normal"
/home/$USER/git/Godot4Net/server/Server.x86_64 # --headless # --verbose

#run server debug
#/home/$USER/git/godot/bin/godot.linuxbsd.tools.64 --path /home/$USER/git/Godot4Net/server/ # --verbose
