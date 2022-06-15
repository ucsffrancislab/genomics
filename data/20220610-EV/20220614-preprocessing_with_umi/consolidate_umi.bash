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


#	NOTE THAT ALSO USING FIRST 9 OF R1 WHICH IS REALLY NOT THE UMI, BUT THESE UMIs ARE TOO SHORT


echo "Adding UMI to read name"
paste <( zcat $in1 | paste - - - - ) <( zcat $in2 | paste - - - - ) |
	awk -F"\t" -v o1=${out1%.fastq.gz}.tmp -v o2=${out2%.fastq.gz}.tmp -v l=${length} '{
		umi=substr($6,0,l)
		#umi1=substr($2,0,l)
		#umi2=substr($6,0,l)
		#umi=umi1""umi2
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
#cat ${out2%.fastq.gz}.tmp | paste - - - - | sort --parallel=8 -k3,3 -k1,1 | tr "\t" "\n" > ${out2%.fastq.gz}.tmpsorted
gzip ${out2%.fastq.gz}.tmp

# sort --parallel=8 --temporary-directory=$HOME/.sort_sequences

#\rm ${out1%.fastq.gz}.tmp ${out2%.fastq.gz}.tmp
\rm ${out1%.fastq.gz}.tmp

echo "Consolidating"
python3 ~/github/ucsffrancislab/umi/consolidate.py ${out1%.fastq.gz}.tmpsorted ${out1%.gz} 15 0.9
#python3 ~/github/ucsffrancislab/umi/consolidate.py ${out2%.fastq.gz}.tmpsorted ${out2%.gz} 15 0.9

#	min_qual = 15
#	min_freq = 0.9

#\rm ${out1%.fastq.gz}.tmpsorted ${out2%.fastq.gz}.tmpsorted
\rm ${out1%.fastq.gz}.tmpsorted


gzip ${out1%.gz}
#gzip ${out2%.gz}

#chmod -w $out1 $out2
#count_fasta_reads.bash $out1 $out2
#average_fasta_read_length.bash $out1 $out2

chmod -w $out1
count_fasta_reads.bash $out1
average_fasta_read_length.bash $out1

