#!/usr/bin/env bash


for bam in bam/*bam ; do
	echo $bam
	base=${bam%.bam}

	for p in 60 80 ; do

		sambamba view -f bam -t 64 --subsampling-seed=13 -s 0.${p} $bam -o ${base}.${p}a.bam

		sambamba view -f bam -t 64 --subsampling-seed=37 -s 0.${p} $bam -o ${base}.${p}b.bam

		sambamba view -f bam -t 64 --subsampling-seed=91 -s 0.${p} $bam -o ${base}.${p}c.bam

	done

done


