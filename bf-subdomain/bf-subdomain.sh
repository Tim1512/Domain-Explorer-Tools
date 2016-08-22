#!/bin/bash

#------------------------------------------------------------------------------------------------------------
# Brute Force subdomain
#
# Brute force program to locate intern domains of a given website
# 
# This code is under the license WTFPL: 
# http://www.wtfpl.net/
#
# Developer - Giovani Ferreira
#------------------------------------------------------------------------------------------------------------

# Trap for abort scritp with sigint
trap "exit" INT

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

main $@
