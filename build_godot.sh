#!/bin/bash

purple=`echo -en "\e[35m"`
green=`echo -en "\e[32m"`
lightblue=`echo -en "\e[94m"`
normal=`echo -en "\e[0m"`

version=4.0.beta
git_dir=$HOME/git
godot_dir=$git_dir/godot
godot_editor_bin=godot.linuxbsd.editor.x86_64
#TODO godot_server_bin=godot.linuxbsd.server.x86_64
godot_template_release_bin=godot.linuxbsd.template_release.x86_64
godot_template_debug_bin=godot.linuxbsd.template_debug.x86_64
bin_dir=$godot_dir/bin
template_dir=$HOME/.local/share/godot/export_templates/$version

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

echo "${purple}Build godot 4 editor with $(nproc) threads$normal"
scons -C $godot_dir --silent -j$(nproc) platform=linuxbsd tools=yes target=editor use_lto=yes bits=64

echo "${purple}Create godot alias$normal"
grep -qxF "alias godot=$bin_dir/$godot_editor_bin" ~/.bash_aliases || echo "alias godot=$bin_dir/$godot_bin" >> ~/.bash_aliases
source ~/.bash_aliases

#TODO
#echo "${purple}Build godot 4 server with $(nproc) threads$normal"
#scons -C $godot_dir --silent -j$(nproc) platform=linuxbsd tools=no target=editor use_lto=yes bits=64
#scons -C $godot_dir --silent -j$(nproc) platform=server tools=no target=editor use_lto=yes bits=64


echo "${purple}Build godot 4 template_release with $(nproc) threads$normal"
scons -C $godot_dir --silent -j$(nproc) platform=linuxbsd tools=no target=template_release use_lto=yes bits=64

echo "${purple}Build godot 4 template_debug with $(nproc) threads$normal"
scons -C $godot_dir --silent -j$(nproc) platform=linuxbsd tools=no target=template_debug use_lto=yes bits=64

echo "${purple}Copy export template_release to: $template_dir $normal"
mkdir -p $template_dir
cp $bin_dir/$godot_template_debug_bin $template_dir/$godot_template_debug_bin

echo "${purple}Copy export template_debug to: $template_dir $normal"
mkdir -p $template_dir
cp $bin_dir/$godot_template_debug_bin $template_dir/$godot_template_debug_bin

# echo "${purple}Open server project in editor$normal"
# $bin_dir/$godot_bin /home/$USER/git/Godot4Net/server/project.godot --editor

# echo "${purple}Open client project in editor$normal"
# $bin_dir/$godot_bin /home/$USER/git/Godot4Net/client/project.godot --editor
