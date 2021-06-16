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

#base=${1%%?R?.fastq.gz}
base=${1%.fastq.gz}
r=${base: -2}
base=${base%?R?}

#base=$( basename $1 .fastq.gz )
#base=$( basename $1 .fastq.gz )
#dir=/francislab/data1/working/20210428-EV/20210504-REdiscoverTE/out
#mkdir -p ${dir}

l=101

#zcat $1 | paste - - - - | awk -F"\t" -v l=${l} -v base=${base} -v dir=${dir} '\
zcat $1 | paste - - - - | awk -F"\t" -v l=${l} -v base=${base} -v r=${r} '\
{
	if( length($2)>l ){
		ext="gt"l"."r".fastq"
	}else{
		ext="lte"l"."r".fastq"
	}
	print $1"\n"$2"\n"$3"\n"$4 > base"."ext
}'

ls -l ${base}*

gzip ${base}.gt${l}.${r}.fastq
gzip ${base}.lte${l}.${r}.fastq

chmod -w ${base}.gt${l}.${r}.fastq.gz
chmod -w ${base}.lte${l}.${r}.fastq.gz

count_fasta_reads.bash ${base}.gt${l}.${r}.fastq.gz
count_fasta_reads.bash ${base}.lte${l}.${r}.fastq.gz

average_fasta_read_length.bash ${base}.gt${l}.${r}.fastq.gz
average_fasta_read_length.bash ${base}.lte${l}.${r}.fastq.gz


