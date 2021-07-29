
Raw data is 101bp


```
mkdir -p raw
for f in /francislab/data1/raw/20200529_Raleigh_WES/fastq/*fastq.gz ; do
echo $f
base=$( basename $f .fastq.gz )
ln -s $f raw/${base}.fastq.gz
done
```

```
awk -v dir=${PWD}/raw/ 'BEGIN{FS=",";OFS="\t"}(NR>1){print $1,$2,dir$1"_R1.fastq.gz;"dir$1"_R2.fastq.gz"}' /francislab/data1/raw/20200529_Raleigh_WES/WES_samples_classified.csv > source.tumor_type.tsv

awk -v dir=${PWD}/raw/ 'BEGIN{FS=",";OFS="\t"}(NR>1){sub(/T/,"N",$1);print $1,$2,dir$1"_R1.fastq.gz;"dir$1"_R2.fastq.gz"}' /francislab/data1/raw/20200529_Raleigh_WES/WES_samples_classified.csv > source.normal_tumor_type.tsv

```

Removed the "Benign" entry as aggregate failed.
The reduced matrix only has 1 line. Likely due to Benign having only 1 entry.

Step 0 : Reading /francislab/data1/working/20200529_Raleigh_WES/20210721-iMOKA/31.tumor_type/reduced.matrix...
	Total lines: 2
/var/spool/slurm/d/job204296/slurm_script: line 4: 217669 Segmentation fault      singularity exec /francislab/data2/refs/singularity/iMOKA_extended-1.1.3.img iMOKA_core aggregate --input /francislab/data1/working/20200529_Raleigh_WES/20210721-iMOKA/31.tumor_type/reduced.matrix --count-matrix /francislab/data1/working/20200529_Raleigh_WES/20210721-iMOKA/31.tumor_type/matrix.json --mapper-config /francislab/data1/working/20200529_Raleigh_WES/20210721-iMOKA/31.tumor_type/config.json --output /francislab/data1/working/20200529_Raleigh_WES/20210721-iMOKA/31.tumor_type/aggregated



```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20200529_Raleigh_WES"
curl -netrc -X MKCOL "${BOX}/"
BOX="https://dav.box.com/dav/Francis _Lab_Share/20200529_Raleigh_WES/20210721-iMOKA"
curl -netrc -X MKCOL "${BOX}/"

for i in 31 51 ; do
s=${i}.tumor_type
BOX="https://dav.box.com/dav/Francis _Lab_Share/20200529_Raleigh_WES/20210721-iMOKA/${s}"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T ${s}/aggregated.json "${BOX}/"
curl -netrc -T ${s}/output.json "${BOX}/"
done
```



