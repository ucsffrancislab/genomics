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

#threads=8
#vmem=64
#scratch=16
#	running out of space so doubling all resources
threads=16
vmem=120
scratch=32

#	don't really need that much thread and mem

date=$( date "+%Y%m%d%H%M%S" )

INDIR="/francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/bam"
OUTDIR="/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200720-manta-strelka/out"
mkdir -p ${OUTDIR}

#	NEED FULL PATH HERE ON THE CLUSTER




#	01 - Primary Tumor
#	02 - Recurring Tumor
#	10 - Blood Derived Normal
#	11 - Solid Tissue Derived Normal


#	#	/francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/bam/02-2483-01A-01D-1494.bam
#	for tumor in ${INDIR}/??-????-01?-???-????.bam ; do
#	#for tumor in ${INDIR}/02-2483-01?-???-????.bam ; do


#	New way
while IFS=, read -r tumor normal ; do

#	echo ${tumor}
	tumor=${INDIR}/${tumor}.bam

#	echo ${normal}
	normal=${INDIR}/${normal}.bam

#	if [ $tumor == "/francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/bam/02-2483-01A-01D-1494.bam" ] ; then
#		echo skipping $tumor
#		continue
#	fi


#	normal=${tumor/N./T.}
#	echo ${normal}


#
#	There are 4 tumors with duplicated normal.
#	Using the first normal for no reason other than convenience.
#	Could be wrong.
#
#	/francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/bam/CS-6186-01A-12D-2022.bam
#	/francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/bam/CS-6186-10A-01D-2022.bam /francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/bam/CS-6186-10A-01D-2024.bam
#	/francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/bam/CS-6186-10A-01D-2022.bam
#	
#	/francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/bam/CS-6186-01A-12D-A461.bam
#	/francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/bam/CS-6186-10A-01D-2022.bam /francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/bam/CS-6186-10A-01D-2024.bam
#	/francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/bam/CS-6186-10A-01D-2022.bam
#	
#	/francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/bam/DU-5872-01A-11D-1703.bam
#	/francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/bam/DU-5872-10A-01D-1703.bam /francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/bam/DU-5872-10A-01D-A465.bam
#	/francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/bam/DU-5872-10A-01D-1703.bam
#	
#	/francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/bam/DU-5872-01A-11D-A465.bam
#	/francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/bam/DU-5872-10A-01D-1703.bam /francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/bam/DU-5872-10A-01D-A465.bam
#	/francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/bam/DU-5872-10A-01D-1703.bam
#	
#
#	And 1 case of 11 (solid tissue normal, not blood derived)
#
#	/francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/bam/FG-5963-01A-11D-1703.bam
#	/francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/bam/FG-5963-11A-01D-1703.bam

#	normal=${tumor/-01?-???-????.bam/-1\?\?-\?\?\?-\?\?\?\?.bam}
#	#echo ${normal}
#	#ls -1 $normal | wc -l
#	normal=$( ls -1 $normal | head -1 )
#	#echo ${normal}
#
#	#echo
#
	tumor_base=$( basename $tumor .bam )
#	tumor_base=${tumor_base%-01?-???-????.bam}			#	shouldn't've done this. 2 duplicates.
#	#echo ${tumor_base}

	base=${OUTDIR}/${tumor_base}
	#echo ${base}

	#jobbase=$( basename ${base} )
	jobbase=${tumor_base}
	echo ${jobbase}


	outbase="${base}.manta_strelka"
	#out/TQ-A8XE.manta_strelka/strelka/results/variants/somatic.snvs.vcf.gz
	f=${outbase}/strelka/results/variants/somatic.snvs.vcf.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		#	gres=scratch should be about total needed divided by num threads
		#	I think that the reference NEEDs to be unzipped and have an index
		qsub -N ${jobbase}.mantastrelka -l gres=scratch:${scratch} \
			-l feature=nocommunal \
			-l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
			-j oe -o ${outbase}.${date}.out.txt \
			~/.local/bin/manta_strelka_scratch.bash \
			-F "--normalBam ${normal} \
				--tumorBam ${tumor} \
				--referenceFasta /francislab/data1/refs/fasta/Homo_sapiens_assembly19.fasta \
				--memGb ${vmem} \
				--dir ${outbase}"
	fi

###done	#	for tumor in
done < /francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/tumor_normal_pairs.csv
