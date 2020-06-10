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
vmem=64

#	don't really need that much thread and mem

date=$( date "+%Y%m%d%H%M%S" )

INDIR="/francislab/data1/working/20200529_Raleigh_WES/20200605-hg38/out"
OUTDIR="/francislab/data1/working/20200529_Raleigh_WES/20200607-manta-strelka/out"
mkdir -p ${OUTDIR}

#	NEED FULL PATH HERE ON THE CLUSTER

for normal in ${INDIR}/??N.h38au.bowtie2-e2e.PP.bam ; do
	echo ${normal}

	tumor=${normal/N./T.}
	echo ${tumor}

	base=${OUTDIR}/$( basename $normal N.h38au.bowtie2-e2e.PP.bam )
	echo ${base}

	jobbase=$( basename ${base} )
	echo ${jobbase}

	outbase="${base}.manta"
	mantaid=""
	f="${outbase}/results/variants/candidateSmallIndels.vcf.gz"
	indelCandidates="${f}"
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		#	gres=scratch should be about total needed divided by num threads
		mantaid=$( qsub -N ${jobbase}.manta \
			-l nodes=1:ppn=${threads} -l vmem=${vmem}gb -l gres=scratch:10 \
			-j oe -o ${outbase}.${date}.out.txt \
			~/.local/bin/manta_scratch.bash \
			-F "--normalBam ${normal} \
				--tumorBam ${tumor} \
				--referenceFasta /francislab/data1/refs/fasta/h38au.fa \
				--exome \
				--memGb ${vmem} \
				--dir ${outbase}" )
		echo "${mantaid}"
	fi

	outbase="${base}.strelka"
	depend=""
	f=${outbase}/results/variants/somatic.snvs.vcf.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${mantaid} ] ; then
			depend="-W depend=afterok:${mantaid}"
		else
			depend=""
		fi
		#	gres=scratch should be about total needed divided by num threads
		strelkaid=$( qsub ${depend} -N ${jobbase}.strelka -l gres=scratch:10 \
			-l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
			-j oe -o ${outbase}.${date}.out.txt \
			~/.local/bin/strelka_scratch.bash \
			-F "--normalBam ${normal} \
				--tumorBam ${tumor} \
				--referenceFasta /francislab/data1/refs/fasta/h38au.fa \
				--indelCandidates ${indelCandidates} \
				--exome \
				--memGb ${vmem} \
				--dir ${outbase}" )
		echo "${strelkaid}"
	fi

done	#	for normal in
