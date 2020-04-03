#!/usr/bin/env bash


date=$( date "+%Y%m%d%H%M%S" )


for input in /francislab/data1/working/Geuvadis/20200311-viral_identification/s3/www.ebi.ac.uk/arrayexpress/files/E-GEUV-1/*.bam.diamond.viral.csv.gz ; do

	echo $input

	base=${input%.csv.gz}
	echo $outbase

	jobbase=$( basename $base )
	jobbase=${jobbase%%.*}
	echo $jobbase

	summaryid=""
	outbase=${base}.summary
	f=${outbase}.txt.gz
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
			-o ${outbase}.${date}.out.txt -e ${outbase}.${date}.err.txt \
			~/.local/bin/blastn_summary.bash -F "-input ${input}" )
		echo $summaryid
	fi

	summary=$f

	count_base=$( basename $input .diamond.viral.csv.gz )
	unmapped_read_count=$( cat /francislab/data1/raw/Geuvadis/bam/${count_base}.bai.unmapped_read_count.txt )

	echo "Unmapped Count :${unmapped_read_count}:"

	outbase=${base}.summary.normalized
	f=${outbase}.txt.gz
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
			-o ${outbase}.${date}.out.txt -e ${outbase}.${date}.err.txt \
			~/.local/bin/normalize_summary.bash -F "-input ${summary} -d ${unmapped_read_count}"
	fi

	#for level in species genus subfamily ; do
	for level in species ; do
		suffix=${level%%,*}

		sumsummaryid=""
		outbase=${base}.summary.sum-${suffix}
		f=${outbase}.txt.gz
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z ${summaryid} ] ; then
				depend="-W depend=afterok:${summaryid}"
			else
				depend=""
			fi
			sumsummaryid=$( qsub ${depend} -N ${jobbase}.${suffix:0:2} -l nodes=1:ppn=2 -l vmem=4gb \
				-o ${outbase}.${date}.out.txt -e ${outbase}.${date}.err.txt \
				~/.local/bin/sum_summary.bash -F "-input ${summary} -level ${level}" )
			echo $sumsummaryid
		fi
	
		outbase=${base}.summary.sum-${suffix}.normalized
		f=${outbase}.txt.gz
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
				-o ${outbase}.${date}.out.txt -e ${outbase}.${date}.err.txt \
				~/.local/bin/normalize_summary.bash \
					-F "-input ${base}.summary.sum-${suffix}.txt.gz -d ${unmapped_read_count}"
		fi

	done	#	for s in species genus subfamily ; do

done





for input in /francislab/data1/working/Geuvadis/20200311-viral_identification/s3/geuvadis-bam/*.bam.blastn.viral.masked.csv.gz ; do

	echo $input

	base=${input%.csv.gz}
	echo $outbase

	jobbase=$( basename $base )
	jobbase=${jobbase%%.*}
	echo $jobbase

	summaryid=""
	outbase=${base}.summary
	f=${outbase}.txt.gz
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
			-o ${outbase}.${date}.out.txt -e ${outbase}.${date}.err.txt \
			~/.local/bin/blastn_summary.bash -F "-input ${input}" )
		echo $summaryid
	fi

	summary=$f

	count_base=$( basename $input .blastn.viral.masked.csv.gz )
	unmapped_read_count=$( cat /francislab/data1/raw/Geuvadis/bam/${count_base}.bai.unmapped_read_count.txt )

	echo "Unmapped Count :${unmapped_read_count}:"

	outbase=${base}.summary.normalized
	f=${outbase}.txt.gz
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
			-o ${outbase}.${date}.out.txt -e ${outbase}.${date}.err.txt \
			~/.local/bin/normalize_summary.bash -F "-input ${summary} -d ${unmapped_read_count}"
	fi

	#for level in species genus subfamily ; do
	for level in species ; do
		suffix=${level%%,*}

		sumsummaryid=""
		outbase=${base}.summary.sum-${suffix}
		f=${outbase}.txt.gz
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z ${summaryid} ] ; then
				depend="-W depend=afterok:${summaryid}"
			else
				depend=""
			fi
			sumsummaryid=$( qsub ${depend} -N ${jobbase}.${suffix:0:2} -l nodes=1:ppn=2 -l vmem=4gb \
				-o ${outbase}.${date}.out.txt -e ${outbase}.${date}.err.txt \
				~/.local/bin/sum_summary.bash -F "-input ${summary} -level ${level} \
					-db /francislab/data1/refs/taxadb/taxadb_gb.sqlite" )
			echo $sumsummaryid
		fi
	
		outbase=${base}.summary.sum-${suffix}.normalized
		f=${outbase}.txt.gz
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
				-o ${outbase}.${date}.out.txt -e ${outbase}.${date}.err.txt \
				~/.local/bin/normalize_summary.bash \
					-F "-input ${base}.summary.sum-${suffix}.txt.gz -d ${unmapped_read_count}"
		fi

	done	#	for s in species genus subfamily ; do

done
