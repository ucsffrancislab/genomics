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

date=$( date "+%Y%m%d%H%M%S" )

INDIR="/francislab/data1/working/20200529_Raleigh_WES/20200604-prepare/trimmed/length"
OUTDIR="/francislab/data1/working/20200529_Raleigh_WES/20200610-HKLE_chimera/out"
mkdir -p ${OUTDIR}

#	NEED FULL PATH HERE ON THE CLUSTER

for r1 in ${INDIR}/???_R1.fastq.gz ; do
	echo ${r1}

	r2=${r1/R1/R2}
	echo ${r2}

	base=${OUTDIR}/$( basename $r1 _R1.fastq.gz )
	echo ${base}

	jobbase=$( basename ${base} )
	echo ${jobbase}

	outbase="${base}.hkle"
	f=${outbase}
	if [ -d $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		#	gres=scratch should be about total needed divided by num threads
		qsub -N ${jobbase}.hkle \
			-l nodes=1:ppn=${threads} -l vmem=${vmem}gb -l gres=scratch:100 \
			-j oe -o ${outbase}.${date}.out.txt \
			~/.local/bin/hkleseq_scratch.bash \
			-F "--base ${jobbase} -1 $r1 -2 $r2 --dir ${f} --human ${BOWTIE2}/hg38 --index_dir ${BOWTIE2}/SVAs_and_HERVs_KWHE"
	fi

done	#	for r1 in
