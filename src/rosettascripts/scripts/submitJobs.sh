#!/bin/bash

# cmd parsing functions
usage() { echo "Submit a Rosetta FARFAR job on multiple cores
Usage: submitJobs -i <FARFAR input script> [-d <directory>] [-p <number of processors>]" 1>&2; exit 1; }
invalidOpt() { echo "Invalid option: -$OPTARG" 1>&2; exit 1; }
missingArg() { echo "Option -$OPTARG requires an argument" 1>&2; exit 1; }

# default cmd arguments
dir=out
proc=1


#------------
# cmd parsing
#------------

while getopts ":i:d:p:h" opt; do
    case $opt in
        i)
            farfar=$OPTARG
            ;;
        d)
            dir=$OPTARG
            ;;
        p)
            proc=$OPTARG
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
if [ -z "$farfar" ]; then
    usage
fi

# folder exists
if [ -d "$dir" ]; then
    echo "the specified output folder already exists"
    exit 1
fi


#-----------
# Submission
#-----------

# create output directories
mkdir ./$dir
for i in `seq 1 $proc`; do
    mkdir ./"$dir"/"$i"
done
echo "directories for $proc processes created in ./$dir."
sleep 0.5

# create submit script for each processor
for i in `seq 1 $proc`; do
    file=`cat ./"$farfar" | sed "s/-silent /-silent .\/$dir\/$i\//g"`
    if [ ! -d "submit" ]; then
        mkdir ./submit
    fi
    echo "$file" > ./submit/job"$i".sh
    echo "-run:use_time_as_seed" >> ./submit/job"$i".sh
    chmod +x ./submit/job"$i".sh
done

# submit jobs
for i in `seq 1 $proc`; do
    ./submit/job"$i".sh &
    echo "job $i started..."
    sleep 1.5
done


# kill all running jobs by issuing
#pkill rna_*
