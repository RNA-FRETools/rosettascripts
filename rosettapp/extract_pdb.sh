#!/bin/bash

# cmd parsing functions
usage() { echo "Extract n pdbs with the lowest energy score from silentfile 
Usage: extract_pdb.sh -s <silentfile> -f <folder with silentfiles> -n <number of models> -e <extract pdbs (true|false, default: true)>"1>&2; exit 1; }
invalidOpt() { echo "Invalid option: -$OPTARG" 1>&2; exit 1; }
missingArg() { echo "Option -$OPTARG requires an argument" 1>&2; exit 1; }

#------------
# cmd parsing
#------------

while getopts ":s:f:n:e:h" opt; do
    case $opt in
        s) 
            silentfile=$OPTARG
            ;;
        f) 
            silentfolder=$OPTARG
            ;;
        n) 
            number=$OPTARG
            ;;
        e)
            extract=$OPTARG
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
if [ -z "$silentfile" ] && [ -z "$silentfolder" ]; then
    usage
fi


# check if file is present
if [ ! -z "$silentfile" ] && [ ! -e "$silentfile" ]; then
    echo Error: the specified file does not exist
    exit 1
fi

# check if folder is present
if [ -z "$silentfile" ]; then
    if [ ! -e "$silentfolder" ]; then
        echo Error: the specified folder does not exist
        exit 1
    else
        easy_cat.py $silentfolder | tee tmp
        silentfile=`sed -n 's/Catting into:  \(.*\)\.\.\..*/\1/p' tmp`
        rm tmp
        # check if file is present
        if [ ! -e "$silentfile" ]; then
            echo No models ready to extract.
            exit 1
        fi
    fi
fi




# no cmd line arguments given
if [ -z "$number" ]; then
    number=1
fi

echo "$number" lowest energy models: 
grep "^SCORE:" "$silentfile" | grep -v description | sort -nk2 | head -n "$number" | awk '{print $NF ": " $2}' | tee tmp_models
echo ""

# check if file is present
if [ "$extract" != "false" ]; then
    extract_pdbs.linuxgccrelease -in:file:silent "$silentfile" -tags `cat tmp_models | cut -f1 -d':'` && echo "$number model(s) successfully extracted!" && rm tmp_models
else
    rm tmp_models
fi
