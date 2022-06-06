#!/bin/bash

#TODO: errorhandling with ${red}[error]$normal

#colors
purple=`echo -en "\e[35m"`
green=`echo -en "\e[32m"`
lightblue=`echo -en "\e[94m"`
normal=`echo -en "\e[0m"`

#vars
user_dir=/home/$USER
git_dir=$user_dir/git
godot_dir=$git_dir/godot
godot_bin=godot.linuxbsd.opt.tools.64
bin_dir=$godot_dir/bin
template_dir=$user_dir/.local/share/godot/templates/4.0.alpha

echo "${lightblue}**************************************$normal"
echo "${lightblue}            build_godot.sh            $normal"
echo "${lightblue}**************************************$normal"

silent="false"

usage() { echo -e "Usage: $0\n[-s <true|false>]                Silent mode\n[-p <string>]                    Test command\n[-h]                             Display this help message and exit" 1>&2; exit 1; }

while getopts ":s:p" opt; do
    case $opt in
    s)
        silent=${OPTARG}
        ;;
    p)
        p=${OPTARG}
        ;;
    *)
        usage
        ;;

    esac
done
shift $(( OPTIND - 1 ))
[[ "${1}" == "--" ]] && shift

#usage: mystix_exec "text" "cmd1" "cmd2" "cmd3" 
mystix_exec(){
    text=$1
    echo -n "${purple}$text.. $normal"
    anim="& while [ \$(ps a | awk '{print \$1}' | grep \$!) ] ; do for X in '-' '/' '|' '\'; do echo -en \"\b\$X\"; sleep 0.1; done; done; echo -en '\b '"
    shift
    for i in "$@";
    do
        if ${silent} ; then
            cmd_with_anim="$i > /dev/null 2>&1 $anim"
        else
            echo
            cmd_with_anim="$i"
        fi
        eval $cmd_with_anim
    done
    echo "${green}[done]$normal"
}

mystix_exec "Install build dependencies" \
"sudo apt-get -qq install build-essential scons pkg-config libx11-dev libxcursor-dev libxinerama-dev libgl1-mesa-dev libglu-dev libasound2-dev libpulse-dev libudev-dev libxi-dev libxrandr-dev yasm"

mystix_exec "Remove old installation" \
"unalias godot" "rm -rf $godot_dir" \
"rm -rf $user_dir/.config/godot" \
"rm -rf $user_dir/.cache/godot" \
"rm -rf $user_dir/.local/share/godot"

mystix_exec "Create git dir" "mkdir -p $git_dir"

mystix_exec "Clone godot 4" "git -C $git_dir clone https://github.com/godotengine/godot.git"

mystix_exec "Build godot 4 with $(nproc) threads" \
"scons -C $godot_dir --silent -j$(nproc) platform=linuxbsd tools=yes target=release_debug use_lto=yes bits=64" \
"alias godot=$bin_dir/$godot_bin" \
"source ~/.bashrc"

mystix_exec "Copy export template to: $template_trg_dir" \
"mkdir -p $template_dir" \
"cp $bin_dir/godot.linuxbsd.opt.tools.64 $template_dir/linux_x11_64_release"

mystix_exec "Open server project in editor" "$bin_dir/$godot_bin /home/$USER/git/Godot4Net/server/project.godot --editor"

mystix_exec "Open client project in editor" "$bin_dir/$godot_bin /home/$USER/git/Godot4Net/client/project.godot --editor"
