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
#arguments_file=${PWD}/${script}.arguments

#if [ -n "${SLURM_ARRAY_TASK_ID}" ] ; then
if [ $( basename ${0} ) == "slurm_script" ] ; then

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
	
	#IN="/francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/in"
	OUT="/francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/out"
	
	#while [ $# -gt 0 ] ; do
	#	case $1 in
	#		-d|--dir)
	#			shift; OUT=$1; shift;;
	#		*)
	#			echo "Unknown params :${1}:"; exit ;;
	#	esac
	#done
	
	mkdir -p ${OUT}
	
	MELTJAR="/c4/home/gwendt/.local/MELTv2.1.5fast/MELT.jar"
	
	
	discoverydir=${OUT}/DISCOVERYIND/
	
	outbase=${OUT}/DISCOVERYGROUP/ALU
	f=${outbase}.pre_geno.tsv
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		java -Xmx4G -jar ${MELTJAR} GroupAnalysis \
			-discoverydir ${discoverydir}/ \
			-w $( dirname ${f} ) \
			-cov 25 -sr 2 \
			-t ~/.local/MELTv2.2.2/me_refs/1KGP_Hg19/transposon_file_list.txt \
			-h /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/20200117/hg19.chrXYMT_alts.fa \
			-n ~/.local/MELTv2.2.2/add_bed_files/1KGP_Hg19/hg19.genes.bed
	
		chmod -w ${f}	#${OUT}/${mei}DISCOVERYGROUP/${mei}.pre_geno.tsv
	fi
	
	
	#	EXOME!
	#	https://groups.google.com/g/melt-help/c/I8-D_fXn3Io/m/9JbkA9IFBQAJ
	#	1.) use "-exome" when running IndivAnalysis
	#	2.) Set "-cov 25" when running GroupAnalysis - This is to compensate for the smaller insert size associated with WXS (in my samples, this was ~300bp)
	#	3.) Set "-sr 2" when running GroupAnalysis - This removes any sites with ≤ 2 split reads and greatly increases sensitivity when running MELT on WXS
	
	# -cov <arg>            Standard deviation cutoff when calling final sites in integer format. [35]
	# -sr <arg>             Filter sites with less than X SRs during breakpoint ascertainment. Default, -1, is to not filter any such sites. [-1]
	
	
	
	date
	#exit

else

	mkdir -p ${PWD}/logs
	date=$( date "+%Y%m%d%H%M%S%N" )
	sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="MELT2" \
		--output="${PWD}/logs/MELT2.${date}.out" --time=14400 --nodes=1 --ntasks=8 --mem=60G \
		$( realpath ${0} )
		#${PWD}/MELT_2.bash

fi

