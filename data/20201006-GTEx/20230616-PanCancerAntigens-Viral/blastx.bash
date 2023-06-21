#!/usr/bin/env bash

zcat /francislab/data1/working/20201006-GTEx/20201116-preprocess/trimmed/SRR821690_R?.fastq.gz \
 | paste - - - - \
 | awk -F"\t" '{sub(/^@/,">",$1);print $1;print $2}' \
 | blastx -outfmt 6 -evalue 0.05 \
 -db /francislab/data1/working/20230426-PanCancerAntigens/20230426-explore/viral_protein_accessions \
 > SRR821690_IN_viral_protein_accessions.blastx.e0.05.tsv
