#!/bin/bash

#------------------------------------------------------------------------------------------------------------
# Program to locate and solve intern domains of a given website
# 
# This code is under the GPLv3 license. See LICENSE for more informations 
#
# Developer - Giovani Ferreira
#------------------------------------------------------------------------------------------------------------

SEPARATOR=":"           # This is the separator for the output. Default will be <domain>:<ip>
OUTPUT=""               # The file to write the output
URL=""                  # The url to explore
QUIET=false             # Operate in quiet mode
VERBOSE=false           # Operate in verbose mode
CONTAINS=""             # To show only domains that contains this piece

# This function performs the actions to explore a given domain
function main(){
    echo "--> Checking $1..."                               # User feedback

    # Check if the url is a valid url
    # Hide the output of ping, including error messagens
    ping -q -c1 $1 > /dev/null 2> /dev/null

    if [ $? -ne 0 ]; then
        # Display error message
        echo -e "Unreachable url $1\nAborting..."
        # Finish the script execution
        exit 1
    fi

    # Starting downloading the index.html file
    echo "--> Downloading index file..."
    wget -q $1

    # Cleaning the html file:
    # - Grepping only the href= lines
    # - Using / as separator for get the "links" after http://
    # - Grepping only line with dot .
    # - Removing the lines with <li> tags
    # - Remove repeated lines
    echo "--> Searching for internal domains..."
    cat index.html | grep href= | cut -d "/" -f 3 | grep "\." | cut -d '"' -f 1 | grep -v "<li" | sort -u > $DOMAINS

    # Finding which host have an ip addres
    echo "--> Checking internal domains..."
    # Iterating through all founded domains
    # - Displaying in screen
    # - Saving into $HOSTS file
    for domain in $(cat $DOMAINS); do
        # For verbose output
        # host $domain | grep "has address" | tee -a $HOSTS
        host $domain | grep "has address" >> $HOSTS
    done

    echo "--> Generating output file: $HOSTS..."

    # Cleaning the auxiliary files
    echo "--> Removing auxiliary files..."
    rm $DOMAINS index.html

    echo "--> Hosts are in $HOSTS!"

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
            -v|--version) 
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
    echo display_help
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
