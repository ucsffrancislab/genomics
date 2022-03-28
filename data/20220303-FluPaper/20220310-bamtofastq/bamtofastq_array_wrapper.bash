#!/usr/bin/env bash

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

#set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
set -o pipefail
if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	#module load CBI samtools/1.13 bowtie2/2.4.4 
	#bedtools2/2.30.0
fi
#set -x  #       print expanded command before executing it


IN="/francislab/data1/raw/PRJNA736483"
OUT="/francislab/data1/working/PRJNA736483/20220310-bamtofastq/out"
mkdir -p ${OUT}

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

bam=$( ls -1 ${IN}/SRR14773*/*_alignment_bam.bam | sed -n "$line"p )
echo $bam

if [ -z "${bam}" ] ; then
	echo "No line at :${line}:"
	exit
fi

#date=$( date "+%Y%m%d%H%M%S" )

s=$( basename ${bam} _alignment_bam.bam )
echo ${s}

base=${OUT}/${s}

outbase="${base}"
f=${outbase}_R1.fastq.gz
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else

#	#scratch=$( stat --dereference --format %s ${bam} | awk -v p=${threads} '{print int(1.7*$1/p/1000000000)}' )
#
#	bam_size=$( stat --dereference --format %s ${bam} )
#	#scratch=$( echo $(( ((${bam_size})/${threads}/1000000000*18/10)+1 )) )
#	#scratch=$( echo $(( (${bam_size}/${threads}/1000000000*2)+1 )) )
#	scratch=$( echo $(( (${bam_size}/1000000000*2)+1 )) )
#
#	echo "Requesting ${scratch} scratch"
#	#	gres=scratch should be about total needed divided by num threads
#
#	sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=${jobbase} --time=1440 \
#		--nodes=1 --ntasks=${threads} --mem=${vmem}G --gres=scratch:${scratch}G \
#		--output=${outbase}.${date}.%j.txt \
		~/.local/bin/bamtofastq_scratch.bash \
			collate=1 \
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
			O2=${outbase}_O2.fastq.gz

fi
