#!/usr/bin/env bash

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail
#if [ -n "$( declare -F module )" ] ; then
#	echo "Loading required modules"
#	module load CBI htslib samtools bowtie2
#fi
set -x	#	print expanded command before executing it


while [ $# -gt 0 ] ; do
	case $1 in
		-t|--tumor|--tumor_file)
			shift; tumor_file=$1; shift;;
		-n|--normal|--normal_file)
			shift; normal_file=$1; shift;;
		-o|--out|--out_file)
			shift; out_file=$1; shift;;
#		*)
#			FILES="${FILES} $1"; shift;;
#   *)
#     echo "Unknown params :${1}:"; exit ;;
	esac
done





#/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20210923-iMOKA-tumor-normal-test/difference -t=${tumor_file} -n=${normal_file} -o=${out_file}




