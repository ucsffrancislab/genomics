#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

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

in1=$1
in2=$2
out1=$3
out2=$4

	#awk -F"\t" -v o1=${out1%.gz} -v o2=${out2%.gz} '( $6 ~ /^.........GTTTTT/ ){
	#awk -F"\t" -v o1=${out1%.gz} -v o2=${out2%.gz} '( $6 ~ /^.........GTTT/ ){
	#awk -F"\t" -v o1=${out1%.gz} -v o2=${out2%.gz} '( $6 ~ /^..................GTTTTTTTTTTTTTTTTTTTTT/ ){ 
	#awk -F"\t" -v o1=${out1%.gz} -v o2=${out2%.gz} '( $6 ~ /^.{18}GT{21}/ ){
paste <( zcat $in1 | paste - - - - ) <( zcat $in2 | paste - - - - ) |
	awk -F"\t" -v o1=${out1%.gz} -v o2=${out2%.gz} '( $6 ~ /^.{18}GT{5}/ ){
		print $1 >> o1
		print $2 >> o1
		print $3 >> o1
		print $4 >> o1
		print $5 >> o2
		print $6 >> o2
		print $7 >> o2
		print $8 >> o2
	}'

gzip ${out1%.gz}
gzip ${out2%.gz}

chmod -w $out1 $out2

count_fasta_reads.bash $out1 $out2
average_fasta_read_length.bash $out1 $out2

