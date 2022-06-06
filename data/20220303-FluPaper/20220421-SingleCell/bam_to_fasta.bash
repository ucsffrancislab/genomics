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
	module load CBI samtools
fi
set -x  #       print expanded command before executing it


IN="/francislab/data1/working/20220303-FluPaper/20220421-SingleCell/out"
OUT="/francislab/data1/working/20220303-FluPaper/20220421-SingleCell/out"

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

sample=$( ls -1trd ${IN}/B*-c?  | sed -n "$line"p )
sample=$( basename ${sample} )

echo $sample

if [ -z "${sample}" ] ; then
	echo "No line at :${line}:"
	exit
fi

date=$( date "+%Y%m%d%H%M%S" )



for bam in ${OUT}/${sample}/outs/possorted_genome_bam.bam_barcodes/*bam ; do
	
	f=${bam%.bam}.fa.gz
	
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "$f exists. Skipping."
	else
		echo "Creating $f"

		samtools fasta ${bam} | gzip > ${f}
		chmod -w ${f}

	fi

done

echo "Done"
date
exit





mkdir -p /francislab/data2/working/20220303-FluPaper/20220421-SingleCell/logs
date=$( date "+%Y%m%d%H%M%S" )

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-30%1 --job-name="bam2fasta" --output="${PWD}/logs/bam2fasta.${date}-%A_%a.out" --time=10080 --nodes=1 --ntasks=4 --mem=30G ${PWD}/bam_to_fasta.bash




