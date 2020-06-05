#!/bin/sh

if [ $# -eq 0 ]; then
	echo "I need at least one filename"
	exit
fi

while [ $# -ne 0 ] ; do
	echo $1
	base=${1%.*}		#	drop the .bam extension
	name=${base#*/}	#	just in case given path
	name=${name%-01A*}	#	just in case given path
	name=${name#*TCGA-}	#	just in case given path

#		--exclude=n[0000-0029] \

	srun --nice --share \
		--partition=bigmem \
		--begin=23:00 \
		--job-name="bam2fastx_${name}" \
		--cpus-per-task=8 \
		--error=$base.bam2fastx.errors.`date "+%Y%m%d%H%M%S"`.nobackup \
		--output=$base.bam2fastx.output.`date "+%Y%m%d%H%M%S"`.nobackup \
		bam2fastx --fastq --all -N \
			-o $name.fastq \
			$1 &

	shift
done
