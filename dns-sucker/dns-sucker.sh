#!/bin/bash

declare -A QUERIES                                  # Associative array with several DNS query types description
DEFAULT=(A AAAA CNAME HINFO MX NS PTR SOA SRV)      # Default QUERIES to perform
EXCEPT=()                                           # Queries that should not be executed
ALL=false                                           # To execute all possible queries
VERBOSE=false                                       # Operation mode verbose
OUTPUT=""                                           # File to send the output
DOMAIN=""                                           # Target domain to extract DNS information

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
                echo ":: Version: 0.1"
                exit 0;;

            -o|--output)            # Get the next arg to be the output file
                if [ -z $2 ] || [[ $2 == -* ]]; then
                    error_with_message "Expected argument after output file option"
                fi
                OUTPUT=$2
                shift;;             # To ensure that the next parameter will not be evaluated again

            -e|--except)            # Queries to ignore
                until [[ $2 == -* ]] || [ -z $2 ] || [[ $2 =~ \. ]]; do
                    EXCEPT=("${EXCEPT[@]}" "$2")  
                    shift
                done

                if [ ${#EXCEPT[@]} -eq 0 ]; then
                    error_with_message "Expected argument after except option"
                fi;;

            -v|--verbose)           # Set the program opeartion mode to verbose 
                VERBOSE=true;;

            -a|--all)               # Executes all queries
                ALL=true;;

            -h|--help)              # Display the help message
                display_help
                exit 0;;

            *)                      # If a different parameter was passed
                if [ ! -z $DOMAIN ] || [[ $1 == -* ]]; then
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

function contain {
    for key in "${!QUERIES[@]}"; do
        if [ $key == "$1" ]; then
            return 0
        fi
    done
    return 1
}

function display_help {
    echo
    echo ":: Usage: dns-sucker [DOMAIN] [-o OUTPUT FILE] [-e Q1 Q2 Q3 ... Qn]"
    echo
    echo ":: DOMAIN: The target domain to extract DNS records. MUST be a reachable domain."
    echo ":: EXCEPT: Don't perform queries. Ex: '-e|--except PTR MX'. Do not perform PTR and MX queries."
    echo ":: OUTPUT: The file to store the output generated. '-o|--output'"
    echo ":: ALL: Perform all queries availabe, except the ones pointed in '--except'. '-a|--all'"
    echo ":: VERBOSE: Activate verbose operation mode. '-v|--verbose'"
    echo ":: VERSION: To see the version and useful informations, use '-V|--version'"
}

function error_with_message {
    echo ":: Error: $1"
    echo ":: Use -h for help"
    exit 1
}

QUERIES[A]="IPv4 Address Record"
QUERIES[AAAA]="IPv6 Address Record"
QUERIES[AFSDB]="AFS Database Record"
QUERIES[APL]="Address Prefix List"
QUERIES[CAA]="Certification Authority Authorization"
QUERIES[CDNSKEY]="Child DNSKEY"
QUERIES[CDS]="Child DS"
QUERIES[CERT]="Certificate Record"
QUERIES[CNAME]="Canonical name record"
QUERIES[DHCID]="DHCP Identifier"
QUERIES[DLV]="DNSSEC Lookaside Validation Record"
QUERIES[DNAME]="Delegation Name"
QUERIES[DNSKEY]="DNS Key Record"
QUERIES[DS]="Delegation Signer"
QUERIES[HINFO]="Host Information"
QUERIES[HIP]="Host Identity Protocol"
QUERIES[IPSECKEY]="IPsec Key"
QUERIES[KEY]="Key Record"
QUERIES[KX]="Key Exchanger Record"
QUERIES[LOC]="Location Record"
QUERIES[MX]="Mail Exchange Record"
QUERIES[NAPTR]="Naming Authority Pointer"
QUERIES[NS]="Name Server Record"
QUERIES[NSEC]="Next Secure Record"
QUERIES[NSEC3]="Next Secure Record version 3"
QUERIES[NSEC3PARAM]="NSEC3 Parameters"
QUERIES[PTR]="Pointer Record"
QUERIES[RRSIG]="DNSSEC Signature"
QUERIES[RP]="Responsible Person"
QUERIES[SIG]="Signature"
QUERIES[SOA]="Start of Authority Record"
QUERIES[SRV]="Service Locator"
QUERIES[SSHFP]="SSH Public Key Fingerprint"
QUERIES[TA]="DNSSEC Trust Authorities"
QUERIES[TKEY]="Transaction Key Record"
QUERIES[TLSA]="TLSA Certificate Association"
QUERIES[TSIG]="Transaction Signature"
QUERIES[TXT]="Text Record"
QUERIES[URI]="Uniform Resource Identifier"
QUERIES[AXFR]="Authoritative Zone Transfer"
QUERIES[IXFR]="Incremental Zone Transfer"
QUERIES[OPT]="Option"


for t in "${DEFAULT[@]}"; do
    # echo "DNS Query $t: ${QUERIES[$t]}"
    host -t $t grandbusiness.com.br
done

if contain "PTR"; then
    # echo contains
    :
fi

parse_args $@

echo ${EXCEPT[@]}
echo $DOMAIN
