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


length=$1

in1=$2
in2=$3
out1=$4
out2=$5



echo "Adding UMI to read name"
paste <( zcat $in1 | paste - - - - ) <( zcat $in2 | paste - - - - ) |
	awk -F"\t" -v o1=${out1%.fastq.gz}.tmp -v o2=${out2%.fastq.gz}.tmp -v l=${length} '{
		umi=substr($6,0,l)
		print $1" "umi >> o1
		print $2 >> o1
		print $3 >> o1
		print $4 >> o1
		print $5" "umi >> o2
		print $6 >> o2
		print $7 >> o2
		print $8 >> o2
	}'

echo "and sorting"
#zcat $input | paste - - - - | awk -v l=${length} -F"\t" '{print $1" "substr($2,0,l); print $2; print $3; print $4}' | paste - - - - | sort --parallel=8 -k3,3 -k1,1 | tr "\t" "\n" | gzip > ${output%.fastq.gz}.sortedbyumi.fastq.gz

cat ${out1%.fastq.gz}.tmp | paste - - - - | sort --parallel=8 -k3,3 -k1,1 | tr "\t" "\n" > ${out1%.fastq.gz}.tmpsorted
cat ${out2%.fastq.gz}.tmp | paste - - - - | sort --parallel=8 -k3,3 -k1,1 | tr "\t" "\n" > ${out2%.fastq.gz}.tmpsorted


echo "Consolidating"
python3 ~/github/ucsffrancislab/umi/consolidate.py ${out1%.fastq.gz}.tmpsorted ${out1%.gz} 15 0.9
python3 ~/github/ucsffrancislab/umi/consolidate.py ${out2%.fastq.gz}.tmpsorted ${out2%.gz} 15 0.9


gzip ${out1%.gz}
gzip ${out2%.gz}

chmod -w $out1 $out2

count_fasta_reads.bash $out1 $out2
average_fasta_read_length.bash $out1 $out2







#	#min_qual = 15
#	#min_freq = 0.9
#	#	Otherwise it returns an N
#	mv ${output} ${output%.gz}
#	gzip ${output%.gz}
#	
#	count_fasta_reads.bash ${output}
#	
#	chmod -w ${output}
#	

















#	length=12
#	
#	while [ $# -gt 0 ] ; do
#		case $1 in
#			-l)
#				shift; length=$1; shift;;
#			-i)
#				shift; input=$1; shift;;
#			-o)
#				shift; output=$1; shift;;
#			*)
#				shift;
#		esac
#	done
#	
#	#	UMI and actual adapter found (not the adapter demultiplexed on)
#	#zcat $input | paste - - - - | awk -v l=${length} -F"\t" '{split($1,a,":"); print $1" "substr($2,0,l)"_"a[length(a)]; print $2; print $3; print $4}' | gzip > $output
#	
#	#echo "Adding UMI to read name"
#	##	Just the UMI given that the adapter may differ and already demultiplexed
#	#zcat $input | paste - - - - | awk -v l=${length} -F"\t" '{print $1" "substr($2,0,l); print $2; print $3; print $4}'> ${output%.fastq.gz}.copiedumi.fastq
#	#
#	#echo "Sorting"
#	#cat ${output%.fastq.gz}.copiedumi.fastq | paste - - - - | sort --parallel=8 -k3,3 -k1,1 | tr "\t" "\n" | gzip > ${output%.fastq.gz}.sortedbyumi.fastq.gz
#	
#	echo "Adding UMI to read name and sorting"
#	#	Just the UMI given that the adapter may differ and already demultiplexed
#	zcat $input | paste - - - - | awk -v l=${length} -F"\t" '{print $1" "substr($2,0,l); print $2; print $3; print $4}' | paste - - - - | sort --parallel=8 -k3,3 -k1,1 | tr "\t" "\n" | gzip > ${output%.fastq.gz}.sortedbyumi.fastq.gz
#	
#	# sort --parallel=8 --temporary-directory=$HOME/.sort_sequences
#	
#	
#	echo "Consolidating"
#	python3 ~/github/ucsffrancislab/umi/consolidate.py ${output%.fastq.gz}.sortedbyumi.fastq.gz ${output} 15 0.9
#	
#	#min_qual = 15
#	#min_freq = 0.9
#	#	Otherwise it returns an N
#	
#	
#	mv ${output} ${output%.gz}
#	gzip ${output%.gz}
#	
#	count_fasta_reads.bash ${output}
#	
#	chmod -w ${output}

