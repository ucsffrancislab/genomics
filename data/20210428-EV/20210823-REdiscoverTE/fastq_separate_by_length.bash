#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x	#	print expanded command before executing it


base=$( basename $1 .fastq.gz )
outdir=/francislab/data1/working/20210428-EV/20210823-REdiscoverTE/output
mkdir -p ${outdir}

zcat $1 | paste - - - - | awk -F"\t" -v l=31 -v base=${base} -v outdir=${outdir} '\
{
	if( length($2)>l ){
		ext="gt"l".fastq"
	}else{
		ext="lte"l".fastq"
	}
	print $1"\n"$2"\n"$3"\n"$4 > outdir"/"base"."ext
}'

gzip ${outdir}/${base}.gt31.fastq
gzip ${outdir}/${base}.lte31.fastq

chmod -w ${outdir}/${base}.gt31.fastq.gz
chmod -w ${outdir}/${base}.lte31.fastq.gz

count_fasta_reads.bash ${outdir}/${base}.gt31.fastq.gz
count_fasta_reads.bash ${outdir}/${base}.lte31.fastq.gz


