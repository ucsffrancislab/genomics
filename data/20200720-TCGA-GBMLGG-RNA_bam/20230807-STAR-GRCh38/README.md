
#	20200720-TCGA-GBMLGG-RNA_bam/20230807-STAR-GRCh38



```
ll ${PWD}/../20200803-bamtofastq/out/*_R1.fastq.gz | wc -l
895
```



```
STAR_array_wrapper.bash --threads 8 \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome \
  --out ${PWD}/out \
  ${PWD}/../20230807-cutadapt/out/*_R1.fastq.gz

```



```
grep "not enough mem" logs/STAR_array_wrapper.bash.20230808115853017624055-1500227_*
logs/STAR_array_wrapper.bash.20230808115853017624055-1500227_217.out.log:EXITING because of fatal ERROR: not enough memory for BAM sorting: 
logs/STAR_array_wrapper.bash.20230808115853017624055-1500227_219.out.log:EXITING because of fatal ERROR: not enough memory for BAM sorting: 
logs/STAR_array_wrapper.bash.20230808115853017624055-1500227_246.out.log:EXITING because of fatal ERROR: not enough memory for BAM sorting: 
logs/STAR_array_wrapper.bash.20230808115853017624055-1500227_260.out.log:EXITING because of fatal ERROR: not enough memory for BAM sorting: 
logs/STAR_array_wrapper.bash.20230808115853017624055-1500227_328.out.log:EXITING because of fatal ERROR: not enough memory for BAM sorting: 
logs/STAR_array_wrapper.bash.20230808115853017624055-1500227_86.out.log:EXITING because of fatal ERROR: not enough memory for BAM sorting: 

```





```

./report.bash > report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '2d' report.md > report.csv

```




