#!/bin/bash

#------------------------------------------------------------------------------------------------------------
# Zone Transfer
#
# Program for query DNS servers of the domain and try to get the full zone file.
# 
# This code is under the license WTFPL: 
# http://www.wtfpl.net/
#
# Developer - Giovani Ferreira
#------------------------------------------------------------------------------------------------------------

OUTPUT="zone_file.txt"                  # Output file of the program
URL=""                                  # Target url for the attack
QUIET=false                             # Operation mode quiet
VERBOSE=false                           # Operation mode verbose

function main {
    echo "--> Starting zone transfer attempt in $URL"

    echo $URL

    # Discovering all DNS servers of the domain
    for server in $(host -t ns $URL | cut -d " " -f4 ); do
        # Get only the useful information in the zone file
        host -l $URL $server | grep -E 'has address|name server' | sed 's/\.$//' >> $OUTPUT # Maybe "| tee -a $OUTPUT" instead of ">> $OUTPUT" for real time feedback
        # Check if zone transfer was successful 
        if [ ${PIPESTATUS[0]} -eq 0 ]; then
            echo -e "--> Successful zone transfer in server: $server\n--> Results are in $OUTPUT"
            # Exit program with success
            exit 0
        fi
        # If zone transfer was not successful
        echo "--> Failed zone transfer in $server"
    done

    # If the program still running, there are no results
    echo "--> Unable to do zone transfer in $URL"

    return 1;
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
                if [ ! -z "$URL" ] || [[ $1 == -* ]]; then
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
    echo
    echo ":: Usage: zone-trasfer [URL] [-o OUTPUT FILE] "
    echo
    echo ":: URL: The target url to gather information. MUST be a reachable domain."
    echo ":: OUTPUT: The file to store the output generated. Use '-o | --output-file'"
    echo ":: VERBOSE|QUIET: Operation mode can be specified by '-v|--verbose' or '-q|--quiet'"
    echo ":: VERSION: To see the version and useful informations, use '-V|--version'"

    return 0
}

function error_with_message {
    echo ":: Error: $1"
    echo ":: Use -h for help"
    exit 1
}

parse_args $@
main
