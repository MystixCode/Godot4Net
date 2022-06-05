# Godot4Net
This is a godot 4 alpha test project to checkout the new network sync code. \
Server and client are separated into two projects and its 3D.
With global_state replication



## Install

```bash
# Create git directory
mkdir -p /home/$USER/git && /
cd /home/$USER/git && /

# Download Godot4Net from master branch
git clone https://github.com/MystixCode/Godot4Net.git && /

# Build and install godot4 and export tools
chmod u+x /home/$USER/git/Godot4Net/build_godot.sh && /
bash /home/$USER/git/Godot4Net/build_godot.sh
```

You need to open both projects with the godot editor atleast once:

import client project --> /home/$USER/git/Godot4Net/client/ \
import server project --> /home/$USER/git/Godot4Net/server/

```bash
#build and run client and server
chmod u+x /home/$USER/git/Godot4Net/build_run_client_server.sh && /
bash /home/$USER/git/Godot4Net/build_run_client_server.sh
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
