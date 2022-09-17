#!/bin/bash

purple=`echo -en "\e[35m"`
green=`echo -en "\e[32m"`
lightblue=`echo -en "\e[94m"`
normal=`echo -en "\e[0m"`

git_dir=$HOME/git
godot_dir=$git_dir/godot
godot_bin=godot.linuxbsd.opt.tools.x86_64
bin_dir=$godot_dir/bin
template_dir=$HOME/.local/share/godot/export_templates/4.0.beta

echo "${lightblue}**************************************$normal"
echo "${lightblue}            build_godot.sh            $normal"
echo "${lightblue}**************************************$normal"

echo "${purple}Install build dependencies$normal"
sudo apt-get -qq install build-essential scons pkg-config libx11-dev libxcursor-dev libxinerama-dev libgl1-mesa-dev libglu-dev libasound2-dev libpulse-dev libudev-dev libxi-dev libxrandr-dev yasm

echo "${purple}Remove old installation$normal" 
#unalias godot
rm -rf $godot_dir
rm -rf $HOME/.config/godot
rm -rf $HOME/.cache/godot
rm -rf $HOME/.local/share/godot

echo "${purple}Create git dir$normal"
mkdir -p $git_dir

echo "${purple}Clone godot 4$normal"
git -C $git_dir clone https://github.com/godotengine/godot.git

echo "${purple}Build godot 4 with $(nproc) threads$normal"
scons -C $godot_dir --silent -j$(nproc) platform=linuxbsd tools=yes target=release_debug use_lto=yes bits=64

echo "${purple}Create godot alias$normal"
grep -qxF "alias godot=$bin_dir/$godot_bin" ~/.bash_aliases || echo "alias godot=$bin_dir/$godot_bin" >> ~/.bash_aliases
source ~/.bash_aliases

echo "${purple}Copy export template to: $template_dir $normal"
mkdir -p $template_dir
cp $bin_dir/$godot_bin $template_dir/linux_release.x86_64

# echo "${purple}Open server project in editor$normal"
# $bin_dir/$godot_bin /home/$USER/git/Godot4Net/server/project.godot --editor

# echo "${purple}Open client project in editor$normal"
# $bin_dir/$godot_bin /home/$USER/git/Godot4Net/client/project.godot --editor
