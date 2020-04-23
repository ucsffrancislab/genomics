#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

REFS=/francislab/data1/refs
FASTA=${REFS}/fasta
BOWTIE2=${REFS}/bowtie2
date=$( date "+%Y%m%d%H%M%S" )


while [ $# -gt 0 ] ; do
	case $1 in
		-r1)
			shift; R1=$1; shift;;
		-r2)
			shift; R2=$1; shift;;
	esac
done


base=${R1%_R1.*}
sample=$( basename ${base} )
echo $base


bowtie2bam="${base}.hg38.bowtie2-e2e.bam"
bowtie2.bash \
	--xeq --threads ${PBS_NUM_PPN} --very-sensitive -x ${BOWTIE2}/hg38 \
	--rg-id ${sample} --rg "SM:${sample}" -1 ${R1} -2 ${R2} -o ${bowtie2bam}


unmapped_fasta="${base}.hg38.bowtie2-e2e.unmapped.fasta.gz"
samtools.bash fasta -f 4 --threads $[PBS_NUM_PPN-1] -N -o ${unmapped_fasta} ${bowtie2bam}


vmem=16

#for k in 11 21 31 ; do
for k in 21 ; do

	outbase="${base}.hg38.bowtie2-e2e.unmapped.${k}mers.dsk"

	h5="${outbase}.h5"
	dsk.bash \
		-nb-cores ${PBS_NUM_PPN} -kmer-size ${k} -abundance-min 0 \
		-max-memory $[vmem/2]000 -file ${unmapped_fasta} -out ${outbase}.h5

	dsk2ascii.bash -nb-cores ${PBS_NUM_PPN} -file ${h5} -out ${outbase}.txt.gz

done	#	for k in 21 ; do

