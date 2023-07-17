#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail
if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	module load CBI blast
fi
set -x	#	print expanded command before executing it

zcat /c4/home/gwendt/github/ucsffrancislab/Human_Virome_analysis/virus_genome_for_second_blast.fas.gz /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome.fa.gz /francislab/data1/refs/refseq/archaea-20230714/archaea.*.genomic.fna.gz /francislab/data1/refs/refseq/bacteria-20210916/bacteria.*.genomic.fna.gz | makeblastdb -input_type fasta -dbtype nucl -parse_seqids -out ${PWD}/db_for_second_blast -title db_for_second_blast

