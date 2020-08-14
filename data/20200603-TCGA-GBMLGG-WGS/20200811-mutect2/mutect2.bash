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
#vmem=62
threads=4
vmem=31
#scratch=25

#	should try to compute this need

#	running out of space so doubling all resources
#threads=16
#vmem=125


#scratch=32	#	doubling the threads, doubles the scratch space requested

#	don't really need that much thread and mem

date=$( date "+%Y%m%d%H%M%S" )

#	NOTE that these links are different than before because I had trimmed too far
INDIR="/francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/bam-long"
OUTDIR="/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200811-mutect2/out"
mkdir -p ${OUTDIR}

#	NEED FULL PATH HERE ON THE CLUSTER




#	01 - Primary Tumor
#	02 - Recurring Tumor
#	10 - Blood Derived Normal
#	11 - Solid Tissue Derived Normal


#	#	/francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/bam/02-2483-01A-01D-1494.bam
#	for tumor in ${INDIR}/??-????-01?-???-????.bam ; do
#	#for tumor in ${INDIR}/02-2483-01?-???-????.bam ; do


reference=/francislab/data1/refs/fasta/Homo_sapiens_assembly19.fasta


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
	normal_base=$( basename $normal .bam )
	tumor_base=$( basename $tumor .bam )
#	tumor_base=${tumor_base%-01?-???-????.bam}			#	shouldn't've done this. 2 duplicates.
#	#echo ${tumor_base}

	base=${OUTDIR}/${tumor_base}
	#echo ${base}

	#jobbase=$( basename ${base} )
	jobbase=${tumor_base}
	echo ${jobbase}


	outbase="${base}.mutect2"
	#out/TQ-A8XE.manta_strelka/strelka/results/variants/somatic.snvs.vcf.gz
	f=${outbase}.vcf.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else

		normal_size=$( stat --dereference --format %s ${normal} )
		tumor_size=$( stat --dereference --format %s ${tumor} )
		ref_size=$( stat --dereference --format %s ${reference} )
		scratch=$( echo $(((${ref_size}+${normal_size}+${tumor_size})/${threads}/1000000000*11/10)) )
		echo "Requesting ${scratch} scratch"

		#	echo $(((185258413619+184213132523)/8/1000000000))
		#	46
		#	echo $(((185258413619+184213132523)/8/1000000000*12/10))
		#	55

		#	gres=scratch should be about total needed divided by num threads
		#	I think that the reference NEEDs to be unzipped and have an index and a dict
		#	-l feature=nocommunal \
		qsub -N ${jobbase}.mutect2 -l gres=scratch:${scratch} \
			-l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
			-j oe -o ${outbase}.${date}.out.txt \
			~/.local/bin/mutect2_scratch.bash \
			-F "--input ${normal} \
				--input ${tumor} \
				--normal-sample TCGA-${normal_base} \
				--tumor-sample TCGA-${tumor_base} \
				--reference ${reference} \
				-A MappingQuality -A MappingQualityRankSumTest -A ReadPosRankSumTest \
				-A FisherStrand -A StrandOddsRatio -A DepthPerSampleHC -A InbreedingCoeff \
				-A QualByDepth -A RMSMappingQuality -A Coverage \
				--output ${f}"
	fi

done < /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200811-mutect2/test_tumor_normal_pairs.csv
#done < /francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/tumor_normal_pairs.csv



#A USER ERROR has occurred: Bad input: BAM header sample names [TCGA-02-2483-01A-01D-1494-08, TCGA-02-2483-10A-01D-1494-08]does not contain given tumor sample name TCGA-02-2483-01A-01D-1494



