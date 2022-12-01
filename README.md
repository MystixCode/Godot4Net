# Godot4Net
This is a godot4 test/example project implementing multiplayer networking with a states array. \
Server and client are separated into two projects and its 3D.

## Install newest godot4

```bash
bash /home/$USER/<your_git_dir>/Godot4Net/build_godot.sh
```
## Open client and server project

### start godot

doubleclick in a file browser
```bash
/home/$USER/<your_git_dir>/godot/bin/godot.linuxbsd.editor.x86_64
```

or just type godot in a console
```bash
godot
```

### import projects
```bash
/home/$USER/<your_git_dir>/Godot4Net/client/
/home/$USER/<your_git_dir>/Godot4Net/server/
```

## Info
### global_state{} example
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
### Tested on:
- Debian GNU/Linux 11 (bullseye)
