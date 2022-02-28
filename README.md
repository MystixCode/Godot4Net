# Godot4Net
This is a godot 4.0.2 alpha test project to checkout the new network sync code. \
Server and client are separated into two projects and its 3D.

Some issues to fix are:
 - spawn initial position
 - bullet actually hitting center of crosshair correctly
 - interpolation (supposed to be added to godot core)
 
<img src="/screenshot.png" width="100%" height="100%">

Get started on deb based distributions
```bash
#Install build dependencies
sudo apt-get install build-essential scons pkg-config libx11-dev libxcursor-dev libxinerama-dev libgl1-mesa-dev libglu-dev libasound2-dev libpulse-dev libudev-dev libxi-dev libxrandr-dev yasm

#Download godot 4 from master branch
git clone https://github.com/godotengine/godot.git
cd godot

#Compile godot editor
scons -j16 platform=linuxbsd

#Compile godot export tools
scons -j16 platform=x11 tools=no target=release_debug bits=64
```
