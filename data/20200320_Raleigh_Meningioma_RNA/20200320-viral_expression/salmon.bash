#!/usr/bin/env bash

SALMON="/francislab/data1/refs/salmon"
DIR="/francislab/data1/working/20200320_Raleigh_Meningioma_RNA/20200320-viral_expression/trimmed"

for f in ${DIR}/???.fastq.gz ; do

	echo $f

	base=${f%.fastq.gz}
	echo $base

	for k in 21 31 ; do

		echo "salmon quant --index ${SALMON}/RepeatDatabase_${k} --libType A --unmatedReads ${f} --validateMappings -o ${base}.salmon.RepeatDatabase_${k} --threads 8" | qsub -l vmem=16gb -N $(basename $f .fastq.gz)_${k} -l nodes=1:ppn=8 -j oe -o ${base}.salmon.RepeatDatabase_${k}.out.txt

	done

done

