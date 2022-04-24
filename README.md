# Godot4Net
This is a godot 4 alpha test project to checkout the new network sync code. \
Server and client are separated into two projects and its 3D.
With global_state replication

Some issues to fix are:
 - interpolation (supposed to be added to godot core)

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

global_state{} example
```bash
{
    players: {
        37865572: [Spartan30, (-1, 1.000636, -3), (3.016519, 0.266667), 200, 200],
        47865572: [Spartan40, (-1, 1.000636, -3), (3.016519, 0.266667), 200, 200],
        47865572: [Spartan40, (-1, 1.000636, -3), (3.016519, 0.266667), 200, 200]
    },
    bullets: {
        Bullet: [Spartan30, (-1, 1.000636, -3)],
        Bullet1: [Spartan30, (-1, 1.000636, -3)],
        Bullet2: [Spartan40, (-1, 1.000636, -3)],
    },
    synced_cubes: {
        obj_name: [(-1, 1.000636, -3), (3.016519, 0.266667)],
        obj_name1: [(-1, 1.000636, -3), (3.016519, 0.266667)]
    }
}
```
