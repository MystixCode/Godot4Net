#!/bin/bash

#colors
purple=`echo -en "\e[35m"`
green=`echo -en "\e[32m"`
lightblue=`echo -en "\e[94m"`
normal=`echo -en "\e[0m"`

echo "${lightblue}**************************************$normal"
echo "${lightblue}        build_client_server.sh        $normal"
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

#build client
mystix_exec "Build client" \
"chmod u+x /home/$USER/git/Godot4Net/client/build.sh" \
"bash /home/$USER/git/Godot4Net/client/build.sh"

#build server
mystix_exec "Build server" \
"chmod u+x /home/$USER/git/Godot4Net/server/build.sh" \
"bash /home/$USER/git/Godot4Net/server/build.sh"
