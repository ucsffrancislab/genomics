#!/usr/bin/env bash

echo -n "subject,raw pair count"
for hkle in HERVK113 SVA_A SVA_B SVA_C SVA_D SVA_E SVA_F ; do
#	echo -n "${hkle} unpaired reads aligned,"
#	echo -n "${hkle} paired pairs aligned,"
	for pup in unpaired paired ; do
		echo -n ",${hkle} ${pup} reads aligned"
		for quality in Q00 Q10 Q20 ; do
			echo -n ",${hkle} ${pup} human ${quality} aligned"
			echo -n ",uniq ${hkle} ${pup} human ${quality} aligned"
			echo -n ",r10 uniq ${hkle} ${pup} human ${quality} aligned"
			echo -n ",r100 uniq ${hkle} ${pup} human ${quality} aligned"
			echo -n ",r1000 uniq ${hkle} ${pup} human ${quality} aligned"
			echo -n ",r10000 uniq ${hkle} ${pup} human ${quality} aligned"
			echo -n ",r100000 uniq ${hkle} ${pup} human ${quality} aligned"
		done
	done
done
echo

#for raw_subject in /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/sample/*.fastq.gz.read_count.txt ; do
for raw_subject in /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out/*.fastq.gz.read_count.txt ; do
	subject=$( basename ${raw_subject} _R1.fastq.gz.read_count.txt )

	if [ -d "hkle/${subject}.hkle" ] ; then

		echo -n ${subject%-???-????},
		echo -n $( cat ${raw_subject} )
	
		for hkle in HERVK113 SVA_A SVA_B SVA_C SVA_D SVA_E SVA_F ; do
	
	#		echo -n ,$( cat hkle/${subject}.hkle/${subject}.bowtie2.${hkle}.*.unpaired.*.fasta.read_count 2> /dev/null | awk 'BEGIN{s=0}{s+=$1}END{print s}' )
	#		echo -n ,$( cat hkle/${subject}.hkle/${subject}.bowtie2.${hkle}.*.paired.*_1.fasta.read_count 2> /dev/null | awk 'BEGIN{s=0}{s+=$1}END{print s}' )
	
			for pup in unpaired paired ; do
				echo -n ,$( cat hkle/${subject}.hkle/${subject}.bowtie2.${hkle}.*.${pup}.*.fasta.read_count 2> /dev/null | awk 'BEGIN{s=0}{s+=$1}END{print s}' )
				for quality in Q00 Q10 Q20 ; do
	
					echo -n ,$( cat hkle/${subject}.hkle/${subject}.bowtie2.${hkle}.*.${pup}.*.${quality}.*insertion_points.count 2> /dev/null | awk 'BEGIN{s=0}{s+=$1}END{print s}' )
	
					echo -n ,$( cat hkle/${subject}.hkle/${subject}.bowtie2.${hkle}.*.${pup}.*.${quality}.*insertion_points 2> /dev/null | sort -u | wc -l )
	
					echo -n ,$( cat hkle/${subject}.hkle/${subject}.bowtie2.${hkle}.*.${pup}.*.${quality}.*insertion_points 2> /dev/null | awk 'BEGIN{FS=OFS="|"}{print $1,int($2/10)*10}' | sort -u | wc -l )
					echo -n ,$( cat hkle/${subject}.hkle/${subject}.bowtie2.${hkle}.*.${pup}.*.${quality}.*insertion_points 2> /dev/null | awk 'BEGIN{FS=OFS="|"}{print $1,int($2/100)*100}' | sort -u | wc -l )
					echo -n ,$( cat hkle/${subject}.hkle/${subject}.bowtie2.${hkle}.*.${pup}.*.${quality}.*insertion_points 2> /dev/null | awk 'BEGIN{FS=OFS="|"}{print $1,int($2/1000)*1000}' | sort -u | wc -l )
					echo -n ,$( cat hkle/${subject}.hkle/${subject}.bowtie2.${hkle}.*.${pup}.*.${quality}.*insertion_points 2> /dev/null | awk 'BEGIN{FS=OFS="|"}{print $1,int($2/10000)*10000}' | sort -u | wc -l )
					echo -n ,$( cat hkle/${subject}.hkle/${subject}.bowtie2.${hkle}.*.${pup}.*.${quality}.*insertion_points 2> /dev/null | awk 'BEGIN{FS=OFS="|"}{print $1,int($2/10000)*10000}' | sort -u | wc -l )
	
				done	#	quality
			done	#	pup
		done	#	hkle

		echo
	fi
done	#	subject
