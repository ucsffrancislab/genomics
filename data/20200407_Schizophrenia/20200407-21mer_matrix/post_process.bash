#!/usr/bin/env bash


#set -v

REFS=/francislab/data1/refs
FASTA=${REFS}/fasta
dir=/francislab/data1/working/20200407_Schizophrenia/20200407-21mer_matrix/trimmed/length	#/unpaired

#threads=16
#vmem=8
threads=8
vmem=8
date=$( date "+%Y%m%d%H%M%S" )



#for q in 00 15 30 ; do
#
#	f="${dir}/lt30bp.human_mature.bowtie2-e2e.q${q}.counts-matrix.csv.gz"
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		qsub -N merge${q} -j oe -o ${f}.${date}.out.txt \
#			-l nodes=1:ppn=${threads} -l vmem=64gb \
#			~/.local/bin/merge_summaries.py \
#				-F "--int -s ' ' -o ${f} ${dir}/??.lt30bp.human_mature.bowtie2-e2e.q${q}.counts.txt.gz"
#	fi
#
#done




#for k in 13 15 17 ; do
#for k in 15 ; do
for k in 13 ; do

	f="${dir}/hg38.bowtie2-e2e.unmapped.${k}mers.dsk-matrix.csv.gz"
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		qsub -N merge${k} -j oe -o ${f}.${date}.out.txt \
			-l nodes=1:ppn=64 -l vmem=500gb \
			-l feature=nocommunal \
			~/.local/bin/merge_mer_counts_scratch.bash \
				-F "-o ${f} ${dir}/????.hg38.bowtie2-e2e.unmapped.${k}mers.dsk.txt.gz"
	fi

done

#	13kmers join easily with less than 500gb memory.
#	15kmers and about do not.
#	This is odd since the 21mers are chopped into 6mer prefix making them like 15kmers.
#	However a chopped 21kmer into 6kmer prefixes is 40x smaller than a raw 15kmer file.

exit



#	zcat trimmed/length/SD01.hg38.bowtie2-e2e.unmapped.13mers.dsk.txt.gz | wc -l
#	17462065
#	zcat trimmed/length/SD01.hg38.bowtie2-e2e.unmapped.15mers.dsk.txt.gz | wc -l
#	39270616
#	zcat trimmed/length/SD01.hg38.bowtie2-e2e.unmapped.17mers.dsk.txt.gz | wc -l
#	56494787
#	zcat trimmed/length/SD01.hg38.bowtie2-e2e.unmapped.21mers.dsk.txt.gz | wc -l
#	82364600
#	zcat trimmed/length/SD01.hg38.bowtie2-e2e.unmapped.21mers.dsk/SD01.hg38.bowtie2-e2e.unmapped.21mers.dsk-ACACAC.txt.gz | wc -l
#	1228662





for mer in $( mers.bash 6 ) ; do
	echo $mer

	#f="${dir}/h38au.bowtie2-e2e.unmapped.21mers-${mer}.dsk-matrix.csv.gz"
	f="${dir}/hg38.bowtie2-e2e.unmapped.21mers-${mer}.dsk-matrix.csv.gz"
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		vmem=32
		#size=$( ls -l ${dir}/??.h38au.bowtie2-e2e.unmapped.21mers.dsk/??.h38au.bowtie2-e2e.unmapped.21mers.dsk-${mer}.txt.gz | awk '{s+=$5}END{print s}' )
		size=$( ls -l ${dir}/????.hg38.bowtie2-e2e.unmapped.21mers.dsk/????.hg38.bowtie2-e2e.unmapped.21mers.dsk-${mer}.txt.gz | awk '{s+=$5}END{print s}' )

		echo $size

		if [ $size -lt 100000000 ] ; then
			echo "Size $size lt 100000000"
			vmem=32
			threads=4
		elif [ $size -lt 400000000 ] ; then
			echo "Size $size lt 400000000"
			vmem=64
			threads=8
		elif [ $size -lt 800000000 ] ; then
			echo "Size $size lt 800000000"
			vmem=128
			threads=16
		elif [ $size -lt 1600000000 ] ; then
			echo "Size $size lt 1600000000"
			vmem=256
			threads=32
		else
			echo "Size $size is big"
			vmem=500
			threads=64
		fi
		echo "Using ${vmem}GB mem and ${threads} threads"
#		case ${mer} in
#			TTTTTT|AAAGAA|AAAAGA)
#				echo "Custom"; vmem=128; threads=16;;
#			AATTTT|AAATTT|AAAATT)
#				echo "Custom"; vmem=64; threads=8;;
#		esac
#		echo "Using ${vmem}GB mem and ${threads} threads"
		qsub -N ${mer}-${k}merge -j oe -o ${f}.${date}.out.txt \
			-l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
			~/.local/bin/merge_mer_counts_scratch.bash \
				-F "-o ${f} ${dir}/????.hg38.bowtie2-e2e.unmapped.21mers.dsk/????.hg38.bowtie2-e2e.unmapped.21mers.dsk-${mer}.txt.gz"
#	Threads extracted in script
#				-F "-p ${threads} -o ${f} ${dir}/??.h38au.bowtie2-e2e.unmapped.21mers.dsk/??.h38au.bowtie2-e2e.unmapped.21mers.dsk-${mer}.txt.gz"
	fi

done

