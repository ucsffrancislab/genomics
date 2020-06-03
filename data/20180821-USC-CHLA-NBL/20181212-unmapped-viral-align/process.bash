#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables

set -o pipefail


database_file="viral_mapped_unmapped.sqlite3"

sql="sqlite3 ${database_file}"

if [ ! -f ${database_file} ] ; then

	${sql} "CREATE TABLE subjects( subject, unmapped ); CREATE UNIQUE INDEX subjects_subject ON subjects (subject);"

#CREATE TABLE subjects( subject, unmapped , NC_001710_1, NC_001710_1_unmapped, NC_001716_2, NC_001716_2_unmapped, NC_001664_4, NC_001664_4_unmapped, NC_000898_1, NC_000898_1_unmapped, NC_008168_1, NC_008168_1_unmapped);

	for virus in NC_001710.1 NC_001716.2 NC_001664.4 NC_000898.1 NC_008168.1 ; do
	#for virus in /raid/refs/fasta/virii/*fasta ; do
		#virus=$( basename $virus .fasta )
		virus=${virus/./_}
		#echo $virus
		${sql} "ALTER TABLE subjects ADD COLUMN ${virus}"
		${sql} "ALTER TABLE subjects ADD COLUMN ${virus}_unmapped"
		${sql} "ALTER TABLE subjects ADD COLUMN uncommon_${virus}"
		${sql} "ALTER TABLE subjects ADD COLUMN uncommon_${virus}_unmapped"
	#	${sql} "ALTER TABLE subjects ADD COLUMN uncommon_${virus}_total"
	done

fi



#for bam in $( find /raid/data/raw/1000genomes/phase3/data/ -name *unmapped*bam ) ; do
#for bam in /raid/data/raw/1000genomes/phase3/data/*/alignment/*unmapped*bam ; do
for r1 in /raid/data/raw/USC-CHLA-NBL/2018????/*.R1.fastq.gz ; do

	echo "------------------------------------------------------------"
	base=$( basename $r1 )
	subject=${base%.R1.fastq.gz}
	r2=${r1/.R1.fastq.gz/.R2.fastq.gz}
	echo $r1
	echo $r2
	echo $base
	echo $subject

	echo "Processing $subject"


	if [ -f ${subject}/${subject}.unmapped.count.txt ] && [ ! -w ${subject}/${subject}.unmapped.count.txt ]  ; then
		echo "Write-protected ${subject}.unmapped.count.txt exists. Skipping step."
	else
		echo "Counting reads in $r1"
		r1lines=$( zcat $r1 | wc -l )
		echo $[r1lines/2] > ${subject}/${subject}.unmapped.count.txt
		chmod a-w ${subject}/${subject}.unmapped.count.txt
	fi

	if [ -z $( ${sql} "SELECT unmapped FROM subjects WHERE subject = '${subject}'" ) ] ; then
		count=$( cat ${subject}/${subject}.unmapped.count.txt )
		command="INSERT INTO subjects( subject, unmapped ) VALUES ( '${subject}', '${count}' );"
		echo "${command}"
		${sql} "${command}"
	fi

#	NC_001710.1 GB virus C/Hepatitis G virus, complete genome
#	NC_001716.2 Human herpesvirus 7, complete genome
#	NC_001664.4 Human betaherpesvirus 6A, variant A DNA, complete virion genome,
#	NC_000898.1 Human herpesvirus 6B
#	NC_008168.1 Choristoneura fumiferana granulovirus, complete genome

	for virus in NC_001710.1 NC_001716.2 NC_001664.4 NC_000898.1 NC_008168.1 ; do

#	for virus in /raid/refs/fasta/virii/*fasta ; do
#		virus=$( basename $virus .fasta )

		echo "Processing $subject / $virus"
		v=${virus/./_}

		if [ -f ${subject}/${subject}.${virus}.bam ] && [ ! -w ${subject}/${subject}.${virus}.bam ]  ; then
			echo "Write-protected ${subject}.${virus}.bam exists. Skipping step."
		else

			if [ -f ${subject}/${subject}.${virus}.unsorted.bam ] && [ ! -w ${subject}/${subject}.${virus}.unsorted.bam ]  ; then
				echo "Write-protected ${subject}.${virus}.unsorted.bam exists. Skipping step."
			else
				bowtie2 --threads 40 --xeq -x virii/${virus} --very-sensitive -1 ${r1} -2 ${r2} 2>> ${subject}/${subject}.${virus}.log | samtools view -F 4 -o ${subject}/${subject}.${virus}.unsorted.bam -
				#chmod a-w ${subject}.${virus}.unsorted.bam
			fi

			echo "Sorting"
			samtools sort -o ${subject}/${subject}.${virus}.bam ${subject}/${subject}.${virus}.unsorted.bam
			chmod a-w ${subject}/${subject}.${virus}.bam

			\rm ${subject}/${subject}.${virus}.unsorted.bam
		fi

		if [ -f ${subject}/${subject}.${virus}.bam.bai ] && [ ! -w ${subject}/${subject}.${virus}.bam.bai ]  ; then
			echo "Write-protected ${subject}.${virus}.bam.bai exists. Skipping step."
		else
			echo "Indexing"
			samtools index ${subject}/${subject}.${virus}.bam
			chmod a-w ${subject}/${subject}.${virus}.bam.bai
		fi

		if [ -f ${subject}/${subject}.${virus}.depth.csv ] && [ ! -w ${subject}/${subject}.${virus}.depth.csv ]  ; then
			echo "Write-protected ${subject}.${virus}.depth.csv exists. Skipping step."
		else
			echo "Getting depth"
#	Should have
#			samtools depth -d 0 ${subject}/${subject}.${virus}.bam > ${subject}/${subject}.${virus}.depth.csv
			samtools depth ${subject}/${subject}.${virus}.bam > ${subject}/${subject}.${virus}.depth.csv
			chmod a-w ${subject}/${subject}.${virus}.depth.csv
		fi

		if [ -f ${subject}/${subject}.${virus}.bowtie2.mapped.count.txt ] && [ ! -w ${subject}/${subject}.${virus}.bowtie2.mapped.count.txt ]  ; then
			echo "Write-protected ${subject}.${virus}.bowtie2.mapped.count.txt exists. Skipping step."
		else
			echo "Counting reads bowtie2 aligned to ${virus}"
			#	-F 4 needless here as filtered with this flag above.
			samtools view -c -F 4 ${subject}/${subject}.${virus}.bam > ${subject}/${subject}.${virus}.bowtie2.mapped.count.txt
			chmod a-w ${subject}/${subject}.${virus}.bowtie2.mapped.count.txt
		fi

		if [ -z $( ${sql} "SELECT ${v} FROM subjects WHERE subject = '${subject}'" ) ] ; then
			count=$( cat ${subject}/${subject}.${virus}.bowtie2.mapped.count.txt )
			command="UPDATE subjects SET ${v} = '${count}' WHERE subject = '${subject}'"
			echo "${command}"
			${sql} "${command}"
		fi


		for exp in 2500 ; do

			for per in 1 ; do
	
				if [ -f common_regions/common_regions.${exp}.${per}.${virus}.txt ] ; then

					f="${subject}/${subject}.${virus}.bowtie2.mapped_uncommon.${exp}.${per}.count.txt"
		
					if [ -f ${f} ] && [ ! -w ${f} ]  ; then
						echo "Write-protected ${f} exists. Skipping step."
					else
						echo "Counting reads bowtie2 aligned uncommon.${exp}.${per} to ${virus}"
						#	-F 4 needless here as filtered with this flag above.
			
						#	grep will return error code if no line found so add || true
						region=$( grep Samtools common_regions/common_regions.${exp}.${per}.${virus}.txt || true )
		
						echo $region
						region=${region#Samtools uncommon regions: }
						#common_regions.D13784.1.txt:Samtools uncommon regions: D13784.1:1-4163 D13784.1:4208-7649 D13784.1:7691-8000 D13784.1:8053-1000000
			
						echo "${region}"
						[ -z "${region}" ] && region="${virus}"
			
						#samtools view -c -F 4 ${subject}/${subject}.virii.bam ${region} > ${f}
						samtools view -c -F 4 ${subject}/${subject}.${virus}.bam ${region} > ${f}
			
						chmod a-w ${f}
					fi
		
					if [ -z $( ${sql} "SELECT uncommon_${v} FROM subjects WHERE subject = '${subject}'" ) ] ; then
						count=$( cat ${f} )
						command="UPDATE subjects SET uncommon_${v} = '${count}' WHERE subject = '${subject}'"
						echo "${command}"
						${sql} "${command}"
					fi

				fi

			done

		done


#		if [ -f ${subject}/${subject}.${virus}.bowtie2.mapped.ratio_unmapped.txt ] && [ ! -w ${subject}/${subject}.${virus}.bowtie2.mapped.ratio_unmapped.txt ] ; then
#			echo "Write-protected ${subject}.${virus}.bowtie2.mapped.ratio_unmapped.txt exists. Skipping step."
#		else
#			echo "Calculating ratio ${virus} bowtie2 alignments to total unaligned reads"
#			echo "scale=9; "$(cat ${subject}/${subject}.${virus}.bowtie2.mapped.count.txt)"/"$(cat ${subject}/${subject}.unmapped.count.txt) | bc > ${subject}/${subject}.${virus}.bowtie2.mapped.ratio_unmapped.txt
#			chmod a-w ${subject}/${subject}.${virus}.bowtie2.mapped.ratio_unmapped.txt
#		fi
#
#		if [ -z $( ${sql} "SELECT ${v}_unmapped FROM subjects WHERE subject = '${subject}'" ) ] ; then
#			count=$( cat ${subject}/${subject}.${virus}.bowtie2.mapped.ratio_unmapped.txt )
#			command="UPDATE subjects SET ${v}_unmapped = '${count}' WHERE subject = '${subject}'"
#			echo "${command}"
#			${sql} "${command}"
#		fi

	done

done

for virus in NC_001710.1 NC_001716.2 NC_001664.4 NC_000898.1 NC_008168.1 ; do
	virus=${virus/./_}
	command="UPDATE subjects SET ${virus}_unmapped = 1.0 * ${virus} / unmapped;"
	echo "${command}"
	${sql} "${command}"
	command="UPDATE subjects SET uncommon_${virus}_unmapped = 1.0 * uncommon_${virus} / unmapped;"
	echo "${command}"
	${sql} "${command}"
done


echo "---"
echo "Done"
