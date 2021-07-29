


```
mkdir -p raw
for f in /francislab/data1/raw/20200407_Schizophrenia/fastq/SD*fastq.gz ; do
echo $f
base=$( basename $f .fastq.gz )
ln -s $f raw/${base}.fastq.gz
done
```

```
awk -F, -v dir=/francislab/data1/working/20200407_Schizophrenia/20210721-iMOKA/raw/ 'BEGIN{OFS="\t"}{print $1,$2,dir$1"_R1.fastq.gz;"dir$1"_R2.fastq.gz"}' /francislab/data1/raw/20200407_Schizophrenia/metadata.csv > source.tsv
```


```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20200407_Schizophrenia"
curl -netrc -X MKCOL "${BOX}/"
BOX="https://dav.box.com/dav/Francis _Lab_Share/20200407_Schizophrenia/20210721-iMOKA"
curl -netrc -X MKCOL "${BOX}/"

for i in 81 ; do
s=${i}
BOX="https://dav.box.com/dav/Francis _Lab_Share/20200407_Schizophrenia/20210721-iMOKA/${s}"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T ${s}/aggregated.json "${BOX}/"
curl -netrc -T ${s}/output.json "${BOX}/"
done
```



