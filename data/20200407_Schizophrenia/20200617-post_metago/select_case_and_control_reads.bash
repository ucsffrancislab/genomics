#!/usr/bin/env bash



while IFS=, read -r sample cc ; do

	echo "$sample -> $cc"

	for r in R1 R2 ; do

		#grep -f ASS_filtered_down_kmers.txt -B 1 -A 2 --no-group-separator out/${sample}_${r}.fastq \
		#	| paste - - - - | sed "s/^@/@${sample}_${r}:/" | tr "\t" "\n" >> ${cc}.fastq

		grep -f ASS_filtered_down_kmers.txt -B 1 -A 2 --no-group-separator out/${sample}_${r}.fastq \
			| sed "1~4s/^@/@${sample}_${r}:/" >> ${cc}.fastq

		sed "1~4s/^@/@${sample}_${r}:/" out/${sample}_${r}.fastq >> ${cc}_${r}.fastq

	done


done < /francislab/data1/raw/20200407_Schizophrenia/metadata.csv 

