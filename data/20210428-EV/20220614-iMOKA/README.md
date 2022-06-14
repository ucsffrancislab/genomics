


```
mkdir -p raw
for f in /francislab/data1/working/20210428-EV/20210518-preprocessing/output/SFHH005*.cutadapt2.fastq.gz ; do
echo $f
base=$( basename $f .cutadapt2.fastq.gz )
ln -s $f raw/${base}.fastq.gz
done
```




Remove control data

```
awk -F, '($1~/_11$/){print "rm -f raw/"$2".fastq.gz"}' /francislab/data1/raw/20210428-EV/metadata.csv

rm -f raw/SFHH005k.fastq.gz
rm -f raw/SFHH005v.fastq.gz
rm -f raw/SFHH005ag.fastq.gz
rm -f raw/SFHH005ar.fastq.gz
```





```
awk 'BEGIN{FPAT = "([^,]+)|(\"[^\"]+\")";OFS="\t"}{group=""}( (NR==1) || ($4~/blank/) || ($4~/control/) ){next}($4~/Astro/){group="Astro"}($4~/Oligo/){group="Oligo"}($4~/GBM, IDH-mutant/){group="GBMmut"}($4~/GBM, IDH1R132H WT/){group="GBMWT"}{print $2,group,"/francislab/data1/working/20210428-EV/20220614-iMOKA/raw/"$2".fastq.gz"}' /francislab/data1/raw/20210428-EV/metadata.csv > source.tsv
```

```
cat source.tsv | awk 'BEGIN{FS=OFS="\t"}($2!="GBMWT"){$2="nonGBMWT"}{print}' > source.GBMWT.tsv
```






