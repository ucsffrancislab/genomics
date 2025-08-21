
#	20210302-AGS-illumina

https://pmc.ncbi.nlm.nih.gov/articles/PMC9247888/


The second dataset (AGS-i370) included 659 cases and 586 controls from the UCSF Adult Glioma study genotyped on the Illumina HumanHap370duo panel.

Within the I370 dataset, the non-AGS prefix controls are these illumina “icontrols” meaning they were provided by illumina, I never used these in any study, per Margaret’s advice.


FAM file format
1 Family ID ('FID')
2 Within-family ID ('IID'; cannot be '0')
3 Within-family ID of father ('0' if father isn't in dataset)
4 Within-family ID of mother ('0' if mother isn't in dataset)
5 Sex code ('1' = male, '2' = female, '0' = unknown)
6 Phenotype value ('1' = control, '2' = case, '-9'/'0'/non-numeric = missing data if case/control)


```

cut -d' ' -f2,5,6 AGS_illumina_for_QC.fam | awk '(/AGS/){s="AGS"}(!/AGS/){s="not"}{print s,$2,$3}' | sort | uniq -c
    314 AGS 1 1
    437 AGS 1 2
    285 AGS 2 1
    232 AGS 2 2
   1254 not 1 1
   2097 not 2 1

```



A text file with no header line, and one line per variant with the following six fields:

Chromosome code (either an integer, or 'X'/'Y'/'XY'/'MT'; '0' indicates unknown) or name
Variant identifier
Position in morgans or centimorgans (safe to use dummy value of '0')
Base-pair coordinate (1-based; limited to 231-2)
Allele 1 (corresponding to clear bits in .bed; usually minor)
Allele 2 (corresponding to set bits in .bed; usually major)

In genetics, the major allele is the most common allele at a specific genetic location (locus) within a population, while the minor allele is the less common allele at that same location. The minor allele frequency (MAF) is the frequency at which the minor allele occurs. 

Neither is necesarily the reference allele, but Allele 2 is apparently the most common in the given dataset



Assuming hg19 or hg38 as no data available for hg18

```BASH
awk 'BEGIN{OFS=":"}{print $1,$4,$2}' AGS_illumina_for_QC.bim | sort > rsids
awk 'BEGIN{OFS=":"}{print $1,1+$4,$2}' AGS_illumina_for_QC.bim | sort > plusonersids


join plusonersids /francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh37p13/VCF/common_rsids > hg19_common_plusonersids
join plusonersids /francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh37p13/VCF/All_rsids > hg19_All_plusonersids
join plusonersids /francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/common_rsids > hg38_common_plusonersids
join plusonersids /francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/All_rsids > hg38_All_plusonersids

join rsids /francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh37p13/VCF/common_rsids > hg19_common_rsids
join rsids /francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh37p13/VCF/All_rsids > hg19_All_rsids
join rsids /francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/common_rsids > hg38_common_rsids
join rsids /francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/All_rsids > hg38_All_rsids

wc -l *rsids

  293664 hg19_All_plusonersids
       0 hg19_All_rsids
  292902 hg19_common_plusonersids
       0 hg19_common_rsids
    3092 hg38_All_plusonersids
     172 hg38_All_rsids
    3063 hg38_common_plusonersids
     172 hg38_common_rsids
  293698 plusonersids
  293698 rsids
 1180461 total
```


the rsids say that this is hg19 MINUS one. Not entirely sure how or why this happens


##	20250821

Incrementing position by 1 in bim file.

```
mv AGS_illumina_for_QC.bim AGS_illumina_for_QC.bim.original
awk 'BEGIN{FS=OFS="\t"}{$4=$4+1;print}' AGS_illumina_for_QC.bim.original > AGS_illumina_for_QC.bim
chmod -w AGS_illumina_for_QC.bim
```

