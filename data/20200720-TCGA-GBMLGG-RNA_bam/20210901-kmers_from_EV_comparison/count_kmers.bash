#!/usr/bin/env bash

date=$( date "+%Y%m%d%H%M%S" )

sbatch="sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL "


threads=2
mem=15G

OUT=${PWD}/out
mkdir -p ${OUT}

#for f in /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/subject/[1-9]?-????_R?.fastq.gz ; do
for f in /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/subject/??-????_R?.fastq.gz ; do
	echo $f
	base=$( basename ${f} .fastq.gz )
	outbase="${OUT}/${base}"

#	#	read count greater than 25bp
#	o=${outbase}.25.read_count.txt
#	if [ -f $o ] && [ ! -w $o ] ; then
#		echo "Write-protected $o exists. Skipping."
#	else
#		${sbatch} --job-name=${base}rc --time=60 --ntasks=${threads} --nodes=1 --mem=${mem} --output=${o%.txt}.${date}.txt \
#			${PWD}/read_count.bash -m 25 -o ${o} ${f}
#	fi
#
#	#	base count greater than 25bp
#	o=${outbase}.25.base_count.txt
#	if [ -f $o ] && [ ! -w $o ] ; then
#		echo "Write-protected $o exists. Skipping."
#	else
#		${sbatch} --job-name=${base}bc --time=60 --ntasks=${threads} --nodes=1 --mem=${mem} --output=${o%.txt}.${date}.txt \
#			${PWD}/base_count.bash -m 25 -o ${o} ${f}
#	fi

#	#	kmer counts
#	for kmer in $( cat kmers.all.txt ) ; do
#		o=${outbase}.${kmer}.txt
#		if [ -f $o ] && [ ! -w $o ] ; then
#			echo "Write-protected $o exists. Skipping."
#		else
#			${sbatch} --job-name=${base}${kmer} --time=60 --ntasks=${threads} --nodes=1 --mem=${mem} --output=${o%.txt}.${date}.txt \
#				${PWD}/kmer_count.bash -m ${kmer} -o ${o} ${f}
#		fi
#	done

	${sbatch} --job-name=${base}kmers --time=60 --ntasks=${threads} --nodes=1 --mem=${mem} --output=${outbase}.kmers_count.${date}.txt \
		${PWD}/kmers_count.bash -k ${PWD}/kmers.all.txt -i ${f} -o ${outbase}

done


