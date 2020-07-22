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

threads=4
vmem=32
scratch=16
#	running out of space so doubling all resources
#threads=16
#vmem=120
#scratch=32

#	don't really need that much thread and mem

date=$( date "+%Y%m%d%H%M%S" )

INDIR="/francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/bam"
OUTDIR="/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out"
mkdir -p ${OUTDIR}

#	NEED FULL PATH HERE ON THE CLUSTER

#	01 - Primary Tumor
#	02 - Recurring Tumor
#	10 - Blood Derived Normal
#	11 - Solid Tissue Derived Normal


#for bam in ${INDIR}/02-2485*.bam ; do
for bam in ${INDIR}/02-2483-0*.bam ; do

	echo ${bam}

	jobbase=$( basename ${bam} .bam )
	echo ${jobbase}

	base=${OUTDIR}/${jobbase}
	#echo ${base}

	outbase="${base}"
	f=${outbase}/results/variants/somatic.snvs.vcf.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		#	gres=scratch should be about total needed divided by num threads
		#	-l feature=nocommunal \
		qsub -N ${jobbase}.tofastq -l gres=scratch:${scratch} \
			-l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
			-j oe -o ${outbase}.${date}.out.txt \
			~/.local/bin/bamtofastq_scratch.bash \
			-F "collate=1 \
				exclude=QCFAIL,SECONDARY,SUPPLEMENTARY \
				filename=${bam} \
				gz=1 \
				inputformat=bam \
				level=5 \
				outputdir=${OUTDIR} \
				outputperreadgroup=1 \
				outputperreadgroupsuffixF=_1.fq.gz \
				outputperreadgroupsuffixF2=_2.fq.gz \
				outputperreadgroupsuffixO=_o1.fq.gz \
				outputperreadgroupsuffixO2=_o2.fq.gz \
				outputperreadgroupsuffixS=_s.fq.gz \
				tryoq=1"
	fi

done	#	for bam in

