#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
set -o pipefail
if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	module load CBI samtools
fi
set -x  #       print expanded command before executing it

mkdir -p ${1}_barcodes


#	Not all reads have a CB tag?

samtools view $1 | awk -v dir=${1}_barcodes '{
cb=index($0,"CB:Z:")
if(cb>0){
a=substr($0,index($0,"CB:Z:"))
b=substr(a,6,index(a,"\t")-6)
print $0 > dir"/"b
}
}'

