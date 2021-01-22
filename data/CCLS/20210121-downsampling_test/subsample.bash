#!/usr/bin/env bash


for bam in bam/*bam ; do
	echo $bam
	base=${bam%.bam}

	for p in 0.6 0.8 ; do

		echo sambamba view -f bam -t 64 --subsampling-seed=13 -s ${p} $bam -o ${base}.${p}a.bam
		echo sambamba view -f bam -t 64 --subsampling-seed=37 -s ${p} $bam -o ${base}.${p}b.bam
		echo sambamba view -f bam -t 64 --subsampling-seed=91 -s ${p} $bam -o ${base}.${p}c.bam

	done

done


