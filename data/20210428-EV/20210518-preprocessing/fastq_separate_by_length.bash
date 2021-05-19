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

base=${1%%.fastq.gz}
#base=$( basename $1 .fastq.gz )
#base=$( basename $1 .fastq.gz )
#dir=/francislab/data1/working/20210428-EV/20210504-REdiscoverTE/out
#mkdir -p ${dir}

l=30

#zcat $1 | paste - - - - | awk -F"\t" -v l=${l} -v base=${base} -v dir=${dir} '\
zcat $1 | paste - - - - | awk -F"\t" -v l=${l} -v base=${base} '\
{
	if( length($2)>l ){
		ext="gt"l".fastq"
	}else{
		ext="lte"l".fastq"
	}
	print $1"\n"$2"\n"$3"\n"$4 > base"."ext
}'

ls -l ${base}*

	#print $1"\n"$2"\n"$3"\n"$4 > dir"/"base"."ext
#gzip ${dir}/${base}.gt${l}.fastq
#gzip ${dir}/${base}.lte${l}.fastq
#
#chmod -w ${dir}/${base}.gt${l}.fastq.gz
#chmod -w ${dir}/${base}.lte${l}.fastq.gz
#
#count_fasta_reads.bash ${dir}/${base}.gt${l}.fastq.gz
#count_fasta_reads.bash ${dir}/${base}.lte${l}.fastq.gz
#
#average_fasta_read_length.bash ${dir}/${base}.gt${l}.fastq.gz
#average_fasta_read_length.bash ${dir}/${base}.lte${l}.fastq.gz


gzip ${base}.gt${l}.fastq
gzip ${base}.lte${l}.fastq

chmod -w ${base}.gt${l}.fastq.gz
chmod -w ${base}.lte${l}.fastq.gz

count_fasta_reads.bash ${base}.gt${l}.fastq.gz
count_fasta_reads.bash ${base}.lte${l}.fastq.gz

average_fasta_read_length.bash ${base}.gt${l}.fastq.gz
average_fasta_read_length.bash ${base}.lte${l}.fastq.gz


