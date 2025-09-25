
#	20250925-Illumina-PhIP/20250925b-bowtie2



```
bowtie2_array_wrapper.bash --single --threads 8 --sort --very-sensitive \
  --norc --extension .fastq.gz --outdir ${PWD}/out \
  -x /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_upper_oligo.uniq.1-80 \
  ${PWD}/../20250925a-cutadapt/out/*fastq.gz
```


```
./report.bash > report.csv
cat report.csv | datamash transpose -t, > report.t.csv
box_upload.bash report*csv
```


```
module load r
./tile_counts.Rmd
box_upload.bash tile_counts.html 
```














##	20250925


```BASH
merge_matrices.py -o reports.csv --header_rows 9 --index_col asdf --axis columns /francislab/data1/working/*-Illumina-PhIP/{20250925b,20250822b,20250410}-bowtie2/report.csv

sed -i '1s/asdf/Snumber/' reports.csv 
sed -i '2s/asdf/Subject/' reports.csv 
sed -i '3s/asdf/Sample/' reports.csv 
sed -i '4s/asdf/Type/' reports.csv 
sed -i '5s/asdf/Study/' reports.csv 
sed -i '6s/asdf/Group/' reports.csv 
sed -i '7s/asdf/Age/' reports.csv 
sed -i '8s/asdf/Sex/' reports.csv 
sed -i '9s/asdf/Plate/' reports.csv 
```


```BASH
head -4 reports.csv | tail -n 1 | tr , "\n" | sort | uniq -c
     40 ALL maternal serum
     20 commercial serum control
    632 glioma serum
     48 meningioma serum
     80 PBS blank
    120 pemphigus serum
     20 Phage Library
      1 Type
```


