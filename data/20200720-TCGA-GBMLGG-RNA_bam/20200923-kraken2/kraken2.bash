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
SALMON=${REFS}/salmon

INDIR="/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/subject"
DIR="/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200923-kraken2/out"
mkdir -p ${DIR}

#	remember 64 cores and ~504GB mem
threads=8
vmem=62

date=$( date "+%Y%m%d%H%M%S" )

for r1 in ${INDIR}/[1-9]*_R1.fastq.gz ; do

#	Only want to process the ALL files at the moment so ...
#while IFS=, read -r r1 ; do


	base=${r1%_R1.fastq.gz}
	r2=${r1/_R1/_R2}

	base=$( basename $r1 _R1.fastq.gz )
	echo $base

	outbase="${DIR}/${base}.kraken2_abv"
	f=${outbase}.txt.gz
	#if [ -d $f ] && [ ! -w $f ] ; then
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		index=${KRAKEN2}/abv
		r1_size=$( stat --dereference --format %s ${r1} )
		r2_size=$( stat --dereference --format %s ${r2} )
		index_size=$( du -sb ${index} | awk '{print $1}' )
		scratch=$( echo $(( ((2*(${r1_size}+${r2_size})+${index_size})/${threads}/1000000000)+1 )) )

		#	Add 1 in case files are small so scratch will be 1 instead of 0.
		#	11/10 adds 10% to account for the output

		echo "Using scratch:${scratch}"

		qsub -N ${base} -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
			-l feature=nocommunal \
			-l gres=scratch:${scratch} \
			-j oe -o ${outbase}.${date}.out.txt \
			~/.local/bin/kraken2_scratch.bash \
			-F "--db ${index} --threads ${threads} --output ${f} --paired --use-names --report ${f}.kreport.txt -1 ${r1} -2 ${r2}"
			#-F "--db ${KRAKEN2}/standard --threads ${threads} --output ${f} --paired --use-names --report ${f}.kreport.txt -1 ${r1} -2 ${r2}"
	fi

#done < ALL-P2.fastq_files.txt

done

