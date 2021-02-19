#!/usr/bin/env bash
#SBATCH --export=NONE      # required when using 'module'

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail
if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	#module load CBI htslib samtools bowtie2
	#module load CBI bcftools/1.11
	module load CBI bcftools/1.10.2
fi
set -x	#	print expanded command before executing it

dirname=$( dirname $1 )
#pdirname=$( dirname $dirname )
basename=$( basename $1 .bam )

f=${basename}.vcf.gz
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	cp $1 ${TMPDIR}/
	bam=${TMPDIR}/$( basename $1 )
	cp /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.numericXYMT_no_alts.fa ${TMPDIR}/
	ref=${TMPDIR}/hg38.numericXYMT_no_alts.fa
	vcf=${TMPDIR}/${basename}.vcf.gz

	bcftools mpileup --threads 2 -Ou -f ${ref} ${bam} | bcftools call --threads 2 -mv -Oz -o ${vcf}
	bcftools index ${vcf}
	mv ${vcf} ${dirname}/
	mv ${vcf}.csi ${dirname}/
	chmod a-w ${dirname}/$( basename ${vcf} )
	chmod a-w ${dirname}/$( basename ${vcf} ).csi
fi

