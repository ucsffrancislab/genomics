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


IN="/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20220329-hg38/out"
OUT="/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230110-MELT-2.0.5/out"

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


MELTJAR="/c4/home/gwendt/.local/MELTv2.1.5fast/MELT-v2.0.5-r38-v4.jar"


outbase=${OUT}/${basename}
inbase=${outbase}
f=${outbase}.bam
if [ -h $f ] ; then
	#       -h file True if file exists and is a symbolic link.
	echo "Link $f exists. Skipping."
else
	ln -s ${bam} ${f}
	ln -s ${bam}.bai ${f}.bai
fi



ave_read_length=$( samtools view ${f} | head -100 | awk '{s+=length($10)}END{print s/NR}' )

aligned_read_count=$( cat ${f}.bai| ~/.local/bin/bamReadDepther | grep "^#" | awk '{s+=$1;s+=$2}END{print s}' )

#zcat /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_no_alts.fa.gz | grep -vs "^>" | awk '{s+=length($0)}END{print s}'
#3088286401

coverage=$[($aligned_read_count*$ave_read_length)/3088286401]

echo "Computed depth of coverage at ${coverage}"

#cat out/02-2483-01A-01D-1494.bam.bai | ~/.local/bin/bamReadDepther | grep "^#" | awk '{s+=$1;s+=$2}END{print s}'
#1103198361

#	* read length. Assume all the same. Check first 100.

#




f=${outbase}.bam.disc.bai
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	java -Xmx2G -jar ${MELTJAR} Preprocess \
		-bamfile ${inbase}.bam \
		-h /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts.fa
	chmod -w ${f}
	chmod -w ${f%.bai}
	chmod -w ${f%.disc.bai}.fq
fi

inbase=${outbase}

for mei in ALU HERVK LINE1 SVA ; do

	outbase=${OUT}/${mei}DISCOVERYIND/${basename}.${mei}
	f=${outbase}.tmp.bed
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		java -Xmx6G -jar ${MELTJAR} IndivAnalysis \
			-c ${coverage} \
	  	-bamfile ${inbase}.bam \
	  	-h /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts.fa \
	  	-t ~/.local/MELTv2.2.2/me_refs/Hg38/${mei}_MELT.zip \
	  	-w $( dirname ${f} )/
		chmod -w ${outbase}.*

		#	2.0.5 and 2.1.5 both require -c "Coverage level of supplied bam file." 2.2.2 does this automatically.
	
		#-rw-r----- 1 gwendt francislab 31539463 Nov 29 11:03 TQ-A8XE-10A-01D-A367.LINE1.aligned.final.sorted.bam
		#-rw-r----- 1 gwendt francislab       96 Nov 29 11:03 TQ-A8XE-10A-01D-A367.LINE1.aligned.final.sorted.bam.bai
		#-rw-r----- 1 gwendt francislab 12526748 Nov 29 11:09 TQ-A8XE-10A-01D-A367.LINE1.aligned.pulled.sorted.bam
		#-rw-r----- 1 gwendt francislab  2394960 Nov 29 11:09 TQ-A8XE-10A-01D-A367.LINE1.aligned.pulled.sorted.bam.bai
		#-rw-r----- 1 gwendt francislab   707113 Nov 29 11:32 TQ-A8XE-10A-01D-A367.LINE1.hum_breaks.sorted.bam
		#-rw-r----- 1 gwendt francislab  1444464 Nov 29 11:32 TQ-A8XE-10A-01D-A367.LINE1.hum_breaks.sorted.bam.bai
		#-rw-r----- 1 gwendt francislab     5464 Nov 29 11:32 TQ-A8XE-10A-01D-A367.LINE1.tmp.bed
	fi

done



date
exit



Took about 50 hours in total running 20 tasks.
This seems to really only use 1 thread and about 3GB so could really ramp this up.
Changing to 2/10G for "next" go.


ll /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20220329-hg38/out/*bam | wc -l

mkdir -p ${PWD}/logs
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-278%4 --job-name="MELT1" --output="${PWD}/logs/MELT1.${date}-%A_%a.out" --time=4320 --nodes=1 --ntasks=2 --mem=10G ${PWD}/MELT_1_array_wrapper.bash


scontrol update ArrayTaskThrottle=6 JobId=352083


ls -1 /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out/*_R1.fastq.gz | xargs -I% basename % _R1.fastq.gz > to_run.txt
wc -l to_run.txt 
278 to_run.txt
