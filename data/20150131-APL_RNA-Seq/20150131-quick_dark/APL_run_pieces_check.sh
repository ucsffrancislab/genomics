#!/bin/sh


base=`basename $PWD`
now=`date "+%Y%m%d%H%M%S"`

srun --chdir $PWD --cpus-per-task=8 \
	--begin=23:00 \
	--partition=bigmem \
	--share --nice --exclude=n0000,n0001,n0002 \
	--job-name="pieces_check-$base" \
	--output=$PWD/$now.pieces_check.output  \
	--error=$PWD/$now.pieces_check.error  \
		pieces_check.sh *pieces.nobackup &


#	/my/home/ccls/data/working/APL_RNA-Seq/pieces_merge.sh *pieces.nobackup &


#		/my/home/ccls/data/nobackup/APL_RNA-Seq/${base}_R1.fastq \
#		/my/home/ccls/data/nobackup/APL_RNA-Seq/${base}_R2.fastq &
#
#	No naming convention has been established, but we kinda need one.
#	${base}_R1.fastq and ${base}_R2.fastq are not always correct.
#	Sometimes just .fq extension.  Other times . instead of _.
#
#		`ls /my/home/ccls/data/nobackup/APL_RNA-Seq/${base}*R1*q` \
#		`ls /my/home/ccls/data/nobackup/APL_RNA-Seq/${base}*R2*q` &
#
#	And ${base}*R1*q and ${base}*R2*q also won't always work as in the
#	following example.  Trying to run the first would end in failure.
#
# P-NB4.R1.fq
# P-NB4.R2.fq
# P-NB4-stranded.R1.fq
# P-NB4-stranded.R2.fq
#



