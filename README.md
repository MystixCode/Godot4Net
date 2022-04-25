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
    player:{
        1183871435:[Spartan153, (-2, 1.000247, -3), (-0.7, 0.8), 200, 200],
        1939770442:[Spartan31, (-1, 1.000045, 3), (-0.733333, 0.233333), 200, 200]
    },
    bullet:{
        Bullet1:[1939770442, (-1, 5.140666, -78.666656)],
        Bullet2:[1939770442, (-1, 5.091667, -77.999992)],
        Bullet3:[1183871435, (-1, 4.206944, -69.333359)],

    },
    moving_cube:{
        MovingCube1:[(26.47962, 0.5, -20)]
    },
    rigid_cube:{
        RigidCube1:[(10, 0.5, -10), (0, 0, 0)]
    },
    other:{
    
    }
}
```
