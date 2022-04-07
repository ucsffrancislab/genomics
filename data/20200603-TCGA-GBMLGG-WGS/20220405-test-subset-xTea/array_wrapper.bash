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


IN="/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20220405-test-subset-xTea/tmp"
OUT="/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20220405-test-subset-xTea/tmp"

#while [ $# -gt 0 ] ; do
#	case $1 in
#		-d|--dir)
#			shift; OUT=$1; shift;;
#		*)
#			echo "Unknown params :${1}:"; exit ;;
#	esac
#done

mkdir -p ${OUT}

echo "SLURM_ARRAY_TASK_ID ${SLURM_ARRAY_TASK_ID:-1}"
line=${SLURM_ARRAY_TASK_ID:-1}
echo "Running line :${line}:"
echo "${line}"

#	Use a 1 based index since there is no line 0.
#sample=$( sed -n ${line}p to_run.txt )
#echo ${sample}

#r1=$( ls -1 ${IN}/*_R1.fastq.gz | sed -n "$line"p )
#r1=$( ls -1 ${IN}/${sample}*_R1.fastq.gz )
r1=$( ls -1d ${IN}/* | sed -n "${line}"p )
#for dir in ${PWD}/tmp/* ; do 
#base=$( basename $dir )
echo $r1

if [ -z "${r1}" ] ; then
	echo "No line at :${line}:"
	exit
fi

date=$( date "+%Y%m%d%H%M%S" )

#r2=${r1/_R1./_R2.}
#echo $r2

basename=$( basename $r1 )	#_R1.fastq.gz )
echo ${basename}

outbase=${OUT}/${basename}/HERV
echo $outbase

f=${outbase}/candidate_disc_filtered_cns.txt
echo $f

if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	singularity exec --bind /francislab,/scratch /francislab/data1/refs/singularity/xTea.img ${r1}/HERV/run_xTEA_pipeline.sh
fi





echo "Done: $(date)"
exit




mkdir -p ${PWD}/logs
date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-6%1 --job-name="xTea" --output="${PWD}/logs/array.${date}-%A_%a.out" --time=4320 --nodes=1 --ntasks=16 --mem=60G ${PWD}/array_wrapper.bash

scontrol update ArrayTaskThrottle=6 JobId=352083


