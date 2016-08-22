#!/bin/bash

#------------------------------------------------------------------------------------------------------------
# Brute Force subdomain
#
# Brute force program to locate intern domains of a given website
# 
# This code is under the license GPLv3. See more informations in LICENSE. 
#
# Developer - Giovani Ferreira
#------------------------------------------------------------------------------------------------------------

DOMAIN=                                         # Target domain to brute force
OUTPUT=                                         # To write output to disk
WORDLIST="common.wordlist"                      # Default wordlist
VERBOSE=false                                   # Operation mode verbose

trap "exit" INT                                 # Trap for abort scritp with sigint

function main {
    # Check if the url was given
    if [ -z $1 ]; then
        echo -e "Incorret usage, should consider pass the url(without 'www'):\n$0 website.com wordlist(optional)"
        # Abort the script if no URL was given
        exit 1
    fi

    # File name for the result
    SUBDOMAINS="subdomains.txt"

    # Set the default wordlist file
    WORDLIST="wordlist.txt"
    # Check if user pointed for another wordlist
    if [ ! -z $2 ]; then
        # Set the desired list from user
        WORDLIST="$2"
    fi

    # Displaying feedback
    echo "--> Starting bruteforce in $1..."

    # Check if the file exists
    if [ ! -e $WORDLIST ]; then
        # Abort the script execution
        echo "Unable to locate the wordlist $WORDLIST"
        exit 1
    fi

    # Reading possible subDomains from list
    for sub in $(cat $WORDLIST); do
        # Ping subdomain
        ping -q -c1 $sub.$1 > /dev/null 2> /dev/null
        # Check if host exists
        if [ $? -eq 0 ]; then
            echo "--> Found subdomain: $(echo $sub.$1 | tee -a $SUBDOMAINS)"
        fi
    done

    # Displaying feedback
    echo -e "Finished bruteforce.\nResults stored in $SUBDOMAINS"
}

function parse_args {
    if [ $# -eq 0 ]; then           # Check if at least one arg was passed
        display_help
        exit 1
    fi

    while (( "$#" )); do            # Stays in the loop as long as the number of parameters is greater than 0
        case $1 in                  # Switch through cases to see what arg was passed
            -V|--version) 
                echo ":: Author: Giovani Ferreira"
                echo ":: Source: https://github.com/giovanifss/Domain-Explorer-Tools"
                echo ":: License: GPLv3"
                echo ":: Version: 0.2"
                exit 0;;

            -o|--output)            # Get the next arg to be the output file
                if [ -z $2 ] || [[ $2 == -* ]]; then
                    error_with_message "Expected argument after output file option"
                fi
                OUTPUT=$2
                shift;;             # To ensure that the next parameter will not be evaluated again

            -w|--wordlist)          # Get the next arg to be the output file
                if [ -z $2 ] || [[ $2 == -* ]]; then
                    error_with_message "Expected argument after wordlist option"
                fi
                WORDLIST=$2
                shift;;             # To ensure that the next parameter will not be evaluated again

            -v|--verbose)           # Set the program opeartion mode to verbose 
                if $QUIET; then     # Program can not behave quiet and verbose at same time
                    error_with_message "Operation mode can not be quiet and verbose at the same time"
                fi
                VERBOSE=true;;

            -h|--help)              # Display the help message
                display_help
                exit 0;;

            *)                      # If a different parameter was passed
                if [ ! -z "$DOMAIN" ] || [[ $1 == -* ]]; then
                    error_with_message "Unknow argument $1"
                fi

                DOMAIN=$1;;
        esac
        shift                       # Removes the element used in this iteration from parameters
    done

    if [ -z $DOMAIN ]; then
        error_with_message "The target domain must be passed"
    fi

    return 0
}

function display_help {
    echo
    echo ":: Usage: bf-subdomain [DOMAIN] [-w WORDLIST] [-o OUTPUT FILE] "
    echo
    echo ":: DOMAIN: The target domain lo brute force." 
    echo ":: OUTPUT: The file to store the output generated. Use '-o | --output-file'"
    echo ":: WORDLIST: The path to wordlist to use in the attack. Use '-w | --wordlist'"
    echo ":: VERBOSE: Verbose operation mode can be specified by '-v|--verbose'"
    echo ":: VERSION: To see the version and useful informations, use '-V|--version'"

    return 0
}

function error_with_message {
    echo ":: Error: $1"
    echo ":: Use -h for help"
    exit 1
}

# Start of script
parse_args $@
# main
