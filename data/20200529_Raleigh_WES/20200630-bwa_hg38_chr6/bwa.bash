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
BWA=${REFS}/bwa

#	do exported variables get passed to submitted jobs? No
#export BOWTIE2_INDEXES=/francislab/data1/refs/bowtie2
#export BLASTDB=/francislab/data1/refs/blastn
threads=8
vmem=64

date=$( date "+%Y%m%d%H%M%S" )

INDIR="/francislab/data1/working/20200529_Raleigh_WES/20200604-prepare/trimmed/length"
OUTDIR="/francislab/data1/working/20200529_Raleigh_WES/20200630-bwa_hg38_chr6/out"
mkdir -p ${OUTDIR}

#	NEED FULL PATH HERE ON THE CLUSTER

for r1 in ${INDIR}/*_R1.fastq.gz ; do
	echo ${r1}

	r2=${r1/R1/R2}
	echo ${r2}

	base=${OUTDIR}/$( basename $r1 _R1.fastq.gz )
	echo ${base}

	jobbase=$( basename ${base} )
	echo ${jobbase}


	for ref in hg38_chr6  ; do

		outbase=${base}.${ref}
		#	bowtie2 really only uses a bit more memory than the reference.
		#	4gb would probably be enough for hg38. Nope. Needs more than 4.
		#	Ran well with 8gb.
		#vmem=8
		#	with the --sort option, needs much more memory.

		outbase="${base}.${ref}.bwa"
		bwaid=""
		f=${outbase}.bam
		bwabam=${f}
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			bwaid=$( qsub -N ${jobbase}.${ref} \
				-l nodes=1:ppn=${threads} -l vmem=${vmem}gb -l gres=scratch:5 \
				-j oe -o ${outbase}.${date}.out.txt -l feature=nocommunal \
				~/.local/bin/bwa_mem_scratch.bash \
				-F "--index ${BWA}/${ref} --sort --mem ${vmem}GB \
					-R \"@RG\tID:${jobbase}\tSM:${jobbase}\" \
					-1 ${r1} -2 ${r2} -o ${outbase}.bam" )
			echo "${bwaid}"
		fi

	done	#	for ref in

done	#	for r1 in
