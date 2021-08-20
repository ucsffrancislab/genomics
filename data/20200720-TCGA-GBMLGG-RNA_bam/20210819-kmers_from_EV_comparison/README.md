


```
/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/subject/??-????_R?.fastq.gz


tail -q -n +2 /francislab/data1/working/20210428-EV/20210706-iMoka/25.cutadapt2.{GBMmut,GBMWT,Oligo,Astro}/output_fi.tsv | awk '{print $1}' | sort > kmers.fw.txt
tail -q -n +2 /francislab/data1/working/20210428-EV/20210706-iMoka/25.cutadapt2.{GBMmut,GBMWT,Oligo,Astro}/output_fi.tsv | awk '{print $1}' | sort | rev | tr "ACTG" "TGAC" > kmers.rc.txt

sort kmers.??.txt > kmers.all.txt


./count_kmers.bash

./aggregate.bash
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
```

