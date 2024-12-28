#!/bin/bash
set -e
processUser=$USER

if [ $# -eq 0 ]; then
    echo "No arguments provided!
Please try again or use --help for more information" >&2
exit 1
fi

while [ $# -gt 0 ]; do
    case $1 in
        -h | --help)
            echo "lol"
            exit 0
        ;;
        -v | --verbose)
            verbose=true
        ;;
        -f | --force)
            force=true
        ;;
        -vf | -fv)
            verbose=true
            force=true
        ;;
        --user=*)
            if [ ! "$USER" == "root" ]; then
                echo "--user= must be ran with privledges" >&2
                exit 1
            fi
            while [[ ! "${confirm,,}" == [ny] ]]; do
                read -p "Running as root, please confirm you understand the risks
(see --help for more information) (y/N): " confirm
                if [ "${confirm,,}" == "n" ]; then
                    exit 0
                elif [ "${confirm,,}" == "y" ]; then
                    processUser=${1#"--user="}
                fi
            done
        ;;
        -*)
            echo "Invalid case, try again." >&2
            exit 1
        ;;
        *)
            processName=$1
        ;;
    esac
    shift
done

if [ "$verbose" == true ] && [ "$force" == true ]; then
    echo "Forcing...."
fi

if [ ! -n "$processName" ]; then
    echo "No process name was provided!
Please try again or use --help for more information" >&2
exit 1
fi

list=$(ps -u "$processUser" 2>/dev/null | grep -w "$processName" 2>/dev/null | awk '{print $1}' 2>/dev/null) || list=""
if [ -z "$list" ]; then
    echo "User name or process does not exist!" >&2
    exit 1
fi

for pid in $list;
do
    if [ "$force" == true ]; then
        kill -9 $pid 2>/dev/null
    else 
        kill $pid 2>/dev/null
    fi
    
    if [ "$verbose" == true ]; then
        echo "killed $processName at $pid"
    fi
done

