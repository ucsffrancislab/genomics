#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

if [ -n "${SLURM_JOB_NAME}" ] ; then
	script=${SLURM_JOB_NAME}
else
	script=$( basename $0 )
fi

#	PWD preserved by slurm for where job is run? I guess so.
arguments_file=${PWD}/${script}.arguments

#if [ -n "${SLURM_ARRAY_TASK_ID}" ] ; then
if [ $( basename ${0} ) == "slurm_script" ] ; then

	#set -e  #       exit if any command fails
	set -u  #       Error on usage of unset variables
	set -o pipefail
	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		#module load CBI samtools
		#module load CBI samtools/1.13 bowtie2/2.4.4 htslib
		#bedtools2/2.30.0
	fi
	#set -x  #       print expanded command before executing it


	date

	/francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/merge_select_genotypes.py -o /francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/merged_select_genotypes.tsv.gz

	date


else

	mkdir -p ${PWD}/logs
	date=$( date "+%Y%m%d%H%M%S%N" )
	sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="${script}" \
		--output="${PWD}/logs/${script}.${date}.out" --time=14400 --nodes=1 --ntasks=8 --mem=60G \
		$( realpath ${0} )

fi

