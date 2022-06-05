#!/bin/bash

#run client
chmod u+x /home/$USER/git/Godot4Net/client/run.sh
nohup bash /home/$USER/git/Godot4Net/client/run.sh &>/dev/null &

#run server
chmod u+x /home/$USER/git/Godot4Net/server/run.sh
bash /home/$USER/git/Godot4Net/server/run.sh