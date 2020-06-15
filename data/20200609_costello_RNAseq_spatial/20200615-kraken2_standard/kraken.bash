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
STAR=${REFS}/STAR

#	do exported variables get passed to submitted jobs? No
#export BOWTIE2_INDEXES=/francislab/data1/refs/bowtie2
#export BLASTDB=/francislab/data1/refs/blastn
vmem=8
threads=8

date=$( date "+%Y%m%d%H%M%S" )


#
#	NOTE: This data is all Paired RNA
#

INDIR="/francislab/data1/working/20200609_costello_RNAseq_spatial/20200612-prepare/trimmed/length"
DIR="/francislab/data1/working/20200609_costello_RNAseq_spatial/20200615-kraken2_standard/out"

for r1 in ${INDIR}/*_R1.fastq.gz ; do

	#base=${r1%_R1.fastq.gz}
	r2=${r1/_R1/_R2}

	base=$( basename $r1 _R1.fastq.gz )
	echo $base

	outbase="${DIR}/${base}.kraken2_standard"

	f=${outbase}.txt.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		qsub -N ${base}.kraken -l nodes=1:ppn=${threads} -l vmem=32gb \
			-j oe -o ${outbase}.${date}.out.txt \
			~/.local/bin/kraken2_scratch.bash \
			-F "--db ${KRAKEN2}/standard --threads ${threads} --output ${f} --paired --use-names -1 ${r1} -2 ${r2}"
	fi

done
