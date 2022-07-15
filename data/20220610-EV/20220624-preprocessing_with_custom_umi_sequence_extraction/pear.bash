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
	#module load CBI samtools/1.13 bowtie2/2.4.4 picard
	#bedtools2/2.30.0
fi
#set -x  #       print expanded command before executing it

IN="/francislab/data1/working/20220610-EV/20220624-preprocessing_with_custom_umi_sequence_extraction/out"
OUT="/francislab/data1/working/20220610-EV/20220624-preprocessing_with_custom_umi_sequence_extraction/pear"

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

#r1=$( ls -1 /francislab/data1/raw/20220610-EV/SF*R1_001.fastq.gz | sed -n "$line"p )
sample=$( sed -n "$line"p /francislab/data1/working/20220610-EV/20220624-preprocessing_with_custom_umi_sequence_extraction/metadata.csv | awk -F, '{print $1}' )
r1=$( ls ${IN}/${sample}.quality.R1.fastq.gz )


echo $r1

if [ -z "${r1}" ] ; then
	echo "No line at :${line}:"
	exit
fi


date=$( date "+%Y%m%d%H%M%S" )


echo $r1
r2=${r1/.R1./.R2.}
echo $r2
s=$( basename $r1 .quality.R1.fastq.gz ) # SFHH009L
#s=$( basename $r1 ) # SFHH009L_S7_L001_R1_001
#s=${s%%_*}          # SFHH009L


outbase="${OUT}/${s}.quality"
f=${outbase}.assembled.fastq.gz
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	~/.local/pear-0.9.11-linux-x86_64/bin/pear \
		--forward-fastq ${r1} --reverse-fastq ${r2} \
		-o ${outbase} \
		--threads ${SLURM_NTASKS:-8}

	chmod -w ${outbase}.assembled.fastq
	gzip ${outbase}.assembled.fastq
	count_fasta_reads.bash  ${outbase}.assembled.fastq.gz
	
	chmod -w ${outbase}.unassembled.reverse.fastq
	gzip ${outbase}.unassembled.reverse.fastq
	count_fasta_reads.bash  ${outbase}.unassembled.reverse.fastq.gz
	
	chmod -w ${outbase}.unassembled.forward.fastq
	gzip ${outbase}.unassembled.forward.fastq
	count_fasta_reads.bash  ${outbase}.unassembled.forward.fastq.gz
	
fi

echo "Done"
date

exit




ll /francislab/data1/raw/20220610-EV/SF*R1_001.fastq.gz | wc -l
86


mkdir -p /francislab/data1/working/20220610-EV/20220624-preprocessing_with_custom_umi_sequence_extraction/logs
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-86%1 --job-name="pear" --output="/francislab/data1/working/20220610-EV/20220624-preprocessing_with_custom_umi_sequence_extraction/logs/pear.${date}-%A_%a.out" --time=14400 --nodes=1 --ntasks=8 --mem=60G /francislab/data1/working/20220610-EV/20220624-preprocessing_with_custom_umi_sequence_extraction/pear.bash


scontrol update ArrayTaskThrottle=6 JobId=352083


