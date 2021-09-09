


Align to hg38

```
./align.bash
```


Compile feature count matrices

```
for j in 5 6 ; do
for g in LTR Retroposon ; do
for t in bbduk cutadapt ; do
for i in 1 2 3 ; do
featureCounts -a /francislab/data1/refs/sources/igv.org.genomes/hg38/rmsk/hg38_rmsk_${g}.gtf -t feature -g feature_name -o feature_counts.${j}.${t}${i}.${g}.tsv output/SFHH00${j}*.${t}${i}.bam
done ; done ; done ; done
```

Remove path and extensions from tsv headers

```
for j in 5 6 ; do
for g in LTR Retroposon ; do
for t in bbduk cutadapt ; do
for i in 1 2 3 ; do
sed -i -e "1,2s'output/''g" -e "1,2s'.${t}${i}.bam''g" feature_counts.${j}.${t}${i}.${g}.tsv 
sed -i -e "1,2s'output/''g" -e "1,2s'.${t}${i}.bam''g" feature_counts.${j}.${t}${i}.${g}.tsv.summary 
done ; done ; done ; done
```


```
rename tsv.summary summary.tsv *summary
```



