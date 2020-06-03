#!/usr/bin/env bash


#	for log in *log ; do echo -n "$log "; grep bowtie $log | grep -o , | wc -l ; done | awk '( $2 > 1 )'
#	080217_S1.log 21
#	080217_S2.log 21
#	080217_S3.log 21
#	080217_S4.log 21
#	080217_S5.log 21
#	080217_S6.log 21
#	080217_S7.log 21
#	080217_S8.log 21
#	080217_S9.log 11
#	SMS-KAN.log 3


#mkdir too_inclusive

#for subject in /raid/data/raw/USC-CHLA-NBL/20180821/*.R1.fastq.gz ; do
for subject in 080217_S1 080217_S2 080217_S3 080217_S4 080217_S5 080217_S6 080217_S7 080217_S8 080217_S9 SMS-KAN ; do

#	mv ${subject}.log too_inclusive/
#	mv ${subject}.nonhg38.blastn.txt.gz too_inclusive/
#	mv ${subject}.nonhg38.blastn.viral_hits.txt too_inclusive/
#	mv ${subject}.nonhg38.fasta.gz too_inclusive/
#	mv ${subject}.nonhg38.fasta.reads.txt too_inclusive/

	rm -f ${subject}.log
	rm -f ${subject}.nonhg38.blastn.txt.gz
	rm -f ${subject}.nonhg38.blastn.viral_hits.txt
	rm -f ${subject}.nonhg38.fasta.gz
	rm -f ${subject}.nonhg38.fasta.reads.txt

	root=/raid/data/raw/USC-CHLA-NBL/20180821/${subject}
	base=$( basename $root )
	echo $subject $root
#	if [[ -e ${base}.log ]] ; then
#		echo "Log exists. Skipping."
#	else
		dark.bash --threads 40 $root
#	fi

done

