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

INDIR="/francislab/data1/raw/20200407_Schizophrenia/fastq"

DIR="/francislab/data1/working/20200407_Schizophrenia/20200819-coxsackievirus/out"
mkdir -p ${DIR}

for r1 in ${INDIR}/SD??_R1.fastq.gz ; do

	r2=${r1/_R1/_R2}

	base=$( basename $r1 _R1.fastq.gz )
	echo $base

	outbase="${DIR}/${base}.coxsackie"
	f=${outbase}.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Running bowtie2 scratch"

		r1_size=$( stat --dereference --format %s ${r1} )
		r2_size=$( stat --dereference --format %s ${r2} )
		#ref_size=$( stat --dereference --format %s ${reference} )
		#scratch=$( echo $(((${ref_size}+${normal_size}+${tumor_size})/${threads}/1000000000*11/10)) )
		scratch=$( echo $(( (2*(${r1_size}+${r2_size})/${threads}/1000000000*11/10)+1 )) )
		#	These files are small. Scratch will be 1.

		echo "Requesting ${scratch} scratch"
		qsub -N ${base} -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
			-l feature=nocommunal \
			-l gres=scratch:${scratch} \
			-j oe -o ${outbase}.${date}.out.txt \
			~/.local/bin/bowtie2_scratch.bash \
			-F "--sort --very-sensitive --xeq --threads ${threads} -x ${BOWTIE2}/Coxsackievirus \
					--rg-id ${base} --rg "SM:${base}" -1 ${r1} -2 ${r2} -o ${f}"
	fi

done
