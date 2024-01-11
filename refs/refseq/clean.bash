#!/usr/bin/env bash


#	sadly this kept quiting on dev3. Probably admin killing it

zcat /francislab/data1/refs/refseq/bacteria-20210916/bacteria.*.*.genomic.fna.gz | sed -e '/^>/s/[],;:\(\)\/'' []/_/g' -r -e '/^>/s/_{2,}/_/g' -e '/^>/s/(^.{1,245}).*/\1/' | gzip > /francislab/data1/refs/refseq/bacteria-20210916/bacteria.genomic.cleaned5.fna.gz


#	faSplit
#
#	mustOpen: Can't open /francislab/data1/refs/refseq/bacteria-20210916/individual/NC_010064.1_Escherichia_coli_isolate_BL26A_plasmid_pLMO226_IS6-like_element_IS26_family_transposase_H4K13_RS00005_gene_partial_cds;_trimethoprim-resistant_dihydrofolate_reductase_DfrA8_dfrA8_gene_complete_cds;_frameshifted_H4K13_RS00015_pseudogene_complete_sequence;_and_incomplete_H4K13_RS00020_pseudogene_partial_sequence.fa to write: File name too long
#
#	echo NC_010064.1_Escherichia_coli_isolate_BL26A_plasmid_pLMO226_IS6-like_element_IS26_family_transposase_H4K13_RS00005_gene_partial_cds_trimethoprim-resistant_dihydrofolate_reductase_DfrA8_dfrA8_gene_complete_cds_frameshifted_H4K13_RS00015_pseudogene_complete_sequence_and_incomplete_H4K13_RS00020_pseudogene_partial_sequence.fa | wc
#      1       1     324

#	Trimming sequence name lines to 250. the addition of .faa.gz may cross the line. Using 245


#	zcat *.protein.faa.gz  | sed -e '/^>/s/[],:\(\)\/'' []/_/g' -r -e '/^>/s/_{2,}/_/g' | gzip > fungi.protein.cleaned.faa.gz



