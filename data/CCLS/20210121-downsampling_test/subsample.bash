#!/usr/bin/env bash


for bam in bam/*100.bam ; do
	echo $bam
	base=${bam%.100.bam}
	basename=$( basename $base )

	echo $basename

	for p in 50 60 80 ; do

		echo $p

		f=${base}.${p}a.bam
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			sbatch --time=3600 --parsable --ntasks=8 --mem=60G --job-name ${basename}.${p}a \
				--output ${PWD}/bam/${basename}.${p}a.sambamba.out.txt \
				~/.local/bin/sambamba.bash view -f bam -t 8 --subsampling-seed=17 -s 0.${p} $bam -o ${f} #${base}.${p}a.bam
				#${PWD}/sambamba.bash view -f bam -t 8 --subsampling-seed=13 -s 0.${p} $bam -o ${base}.${p}a.bam
			#	for some reason 13 creates a problematic bam file that fails when calling for vcf
			#	this is odd since the full file does not have a problem
		fi

		f=${base}.${p}b.bam
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			sbatch --time=3600 --parsable --ntasks=8 --mem=60G --job-name ${basename}.${p}b \
				--output ${PWD}/bam/${basename}.${p}b.sambamba.out.txt \
				~/.local/bin/sambamba.bash view -f bam -t 8 --subsampling-seed=37 -s 0.${p} $bam -o ${f}	#	${base}.${p}b.bam
		fi
		
		f=${base}.${p}c.bam
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			sbatch --time=3600 --parsable --ntasks=8 --mem=60G --job-name ${basename}.${p}c \
				--output ${PWD}/bam/${basename}.${p}c.sambamba.out.txt \
				~/.local/bin/sambamba.bash view -f bam -t 8 --subsampling-seed=91 -s 0.${p} $bam -o ${f}	#	${base}.${p}c.bam
		fi

	done

done


