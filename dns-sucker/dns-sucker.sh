#!/bin/bash

declare -A QUERIES                                  # Associative array with several DNS query types description
DEFAULT=(A AAAA CNAME HINFO MX NS PTR SOA SRV)      # Default QUERIES to perform
EXCEPT=()                                           # Queries that should not be executed
ALL=false                                           # To execute all possible queries
VERBOSE=false                                       # Operation mode verbose
OUTPUT=""                                           # File to send the output

function contain {
    for key in "${!QUERIES[@]}"; do
        if [ $key == "$1" ]; then
            return 0
        fi
    done
    return 1
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
    echo "DNS Query $t: ${QUERIES[$t]}"
    host -t $t grandbusiness.com.br
done

if contain "PTR"; then
    echo contains
fi

