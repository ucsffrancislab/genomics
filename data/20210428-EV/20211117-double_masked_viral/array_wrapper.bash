#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
set -o pipefail
if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	module load CBI samtools/1.13 bowtie2/2.4.4 
	#bedtools2/2.30.0
fi
#set -x  #       print expanded command before executing it


OUT="/francislab/data1/working/20210428-EV/20211117-double_masked_viral/out"
mkdir -p ${OUT}

#date=$( date "+%Y%m%d%H%M%S" )
threads=8


#	Use a 1 based index since there is no line 0.
offset=0
line=$((${SLURM_ARRAY_TASK_ID:-1}+${offset}))
sample=$( sed -n "$line"p /francislab/data1/working/20210428-EV/20211117-double_masked_viral/sample_ids.txt )
echo $sample


#	sadly there are a couple duplicates which complicate things, so take just the first
#	Actually don't think this is true here as I processed all samples
#	There are a couple +2 and +3 files

r1=$( ls /francislab/data1/working/20210428-EV/20210518-preprocessing/output/${sample}.cutadapt2.fastq.gz | head -1 )
echo $r1

r2=${r1/_R1./_R2.}
b=${sample}
#b=$( basename $r1 .cutadapt2.fastq.gz )
#b=${b%-*}
#b=${b%-*}
#b=${b%-*}
echo $b

outbase=${OUT}/${b}.viral

f=${outbase}.bam
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	\rm -f ${f}

	~/.local/bin/bowtie2.bash --sort --threads 8 --xeq \
		-x /francislab/data1/working/20211111-hg38-viral-homology/double_masked_viral \
		--no-unal --very-sensitive-local -U ${r1} -o ${f}
		#--no-unal --very-sensitive-local -1 ${r1} -2 ${r2} -o ${f}

	chmod -w ${f}
fi


#f=${outbase}.fastq.gz
#if [ -f $f ] && [ ! -w $f ] ; then
#	echo "Write-protected $f exists. Skipping."
#else
#	\rm -f ${f}
#
#	~/.local/bin/samtools.bash fastq -N ${outbase}.bam -o ${f}
#
#	chmod -w ${f}
#fi
#
#infile=${f}
#outbase=${OUT}/${b}.viral.human
#f=${outbase}.bam
#if [ -f $f ] && [ ! -w $f ] ; then
#	echo "Write-protected $f exists. Skipping."
#else
#	\rm -f ${f}
#
#	~/.local/bin/bowtie2.bash --sort --threads 8 --xeq \
#		-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_no_alts \
#		--no-unal --very-sensitive-local -U ${infile} -o ${f}
#
#	chmod -w ${f}
#fi


exit



ls /francislab/data1/working/20210428-EV/20210518-preprocessing/output/*.cutadapt2.fastq.gz | xargs -I% basename % | cut -d. -f1 | uniq > sample_ids.txt


date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-1%1 --job-name="DMV-EV" --output="${PWD}/array.${date}-%A_%a.out" --time=480 --nodes=1 --ntasks=8 --mem=60G ${PWD}/array_wrapper.bash

date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-88%1 --job-name="DMV-EV" --output="${PWD}/array.${date}-%A_%a.out" --time=480 --nodes=1 --ntasks=8 --mem=60G ${PWD}/array_wrapper.bash






