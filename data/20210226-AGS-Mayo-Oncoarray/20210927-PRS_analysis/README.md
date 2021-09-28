

```
./process.bash
```


Failed

```
18_lymph
21_baso
21_NLR

```


```
grep Error  out/*.out 

out/chr18_lymph.out:Error: No valid variants in --score file.
out/chr21_baso.out:Error: No valid variants in --score file.
out/chr21_NLR.out:Error: No valid variants in --score file.
```



```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210226-AGS-Mayo-Oncoarray"
curl -netrc -X MKCOL "${BOX}/"

curl -netrc -T ../20210927-PRS_analysis.tar.gz "${BOX}/"
```



