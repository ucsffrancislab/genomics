


```
/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/subject/??-????_R?.fastq.gz


tail -q -n +2 /francislab/data1/working/20210428-EV/20210706-iMoka/25.cutadapt2.{GBMmut,GBMWT,Oligo,Astro}/output_fi.tsv | awk '{print $1}' | sort > kmers.fw.txt
tail -q -n +2 /francislab/data1/working/20210428-EV/20210706-iMoka/25.cutadapt2.{GBMmut,GBMWT,Oligo,Astro}/output_fi.tsv | awk '{print $1}' | sort | rev | tr "ACTG" "TGAC" > kmers.rc.txt

sort kmers.??.txt > kmers.all.txt


./count_kmers.bash

./aggregate.bash
```


```
cp /francislab/data1/working/20210428-EV/20210706-iMoka/25.cutadapt2.GBMmut/output_fi.tsv GBMmut_output_fi.tsv
cp /francislab/data1/working/20210428-EV/20210706-iMoka/25.cutadapt2.GBMWT/output_fi.tsv  GBMWT_output_fi.tsv
cp /francislab/data1/working/20210428-EV/20210706-iMoka/25.cutadapt2.Oligo/output_fi.tsv  Oligo_output_fi.tsv
cp /francislab/data1/working/20210428-EV/20210706-iMoka/25.cutadapt2.Astro/output_fi.tsv  Astro_output_fi.tsv
```




```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20200720-TCGA-GBMLGG-RNA_bam/20210819-kmers_from_EV_comparison"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T kmers.fw.txt "${BOX}/"
curl -netrc -T kmers.rc.txt "${BOX}/"
curl -netrc -T raw_counts.csv "${BOX}/"
curl -netrc -T normal_counts.csv "${BOX}/"
curl -netrc -T metadata.cart.TCGA.GBM-LGG.WGS.bam.2020-07-17.csv "${BOX}/"
curl -netrc -T TCGA.Glioma.metadata.tsv "${BOX}/"
curl -netrc -T GBMmut_output_fi.tsv "${BOX}/"
curl -netrc -T GBMWT_output_fi.tsv "${BOX}/"
curl -netrc -T Oligo_output_fi.tsv "${BOX}/"
curl -netrc -T Astro_output_fi.tsv "${BOX}/"
curl -netrc -T subject_raw_counts.csv "${BOX}/"
curl -netrc -T subject_normal_counts.csv "${BOX}/"
```
