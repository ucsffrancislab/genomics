
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



Run on the 4 groups.

```
for k in 15 20 25 30 ; do
./iMOKA.bash -k ${k}
done
```

Then link the preprocessing dir. No sense running it again, although it doesn't take to terribly long.

```
for k in 15 20 25 30 ; do
for f in Astro GBMmut GBMWT Oligo ; do
mkdir cutadapt2.${k}.${f}
ln -s ../cutadapt2.${k}/preprocess cutadapt2.${k}.${f}/preprocess
done ; done
```





WAIT UNTIL ALL RUNS ARE COMPLETE OR THE create_matrix.tsv files will be incomplete.


And create meta files

```
for k in 15 20 25 30 ; do
for f in Astro GBMmut GBMWT Oligo ; do
cat cutadapt2.${k}/create_matrix.tsv  | awk 'BEGIN{FS=OFS="\t"}($3!="'${f}'"){$3="non'${f}'"}{print}' > cutadapt2.${k}.${f}/create_matrix.tsv
done ; done
```


Run each group vs nongroup

```
for k in 15 20 25 30 ; do
for f in Astro GBMmut GBMWT Oligo ; do
./iMOKA.bash -k ${k} -f ".${f}"
done ; done
```


```
for k in 15 20 25 30 ; do
for f in Astro GBMmut GBMWT Oligo ; do
echo "${k} - ${f}"
jq -r ".best_feature_models[].models[].acc" cutadapt2.${k}.${f}/output.json 2> /dev/null | sort -n | tail -1
done ; done
```



```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210830-iMOKA"
curl -netrc -X MKCOL "${BOX}/"
for i in 15 20 25 30 ; do
for f in Astro Oligo GBMWT GBMmut ; do
d=cutadapt2.${i}.${f}
echo $d
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210830-iMOKA/${d}"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T ${d}/aggregated.json "${BOX}/"
curl -netrc -T ${d}/output.json "${BOX}/"
done ; done
```

```
for x in Astro Oligo GBMWT GBMmut ; do
mkdir cutadapt2.25.${x}/
scp c4:/francislab/data1/working/20210428-EV/20210830-iMOKA/cutadapt2.25.${x}/aggregated.json cutadapt2.25.${x}/
scp c4:/francislab/data1/working/20210428-EV/20210830-iMOKA/cutadapt2.25.${x}/output.json cutadapt2.25.${x}/
done
```



cat cutadapt2.25/aggregated.json  | jq -r '.sequences[].sequence' | sort | uniq -d



```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210830-iMOKA-shift4"
curl -netrc -X MKCOL "${BOX}/"
for i in 15 20 25 30 ; do
for f in Astro Oligo GBMWT GBMmut ; do
d=cutadapt2.${i}.${f}
echo $d
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210830-iMOKA-shift4/${d}"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T ${d}/aggregated.json "${BOX}/"
curl -netrc -T ${d}/output.json "${BOX}/"
done ; done
```

```
for k in 15 20 25 30 ; do
for f in Astro GBMmut GBMWT Oligo ; do
echo "${k} - ${f}"
jq -r ".best_feature_models[].models[].acc" shift-4/cutadapt2.${k}.${f}/output.json 2> /dev/null | sort -n | tail -1
done ; done
```

