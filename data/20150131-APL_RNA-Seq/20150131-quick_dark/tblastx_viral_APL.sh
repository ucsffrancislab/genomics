#!/bin/sh -v

#	This looks like its gonna take a couple days

base=`basename $PWD`

#	--begin=23:00 \

srun --share --nice --partition=bigmem \
	--job-name="tblastx_viral_${base}" \
	--cpus-per-task=8 \
	--error=$PWD/srunerr.tblastx_viral.`date "+%Y%m%d%H%M%S"`  \
	tblastx -num_threads 8 -num_alignments 20 -num_descriptions 20 \
		-evalue 0.05 -outfmt 0 -db viral_genomic \
		-query $PWD/trinity_non_human_paired.fasta \
		-out $PWD/trinity_non_human_paired.tblastx_viral.txt &


#
#	Gauge progress with these ...
#
#	How many reads in the fasta file?
#	grep "^>" *.trinity.fa | wc -l
#
#	How many reads processed by blast?
#	grep "^Query= " *.trinity.tblastx_viral.txt | wc -l
#

