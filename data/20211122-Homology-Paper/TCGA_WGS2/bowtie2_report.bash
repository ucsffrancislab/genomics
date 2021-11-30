#!/usr/bin/env bash

#accessions=$( cat select_viruses.txt | xargs -I% basename % | awk 'BEGIN{FS=OFS="_"}{print $1,$2}' )
accessions=$( cut -f1 ../select_viruses.csv )

echo -n "| sample | read count | average length |"
for accession in $accessions ; do

	echo -n " raw $accession |"
	echo -n " RM $accession |"
	echo -n " hg38 $accession |"
	echo -n " RM+hg38 $accession |"

done
echo


for sample in $( head TCGA_normal_samples.txt ); do

	raw_reads=$( cat /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out/${sample}_R1.fastq.gz.read_count.txt )

	lengths=$( cat /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out/${sample}_R1.fastq.gz.average_length.txt )


#	#	Do I filter on read length? Don't echo until after here.
#	if [ ${lengths} -ne 101 ] ; then
#		continue
#	fi

	echo -n "| ${sample} |"
	echo -n " ${raw_reads} |"
	echo -n " ${lengths} |"


	#	Once complete, normalize to hits per billion reads?


#	raw_counts=""
#	f=${PWD}/aligned/raw/${sample}.bam
#	if [ -f ${f} ] && [ ! -w ${f} ] ; then
#		raw_counts=$( samtools view ${f} | awk -F"\t" '{print $3}' | uniq -c )
#	fi
#
#	RM_counts=""
#	f=${PWD}/aligned/RM/${sample}.bam
#	if [ -f ${f} ] && [ ! -w ${f} ] ; then
#		RM_counts=$( samtools view ${f} | awk -F"\t" '{print $3}' | uniq -c )
#	fi
#
#	hg38masked_counts=""
#	f=${PWD}/aligned/hg38masked/${sample}.bam
#	if [ -f ${f} ] && [ ! -w ${f} ] ; then
#		hg38masked_counts=$( samtools view ${f} | awk -F"\t" '{print $3}' | uniq -c )
#	fi
#
#	RMhg38masked_counts=""
#	f=${PWD}/aligned/RMhg38masked/${sample}.bam
#	if [ -f ${f} ] && [ ! -w ${f} ] ; then
#		RMhg38masked_counts=$( samtools view ${f} | awk -F"\t" '{print $3}' | uniq -c )
#	fi

	for accession in $accessions ; do

#		n=''
#		#n=$( echo "${raw_counts}" | awk -v accession=${accession} '($2 == accession ){print $1}' )
#		if [ -f aligned/raw/${sample}.bam.aligned_sequence_counts.txt ] ; then
#			n=$( awk -v accession=${accession} '($2 == accession ){print $1}' aligned/raw/${sample}.bam.aligned_sequence_counts.txt )
#		fi
#		echo -n " ${n:-0} |"
#
#		n=''
#		#n=$( echo "${RM_counts}" | awk -v accession=${accession} '($1 == accession ){print $2}' )
#		if [ -f aligned/RM/${sample}.bam.aligned_sequence_counts.txt ] ; then
#			n=$( awk -v accession=${accession} '($2 == accession ){print $1}' aligned/RM/${sample}.bam.aligned_sequence_counts.txt )
#		fi
#		echo -n " ${n:-0} |"
#
#		n=''
#		#n=$( echo "${hg38masked_counts}" | awk -v accession=${accession} '($1 == accession ){print $2}' )
#		if [ -f aligned/hg38masked/${sample}.bam.aligned_sequence_counts.txt ] ; then
#			n=$( awk -v accession=${accession} '($2 == accession ){print $1}' aligned/hg38masked/${sample}.bam.aligned_sequence_counts.txt )
#		fi
#		echo -n " ${n:-0} |"
#
#		n=''
#		#n=$( echo "${RMhg38masked_counts}" | awk -v accession=${accession} '($1 == accession ){print $2}' )
#		if [ -f aligned/RMhg38masked/${sample}.bam.aligned_sequence_counts.txt ] ; then
#			n=$( awk -v accession=${accession} '($2 == accession ){print $1}' aligned/RMhg38masked/${sample}.bam.aligned_sequence_counts.txt )
#		fi
#		echo -n " ${n:-0} |"



		n=''
		if [ -f aligned/raw/${accession}/${sample}.bam.aligned_count.txt ] ; then
			n=$( cat aligned/raw/${accession}/${sample}.bam.aligned_count.txt )
		fi
		echo -n " ${n:-0} |"

		n=''
		if [ -f aligned/RM/${accession}/${sample}.bam.aligned_count.txt ] ; then
			n=$( cat aligned/RM/${accession}/${sample}.bam.aligned_count.txt )
		fi
		echo -n " ${n:-0} |"

		n=''
		if [ -f aligned/hg38/${accession}/${sample}.bam.aligned_count.txt ] ; then
			n=$( cat aligned/hg38/${accession}/${sample}.bam.aligned_count.txt )
		fi
		echo -n " ${n:-0} |"

		n=''
		if [ -f aligned/RMhg38/${accession}/${sample}.bam.aligned_count.txt ] ; then
			n=$( cat aligned/RMhg38/${accession}/${sample}.bam.aligned_count.txt )
		fi
		echo -n " ${n:-0} |"

	done

	echo
done


