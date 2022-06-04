# Godot4Net
This is a godot 4 alpha test project to checkout the new network sync code. \
Server and client are separated into two projects and its 3D.
With global_state replication



## Download, build and run
### Create git directory
```bash
mkdir -p /home/$USER/git
cd /home/$USER/git
```
### Download Godot4Net from master branch
```bash
git clone https://github.com/MystixCode/Godot4Net.git
```
### Install godot4
```bash
chmod u+x /home/$USER/git/Godot4Net/install_godot.sh && /
bash /home/$USER/git/Godot4Net/install_godot.sh
```

### Install Godot4Net
```bash
chmod u+x /home/$USER/git/Godot4Net/install_Godot4Net.sh && /
bash /home/$USER/git/Godot4Net/install_Godot4Net.sh
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
