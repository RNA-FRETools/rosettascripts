#!/bin/bash

# removes everything behind NON_STANDARD_RESIDUE_MAP in the silent file which would otherwise break the script extract_lowscore_decoys.py 

# cmd parsing functions
usage() { echo "Remove non standard residues from silentfile 
Usage: process_silentfile -s <silentfile>" 1>&2; exit 1; }
invalidOpt() { echo "Invalid option: -$OPTARG" 1>&2; exit 1; }
missingArg() { echo "Option -$OPTARG requires an argument" 1>&2; exit 1; }

#------------
# cmd parsing
#------------

while getopts ":s:h" opt; do
    case $opt in
        s) 
            silentfile=$OPTARG
            ;;
        h)
            usage
            ;;
        \?)
            invalidOpt
            ;;
        :)
            missingArg
            ;;
        *)
            usage
            ;;
    esac
done


# no cmd line arguments given
if [ -z "$silentfile" ]; then
    usage
fi

# check if file is present
if [ ! -e "$silentfile" ]; then
    echo Error: the specified file does not exist
    exit 1
fi

# remove NON_STANDARD_RESIDUE tag line from silentfile (make a copy first)
silentfile_proc=${silentfile%%.out}_proc.out
cat $silentfile | awk -F '\NON_STANDARD_RESIDUE_MAP' '{ print $1 }' > $silentfile_proc && echo $silentfile successfully processed and written to $silentfile_proc
