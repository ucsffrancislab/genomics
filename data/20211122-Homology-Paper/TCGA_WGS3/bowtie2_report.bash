#!/usr/bin/env bash

#accessions=$( cat select_viruses.txt | xargs -I% basename % | awk 'BEGIN{FS=OFS="_"}{print $1,$2}' )
accessions=$( cut -f1 select_viruses.csv )

echo -n "| sample | read count | average length |"
for accession in $accessions ; do

	echo -n " raw $accession |"
	echo -n " RM $accession |"
	echo -n " hg38 $accession |"
	echo -n " RM+hg38 $accession |"

done
echo


for sample in $( cat TCGA_normal_samples.txt ); do

	raw_reads=$( cat /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out/${sample}_R1.fastq.gz.read_count.txt )

	lengths=$( cat /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out/${sample}_R1.fastq.gz.average_length.txt )

	echo -n "| ${sample} |"
	echo -n " ${raw_reads} |"
	echo -n " ${lengths} |"

	for accession in $accessions ; do

		n=''
		if [ -f aligned/raw/${sample}.bam.aligned_sequence_counts.txt ] ; then
			n=$( awk -v accession=${accession} '($2 == accession ){print $1}' aligned/raw/${sample}.bam.aligned_sequence_counts.txt )
		fi
		echo -n " ${n:-0} |"

		n=''
		if [ -f aligned/RM/${sample}.bam.aligned_sequence_counts.txt ] ; then
			n=$( awk -v accession=${accession} '($2 == accession ){print $1}' aligned/RM/${sample}.bam.aligned_sequence_counts.txt )
		fi
		echo -n " ${n:-0} |"

		n=''
		if [ -f aligned/hg38masked/${sample}.bam.aligned_sequence_counts.txt ] ; then
			n=$( awk -v accession=${accession} '($2 == accession ){print $1}' aligned/hg38masked/${sample}.bam.aligned_sequence_counts.txt )
		fi
		echo -n " ${n:-0} |"

		n=''
		if [ -f aligned/RMhg38masked/${sample}.bam.aligned_sequence_counts.txt ] ; then
			n=$( awk -v accession=${accession} '($2 == accession ){print $1}' aligned/RMhg38masked/${sample}.bam.aligned_sequence_counts.txt )
		fi
		echo -n " ${n:-0} |"

	done

	echo
done

