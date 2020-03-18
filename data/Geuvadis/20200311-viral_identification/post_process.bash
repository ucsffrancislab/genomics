#!/usr/bin/env bash


date=$( date "+%Y%m%d%H%M%S" )


for input in /francislab/data1/working/1000genomes/20200311-viral_identification/s3/www.ebi.ac.uk/arrayexpress/files/E-GEUV-1/*.bam.diamond.viral.csv.gz ; do

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

	summaryid=""
	foutbase=${outbase}.summary
	f=${foutbase}.txt.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		size=$( stat -c %s $input )
		if [ $size -gt 10000000 ] ; then
			echo "Size $size gt 10000000"
			vmem=8
		else
			echo "Size $size NOT gt 10000000"
			vmem=4
		fi
		summaryid=$( qsub -N ${jobbase}.s -l nodes=1:ppn=2 -l vmem=${vmem}gb \
			-o ${foutbase}.${date}.out.txt -e ${foutbase}.${date}.err.txt \
			~/.local/bin/blastn_summary.bash -F "-input ${input}" )
		echo $summaryid
	fi

	summary=$f
	foutbase=${outbase}.summary.sum-species
	f=${foutbase}.txt.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${summaryid} ] ; then
			depend="-W depend=afterok:${summaryid}"
		else
			depend=""
		fi
		qsub ${depend} -N ${jobbase}.species -l nodes=1:ppn=2 -l vmem=4gb \
			-o ${foutbase}.${date}.out.txt -e ${foutbase}.${date}.err.txt \
			~/.local/bin/sum_summary.bash -F "-input ${summary} -level species,genus"
	fi

	foutbase=${outbase}.summary.sum-genus
	f=${foutbase}.txt.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${summaryid} ] ; then
			depend="-W depend=afterok:${summaryid}"
		else
			depend=""
		fi
		qsub ${depend} -N ${jobbase}.genus -l nodes=1:ppn=2 -l vmem=4gb \
			-o ${foutbase}.${date}.out.txt -e ${foutbase}.${date}.err.txt \
			~/.local/bin/sum_summary.bash -F "-input ${summary} -level genus,subfamily"
	fi

	foutbase=${outbase}.summary.sum-subfamily
	f=${foutbase}.txt.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${summaryid} ] ; then
			depend="-W depend=afterok:${summaryid}"
		else
			depend=""
		fi
		qsub ${depend} -N ${jobbase}.subfamily -l nodes=1:ppn=2 -l vmem=4gb \
			-o ${foutbase}.${date}.out.txt -e ${foutbase}.${date}.err.txt \
			~/.local/bin/sum_summary.bash -F "-input ${summary} -level subfamily,family"
	fi

done


