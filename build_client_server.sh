#!/bin/bash

#build client
chmod u+x /home/$USER/git/Godot4Net/client/build.sh
bash /home/$USER/git/Godot4Net/client/build.sh

#build server
chmod u+x /home/$USER/git/Godot4Net/server/build.sh
bash /home/$USER/git/Godot4Net/server/build.sh
