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

INDIR="/francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/bam"
OUTDIR="/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200720-manta-strelka/out"
mkdir -p ${OUTDIR}

#	NEED FULL PATH HERE ON THE CLUSTER

#	/francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/bam/02-2483-01A-01D-1494.bam
#for normal in ${INDIR}/??-????-01?-???-????.bam ; do
for normal in ${INDIR}/02-2483-01?-???-????.bam ; do
	echo ${normal}

#	tumor=${normal/N./T.}
#	echo ${tumor}


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
#	/francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/bam/FG-5963-11A-01D-1703.bam

	tumor=${normal/-01?-???-????.bam/-1\?\?-\?\?\?-\?\?\?\?.bam}
	echo ${tumor}
	tumor=$( ls $tumor | head -1 )
	echo ${tumor}

	echo

	normal_base=$( basename $normal )
	normal_base=${normal_base%-01?-???-????.bam}
	echo ${normal_base}

	base=${OUTDIR}/${normal_base}
	echo ${base}

	#jobbase=$( basename ${base} )
	jobbase=${normal_base}
	echo ${jobbase}

	outbase="${base}.manta"
	mantaid=""
	f="${outbase}/results/variants/candidateSmallIndels.vcf.gz"
	indelCandidates="${f}"


	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		#	gres=scratch should be about total needed divided by num threads
	##			--referenceFasta /francislab/data1/refs/fasta/h38au.fa \
	##			--exome \
		mantaid=$( qsub -N ${jobbase}.manta \
			-l feature=nocommunal \
			-l nodes=1:ppn=${threads} -l vmem=${vmem}gb -l gres=scratch:10 \
			-j oe -o ${outbase}.${date}.out.txt \
			~/.local/bin/manta_scratch.bash \
			-F "--normalBam ${normal} \
				--tumorBam ${tumor} \
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
	##	I think that the reference NEEDs to be unzipped and have an index
	##	Do I need it at all?
	##			--referenceFasta /francislab/data1/refs/fasta/h38au.fa \
	##			--exome \
		strelkaid=$( qsub ${depend} -N ${jobbase}.strelka -l gres=scratch:10 \
			-l feature=nocommunal \
			-l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
			-j oe -o ${outbase}.${date}.out.txt \
			~/.local/bin/strelka_scratch.bash \
			-F "--normalBam ${normal} \
				--tumorBam ${tumor} \
				--indelCandidates ${indelCandidates} \
				--memGb ${vmem} \
				--dir ${outbase}" )
		echo "${strelkaid}"
	fi

done	#	for normal in
