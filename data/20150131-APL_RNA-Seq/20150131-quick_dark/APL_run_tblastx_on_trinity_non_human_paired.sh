#!/bin/sh 


for file in `ls */nobackup/trinity_non_human_paired.fasta`; do

	echo $PWD	#	/my/home/ccls/data/working/APL_RNA-Seq
                
	now=`date "+%Y%m%d%H%M%S"`
	echo $file	#	P-NB4-stranded/nobackup/trinity_non_human_paired.fasta
	
	dir=${file%%/nobackup/trinity_non_human_paired.fasta}
	echo $dir		#	P-NB4-stranded
	base=${file%%.fasta}
	echo $base	#	P-NB4-stranded/nobackup/trinity_non_human_paired


	srun --share --nice --partition=bigmem \
		--begin=23:00 \
		--job-name="tblastx_viral_${dir}" \
		--cpus-per-task=8 \
		--error=$PWD/srunerr.tblastx_viral.`date "+%Y%m%d%H%M%S"`  \
		tblastx -num_threads 8 -num_alignments 20 -num_descriptions 20 \
			-evalue 0.05 -outfmt 0 -db viral_genomic \
			-query $PWD/$file \
			-out $PWD/$base.tblastx_viral.txt &

	echo
done
