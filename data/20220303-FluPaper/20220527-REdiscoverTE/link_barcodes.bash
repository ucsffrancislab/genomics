#!/usr/bin/env bash


#/francislab/data2/working/20220303-FluPaper/20220421-SingleCell/out/B1-c1/outs/possorted_genome_bam.bam_barcodes/

IN="/francislab/data2/working/20220303-FluPaper/20220421-SingleCell/out/"


awk -F, -v i=${IN} '(NR>1 && $2 == "B1_c1"){
split($1,a,"_")
file=i""a[1]"-"a[2]"/outs/possorted_genome_bam.bam_barcodes/"a[3]"-1.fa.gz"
print file
}' mergedAllCells_withCellTypeIdents_CLEAN.filtered.csv

#	Because I've pre-filtered the authors list with ours, we know the barcode files exist.

