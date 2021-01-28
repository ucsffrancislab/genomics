#!/usr/bin/env bash


for bam in bam/*100.bam ; do
	echo $bam
	base=${bam%.100.bam}
	basename=$( basename $base )

	echo $basename

	#for p in 60 80 ; do
	for p in 50 ; do

		echo $p

		sbatch --time=3600 --parsable --ntasks=8 --mem=60G --job-name ${basename}${p}a \
			--output ${PWD}/vcf/${basename}.${p}a.sambamba.out.txt \
			${PWD}/sambamba.bash view -f bam -t 8 --subsampling-seed=13 -s 0.${p} $bam -o ${base}.${p}a.bam

		#	for some reason 13 creates a problematic bam file that fails when calling for vcf
		#	this is odd since the full file does not have a problem

		sbatch --time=3600 --parsable --ntasks=8 --mem=60G --job-name ${basename}${p}b \
			--output ${PWD}/vcf/${basename}.${p}b.sambamba.out.txt \
			${PWD}/sambamba.bash view -f bam -t 8 --subsampling-seed=37 -s 0.${p} $bam -o ${base}.${p}b.bam

		sbatch --time=3600 --parsable --ntasks=8 --mem=60G --job-name ${basename}${p}c \
			--output ${PWD}/vcf/${basename}.${p}c.sambamba.out.txt \
			${PWD}/sambamba.bash view -f bam -t 8 --subsampling-seed=91 -s 0.${p} $bam -o ${base}.${p}c.bam

		#sambamba view -f bam -t 64 --subsampling-seed=13 -s 0.${p} $bam -o ${base}.${p}a.bam
		#sambamba view -f bam -t 64 --subsampling-seed=37 -s 0.${p} $bam -o ${base}.${p}b.bam
		#sambamba view -f bam -t 64 --subsampling-seed=91 -s 0.${p} $bam -o ${base}.${p}c.bam

	done

done


