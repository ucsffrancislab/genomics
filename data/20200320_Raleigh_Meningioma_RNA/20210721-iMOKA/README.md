

Raw data are 51bp



```
mkdir -p raw
for f in /francislab/data1/raw/20200320_Raleigh_Meningioma_RNA/fastq/*fastq.gz ; do
echo $f
base=$( basename $f .fastq.gz )
ln -s $f raw/${base}.fastq.gz
done
```






```
awk -v dir=$PWD/raw/ 'BEGIN{FS=OFS="\t"}(NR>1){print $1,$2,dir$1".fastq.gz"}' /francislab/data1/raw/20200320_Raleigh_Meningioma_RNA/immune_purity.sorted.csv > source.tsv
```

027 exists in the csv file, but no file.
084 files exists, but not in the csv.

Remove 027, but can't add 084 as don't have the metadata



```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20200320_Raleigh_Meningioma_RNA"
curl -netrc -X MKCOL "${BOX}/"
BOX="https://dav.box.com/dav/Francis _Lab_Share/20200320_Raleigh_Meningioma_RNA/20210721-iMOKA"
curl -netrc -X MKCOL "${BOX}/"

for i in 31 51 ; do
s=${i}
BOX="https://dav.box.com/dav/Francis _Lab_Share/20200320_Raleigh_Meningioma_RNA/20210721-iMOKA/${s}"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T ${s}/aggregated.json "${BOX}/"
curl -netrc -T ${s}/output.json "${BOX}/"
done
```



