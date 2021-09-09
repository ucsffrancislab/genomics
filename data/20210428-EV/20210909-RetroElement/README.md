


```
/francislab/data1/refs/sources/igv.org.genomes/hg38/rmsk/hg38_rmsk_LTR.gtf
/francislab/data1/refs/sources/igv.org.genomes/hg38/rmsk/hg38_rmsk_Retroposon.gtf
```


```
./align.bash
```


```


for j in 5 6 ; do
for g in LTR Retroposon ; do
for t in bbduk cutadapt ; do
for i in 1 2 3 ; do
featureCounts -a /francislab/data1/refs/sources/igv.org.genomes/hg38/rmsk/hg38_rmsk_${g}.gtf -t feature -g feature_name -o feature_counts.${j}.${t}${i}.${g}.tsv output/SFHH00${j}*.${t}${i}.bam
done ; done ; done ; done


```
