#!/usr/bin/env bash

mkdir -p bam

for bam in /francislab/data1/raw/CCLS/bam/{GM_,}{268325,439338,63185,634370,983899}.recaled.bam ; do

	echo $bam
	basename=$( basename $bam .recaled.bam )

	base=${PWD}/bam/${basename}

	f=${base}.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		threads=4
		bam_size=$( stat --dereference --format %s ${bam} )
		#r2_size=$( stat --dereference --format %s ${r2} )
		#index_size=$( du -sb ${index} | awk '{print $1}' )
		#scratch=$( echo $(( ((${r1_size}+${r2_size}+${index_size})/${threads}/1000000000*11/10)+1 )) )
		#	Add 1 in case files are small so scratch will be 1 instead of 0.
		#	11/10 adds 10% to account for the output

		scratch=$( echo $(( ((${bam_size}*2)/${threads}/1000000000*11/10)+1 )) )

		echo "Using scratch:${scratch}"

		sbatch --time=3600 --parsable --ntasks=${threads} --mem=30G --job-name ${basename} \
			--gres=scratch:${scratch}G \
			--output ${base}.correct.out.txt \
			${PWD}/correct_scratch.bash ${bam} ${f}
	fi

done


