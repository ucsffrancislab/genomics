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
DIR="/francislab/data1/working/20200609_costello_RNAseq_spatial/20200615-STAR_hg38/out"
mkdir -p ${DIR}

for r1 in ${INDIR}/*_R1.fastq.gz ; do

	#base=${r1%_R1.fastq.gz}
	r2=${r1/_R1/_R2}

	base=$( basename $r1 _R1.fastq.gz )
	echo $base

	outbase="${DIR}/${base}.STAR.hg38"
	starid=""
	f=${outbase}.Aligned.out.bam
	starbam=${f}
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		starid=$( qsub -N ${base}.STAR -l nodes=1:ppn=${threads} -l vmem=32gb \
			-j oe -o ${outbase}.${date}.out.txt \
			~/.local/bin/STAR_scratch.bash \
			-F "--runMode alignReads \
				--outFileNamePrefix ${outbase}. \
				--outSAMtype BAM Unsorted \
				--genomeDir ${STAR}/hg38 \
				--runThreadN ${threads} \
				--outSAMattrRGline ID:${base} SM:${base} \
				--readFilesCommand zcat \
				--outSAMunmapped Within KeepPairs \
				--readFilesIn ${r1} ${r2}" )
		#	I think that KeepPairs could have been dropped
		#		--outSAMunmapped Within KeepPairs
		#	Paired reads. To preserve lane and simplify merging, keep in sam.
		#		--outReadsUnmapped Fastx \
		echo "${starid}"
	fi

done
