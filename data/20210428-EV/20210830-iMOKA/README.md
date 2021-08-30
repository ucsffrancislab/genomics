
```
for s in /francislab/data1/working/20210428-EV/20210830-filter/output/SFHH005z.*.fastq.gz ; do 
s=$( basename $s .fastq.gz )
s=${s#SFHH005z.}
dir=${s%.filtered}
mkdir -p ${dir}
for f in /francislab/data1/working/20210428-EV/20210830-filter/output/SFHH005*.${s}.fastq.gz ; do
echo $f
base=$( basename $f .${s}.fastq.gz )
ln -s $f ${dir}/${base}.fastq.gz
done
awk -F, -v dir=${dir} '($1~/_11$/){print "rm -f "dir"/"$2".fastq.gz"}' /francislab/data1/raw/20210428-EV/metadata.csv
awk -v dir=${dir} 'BEGIN{FPAT = "([^,]+)|(\"[^\"]+\")";OFS="\t"}{group=""}( (NR==1) || ($4~/blank/) || ($4~/control/) ){next}($4~/Astro/){group="Astro"}($4~/Oligo/){group="Oligo"}($4~/GBM, IDH-mutant/){group="GBMmut"}($4~/GBM, IDH1R132H WT/){group="GBMWT"}{print $2,group,"/francislab/data1/working/20210428-EV/20210830-iMOKA/"dir"/"$2".fastq.gz"}' /francislab/data1/raw/20210428-EV/metadata.csv > ${dir}.source.tsv
done
```


```
rm -f */SFHH005k.fastq.gz
rm -f */SFHH005v.fastq.gz
rm -f */SFHH005ag.fastq.gz
rm -f */SFHH005ar.fastq.gz
```


```
cat cutadapt2.source.tsv  | awk 'BEGIN{FS=OFS="\t"}($2!="Oligo"){$2="nonOligo"}{print}' > cutadapt2.source.Oligo.tsv
cat cutadapt2.source.tsv  | awk 'BEGIN{FS=OFS="\t"}($2!="Astro"){$2="nonAstro"}{print}' > cutadapt2.source.Astro.tsv
cat cutadapt2.source.tsv  | awk 'BEGIN{FS=OFS="\t"}($2!="GBMmut"){$2="nonGBMmut"}{print}' > cutadapt2.source.GBMmut.tsv
cat cutadapt2.source.tsv  | awk 'BEGIN{FS=OFS="\t"}($2!="GBMWT"){$2="nonGBMWT"}{print}' > cutadapt2.source.GBMWT.tsv
```



```
./iMOKA.bash
```



```
s=31.cutadapt2
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210706-iMoka/${s}"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T ${s}/aggregated.json "${BOX}/"
curl -netrc -T ${s}/output.json "${BOX}/"

s=31.cutadapt2.lte30
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210706-iMoka/${s}"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T ${s}/aggregated.json "${BOX}/"
curl -netrc -T ${s}/output.json "${BOX}/"

s=25.cutadapt2.lte30
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210706-iMoka/${s}"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T ${s}/aggregated.json "${BOX}/"
curl -netrc -T ${s}/output.json "${BOX}/"

s=31.cutadapt2.IDH
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210706-iMoka/${s}"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T ${s}/aggregated.json "${BOX}/"
curl -netrc -T ${s}/output.json "${BOX}/"
```



```
for s in /francislab/data1/working/20210428-EV/20210518-preprocessing/output/SFHH005z.*.fastq.gz ; do 
s=$( basename $s .fastq.gz )
s=${s#SFHH005z.}
dir=raw.${s}
awk -v dir=${dir} 'BEGIN{FPAT = "([^,]+)|(\"[^\"]+\")";OFS="\t"}{group=""}( (NR==1) || ($4~/blank/) || ($4~/control/) ){next}($4~/IDH-mutant/){group="IDHmut"}($4~/IDH1R132H WT/){group="IDHWT"}{print $2,group,"/francislab/data1/working/20210428-EV/20210706-iMoka/"dir"/"$2".fastq.gz"}' /francislab/data1/raw/20210428-EV/metadata.csv > ${dir}.source.IDH.tsv
done
```

```
for i in 16 17 19 21 23 25 ; do
s=${i}.cutadapt2.lte30
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210706-iMoka/${s}"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T ${s}/aggregated.json "${BOX}/"
curl -netrc -T ${s}/output.json "${BOX}/"
done

for i in 21 27 29 ; do
s=${i}.cutadapt2.IDH
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210706-iMoka/${s}"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T ${s}/aggregated.json "${BOX}/"
curl -netrc -T ${s}/output.json "${BOX}/"
done
```






```

./iMOKA.bash

for i in 25 30 35 ; do
for x in Astro Oligo GBMWT GBMmut ; do
s=${i}.cutadapt2.${x}
echo $s
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210706-iMoka/${s}"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T ${s}/aggregated.json "${BOX}/"
curl -netrc -T ${s}/output.json "${BOX}/"
done ; done

for i in 45 50 55 60 65 70 75 ; do
s=${i}.cutadapt2
echo $s
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210706-iMoka/${s}"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T ${s}/aggregated.json "${BOX}/"
curl -netrc -T ${s}/output.json "${BOX}/"
done
```

#	20210816

```
dir="cutadapt2.lex"
mkdir -p ${dir}
for f in /francislab/data1/working/20210428-EV/20210518-preprocessing/output/SFHH006*.cutadapt2.fastq.gz ; do
echo $f
base=$( basename $f .cutadapt2.fastq.gz )
ln -s $f ${dir}/${base}.fastq.gz
done

rm -f ${dir}/SFHH00?k.fastq.gz
rm -f ${dir}/SFHH00?v.fastq.gz
rm -f ${dir}/SFHH00?ag.fastq.gz
rm -f ${dir}/SFHH00?ar.fastq.gz

./iMOKA.bash
```

```
s=15.cutadapt2.lex
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210706-iMoka/${s}"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T ${s}/aggregated.json "${BOX}/"
curl -netrc -T ${s}/output.json "${BOX}/"
```




##################################################
20210819

Evaluation which k is most predictive in Group/nonGroup comparisons.

Using the model "acc" shown in iMOKA app (not those used in the output_model png file names)



for k  in 15 20 25 30 35 ; do
echo $k
for g in GBMWT GBMmut Oligo Astro ; do
jq -r ".best_feature_models[].models[].acc" ${k}.cutadapt2.${g}/output.json | sort -n | tail -1
done ; done


