


```BASH
./preprocess.bash


./postpreprocess.bash
```



```BASH
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210205 20210205-EV_CATS 20210205-preprocessing"
curl -netrc -X MKCOL "${BOX}/"

for f in output/*daa ;do curl -netrc -T $f "${BOX}/" ; done
```

