
#	20211208-EV/20230815-preprocess


13 samples


```

./EV_preprocessing_array_wrapper.bash --threads 8 --out ${PWD}/out --extension _R1.fastq.gz \
  /francislab/data1/raw/20211208-EV/fastq/*R1.fastq.gz

```


Roughly 3-5 hours each




```
./report.bash > report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '2d' report.md > report.csv
box_upload.bash report.csv
```


