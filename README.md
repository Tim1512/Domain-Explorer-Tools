# Domain Explorer Tools
A collection of some useful bash scripts for information gathering and domain exploration.  

- [Domain Explorer](domain-explorer/DOMAIN-EXPLORER.md)
- [Brute Force Subdomain](bf-subdomain/BF-SUBDOMAIN.md)
- [Content Scanner](content-scanner/CONTENT-SCANNER.md)
- [Network Block Scan](network-block-scan/NETWORK-BLOCK-SCAN.md)

## Zone Transfer
A bash script for zone transfer in a given domain  

#### Parameters:
- ```-s | --separator```: The separator to be used in output. The output is ```<domain> <separator> <ip>```.
- ```-o | --output-file```: Specify the output file to program.
- ```-v | --verbose```: Set operation mode to verbose, note that this can not be used together with ```--quiet```.
- ```-q | --quiet```: Set operation mode to quiet, note that this can not be used together with ```--verbose```.
- ```-V | --version```: Outputs relevant information about the script.

#### Usage
- Give permition for the file:  
``` chmod +x zone-transfer.sh ```

- Execute passing the target for a zone transfer:  
``` ./zone-transfer.sh <target domain>```

## DNS Sucker
A bash script to automate DNS info gather  

#### Parameters:
- ```-e | --except```: Do not execute specific queries.
- ```-o | --output```: Specify the output file to program.
- ```-v | --verbose```: Set operation mode to verbose.
- ```-a | --all```: Execute all possible DNS queries, except the ones pointed in ```-e|--except```
- ```-V | --version```: Outputs relevant information about the script.

#### Usage
- Give permition for the file:  
``` chmod +x dns-sucker.sh ```

##### Usage examples:
- ```./dns-sucker.sh www.fbi.gov --output fbi-dns.txt --except MX PTR```

## License
This collection of scripts is under the GPLv3 license  
See LICENSE for more details  
