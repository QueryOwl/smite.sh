# smite.sh
smite.sh is a simple program that handles both finding and termination of running processes.

# General guide:

Usage:
    ./smite.sh [options]
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
    './smite.sh -v firefox'      sends a SIGTERM to all processes named firefox, that are ran by the current user, will provide the pid the process was at when if was killed
    'sudo ./smite.sh --user=bob -f mcserver.sh' sends a SIGKILL to all processes named mcserver.sh that are ran by bob
    'sudo ./smite.sh -f bash' sends a SIGKILL to all bash processes ran by the root user

Warnings:
    This program assumes the user running it as the user the processes are running that it will kill, if ran with sudo, it will only display applications ran by root; specify the user the application is running with --user=[username] if using with privledges.
    Due to the nature of the matching, please ensure you provide the exact name of the program you wish to kill, otherwise other programs might be cought in the crossfire. As an attempt to mitigate this flaw, all matching is done with case sensative whole words, as such if you are attempting to kill steam only './smite.sh steam' will have any affect and './smite.sh ste' will not match to it.
