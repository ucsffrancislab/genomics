#!/usr/bin/env bash

mkdir -p vcf

for bam in ${PWD}/bam/*bam ; do

	echo $bam
	basename=$( basename $bam .bam )

	f=${base}.${p}a.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		sbatch --time=3600 --parsable --ntasks=2 --mem=15G --job-name ${basename} \
			--output ${PWD}/vcf/${basename}.mpileup.out.txt \
			${PWD}/bcftools_call.bash ${bam}
	fi

done

