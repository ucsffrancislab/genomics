#!/usr/bin/env bash

OUT=/francislab/data2/working/20220303-FluPaper/20220421-SingleCell/merged/
mkdir -p ${OUT}

while read barcode batchID celltype sample condition ancestry ; do

#,orig.ident,nCount_RNA,nFeature_RNA,batchID,percent.mt,SOC_status,SOC_indiv_ID,SOC_infection_status,SOC_genetic_ancestry,CEU,YRI,nCount_SCT,nFeature_SCT,integrated_snn_res.0.5,cluster_IDs,celltype,sample_condition

echo ${barcode} ${batchID} ${celltype} ${sample} ${condition} ${ancestry}

barcode=${barcode##*_}
batchID=${batchID/_/-}
file=/francislab/data2/working/20220303-FluPaper/20220421-SingleCell/out/${batchID}/outs/possorted_genome_bam.bam_barcodes/${barcode}-1.fa.gz	

zcat ${file} >> ${OUT}/${sample}-${condition}-${celltype}-${ancestry}.fa

done < <( tail -n +2 mergedAllCells_withCellTypeIdents_CLEAN.filtered.csv | awk 'BEGIN{FS=",";OFS="\t"}{print $1,$2,$17,$8,$9,$10}' )


#	comma as a delimiter wasn't working well
#done < <( tail -n +2 mergedAllCells_withCellTypeIdents_CLEAN.filtered.csv | head | cut -d, -f1,2,17,18 )

