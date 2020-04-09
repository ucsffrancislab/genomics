#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail


REFS=/francislab/data1/refs
FASTA=${REFS}/fasta
KALLISTO=${REFS}/kallisto
SUBREAD=${REFS}/subread
BOWTIE2=${REFS}/bowtie2
BLASTDB=${REFS}/blastn
KRAKEN2=${REFS}/kraken2
DIAMOND=${REFS}/diamond

#	do exported variables get passed to submitted jobs? No
#export BOWTIE2_INDEXES=/francislab/data1/refs/bowtie2
#export BLASTDB=/francislab/data1/refs/blastn
threads=8
vmem=8

date=$( date "+%Y%m%d%H%M%S" )



for r1 in /francislab/data1/working/20200407_Schizophrenia/20200407-21mer_matrix/trimmed/length/????_R1.fastq.gz ; do

	#	NEED FULL PATH HERE ON THE CLUSTER
	base=${r1%.fastq.gz}
	r2=${r1/_R1/_R2}

	echo $base
	jobbase=$( basename ${base} )

	outbase="${base}.hg38.bowtie2-e2e.unmapped.21mers.dsk"
	f="${outbase}.txt.gz"
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		qsub -N ${jobbase}.unk -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
			-j oe -o ${outbase}.${date}.out.txt \
			~/.local/bin/nonhuman_dsk.bash \
				-F "-r1 ${r1} -r2 ${r2}"
	fi

done	#	for r1 in 

