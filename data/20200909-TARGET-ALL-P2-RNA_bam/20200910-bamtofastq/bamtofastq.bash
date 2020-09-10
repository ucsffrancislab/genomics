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

#	gonna use about 400-500GB of disk space
#	could check filesize before running to be more precise


threads=4
vmem=32
scratch=125

#threads=2
#vmem=16
#scratch=150

#	don't really need that much thread and mem

date=$( date "+%Y%m%d%H%M%S" )

INDIR="/francislab/data1/raw/20200909-TARGET-ALL-P2-RNA_bam/bam"
OUTDIR="/francislab/data1/working/20200909-TARGET-ALL-P2-RNA_bam/20200910-bamtofastq/out"
mkdir -p ${OUTDIR}

#	NEED FULL PATH HERE ON THE CLUSTER

#for bam in ${INDIR}/02-2485*.bam ; do
#for bam in ${INDIR}/02-2483-*.bam ; do
for bam in ${INDIR}/*.bam ; do

	echo ${bam}

	jobbase=$( basename ${bam} .bam )
	echo ${jobbase}

	base=${OUTDIR}/${jobbase}
	#echo ${base}

	outbase="${base}"
	f=${outbase}_R1.fastq.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else

		#scratch=$( stat --dereference --format %s ${bam} | awk -v p=${threads} '{print int(1.7*$1/p/1000000000)}' )

		bam_size=$( stat --dereference --format %s ${bam} )
		#scratch=$( echo $(( ((${bam_size})/${threads}/1000000000*18/10)+1 )) )
		scratch=$( echo $(( (${bam_size}/${threads}/1000000000*2)+1 )) )

		echo "Requesting ${scratch} scratch"
		#	gres=scratch should be about total needed divided by num threads

		qsub -N ${jobbase}.tofastq -l gres=scratch:${scratch} \
			-l feature=nocommunal \
			-l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
			-j oe -o ${outbase}.${date}.out.txt \
			~/.local/bin/bamtofastq_scratch.bash \
			-F "collate=1 \
				exclude=DUP,QCFAIL,SECONDARY,SUPPLEMENTARY \
				filename=${bam} \
				inputformat=bam \
				gz=1 \
				level=5 \
				T=${outbase}_TEMP \
				F=${outbase}_R1.fastq.gz \
				F2=${outbase}_R2.fastq.gz \
				S=${outbase}_S1.fastq.gz \
				O=${outbase}_O1.fastq.gz \
				O2=${outbase}_O2.fastq.gz"
	fi

done	#	for bam in

