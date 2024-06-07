#!/usr/bin/env bash
#SBATCH --export=NONE		# required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail
if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	module load CBI samtools	#/1.10
fi
set -x



bam=$1

SAMPLE_ID=$( basename ${bam} .VIR3_clean.1-80.bam )
base=${bam%.VIR3_clean.1-80.bam}

samtools idxstats $bam | cut -f 1,3 | sed -e '/^\*\t/d' | sort -k1n | sed -e "1 i id\t${SAMPLE_ID}" | tr "\\t" "," | gzip > ${base}.idxstats.count.csv.gz

#samtools idxstats out/SRR13277039.VIR3_clean.1-80.bam | cut -f 1,3 | sed -e '/^\*\t/d' | sort -k1n | sed -e "1 i id\t${SAMPLE_ID}" |  tr "\\t" "," | head
#id,SRR13277039
#1,0
#2,14
#3,0
#4,0
#5,4
#6,0
#7,9
#8,0
#9,1
#
#
#samtools view -q 40 out/SRR13277039.VIR3_clean.1-80.bam | cut -f3 | sort -k1n | uniq -c | head | awk 'BEGIN{OFS=","}{print $2,$1}'
#2,14
#5,4
#7,9
#9,1
#10,2
#11,18
#14,4
#15,7
#16,2
#17,1

samtools view -q 20 ${bam} | cut -f3 | sort -k1n | uniq -c | awk '{print $2","$1}' | sed -e "1 i id,${SAMPLE_ID}" | gzip > ${base}.q20.count.csv.gz

samtools view -q 30 ${bam} | cut -f3 | sort -k1n | uniq -c | awk '{print $2","$1}' | sed -e "1 i id,${SAMPLE_ID}" | gzip > ${base}.q30.count.csv.gz

samtools view -q 40 ${bam} | cut -f3 | sort -k1n | uniq -c | awk '{print $2","$1}' | sed -e "1 i id,${SAMPLE_ID}" | gzip > ${base}.q40.count.csv.gz


