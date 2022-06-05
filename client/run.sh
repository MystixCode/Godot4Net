#!/bin/bash
lightblue=`echo -en "\e[94m"`
normal=`echo -en "\e[0m"`

echo "${lightblue}Run client$normal"
/home/$USER/git/Godot4Net/client/Client.x86_64 # --headless # --verbose

#run client debug
#/home/$USER/git/godot/bin/godot.linuxbsd.tools.64 --path /home/$USER/git/Godot4Net/client/ # --verbose
