#!/bin/bash
 
#create git directory if not exists
mkdir -p /home/$USER/git
cd /home/$USER/git
 
#Download Godot4Net from master branch
git clone https://github.com/MystixCode/Godot4Net.git

#build client
chmod u+x /home/$USER/git/Godot4Net/client/build.sh
bash /home/$USER/git/Godot4Net/client/build.sh

#run client
nohup /home/$USER/git/Godot4Net/client/Client.x86_64 &>/dev/null &
#bash /home/$USER/git/Godot4Net/client/Client.x86_64

#build server
chmod u+x /home/$USER/git/Godot4Net/server/build.sh
bash /home/$USER/git/Godot4Net/server/build.sh

#run server
bash /home/$USER/git/Godot4Net/server/Server.x86_64 --headless
