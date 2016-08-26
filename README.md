# Domain Explorer Tools
A collection of some useful bash scripts for information gathering and domain exploration.  

- [Domain Explorer](domain-explorer/DOMAIN-EXPLORER.md)
- [Brute Force Subdomain](bf-subdomain/BF-SUBDOMAIN.md)

## Content Scanner
A bash script to find files and directories in a given domain, using burte force approach:  
- Read possible files or directories from wordlist  
- Try every possibility
- Output found files or directories

#### Parameters:
- ```-w | --wordlist```: The wordlist to be used by script.
- ```-e | --exists```: Only output found file and directories. That means, only output http status code 200.
- ```-o | --output-file```: Specify the output file to program.
- ```-v | --verbose```: Set operation mode to verbose, note that this can not be used together with ```--quiet```.
- ```-q | --quiet```: Set operation mode to quiet, note that this can not be used together with ```--verbose```.
- ```-V | --version```: Outputs relevant information about the script.

#### Usage
- Give permition for the file:  
``` chmod +x content-scanner.sh ```

##### Usage examples:
- ``` ./content-scanner.sh www.fbi.gov ```: Use the default wordlist and output status code 20* and 3**.
- ``` ./content-scanner.sh www.github.com -e -w /usr/share/wordlists/blabla.txt```: Specify the wordlist located in ```/usr/share/wordlist/``` to be used instead of the default one and output only directories and files with http status code 200 in the request.

## Network Block Scan
A bash script for scan a especified ip range in a network, searching for alive hosts.

#### Parameters:
- ```-f | --first```: Set the first in address to be scanned. Ex: --first 10 (only last octet).
- ```-l | --last```: Set the last address to be scanned. Ex: -l 254 (only last octet).
- ```-e | --except```: Specify addresses to ignore. Ex: -e 244 243 (only last octet).
- ```-o | --output```: Specify the output file to program.
- ```-v | --verbose```: Set operation mode to verbose, note that this can not be used together with ```--quiet```.
- ```-V | --version```: Outputs relevant information about the script.

#### Usage
- Give permition for the file:  
``` chmod +x network-block-scan.sh ```

- Example:  
- ``` ./network-block-scan.sh 192.168.1.16/29```
- ``` ./network-block-scan.sh 192.168.1.1/24 --first 30 -e 35 36 37 38 -l 200 -o "/tmp/output_file.txt"```  

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
