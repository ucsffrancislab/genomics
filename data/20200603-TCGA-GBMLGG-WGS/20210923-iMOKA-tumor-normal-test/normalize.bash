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

#FILES=""
while [ $# -gt 0 ] ; do
	case $1 in
		-k|--kmer|--kmer_length)
			shift; kmer_length=$1; shift;;
		-l|--length|--read_length)
			shift; read_length=$1; shift;;
		-c|--count|--read_count)
			shift; read_count=$1; shift;;
		-i|--in|--in_file)
			shift; in_file=$1; shift;;
		-o|--out|--out_file)
			shift; out_file=$1; shift;;
#		*)
#			FILES="${FILES} $1"; shift;;
#   *)
#     echo "Unknown params :${1}:"; exit ;;
	esac
done


# Tj = (sum of read lengths of reads >=K) + (1-K)*(number reads >=K)


#	echo $read_length
#	echo $read_count
#	kmer_count=$( echo "scale=6; (${read_count}*${read_length})+((1-${kmer_length})*${read_count})" | bc -l )
#	echo $kmer_count
#	norm_factor=$( echo "scale=6; (10^9)/${kmer_count}" | bc -l )
#	echo $norm_factor
#	
#	#for in_file in ${FILES}; do
#	#	echo $in_file
#	
#		while read -r sequence count ; do
#			norm_count=$( echo "scale=2; ${count}*${norm_factor}" | bc -l )
#			echo $sequence $norm_count
#		done < ${in_file} > ${out_file}
#	
#	#done
#	
#	#	time ./normalize.bash --kmer_length 15 --read_length 101 --read_count 1297761740 --in_file 15/preprocess/19-2629-01A/19-2629-01A.tsv --out_file 15/preprocess/19-2629-01A/19-2629-01A.normalized.tsv




#/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20210923-iMOKA-tumor-normal-test/normalize -k=${kmer_length} -l=${read_length} -c=${read_count} -i=${in_file} -o=${out_file}



