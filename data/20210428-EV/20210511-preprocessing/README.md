


```BASH
./preprocess.bash


./postpreprocess.bash

ll S*.{bbduk,cutadapt}?.fastq.gz



./report.head.bash > report.head.md &
#nohup ./report.gene.bash > report.gene.md &
#nohup ./report.mirna.bash > report.mirna.md &
#nohup ./report.mrna.bash > report.mrna.md &
#nohup ./report.rmsk.bash > report.rmsk.md &
#nohup ./report.diamond.bash > report.diamond.md &

cat report.head.md report.mrna.md report.gene.md report.mirna.md report.diamond.md report.rmsk.md > report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' report.md | gzip > report.csv.gz


```



```BASH
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210428-preprocessing"
curl -netrc -X MKCOL "${BOX}/"
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210428-preprocessing/fastqc"
curl -netrc -X MKCOL "${BOX}/"

for f in output/*fastqc* ;do echo $f; curl -netrc -T $f "${BOX}/" ; done
```

