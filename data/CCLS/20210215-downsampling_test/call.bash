#!/usr/bin/env bash

mkdir -p vcf

for bam in ${PWD}/bam/[G9]*bam ; do

	echo $bam
	basename=${bam%.bam}

	f=${basename}.vcf.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		threads=4
		bam_size=$( stat --dereference --format %s ${bam} )
		#r2_size=$( stat --dereference --format %s ${r2} )
		#index_size=$( du -sb ${index} | awk '{print $1}' )
		#scratch=$( echo $(( ((${r1_size}+${r2_size}+${index_size})/${threads}/1000000000*11/10)+1 )) )
		# Add 1 in case files are small so scratch will be 1 instead of 0.
		# 11/10 adds 10% to account for the output

		scratch=$( echo $(( (${bam_size}/${threads}/1000000000*13/10)+1 )) )

		echo "Using scratch:${scratch}"

		sbatch --time=3600 --parsable --ntasks=${threads} --mem=30G --job-name $( basename ${basename} ) \
			--gres=scratch:${scratch}G --output ${basename}.vcf.out.txt \
			${PWD}/bcftools_call.bash ${bam}
	fi

done

