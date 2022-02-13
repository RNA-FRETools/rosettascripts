#!/bin/bash

# cmd parsing functions
usage() { echo "Extract PDB(s) with the lowest energy score from silentfile(s) 
Usage: extract_pdb -s <silentfile> -d <directory with silentfiles> -n <number of models (default: 1)> -e <extract PDBs (true|false, default: true)> -m <merge PDBs (true|false, default: false)>" 1>&2; exit 1; }
invalidOpt() { echo "Invalid option: -$OPTARG" 1>&2; exit 1; }
missingArg() { echo "Option -$OPTARG requires an argument" 1>&2; exit 1; }

#------------
# cmd parsing
#------------

while getopts ":s:d:n:e:m:h" opt; do
    case $opt in
        s) 
            silentfile=$OPTARG
            ;;
        d) 
            silentfolder=$OPTARG
            ;;
        n) 
            number=$OPTARG
            ;;
        e)
            extract=$OPTARG
            ;;
        m)
            merge=$OPTARG
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

grep "^SCORE:" "$silentfile" | grep -v description | sort -nk2 | head -n "$number" | awk '{print $NF ": " $2}' | tee tmp_models
echo ""

# extract pdbs or do not
extract=`echo "$extract" | tr [:upper:] [:lower:]`
if [ "$extract" != "false" ]; then
    extract_pdbs.linuxgccrelease -in:file:silent "$silentfile" -tags `cat tmp_models | cut -f1 -d':'` && echo "$(wc -l <tmp_models) model(s) successfully extracted!"
fi

# merge pdb into single file or not
merge=`echo "$merge" | tr [:upper:] [:lower:]`
if [ "$merge" = "true" ]; then
    i=1
    pdb_merge=`echo ${silentfile%.*}.pdb`
    > $pdb_merge
    for pdb in `cat tmp_models | cut -f1 -d':'`; do
        echo MODEL $i >> "$pdb_merge"
        echo TITLE "$pdb" >> "$pdb_merge"
        cat "$pdb".pdb >> "$pdb_merge"
        echo -e "ENDMDL\n\n" >> "$pdb_merge"
        rm "$pdb".pdb
        i=$(($i+1))
    done
fi

rm tmp_models
