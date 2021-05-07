


```BASH
./preprocess.bash


./postpreprocess.bash

ll S*.{bbduk,cutadapt}?.fastq.gz
```



```BASH
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210428-preprocessing"
curl -netrc -X MKCOL "${BOX}/"
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210428-preprocessing/fastqc"
curl -netrc -X MKCOL "${BOX}/"

for f in output/*fastqc* ;do echo $f; curl -netrc -T $f "${BOX}/" ; done
```

