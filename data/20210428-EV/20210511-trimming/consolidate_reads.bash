#!/usr/bin/env bash

mkdir output
cp /francislab/data1/working/20210428-EV/20210511-trimming/trimmed/*.{subject,diagnosis,labkit} output/

sbatch="sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL --parsable "

date=$( date "+%Y%m%d%H%M%S" )


for fastq in /francislab/data1/working/20210428-EV/20210511-trimming/trimmed/SFHH005*.fastq.gz ; do
	echo $fastq

	basename=$( basename $fastq .fastq.gz )
	basename=${basename%%_*}
	echo $basename
	labkit=$( cat /francislab/data1/raw/20210428-EV/Hansen/${basename}.labkit )

	#	Copy, sort and consolidate on UMI
	cons_id=""
	in_base=${fastq}
	out_base=output/${basename}
	f=${out_base}.fastq.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		#	my copy umi id so it is compatible with the consolidate script
		#	consolidation requires loading all reads with the same umi in memory at the same time.
		#	1 of these reads exists so many times that even 60G isn't enough
		#	Even a few samples that fail on 120GB! (SFHH005u, ...)
		#	And even v won't run on 240! And ar, v and u takes longer than 4 hours!
		#	Note that v and ar are the blank samples. Wondering if 6 hours is too little.
		#	v is now at 12 hours and using about 326GB memory. 23hours! now
#		${sbatch} --parsable --job-name=${basename}_umi --time=360 --ntasks=4 --mem=30G \
#			--output=${out_base}.${date}.txt \
#			${PWD}/consolidate_umi.bash -l 12 -i ${fastq} -o ${f}
	fi

done

#count_fasta_reads.bash trimmed/*fastq.gz
#average_fasta_read_length.bash trimmed/*fastq.gz


