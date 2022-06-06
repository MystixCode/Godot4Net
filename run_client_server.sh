#!/bin/bash

#TODO: errorhandling with ${red}[error]$normal

#colors
bold=`echo -en "\e[1m"`
underline=`echo -en "\e[4m"`
dim=`echo -en "\e[2m"`
strickthrough=`echo -en "\e[9m"`
blink=`echo -en "\e[5m"`
reverse=`echo -en "\e[7m"`
hidden=`echo -en "\e[8m"`
normal=`echo -en "\e[0m"`
black=`echo -en "\e[30m"`
red=`echo -en "\e[31m"`
green=`echo -en "\e[32m"`
orange=`echo -en "\e[33m"`
blue=`echo -en "\e[34m"`
purple=`echo -en "\e[35m"`
aqua=`echo -en "\e[36m"`
gray=`echo -en "\e[37m"`
darkgray=`echo -en "\e[90m"`
lightred=`echo -en "\e[91m"`
lightgreen=`echo -en "\e[92m"`
lightyellow=`echo -en "\e[93m"`
lightblue=`echo -en "\e[94m"`
lightpurple=`echo -en "\e[95m"`
lightaqua=`echo -en "\e[96m"`
white=`echo -en "\e[97m"`
default=`echo -en "\e[39m"`
BLACK=`echo -en "\e[40m"`
RED=`echo -en "\e[41m"`
GREEN=`echo -en "\e[42m"`
ORANGE=`echo -en "\e[43m"`
BLUE=`echo -en "\e[44m"`
PURPLE=`echo -en "\e[45m"`
AQUA=`echo -en "\e[46m"`
GRAY=`echo -en "\e[47m"`
DARKGRAY=`echo -en "\e[100m"`
LIGHTRED=`echo -en "\e[101m"`
LIGHTGREEN=`echo -en "\e[102m"`
LIGHTYELLOW=`echo -en "\e[103m"`
LIGHTBLUE=`echo -en "\e[104m"`
LIGHTPURPLE=`echo -en "\e[105m"`
LIGHTAQUA=`echo -en "\e[106m"`
WHITE=`echo -en "\e[107m"`
DEFAULT=`echo -en "\e[49m"`

echo "${lightblue}*********************************************$normal"
echo "${lightblue}            script_boilerplate.sh            $normal"
echo "${lightblue}*********************************************$normal"

silent="false"
client_dir=/home/$USER/git/Godot4Net/client
server_dir=/home/$USER/git/Godot4Net/server

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


mystix_exec "Run Client" "chmod u+x $client_dir/run.sh" "nohup bash $client_dir/run.sh > /dev/null 2>&1 &"
mystix_exec "Run Server" "chmod u+x $server_dir/run.sh" "bash $server_dir/run.sh"
