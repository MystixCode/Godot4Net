 #!/bin/bash
#create git directory if not exists
mkdir -p /home/$USER/git
cd /home/$USER/git

#remove old godot installs
rm -rf godot

#Install build dependencies
sudo apt-get install build-essential scons pkg-config libx11-dev libxcursor-dev libxinerama-dev libgl1-mesa-dev libglu-dev libasound2-dev libpulse-dev libudev-dev libxi-dev libxrandr-dev yasm

#Download godot 4 from master branch
git clone https://github.com/godotengine/godot.git
cd godot

#Compile godot editor
scons -j16 platform=linuxbsd

#Compile godot export tools
scons -j16 platform=x11 tools=no target=debug bits=64
scons -j16 platform=x11 tools=no target=release bits=64

#Copy export presets to .local
cp bin/godot.linuxbsd.debug.64 /home/$USER/.local/share/godot/templates/4.0.alpha/linux_x11_64_debug
cp bin/godot.linuxbsd.opt.64 /home/$USER/.local/share/godot/templates/4.0.alpha/linux_x11_64_release

#run godot4 editor
#godot/bin/godot.linuxbsd.tools.64
nohup /home/$USER/git/godot/bin/godot.linuxbsd.tools.64 &>/dev/null &
