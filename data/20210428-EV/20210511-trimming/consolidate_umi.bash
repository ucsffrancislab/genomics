#!/usr/bin/env bash

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail
set -x	#	print expanded command before executing it

#ARGS=$*

length=12

while [ $# -gt 0 ] ; do
	case $1 in
		-l)
			shift; length=$1; shift;;
		-i)
			shift; input=$1; shift;;
		-o)
			shift; output=$1; shift;;
		*)
			shift;
	esac
done

#	UMI and actual adapter found (not the adapter demultiplexed on)
#zcat $input | paste - - - - | awk -v l=${length} -F"\t" '{split($1,a,":"); print $1" "substr($2,0,l)"_"a[length(a)]; print $2; print $3; print $4}' | gzip > $output

#echo "Adding UMI to read name"
##	Just the UMI given that the adapter may differ and already demultiplexed
#zcat $input | paste - - - - | awk -v l=${length} -F"\t" '{print $1" "substr($2,0,l); print $2; print $3; print $4}'> ${output%.fastq.gz}.copiedumi.fastq
#
#echo "Sorting"
#cat ${output%.fastq.gz}.copiedumi.fastq | paste - - - - | sort --parallel=8 -k3,3 -k1,1 | tr "\t" "\n" | gzip > ${output%.fastq.gz}.sortedbyumi.fastq.gz

echo "Adding UMI to read name and sorting"
#	Just the UMI given that the adapter may differ and already demultiplexed
zcat $input | paste - - - - | awk -v l=${length} -F"\t" '{print $1" "substr($2,0,l); print $2; print $3; print $4}' | paste - - - - | sort --parallel=8 -k3,3 -k1,1 | tr "\t" "\n" | gzip > ${output%.fastq.gz}.sortedbyumi.fastq.gz

# sort --parallel=8 --temporary-directory=$HOME/.sort_sequences


echo "Consolidating"
python3 ~/github/ucsffrancislab/umi/consolidate.py ${output%.fastq.gz}.sortedbyumi.fastq.gz ${output} 15 0.9

#min_qual = 15
#min_freq = 0.9
#	Otherwise it returns an N


mv ${output} ${output%.gz}
gzip ${output%.gz}

count_fasta_reads.bash ${output}
average_fastq_read_length.bash ${output}

chmod -w ${output}

