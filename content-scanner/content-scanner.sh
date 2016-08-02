#!/bin/bash

#------------------------------------------------------------------------------------------------------------
# Content Scanner
#
# Script for discover files and directories in the given domain
# 
# Developer - Giovani Ferreira
#------------------------------------------------------------------------------------------------------------

OUTPUT="content.txt"            # File name for the content discovered
WORDLIST="content.wordlist"     # Set the default wordlist file
URL=""                          # The target url
QUIET=false                     # Operation mode quiet
VERBOSE=false                   # Operation mode verbose

function main {
    if [ ! -e $WORDLIST ]; then                                             # Check if the wordlist exists
        # Abort the script execution
        echo "Unable to locate the wordlist $WORDLIST"
        exit 1
    fi
    
    if ! $QUIET ; then
        echo "==> Starting brute force in $URL..."                          # Feedback for the user
    fi
    
    for attempt in $(cat $WORDLIST); do                                     # Read the wordlist and attempt every possibility
        resp=$(curl -s -o /dev/null -w "%{http_code}" $URL/$attempt)        # Checking for file in domain
        
        if [ $resp -ne '200' ]; then                                        # If file doesn't exist
            resp=$(curl -s -o /dev/null -w "%{http_code}" $URL/$attempt/)   # Check for directory in domain
            
            if [ $resp -eq '200' ]; then                                    # If directory exists
                echo "--> Directory Found: $(echo $URL/$attempt/ | tee -a $OUTPUT)"  
            fi
        else                                                                # If file exists
            echo "--> File Found: $(echo $URL/$attempt | tee -a $OUTPUT)" 
        fi
    done

    echo "==> Finished brute force in $URL"
    echo ":: Results stored in $OUTPUT"                                     # Showing the location of the result
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

            -o|--output-file)       # Get the next arg to be the output file
                if [ -z $2 ] || [[ $2 == -* ]]; then
                    error_with_message "Expected argument after output file option"
                fi
                OUTPUT=$2
                shift;;             # To ensure that the next parameter will not be evaluated again

            -q|--quiet)             # Set the program operation mode to quiet
                if $VERBOSE; then   # Program can not behave quiet and verbose at same time
                    error_with_message "Operation mode can not be quiet and verbose at the same time"
                fi
                QUIET=true;;

            -v|--verbose)           # Set the program opeartion mode to verbose 
                if $QUIET; then     # Program can not behave quiet and verbose at same time
                    error_with_message "Operation mode can not be quiet and verbose at the same time"
                fi
                VERBOSE=true;;

            -h|--help)              # Display the help message
                display_help
                exit 0;;

            *)                      # If a different parameter was passed
                if [ ! -z "$URL" ]; then
                    error_with_message "Unknow argument $1"
                fi

                URL=$1;;
        esac
        shift                       # Removes the element used in this iteration from parameters
    done

    if [ -z $URL ]; then
        error_with_message "The target url must be passed"
    fi

    return 0
}

function display_help {
    echo display_help
    return 0
}

function error_with_message {
    echo ":: Error: $1"
    echo ":: Use -h for help"
    exit 1
}

#-----------------------------------------------------------------------------------------------------------------------------
# Start of the script
#   - Parse arguments
#   - Gather information from url
#-----------------------------------------------------------------------------------------------------------------------------
parse_args $@
main
