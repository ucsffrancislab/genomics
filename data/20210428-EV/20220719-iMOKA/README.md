

Build models comparing GBM-WT to Oligo and ignore the rest





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


metadata contains columns with commas so need FPAT

```
awk -v pwd=$PWD 'BEGIN{FPAT = "([^,]+)|(\"[^\"]+\")";OFS="\t"}($4~/Oligo/){print $2,"Oligo",pwd"/raw/"$2".fastq.gz"}($4~/GBM, IDH1R132H WT/){print $2,"GBMWT",pwd"/raw/"$2".fastq.gz"}' /francislab/data1/raw/20210428-EV/metadata.csv > source.tsv
```



Run iMOKA





```
for i in 16 21 31 ; do
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210706-iMoka/${s}"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T ${i}/aggregated.json "${BOX}/"
curl -netrc -T ${i}/output.json "${BOX}/"
done





