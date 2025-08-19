
#	20210226-AGS-Mayo-Oncoarray

https://pmc.ncbi.nlm.nih.gov/articles/PMC9247888/

The first set included 1,973 cases from the Mayo Clinic and University of California San Francisco (UCSF) Adult Glioma Study and 1,859 controls from the Glioma International Case-Control Study (GICC) who were genotyped on the Illumina OncoArray


I'm guessing the published numbers are after filters.



FAM file format
1 Family ID ('FID')
2 Within-family ID ('IID'; cannot be '0')
3 Within-family ID of father ('0' if father isn't in dataset)
4 Within-family ID of mother ('0' if mother isn't in dataset)
5 Sex code ('1' = male, '2' = female, '0' = unknown)
6 Phenotype value ('1' = control, '2' = case, '-9'/'0'/non-numeric = missing data if case/control)


```

cut -d' ' -f2,5,6 AGS_Mayo_Oncoarray_for_QC.fam | awk '(/AGS/){print "AGS"}(!/AGS/){print "num"}' | sort | uniq -c
   1339 AGS
   3026 num

cut -d' ' -f6 AGS_Mayo_Oncoarray_for_QC.fam | sort | uniq -c
   2200 1
   2165 2

cut -d' ' -f5 AGS_Mayo_Oncoarray_for_QC.fam | sort | uniq -c
   2534 1
   1831 2

cut -d' ' -f2,5,6 AGS_Mayo_Oncoarray_for_QC.fam | awk '(/AGS/){print "AGS",$2,$3}(!/AGS/){print "num",$2,$3}' | sort | uniq -c
    170 AGS 1 1
    570 AGS 1 2
    161 AGS 2 1
    438 AGS 2 2
   1119 num 1 1
    675 num 1 2
    750 num 2 1
    482 num 2 2

cut -d' ' -f2,6 AGS_Mayo_Oncoarray_for_QC.fam | awk '(/AGS/){print "AGS",$2}(!/AGS/){print "num",$2}' | sort | uniq -c
    331 AGS 1
   1008 AGS 2
   1869 num 1
   1157 num 2
```


Assuming hg19 or hg38 as no data available for hg18

```BASH
awk 'BEGIN{OFS=":"}{print $1,$4,$2}' AGS_Mayo_Oncoarray_for_QC.bim | sort > rsids
awk 'BEGIN{OFS=":"}{print $1,1+$4,$2}' AGS_Mayo_Oncoarray_for_QC.bim | sort > plusonersids


join plusonersids /francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh37p13/VCF/common_rsids > hg19_common_plusonersids
join plusonersids /francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh37p13/VCF/All_rsids > hg19_All_plusonersids
join plusonersids /francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/common_rsids > hg38_common_plusonersids
join plusonersids /francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/All_rsids > hg38_All_plusonersids

join rsids /francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh37p13/VCF/common_rsids > hg19_common_rsids
join rsids /francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh37p13/VCF/All_rsids > hg19_All_rsids
join rsids /francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/common_rsids > hg38_common_rsids
join rsids /francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/All_rsids > hg38_All_rsids

wc -l *rsids

       0 hg19_All_plusonersids
  300782 hg19_All_rsids
       0 hg19_common_plusonersids
  299991 hg19_common_rsids
    1965 hg38_All_plusonersids
    2835 hg38_All_rsids
    1948 hg38_common_plusonersids
    2816 hg38_common_rsids
  403388 plusonersids
  403388 rsids
 1417113 total

```

Again, the rsids say this is hg19.



