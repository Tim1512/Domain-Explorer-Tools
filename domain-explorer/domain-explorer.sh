#!/bin/bash

#------------------------------------------------------------------------------------------------------------
# Program to locate and solve intern domains of a given website
# 
# This code is under the GPLv3 license. See LICENSE for more informations 
#
# Developer - Giovani Ferreira
#------------------------------------------------------------------------------------------------------------

SEPARATOR=":"           # This is the separator for the output. Default will be <domain>:<ip>
OUTPUT="hosts.txt"      # The file to write the output
URL=""                  # The url to explore
QUIET=false             # Operate in quiet mode
VERBOSE=false           # Operate in verbose mode
CONTAINS=""             # To show only domains that contains this piece
DOMAINS="tmp_domain"    # The temporary file to store the domains

# This function performs the actions to explore a given domain
function main(){
    if ! $QUIET; then
        echo "==> Checking $URL..."                             # User feedback
    fi

    ping -q -c1 $URL > /dev/null 2> /dev/null                   # Check if the url is a valid url

    if [ $? -ne 0 ]; then                                       # Finish script with error if the url is unreachable
        error_with_message "Unreachable url $URL. Aborting..."
    fi

    if ! $QUIET; then
        echo "==> Downloading index file..."                    # Starting downloading the index.html file
    fi

    wget -q $URL

    if ! $QUIET; then
        echo "==> Searching for internal domains..."
    fi

    # Cleaning the html file:
    # - Grepping only the href= lines
    # - Using / as separator for get the "links" after http://
    # - Grepping only line with dot .
    # - Removing the lines with <li> tags
    # - Remove repeated lines
    cat index.html | grep href= | cut -d "/" -f 3 | grep "\." | cut -d '"' -f 1 | grep -v "<li" | sort -u > $DOMAINS

    if ! $QUIET; then
        echo "==> Checking internal domains..."
    fi

    # Iterating through all founded domains
    # - Displaying in screen
    # - Saving into $HOSTS file
    for domain in $(cat $DOMAINS | grep "$CONTAINS"); do
        if $VERBOSE; then
            host $domain 2> /dev/null | grep "has address" | awk -F ' ' '{print $1"%%"$4}' | sed -e "s/\%\%/$SEPARATOR/g" | tee -a $OUTPUT
        else
            host $domain 2> /dev/null | grep "has address" | awk -F ' ' '{print $1"%%"$4}' | sed -e "s/\%\%/$SEPARATOR/g" &>> $OUTPUT
        fi
    done

    if ! $QUIET; then
        echo "==> Generating output file: $OUTPUT..."
        echo "==> Removing auxiliary files..."
    fi

    rm $DOMAINS index.html                                      # Cleaning the auxiliary files

    echo "==> Hosts are in $OUTPUT!"

    return 0
}

# This function will check if arguments are valid and prepare the execution of the program
function parse_args(){
    if [ $# -eq 0 ]; then           # Check if at least one arg was passed
        display_help
        exit 1
    fi

    while (( "$#" )); do            # Stays in the loop as long as the number of parameters is greater than 0
        case $1 in                  # Switch through cases to see what arg was passed
            --version) 
                echo ":: Author: Giovani Ferreira"
                echo ":: Source: https://github.com/giovanifss/Domain-Explorer-Tools"
                echo ":: License: GPLv3"
                echo ":: Version: 0.3"
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

            -u|--url)               # Get the url to explore
                if [ -z $2 ] || [[ $2 == -* ]]; then
                    error_with_message "Expected argument after url option"
                fi
                URL=$2
                shift;;             # To ensure that the next parameter will not be evaluated again

            -s|--separator)         # Get the separator to display the output
                if [ -z $2 ] || [[ $2 == -* ]]; then
                    error_with_message "Expected argument after separator option"
                fi
                SEPARATOR=$2
                shift;;             # To ensure that the next parameter will not be evaluated again

            -c|--contains)          # Get the piece of the domain that must be present
                if [ -z $2 ] || [[ $2 == -* ]]; then
                    error_with_message "Expected argument after contains option"
                fi
                CONTAINS=$2
                shift;;             # To ensure that the next parameter will not be evaluated again

            -h|--help)              # Display the help message
                display_help
                exit 0;;

            *)                      # If a different parameter was passed
                error_with_message "Unknow argument $1";;

        esac
        shift                       # Removes the element used in this iteration from parameters
    done

    if [ -z $URL ]; then
        error_with_message "The target url must be passed"
    fi

    return 0
}

function display_help(){
    echo
    echo ":: Usage: domain-explorer [-u URL] [-o OUTPUT FILE] [-s SEPARATOR] [-c CONTAINS]"
    echo
    echo ":: URL: The target url to gather information. MUST be a reachable domain."
    echo ":: OUTPUT: The file to store the output generated."
    echo ":: CONTAINS: Only outputs the domains that contain the specified pattern. Useful to output only subdomains. Ex: -c google.com."
    echo ":: SEPARATOR: The separator of the domain found and the ip in output. Ex: www.google.com:200.175.224.99 Separator=':'"
    echo ":: VERBOSE|QUIET: Operation mode can be specified by '-v|--verbose' or '-q|--quiet'"
    echo ":: VERSION: To see the version and useful informations, use '--version'"
}

# This function prints a message of error and exits the program
function error_with_message(){
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
