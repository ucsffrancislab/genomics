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
	module load CBI samtools/1.13 bowtie2/2.4.4 
	#bedtools2/2.30.0
fi
#set -x  #       print expanded command before executing it


dir="/francislab/data1/working/20211122-Homology-Paper/TCGA_WGS3/aligned"

while [ $# -gt 0 ] ; do
	case $1 in
		-d|--dir)
			shift; dir=$1; shift;;
		*)
			echo "Unknown params :${1}:"; exit ;;
	esac
done

mkdir -p ${dir}


line=${SLURM_ARRAY_TASK_ID:-1}
echo "Running line :${line}:"

#	Use a 1 based index since there is no line 0.

sample=$( sed -n "$line"p /francislab/data1/working/20211122-Homology-Paper/TCGA_WGS3/TCGA_normal_samples.txt )
echo $sample

if [ -z "${sample}" ] ; then
	echo "No line at :${line}:"
	exit
fi


r1=/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out/${sample}_R1.fastq.gz
r2=${r1/_R1/_R2}



for i in raw RM hg38masked RMhg38masked ; do
	mkdir -p ${dir}/${i}
done

for i in raw RM hg38masked RMhg38masked ; do
	echo ${i}
	o=${dir}/${i}/${sample}.bam
	if [ -f ${o} ] && [ ! -w ${o} ] ; then
		echo "${o} exists. Skipping alignment."
	else
		#bowtie2.bash --all --sort --no-unal --xeq --threads 8 --very-sensitive \
		#bowtie2.bash --all --no-unal --xeq --threads 8 --very-sensitive \
		date
		# will using scratch make this any faster?
		#	it will copy in the data files every time.
		bowtie2_scratch.bash --all --no-unal --xeq --threads 8 --very-sensitive \
			-x /francislab/data1/working/20211122-Homology-Paper/bowtie2/${i} \
			-1 ${r1} -2 ${r2} -o ${o}
		date
		#	Scatch run will likely will fail without cleanup.
		#	This is excessive.
		#/bin/rm -rf ${TMPDIR}/*
		/bin/rm -rf ${TMPDIR}/*bam*
		/bin/rm -rf ${TMPDIR}/*bt2
	fi

	bam=${dir}/${i}/${sample}.bam
	o=${dir}/${i}/${sample}.bam.uniq_counts.txt
	if [ -f ${o} ] && [ ! -w ${o} ] ; then
		echo "${o} exists. Skipping alignment."
	else
		date
		#	cut field order selection is ignored. Provided in numeric order. (ie -f3,1 returns 1,3)
		#samtools view ${o} | cut -f3,1 | uniq | sort | uniq | cut -f2 | uniq -c > ${o}.uniq_counts.txt

		if [ -f ${o} ] ; then
			mv ${o} ${o}.old
		fi

		samtools view ${bam} | cut -f3,1 | uniq | sort | uniq | cut -f2 | sort | uniq -c > ${o}

#nohup samtools view 02-2483-10A-01D-1494.raw.all.bam 
#                      | cut -f3,1 | uniq | sort | uniq | cut -f2 | sort | uniq -c > 02-2483-10A-01D-1494.raw.all.bam.uniq_counts.txt &
		chmod -w ${o}
		date
	fi

done





exit


wc -l /francislab/data1/working/20211122-Homology-Paper/TCGA_WGS3/TCGA_normal_samples.txt
126


mkdir -p /francislab/data1/working/20211122-Homology-Paper/TCGA_WGS3/logs
date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-126%8 --job-name="align" --output="/francislab/data1/working/20211122-Homology-Paper/TCGA_WGS3/logs/bowtie2.${date}-%A_%a.out" --time=2880 --nodes=1 --ntasks=8 --mem=60G --gres=scratch:250G /francislab/data1/working/20211122-Homology-Paper/TCGA_WGS3/bowtie2_array_wrapper.bash



scontrol update ArrayTaskThrottle=6 JobId=352083


grep -l "No such file or directory" array.*.out  | wc -l
ll out/masks/*cat.all | wc -l


grep "Running line" array.*.out | wc -l ; date


