#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x	#	print expanded command before executing it


#zcat /francislab/data1/working/20191008_Stanford71/20210326-preprocessing/output/01.bbduk1.unpaired.fastq.gz 

#base=${1%%.fastq.gz}
#base=$( basename $1 .fastq.gz )
base=$( basename $1 .fastq.gz )
dir=/francislab/data1/working/20210428-EV/20210504-REdiscoverTE/out
mkdir -p ${dir}

zcat $1 | paste - - - - | awk -F"\t" -v l=31 -v base=${base} -v dir=${dir} '\
{
	if( length($2)>l ){
		ext="gt"l".fastq"
	}else{
		ext="lte"l".fastq"
	}
	print $1"\n"$2"\n"$3"\n"$4 > dir"/"base"."ext
}'

gzip ${dir}/${base}.gt31.fastq
gzip ${dir}/${base}.lte31.fastq

chmod -w ${dir}/${base}.gt31.fastq.gz
chmod -w ${dir}/${base}.lte31.fastq.gz

count_fasta_reads.bash ${dir}/${base}.gt31.fastq.gz
count_fasta_reads.bash ${dir}/${base}.lte31.fastq.gz


