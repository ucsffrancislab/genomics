

```BASH
./preprocess.bash


./postpreprocess.bash

```


---

```BASH
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210518-preprocessing"
curl -netrc -X MKCOL "${BOX}/"
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210518-preprocessing/fastqc"
curl -netrc -X MKCOL "${BOX}/"

for f in output/*fastqc* ;do echo $f; curl -netrc -T $f "${BOX}/" ; done
```

