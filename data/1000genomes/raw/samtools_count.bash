#!/usr/bin/env bash

date=$( date "+%Y%m%d%H%M%S" )
dir=/francislab/data1/raw/1000genomes

for f in ${dir}/phase3/data/*/*/*unmapped*bam ; do
	b=$( basename $f )
	s=${b%%.*}
	echo $s $b $f

	qsub -N $s \
		-o ${f}.read_count.${date}.out.txt \
		-e ${f}.read_count.${date}.err.txt \
		~/.local/bin/samtools.bash -F "view -c -o ${f}.read_count.txt.gz ${f}"

	qsub -N "u${s}" \
		-o ${f}.unmapped_read_count.${date}.out.txt \
		-e ${f}.unmapped_read_count.${date}.err.txt \
		~/.local/bin/samtools.bash -F "view -f 4 -c -o ${f}.unmapped_read_count.txt.gz ${f}"

done
