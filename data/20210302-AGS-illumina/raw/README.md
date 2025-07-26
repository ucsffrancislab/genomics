
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



