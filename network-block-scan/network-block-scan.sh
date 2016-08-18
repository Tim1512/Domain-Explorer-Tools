#!/bin/bash

#------------------------------------------------------------------------------------------------------------
# Network Block Scan
#
# Program to scan a especified ip range block in a giver network. Searching for alive hosts in this range.
# 
# This code is under the GPLv3 license. See LICENSE for more informations.
#
# Developer - Giovani Ferreira
#------------------------------------------------------------------------------------------------------------

NETWORK=                                    # Network to perform the scan
OUTPUT=                                     # File to write the output
VERBOSE=false                               # Operation mode verbose
QUIET=false                                 # Operatiom mode quiet
EXCEPT=()                                   # Hosts to ignore
FIRST=1                                     # First host of the network to scan
LAST=254                                    # Last host of the network to scan
MASK=                                       # Network mask

function main {
    # Check if the url was given
    if [ -z $1 ] || [ -z $2 ] || [ -z $3 ]; then
        echo -e "Incorret usage, use the correct arguments:\n$0 <first-3-octets-of-the-network-ip> <initial-value-of-the-last-octet> <final-value-of-the-last-octet>\nExample: $0 172.168.22 105 200"
        # Abort the script if parameters are incorrect
        exit 1
    fi

    # Feedback for user
    echo "--> Starting scan in $1.xxx"

    RESULT="alive_hosts.txt"

    # Checking the hosts in the ip range
    for octet in $(seq $2 $3); do
        # Getting only the hosts that exist in the ip range
        host=$(host $1.$octet | cut -d ' ' -f5 | grep -v $1 | sed 's/\.$//') 

        # Checking if the current host exist
        # If it doesn't exist, the var host will be null
        if [ ! -z $host ]; then
            echo "Host found: $(echo "$host - $1.$octet" | tee -a $RESULT)"
        fi
    done

    # Telling user where to find the alive hosts
    echo -e "--> Scan finished\n--> Results are in $RESULT"
}

function parse_args {
    if [ $# -eq 0 ]; then                   # Check if at least one arg was passed
        display_help
        exit 1
    fi

    while (( "$#" )); do                    # Stays in the loop as long as the number of parameters is greater than 0
        case $1 in                          # Switch through cases to see what arg was passed
            -V|--version) 
                echo ":: Author: Giovani Ferreira"
                echo ":: Source: https://github.com/giovanifss/Domain-Explorer-Tools"
                echo ":: License: GPLv3"
                echo ":: Version: 0.2"
                exit 0;;

            -o|--output)                    # Get the next arg to be the output file
                if [ -z $2 ] || [[ $2 == -* ]]; then
                    error_with_message "Expected argument after output file option"
                fi
                OUTPUT=$2
                shift;;                     # To ensure that the next parameter will not be evaluated again

            -q|--quiet)                     # Set the program operation mode to quiet
                if $VERBOSE; then           # Program can not behave quiet and verbose at same time
                    error_with_message "Operation mode can not be quiet and verbose at the same time"
                fi
                QUIET=true;;

            -f|--first)                     # Set the first host in the network to scan
                if [ -z $2 ] || [[ $2 == -* ]]; then
                    error_with_message "Expected argument after first host option"
                fi

                if [[ ! $2 =~ ^([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])$ ]]; then
                    error_with_message "Invalid argument for first option"
                fi

                FIRST=$2
                shift;;

            -l|--last)                      # Set the first host in the network to scan
                if [ -z $2 ] || [[ $2 == -* ]]; then
                    error_with_message "Expected argument after first host option"
                fi

                if [[ ! $2 =~ ^([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])$ ]]; then
                    error_with_message "Invalid argument for first option"
                fi

                LAST=$2
                shift;;

            -v|--verbose)                   # Set the program operation mode to verbose 
                if $QUIET; then             # Program can not behave quiet and verbose at same time
                    error_with_message "Operation mode can not be quiet and verbose at the same time"
                fi
                VERBOSE=true;;

            -e|--except)                    # Hosts to ignore
                while [[ $2 =~ ^([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])$ ]]; do
                    EXCEPT+=($2)  
                    shift
                done

                if [ ${#EXCEPT[@]} -eq 0 ]; then
                    error_with_message "Expected argument after except option"
                fi;;

            -h|--help)                      # Display the help message
                display_help
                exit 0;;

            *)                              # If a different parameter was passed

            # \b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b
                if [ ! -z "$NETWORK" ] || [[ $1 == -* ]]; then
                    error_with_message "Unknow argument $1"
                fi
                #if [[ $1 =~ \b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b ]]; then

                regex="\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\/[0-9][0-9]\b"

                if [[ ! $1 =~ $regex ]];then
                    error_with_message "Invalid network $1. Format ex: 192.168.1.0/24"
                fi

                NETWORK=$1
        esac
        shift                               # Removes the element used in this iteration from parameters
    done

    if [ -z $NETWORK ]; then
        error_with_message "The target network must be passed"
    fi

    MASK=$(echo $NETWORK | grep -oP "\d{1,3}$")

    lastoctet=$(echo $NETWORK | sed 's/\/.*$//' | grep -oP "\d{1,3}$")
    if [ $lastoctet -gt $FIRST ]; then
        FIRST=$lastoctet
    fi

    NETWORK=$(echo $NETWORK | grep -oP "\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b" | grep -oP "\b(\d{1,3}\.){2}\d{1,3}\b")

    return 0
}

function display_help {
    echo
    echo ":: Usage: domain-explorer [URL] [-w WORDLIST] [-o OUTPUT FILE] "
    echo
    echo ":: URL: The target url to gather information. MUST be a reachable domain."
    echo ":: OUTPUT: The file to store the output generated. Use '-o | --output-file'"
    echo ":: WORDLIST: The path to wordlist to use in the attack. Use '-w | --wordlist'"
    echo ":: VERBOSE|QUIET: Operation mode can be specified by '-v|--verbose' or '-q|--quiet'"
    echo ":: VERSION: To see the version and useful informations, use '-V|--version'"
    echo ":: EXIST: Return only file that exists, that means, only http status code of 200. Use '-e|--exists'"

    return 0
}

function error_with_message {
    echo ":: Error: $1"
    echo ":: Use -h for help"
    exit 1
}

# Start of script
parse_args $@
main
