#!/usr/bin/env bash


REFS=/data/shared/francislab/refs
FASTA=${REFS}/fasta
dir=/data/shared/francislab/data/raw/SFGF-Shaw-GS-13361/trimmed/unpaired

threads=16
vmem=8
date=$( date "+%Y%m%d%H%M%S" )

for bambase in subread-dna subread-rna ; do


	for feature in miRNA miRNA_primary_transcript ; do
		qsub -N ${feature} -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
			-o ${dir}/${bambase}.hsa.featureCounts.${feature}.${date}.out.txt \
			-e ${dir}/${bambase}.hsa.featureCounts.${feature}.${date}.err.txt \
			~/.local/bin/featureCounts.bash -F \
				"-T ${threads} -t ${feature} -g Name -a ${FASTA}/hg38.chr.hsa.gff3 \
				-o ${dir}/${bambase}.hsa.featureCounts.${feature}.csv \
				${dir}/??.h38au.${bambase}.bam"
	done	#	for feature in miRNA miRNA_primary_transcript ; do


	for feature in exon CDS start_codon stop_codon ; do
		qsub -N ${feature} -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
			-o ${dir}/${bambase}.genes.featureCounts.${feature}.${date}.out.txt \
			-e ${dir}/${bambase}.genes.featureCounts.${feature}.${date}.err.txt \
			~/.local/bin/featureCounts.bash -F \
				"-T ${threads} -t ${feature} -g gene_id -a ${REFS}/Homo_sapiens/UCSC/hg38/Annotation/Genes/genes.gtf \
				-o ${dir}/${bambase}.genes.featureCounts.${feature}.csv \
				${dir}/??.h38au.${bambase}.bam"
	done	#	for feature in exon CDS start_codon stop_codon ; do


done	#	for bambase in subread-dna subread-rna ; do
