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

threads=16
vmem=120

#	don't really need that much thread and mem

date=$( date "+%Y%m%d%H%M%S" )

INDIR="/francislab/data1/working/CCLS/20210215-downsampling_test/bam"
OUTDIR="/francislab/data1/working/CCLS/20210222-manta-strelka/out"
mkdir -p ${OUTDIR}

#	NEED FULL PATH HERE ON THE CLUSTER

#	01 - Primary Tumor
#	02 - Recurring Tumor
#	10 - Blood Derived Normal
#	11 - Solid Tissue Derived Normal

#	New way
#while IFS=, read -r tumor normal ; do

for tumor in ${INDIR}/[^G]*.bam ; do

	echo ${tumor}
	base=$( basename ${tumor} .bam )
	echo ${base}

	subject=$( basename ${tumor%.???.bam} )
	echo $subject

	normal=${INDIR}/GM_${subject}.100.bam
	echo ${normal}

	outbase="${OUTDIR}/${base}.manta_strelka"
#	#.....out/TQ-A8XE.manta_strelka/strelka/results/variants/somatic.snvs.vcf.gz
	f=${outbase}/strelka/results/variants/somatic.snvs.vcf.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Running ~/.local/bin/manta_strelka_scratch.bash"

		index=/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.numericXYMT_no_alts.fa
		tumor_size=$( stat --dereference --format %s ${tumor} )
		normal_size=$( stat --dereference --format %s ${normal} )
		index_size=$( du -sb ${index} | awk '{print $1}' )
		#scratch=$( echo $(( ((${r1_size}+${r2_size}+${index_size})/${threads}/1000000000*11/10)+1 )) )
		# Add 1 in case files are small so scratch will be 1 instead of 0.
		# 11/10 adds 10% to account for the output

		#	Manta and scratch seems to produce a lot of intermediate files

		scratch=$( echo $(( ((${tumor_size}+${normal_size}+${index_size})/${threads}/1000000000*30/10)+1 )) )

		echo "Using scratch:${scratch}"

		sbatch --time=7200 --parsable --ntasks=${threads} --mem=${vmem}G --job-name ${base} \
			--gres=scratch:${scratch}G --output ${outbase}.${date}.txt \
			~/.local/bin/manta_strelka_scratch.bash \
				--threads ${threads} \
				--normalBam ${normal} \
				--tumorBam ${tumor} \
				--referenceFasta ${index} \
				--memGb ${vmem} \
				--dir ${outbase}
	fi

done	#	for tumor in
#done < /francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/tumor_normal_pairs.csv


