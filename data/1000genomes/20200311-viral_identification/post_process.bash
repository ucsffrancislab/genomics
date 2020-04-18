#!/usr/bin/env bash


date=$( date "+%Y%m%d%H%M%S" )




for input in /francislab/data1/working/1000genomes/20200311-viral_identification/s3/1000genomes/phase3/data/*/alignment/*.unmapped.blastn.viral.masked.csv.gz ; do

done






for input in /francislab/data1/working/1000genomes/20200311-viral_identification/s3/1000genomes/phase3/data/*/alignment/*.unmapped.*.bam.diamond.viral.csv.gz ; do

	echo $input

	outbase=${input%.csv.gz}
	echo $outbase

	jobbase=$( basename $outbase )
	jobbase=${jobbase%%.*}
	echo $jobbase

	count_base=$( basename $input .diamond.viral.csv.gz )
	unmapped_read_count=$( cat /francislab/data1/raw/1000genomes/unmapped/${count_base}.unmapped_read_count.txt )

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
		elif [ $size -gt 8000000 ] ; then
			echo "Size $size gt 8000000"
			vmem=6
		else
			echo "Size $size NOT gt 8000000"
			vmem=4
		fi
		summaryid=$( qsub -N ${jobbase}.s -l nodes=1:ppn=2 -l vmem=${vmem}gb \
			-o ${foutbase}.${date}.out.txt -e ${foutbase}.${date}.err.txt \
			~/.local/bin/blastn_summary.bash -F "-input ${input}" )
		echo $summaryid
	fi

	summary=$f

	foutbase=${outbase}.summary.normalized
	f=${foutbase}.txt.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${summaryid} ] ; then
			depend="-W depend=afterok:${summaryid}"
		else
			depend=""
		fi
		#-l nodes=1:ppn=2 -l vmem=4gb \
		qsub ${depend} -N ${jobbase}.norm \
			-o ${foutbase}.${date}.out.txt -e ${foutbase}.${date}.err.txt \
			~/.local/bin/normalize_summary.bash -F "-input ${summary} -d ${unmapped_read_count}"
	fi

	for level in species genus ; do
		suffix=${level%%,*}

		sumsummaryid=""
		foutbase=${outbase}.summary.sum-${suffix}
		f=${foutbase}.txt.gz
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z ${summaryid} ] ; then
				depend="-W depend=afterok:${summaryid}"
			else
				depend=""
			fi
			sumsummaryid=$( qsub ${depend} -N ${jobbase}.${suffix:0:2} -l nodes=1:ppn=2 -l vmem=4gb \
				-o ${foutbase}.${date}.out.txt -e ${foutbase}.${date}.err.txt \
				~/.local/bin/sum_summary.bash -F "-input ${summary} -level ${level}" )
			echo $sumsummaryid
		fi

		foutbase=${outbase}.summary.sum-${suffix}.normalized
		f=${foutbase}.txt.gz
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z ${sumsummaryid} ] ; then
				depend="-W depend=afterok:${sumsummaryid}"
			else
				depend=""
			fi
			#-l nodes=1:ppn=2 -l vmem=4gb \
			qsub ${depend} -N ${jobbase}.${suffix:0:2}.norm \
				-o ${foutbase}.${date}.out.txt -e ${foutbase}.${date}.err.txt \
				~/.local/bin/normalize_summary.bash \
					-F "-input ${outbase}.summary.sum-${suffix}.txt.gz -d ${unmapped_read_count}"
		fi

	done	#	for s in species,genus genus,subfamily subfamily,family ; do

done




for input in /francislab/data1/working/1000genomes/20200311-viral_identification/s3/1000genomes/phase3/data/*/alignment/*.unmapped.*.bam.blastn.viral.masked.csv.gz ; do

	echo $input

	outbase=${input%.csv.gz}
	echo $outbase

	jobbase=$( basename $outbase )
	jobbase=${jobbase%%.*}
	echo $jobbase

	count_base=$( basename $input .blastn.viral.masked.csv.gz )
	unmapped_read_count=$( cat /francislab/data1/raw/1000genomes/unmapped/${count_base}.unmapped_read_count.txt )

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
		elif [ $size -gt 8000000 ] ; then
			echo "Size $size gt 8000000"
			vmem=6
		else
			echo "Size $size NOT gt 8000000"
			vmem=4
		fi
		summaryid=$( qsub -N ${jobbase}.s -l nodes=1:ppn=2 -l vmem=${vmem}gb \
			-o ${foutbase}.${date}.out.txt -e ${foutbase}.${date}.err.txt \
			~/.local/bin/blastn_summary.bash -F "-input ${input}" )
		echo $summaryid
	fi

	summary=$f

	foutbase=${outbase}.summary.normalized
	f=${foutbase}.txt.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${summaryid} ] ; then
			depend="-W depend=afterok:${summaryid}"
		else
			depend=""
		fi
		#-l nodes=1:ppn=2 -l vmem=4gb \
		qsub ${depend} -N ${jobbase}.norm \
			-o ${foutbase}.${date}.out.txt -e ${foutbase}.${date}.err.txt \
			~/.local/bin/normalize_summary.bash -F "-input ${summary} -d ${unmapped_read_count}"
	fi

	#for level in species genus subfamily ; do
	for level in species ; do
		suffix=${level%%,*}

		sumsummaryid=""
		foutbase=${outbase}.summary.sum-${suffix}
		f=${foutbase}.txt.gz
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z ${summaryid} ] ; then
				depend="-W depend=afterok:${summaryid}"
			else
				depend=""
			fi
			sumsummaryid=$( qsub ${depend} -N ${jobbase}.${suffix:0:2} -l nodes=1:ppn=2 -l vmem=4gb \
				-o ${foutbase}.${date}.out.txt -e ${foutbase}.${date}.err.txt \
				~/.local/bin/sum_summary.bash -F "-input ${summary} -level ${level} \
					-db /francislab/data1/refs/taxadb/taxadb_gb.sqlite" )
			echo $sumsummaryid
		fi

		foutbase=${outbase}.summary.sum-${suffix}.normalized
		f=${foutbase}.txt.gz
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z ${sumsummaryid} ] ; then
				depend="-W depend=afterok:${sumsummaryid}"
			else
				depend=""
			fi
			#-l nodes=1:ppn=2 -l vmem=4gb \
			qsub ${depend} -N ${jobbase}.${suffix:0:2}.norm \
				-o ${foutbase}.${date}.out.txt -e ${foutbase}.${date}.err.txt \
				~/.local/bin/normalize_summary.bash \
					-F "-input ${outbase}.summary.sum-${suffix}.txt.gz -d ${unmapped_read_count}"
		fi

	done	#	for s in species,genus genus,subfamily subfamily,family ; do

done


