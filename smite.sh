#!/bin/bash
set -e
processUser=$USER

help="
Usage:
    $0 [options]
    This program attempts to find and terminate all running processes that share a name with the one provided.

Arguments:
    -h, --help          this menu
    -v, --verbose       increases the information that is provided during operation
    -f, --force         changes the method of termination from a SIGTERM to a SIGKILL, has the potential for data loss use at your own discretion
    --user=[username]   will attempt to terminate process ran by other user, must be ran by a privlidged user or with sudo

Notes:
    -v and -f can be combined as -vf or -fv
    multiple -v such as -vvv do not increase verbosity
    process names must be exact

Examples:
    '$0 -v firefox'      sends a SIGTERM to all processes named firefox, that are ran by the current user, will provide the pid the process was at when if was killed
    'sudo $0 --user=bob -f mcserver.sh' sends a SIGKILL to all processes named mcserver.sh that are ran by bob
    'sudo $0 -f bash' sends a SIGKILL to all bash processes ran by the root user

Warnings:
    This program assumes the user running it as the user the processes are running that it will kill, if ran with sudo, it will only display applications ran by root; specify the user the application is running with --user=[username] if using with privledges.
    Due to the nature of the matching, please ensure you provide the exact name of the program you wish to kill, otherwise other programs might be cought in the crossfire. As an attempt to mitigate this flaw, all matching is done with case sensative whole words, as such if you are attempting to kill steam only '$0 steam' will have any affect and '$0 ste' will not match to it.
"

# acknowledgement of risks when ran as root
if [ "$USER" == "root" ]; then
    while [[ ! "${confirm,,}" == [ny] ]]; do
        read -p "running as root, please confirm you understand the risks
(see --help for more information) (y/N): " confirm
        if [ "${confirm,,}" == "n" ]; then
            exit 0
        fi
    done
fi

# checks if a process name was provided
if [ $# -eq 0 ]; then
    echo "no arguments were provided
try again or use --help for more information" >&2
exit 1
fi

# main function that parses all arguments and assigns variables
while [ $# -gt 0 ]; do
    case $1 in
        -h | --help)
            echo "$help"
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
            # confirms the user is root before proceeding
            if [ ! "$USER" == "root" ]; then
                echo "--user= must be ran with privledges
try again or use --help for more information" >&2
                exit 1
            else
                processUser=${1#"--user="}
            fi
        ;;
        --all-users) 
            # confirms the user is root before proceeding
            if [ ! "$USER" == "root" ]; then
                echo "--user= must be ran with privledges
try again or use --help for more information" >&2
                exit 1
            else
                allUsers=true
            fi
            ;;
        -*)
            # incorrect argument
            echo "invalid argument
try again or use --help for more information" >&2
            exit 1
        ;;
        *)
            processName=$1
        ;;
    esac
    shift
done

if [ "$verbose" == true ] && [ "$force" == true ]; then
    echo "forcing...."
fi

# error handling for no provided process name
if [ ! -n "$processName" ]; then
    echo "no process name was provided
try again or use --help for more information" >&2
exit 1
fi

# finds and confirms provided user and/or processes exist prior to deletion
list=$(if [ "$allUsers" == true ]; then ps -au; else ps -u "$processUser" 2>/dev/null; fi | grep -w "$processName" 2>/dev/null | awk '{print $1}' 2>/dev/null) || list=""
if [ -z "$list" ]; then
    if [ "$allUsers" == true ]; then
        echo "process does not exist
try again or use --help for more information" >&2
    else
        echo "user name or process does not exist
try again or use --help for more information" >&2
    fi
    exit 1
fi

# executes based on provided arguments
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

