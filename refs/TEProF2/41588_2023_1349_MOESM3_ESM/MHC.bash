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
	#module load CBI htslib samtools bowtie2
fi
#set -x	#	print expanded command before executing it



#fasta=/francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/S10/Modified-TCONS_00000820-9.faa
#fasta=/francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/S10/Original-TCONS_00000820-9.faa
#fasta=/francislab/data1/refs/PhIP-Seq/human_herpes.faa

fasta=$1

dir=$( dirname ${fasta} )/MHC
mkdir -p ${dir}

base=$( basename ${fasta} .faa )

echo "MHC Class I"

for allele in $( grep -E '^HLA' /c4/home/gwendt/.local/netMHCpan-4.1/data/allelenames | cut -d' ' -f1 ) ; do

	echo ${allele}

	~/.local/netMHCpan-4.1/netMHCpan -f ${fasta} \
		-l 10 -a ${allele} \
		| grep " <= SB" \
		>> ${dir}/${base}.netMHCpan.txt

		#-l 9 -a ${allele} \

done

echo
echo "MHC Class II"

for allele in $( grep -E '^(HLA|DRB)' /c4/home/gwendt/.local/netMHCIIpan-4.3/data/allelelist.txt | cut -d' ' -f1 ) ; do

	echo ${allele}

	#	MHC II really needs a longer length (~13) before it starts returning strong binding

	~/.local/netMHCIIpan-4.3/netMHCIIpan -f ${fasta} \
		-length 15 -a ${allele} \
		| grep " <= SB" \
		>> ${dir}/${base}.netMHCIIpan.txt

done


