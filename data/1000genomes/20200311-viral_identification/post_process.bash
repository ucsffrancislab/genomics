#!/usr/bin/env bash


for input in /francislab/data1/working/1000genomes/20200311-viral_identification/s3/1000genomes/phase3/data/*/alignment/*.unmapped.*.bam.diamond.viral.csv.gz /francislab/data1/working/1000genomes/20200311-viral_identification/s3/www.ebi.ac.uk/arrayexpress/files/E-GEUV-1/*.bam.diamond.viral.csv.gz ; do

	echo $input

	outbase=${input%.csv.gz}
	echo $outbase

	jobbase=$( basename $outbase )
	jobbase=${jobbase%%.*}
	if [[ "$input" == *"GEUV"* ]]; then
		jobbase="r${jobbase}"
	else
		jobbase="d${jobbase}"
	fi
	echo $jobbase


	f=${outbase}.summary.txt.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		qsub -N ${jobbase}.s \
			-o ${outbase}.summary.${date}.out.txt -e ${outbase}.summary.${date}.err.txt \
			~/.local/bin/blastn_summary.bash -F "-input ${outbase}.txt.gz"
	fi

done


