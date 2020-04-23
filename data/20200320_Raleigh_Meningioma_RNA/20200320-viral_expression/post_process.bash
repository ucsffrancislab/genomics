#!/usr/bin/env bash


REFS=/francislab/data1/refs
FASTA=${REFS}/fasta
dir=/francislab/data1/working/20200320_Raleigh_Meningioma_RNA/20200320-viral_expression/trimmed

threads=8
vmem=8
date=$( date "+%Y%m%d%H%M%S" )


for q in 00 15 30 ; do

	f="${dir}/bowtie2-e2e.SVAs_and_HERVs_KWHE.q${q}.counts-matrix.csv.gz"
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		qsub -N merge${q} -j oe -o ${f}.${date}.out.txt \
			-l nodes=1:ppn=${threads} -l vmem=64gb \
			~/.local/bin/merge_summaries.py \
				-F "--int -s ' ' -o ${f} ${dir}/???.bowtie2-e2e.SVAs_and_HERVs_KWHE.q${q}.counts.txt.gz"
			#~/.local/bin/merge_mer_counts_scratch.bash \
			#	-F "-o ${f} ${dir}/???.bowtie2-e2e.SVAs_and_HERVs_KWHE.q${q}.counts.txt.gz"
	fi

done


