
#	20201006-GTEx/20230818-STAR-GRCh38

1438 samples




```
STAR_array_wrapper.bash --threads 8 \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome \
  --out ${PWD}/out \
  ${PWD}/../20230817-cutadapt/out/*_R1.fastq.gz

```

```
[gwendt@c4-log2 /francislab/data1/working/20201006-GTEx/20230818-STAR-GRCh38]$ grep "not enough mem" logs/STAR_array_wrapper.bash.*
logs/STAR_array_wrapper.bash.20230818083522151232543-1534873_288.out.log:EXITING because of fatal ERROR: not enough memory for BAM sorting: 
logs/STAR_array_wrapper.bash.20230818083522151232543-1534873_723.out.log:EXITING because of fatal ERROR: not enough memory for BAM sorting: 
logs/STAR_array_wrapper.bash.20230818083522151232543-1534873_761.out.log:EXITING because of fatal ERROR: not enough memory for BAM sorting: 
logs/STAR_array_wrapper.bash.20230818200940153632024-1537485_1049.out.log:EXITING because of fatal ERROR: not enough memory for BAM sorting: 
logs/STAR_array_wrapper.bash.20230818200940153632024-1537485_1050.out.log:EXITING because of fatal ERROR: not enough memory for BAM sorting: 
logs/STAR_array_wrapper.bash.20230818200940153632024-1537485_1051.out.log:EXITING because of fatal ERROR: not enough memory for BAM sorting: 
logs/STAR_array_wrapper.bash.20230818200940153632024-1537485_1052.out.log:EXITING because of fatal ERROR: not enough memory for BAM sorting: 
logs/STAR_array_wrapper.bash.20230818200940153632024-1537485_1053.out.log:EXITING because of fatal ERROR: not enough memory for BAM sorting: 
logs/STAR_array_wrapper.bash.20230818200940153632024-1537485_1054.out.log:EXITING because of fatal ERROR: not enough memory for BAM sorting: 

```


```
STAR_array_wrapper.bash --array=288,723,761,1049,1050,1051,1052,1053,1054 --threads 16 \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome \
  --out ${PWD}/out \
  ${PWD}/../20230817-cutadapt/out/*_R1.fastq.gz

```


```

./report.bash > report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '2d' report.md > report.csv
cat report.csv | datamash transpose -t, > report.t.csv

```

