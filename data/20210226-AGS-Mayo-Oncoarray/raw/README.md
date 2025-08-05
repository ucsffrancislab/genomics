
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


