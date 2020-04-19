#!/bin/bash

# extract PDBs from silent file and merge in a single PDBs

# cmd parsing functions
usage() { echo "Extract pdbs from silentfile and merge into single pdb file
Usage: pdb_extract.sh -s <silentfile> -n <number of structures> (default: 1)" 1>&2; exit 1; }
invalidOpt() { echo "Invalid option: -$OPTARG" 1>&2; exit 1; }
missingArg() { echo "Option -$OPTARG requires an argument" 1>&2; exit 1; }

#------------
# cmd parsing
#------------

# defaults
nof_struct=1

while getopts ":s:n:h" opt; do
    case $opt in
        s)
            silentfile=$OPTARG
            ;;
        n)
            nof_struct=$OPTARG
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

# check if the number of structures is an integer
if [ $nof_struct -eq $nof_struct 2>/dev/null ]; then
    echo Extracting $nof_struct structures from silentfile "$silentfile"...
else
    echo Error: number of structures is not an integer
    exit 1
fi

# check that score file exists
if [ ! -e "${silentfile%%_proc.out*}".sc ]; then
    echo Error: the score file "${silentfile%%_proc.out*}".sc is missing    
    exit 1
fi

# extract decoys
mkdir pdb_temp || exit 1
cd pdb_temp
extract_lowscore_decoys.py "../$silentfile" "$nof_struct"
cd ..

# lowest score decoy list
pdbfiles=`ls pdb_temp/"$silentfile".*.pdb | awk -F"/" '{ print $2 }' | sort -t \. -k 3 -g`
scores=`cat "${silentfile%%_proc.out*}".sc | sort -k2 -n | head -$((nof_struct+1)) | tail -$nof_struct | awk '{ print $2,"\t", $19 }'`
paste <(echo "$pdbfiles") <(echo "$scores") --delimiters '\t' > "${silentfile%%_proc.out*}"_score.dat

echo ROSETTA Lowest decoy models > "${silentfile%%_proc.out*}"_merged.pdb
for pdb in $pdbfiles; do
    nof_mdl=`echo $pdb | sed 's/[^0-9]/ /g' | awk '{print $NF}'`
    echo "MODEL        $nof_mdl" >> "${silentfile%%_proc.out*}"_merged.pdb
    grep ATOM pdb_temp/$pdb >> "${silentfile%%_proc.out*}"_merged.pdb
    echo "ENDMDL" >> "${silentfile%%_proc.out*}"_merged.pdb
done

echo Wrote $nof_struct structures to "${silentfile%%_proc.out*}"_merged.pdb

# clean up
rm -r pdb_temp
