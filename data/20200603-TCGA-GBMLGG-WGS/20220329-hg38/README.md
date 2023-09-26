
#	20200603-TCGA-GBMLGG-WGS/20220329-hg38


```
./array_wrapper.bash
```

Not processing samples with multiple subsamples.

CS-6186-01A, CS-6186-10A, DU-5872-01A, DU-5872-10A






Looking for featureCounts of ...

1: Actin, beta	                   ACTB   ENSG00000075624   Chromosome 7: 5,526,409-5,563,902 reverse strand
2: Beta2-microglobulin    β2M     ENSG00000166710   Chromosome 15: 44,711,487-44,718,851 forward strand
3: Albumin                         ALB      ENSG00000163631   Chromosome 4: 73,397,114-73,421,482 forward strand

to use for normalization



```
grep 'gene_id "ACTB"' /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf > subset.gtf
grep 'gene_id "ALB"' /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf >> subset.gtf
grep 'gene_id "B2M"' /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf >> subset.gtf


```



```
date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="fc" --output="${PWD}/featureCount.${date}.out" --time=4320 --nodes=1 --ntasks=16 --mem=120G ~/.local/bin/featureCounts.bash -a ${PWD}/subset.gtf -t transcript -g gene_name -T 16 -o ${PWD}/featureCounts.ncbiRefSeq.transcript.csv ${PWD}/out/[01234CDEF]*bam

date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="fc" --output="${PWD}/featureCount.${date}.out" --time=4320 --nodes=1 --ntasks=64 --mem=490G ~/.local/bin/featureCounts.bash -a ${PWD}/subset.gtf -t transcript -g gene_name -T 64 -o ${PWD}/featureCounts.ncbiRefSeq.transcript.csv ${PWD}/out/*bam

```





```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20200603-TCGA-GBMLGG-WGS"
curl -netrc -X MKCOL "${BOX}/"
BOX="https://dav.box.com/dav/Francis _Lab_Share/20200603-TCGA-GBMLGG-WGS/20220329-hg38"
curl -netrc -X MKCOL "${BOX}/"

curl -netrc -T featureCounts.ncbiRefSeq.transcript.csv "${BOX}/"
```

```
date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="fc-t" --output="${PWD}/featureCount.${date}.out" --time=4320 --nodes=1 --ntasks=64 --mem=490G ~/.local/bin/featureCounts.bash -a ${PWD}/subset.gtf -t transcript -g gene_name -T 64 -o ${PWD}/featureCounts.ncbiRefSeq.subset.transcript.csv ${PWD}/out/*bam

date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="fc-x" --output="${PWD}/featureCount.${date}.out" --time=4320 --nodes=1 --ntasks=64 --mem=490G ~/.local/bin/featureCounts.bash -a ${PWD}/subset.gtf -t exon -g gene_name -T 64 -o ${PWD}/featureCounts.ncbiRefSeq.subset.exon.csv ${PWD}/out/*bam
```




##	20230925

Needed space so freed up 20TB

```
/bin/rm -rf out/*bam
```


