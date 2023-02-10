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
	#module load CBI samtools
	module load CBI samtools/1.13 bowtie2/2.4.4 
	#bedtools2/2.30.0
fi
#set -x  #       print expanded command before executing it


IN="/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230124-hg38-bwa/out"
OUT="/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230202-bwa-MELT-2.1.5-SPLIT/out"

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
#sample=$( sed -n ${line}p to_run.txt )
#echo ${sample}

#bam=$( cat to_run.txt | sed -n ${line}p )
bam=$( ls -1 ${IN}/*bam | sed -n "$line"p )
echo $bam

if [ -z "${bam}" ] ; then
	echo "No line at :${line}:"
	exit
fi

date=$( date "+%Y%m%d%H%M%S%N" )

basename=$( basename $bam .bam )
echo ${basename}


MELTJAR="/c4/home/gwendt/.local/MELTv2.1.5fast/MELT.jar"


inbase=${OUT}/${basename}


outbase=${OUT}/DISCOVERYGENO/${basename}
f=${outbase}.tsv
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else

	java -Xmx2G -jar ${MELTJAR} Genotype \
		-bamfile ${inbase}.bam \
		-t ~/.local/MELTv2.2.2/me_refs/Hg38/transposon_file_list.txt \
		-h /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/20180810/hg38.chrXYM_alts.fa \
		-w $( dirname ${f} ) \
		-p ${OUT}/DISCOVERYGROUP/

	chmod -w ${f}
fi


#for mei in ALU HERVK LINE1 SVA ; do
#
#	outbase=${OUT}/${mei}DISCOVERYGENO/${basename}.${mei}
#	f=${outbase}.tsv
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#
#		java -Xmx2G -jar ${MELTJAR} Genotype \
#			-bamfile ${inbase}.bam \
#			-t ~/.local/MELTv2.2.2/me_refs/Hg38/${mei}_MELT.zip \
#			-h /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/20180810/hg38.chrXYM_alts.fa \
#			-w $( dirname ${f} ) \
#			-p ${OUT}/${mei}DISCOVERYGROUP/
#
#		chmod -w ${f}
#	fi
#
#done


date
exit





ls -1 /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out/*_R1.fastq.gz | xargs -I% basename % _R1.fastq.gz > to_run.txt
wc -l to_run.txt 
278 to_run.txt



ll /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20220329-hg38/out/*bam | wc -l

mkdir -p ${PWD}/logs
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-278%16 --job-name="MELT3" --output="${PWD}/logs/MELT3.${date}-%A_%a.out" --time=4320 --nodes=1 --ntasks=2 --mem=10G ${PWD}/MELT_3_array_wrapper.bash

Looks like about 10 hours each? Many on n17 are at 25hours and they are only halfway!
34 hours now.



mkdir -p ${PWD}/logs
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-4%4 --job-name="MELT3" --output="${PWD}/logs/MELT3.${date}-%A_%a.out" --time=4320 --nodes=1 --ntasks=4 --mem=40G ${PWD}/MELT_3_array_wrapper.bash

scontrol update ArrayTaskThrottle=6 JobId=352083


