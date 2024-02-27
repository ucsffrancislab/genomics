
#	20220610-EV/20230814-preprocess

86 samples


Preprocessing the same as 20230726-Illumina-CystEV/20230809-preprocess




```

EV_preprocessing_array_wrapper.bash --threads 8 --out ${PWD}/out --extension _R1.fastq.gz \
  /francislab/data1/raw/20220610-EV/fastq/*R1.fastq.gz


```




```
./report.bash > report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '2d' report.md > report.csv

```




