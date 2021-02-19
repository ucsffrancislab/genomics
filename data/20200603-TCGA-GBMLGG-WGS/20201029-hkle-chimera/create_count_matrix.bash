#!/usr/bin/env bash

echo -n "subject,raw pair count"
for hkle in HERVK113 SVA_A SVA_B SVA_C SVA_D SVA_E SVA_F ; do
#	echo -n "${hkle} unpaired reads aligned,"
#	echo -n "${hkle} paired pairs aligned,"
	for pup in unpaired paired ; do
		echo -n ",${hkle} ${pup} reads aligned"
		for quality in Q00 Q10 Q20 ; do
			echo -n ",${hkle} ${pup} human ${quality} aligned"
		done
	done
done
echo

for raw_subject in /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/sample/*.fastq.gz.read_count.txt ; do
	subject=$( basename ${raw_subject} _R1.fastq.gz.read_count.txt )
	echo -n ${subject},
	echo -n $( cat ${raw_subject} )

	for hkle in HERVK113 SVA_A SVA_B SVA_C SVA_D SVA_E SVA_F ; do

#		echo -n ,$( cat out/${subject}.SVAs_and_HERVs_KWHE.hkle/${subject}.SVAs_and_HERVs_KWHE.bowtie2.${hkle}.*.unpaired.*.fasta.read_count 2> /dev/null | awk 'BEGIN{s=0}{s+=$1}END{print s}' )
#		echo -n ,$( cat out/${subject}.SVAs_and_HERVs_KWHE.hkle/${subject}.SVAs_and_HERVs_KWHE.bowtie2.${hkle}.*.paired.*_1.fasta.read_count 2> /dev/null | awk 'BEGIN{s=0}{s+=$1}END{print s}' )

		for pup in unpaired paired ; do
			echo -n ,$( cat out/${subject}.SVAs_and_HERVs_KWHE.hkle/${subject}.SVAs_and_HERVs_KWHE.bowtie2.${hkle}.*.${pup}.*.fasta.read_count 2> /dev/null | awk 'BEGIN{s=0}{s+=$1}END{print s}' )
			for quality in Q00 Q10 Q20 ; do

				echo -n ,$( cat out/${subject}.SVAs_and_HERVs_KWHE.hkle/${subject}.SVAs_and_HERVs_KWHE.bowtie2.${hkle}.*.${pup}.*.${quality}.*insertion_points.count 2> /dev/null | awk 'BEGIN{s=0}{s+=$1}END{print s}' )

			done	#	quality
		done	#	pup
	done	#	hkle
	echo
done	#	subject
