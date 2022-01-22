#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

#set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
set -o pipefail
if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	module load CBI samtools
	#module load CBI samtools/1.13 bowtie2/2.4.4 
	#bedtools2/2.30.0
fi
#set -x  #       print expanded command before executing it


IN="/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20220103-viral-chimera/out"
OUT="/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20220121-human-viral-chimera/out"

#while [ $# -gt 0 ] ; do
#	case $1 in
#		-d|--dir)
#			shift; OUT=$1; shift;;
#		*)
#			echo "Unknown params :${1}:"; exit ;;
#	esac
#done

mkdir -p ${OUT}

line=${SLURM_ARRAY_TASK_ID:-1}
echo "Running line :${line}:"

#	Use a 1 based index since there is no line 0.

r1=$( ls -1 ${IN}/*.viral.R1.fastq.gz | sed -n "$line"p )
echo $r1

if [ -z "${r1}" ] ; then
	echo "No line at :${line}:"
	exit
fi



date=$( date "+%Y%m%d%H%M%S" )


echo $r1
r2=${r1/.R1./.R2.}
echo $r2
s=$( basename $r1 .viral.R1.fastq.gz )


#	Select those that align to viral masked then align those to human


outbase=${OUT}/${s}.hg38viral

f=${outbase}.bam
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	~/.local/bin/bowtie2.bash \
		--threads 8 \
		-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts.dblmaskviral \
		--very-sensitive -1 ${r1} -2 ${r2} -o ${f}
fi


f=${outbase}.chimeric.bam
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	samtools view -h ${outbase}.bam | awk -F"\t" '( /^@/ ) || ( ( $3 != $7 ) && ( $7 != "=" ) && !( ( $3 ~ /^chr/ ) && ( $7 ~ /^chr/ ) ) )' | samtools view -o ${f} -
	chmod -w ${f}
fi


f=${outbase}.chimeric.nonchr_counts.txt
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	samtools view ${outbase}.chimeric.bam | awk '( $3 !~ /^chr/ ){print $3}' | sort | uniq -c > ${f}
	chmod -w ${f}
fi



date
exit



895


mkdir -p /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20220121-human-viral-chimera/logs
date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-895%8 --job-name="viralchimera" --output="/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20220121-human-viral-chimera/logs/array.${date}-%A_%a.out" --time=4320 --nodes=1 --ntasks=8 --mem=60G --gres=scratch:250G /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20220121-human-viral-chimera/array_wrapper.bash


scontrol update ArrayTaskThrottle=6 JobId=352083


