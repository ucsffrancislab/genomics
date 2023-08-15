
#	20201006-GTEx/20230714-STAR

1438 samples




```
STAR_array_wrapper.bash --threads 8 \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome \
  --out ${PWD}/out \
  ${PWD}/../20201116-preprocess/trimmed/SRR821*_R1.fastq.gz

```

```
-r--r----- 1 gwendt francislab  2764934793 Nov 30  2020 ../20201116-preprocess/trimmed/SRR821549_R1.fastq.gz
-r--r----- 1 gwendt francislab  2472851106 Nov 30  2020 ../20201116-preprocess/trimmed/SRR821581_R1.fastq.gz
-r--r----- 1 gwendt francislab  2373272201 Nov 30  2020 ../20201116-preprocess/trimmed/SRR821602_R1.fastq.gz
-r--r----- 1 gwendt francislab  2807338190 Nov 30  2020 ../20201116-preprocess/trimmed/SRR821626_R1.fastq.gz
-r--r----- 1 gwendt francislab  4094042125 Nov 30  2020 ../20201116-preprocess/trimmed/SRR821690_R1.fastq.gz


```


```
STAR_array_wrapper.bash --threads 8 \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome \
  --out ${PWD}/out \
  ${PWD}/../20201116-preprocess/trimmed/{SRR1068855,SRR1069303,SRR1069303,SRR1070382,SRR1070689,SRR1072104,SRR1072529,SRR1073679,SRR1074860,SRR1075530,SRR1086256,SRR1088856,SRR1095503,SRR1317751,SRR1333633,SRR1335422}_R1.fastq.gz

```
NONE of those selected are in our collection?



```
STAR_array_wrapper.bash --threads 8 \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome \
  --out ${PWD}/out \
  ${PWD}/../20201116-preprocess/trimmed/SRR8*_R1.fastq.gz

```

##	20230807

```
STAR_array_wrapper.bash --threads 8 \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome \
  --out ${PWD}/out \
  ${PWD}/../20201116-preprocess/trimmed/SRR[023456789]*_R1.fastq.gz

```







##	20230808

Run on all



```
ll ${PWD}/../20201116-preprocess/trimmed/*_R1.fastq.gz | wc -l
1438
```

Eventually 


```
ll ${PWD}/../20201116-preprocess/trimmed/SRR1*_R1.fastq.gz | wc -l
1048
```

```
STAR_array_wrapper.bash --threads 8 \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome \
  --out ${PWD}/out \
  ${PWD}/../20201116-preprocess/trimmed/SRR1*_R1.fastq.gz

```






```
grep "not enough mem" logs/STAR_array_wrapper.bash.20230808192603192591662-1501075_*.out.log
logs/STAR_array_wrapper.bash.20230808192603192591662-1501075_1014.out.log:EXITING because of fatal ERROR: not enough memory for BAM sorting: 
logs/STAR_array_wrapper.bash.20230808192603192591662-1501075_196.out.log:EXITING because of fatal ERROR: not enough memory for BAM sorting: 
logs/STAR_array_wrapper.bash.20230808192603192591662-1501075_272.out.log:EXITING because of fatal ERROR: not enough memory for BAM sorting: 
logs/STAR_array_wrapper.bash.20230808192603192591662-1501075_288.out.log:EXITING because of fatal ERROR: not enough memory for BAM sorting: 
logs/STAR_array_wrapper.bash.20230808192603192591662-1501075_325.out.log:EXITING because of fatal ERROR: not enough memory for BAM sorting: 
logs/STAR_array_wrapper.bash.20230808192603192591662-1501075_614.out.log:EXITING because of fatal ERROR: not enough memory for BAM sorting: 
logs/STAR_array_wrapper.bash.20230808192603192591662-1501075_678.out.log:EXITING because of fatal ERROR: not enough memory for BAM sorting: 
logs/STAR_array_wrapper.bash.20230808192603192591662-1501075_723.out.log:EXITING because of fatal ERROR: not enough memory for BAM sorting: 
logs/STAR_array_wrapper.bash.20230808192603192591662-1501075_731.out.log:EXITING because of fatal ERROR: not enough memory for BAM sorting: 
logs/STAR_array_wrapper.bash.20230808192603192591662-1501075_750.out.log:EXITING because of fatal ERROR: not enough memory for BAM sorting: 
logs/STAR_array_wrapper.bash.20230808192603192591662-1501075_761.out.log:EXITING because of fatal ERROR: not enough memory for BAM sorting: 
logs/STAR_array_wrapper.bash.20230808192603192591662-1501075_956.out.log:EXITING because of fatal ERROR: not enough memory for BAM sorting: 
logs/STAR_array_wrapper.bash.20230808192603192591662-1501075_98.out.log:EXITING because of fatal ERROR: not enough memory for BAM sorting: 
```




##	20230814




```
STAR_array_wrapper.bash --threads 16 --array 98,196,272,288,325,614,678,723,731,750,761,956,1014 \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome \
  --out ${PWD}/out \
  ${PWD}/../20201116-preprocess/trimmed/SRR1*_R1.fastq.gz

```

```
grep "not enough mem" logs/STAR_array_wrapper.bash.20230814083313804125965-1511707*
```


```
STAR_array_wrapper.bash --threads 32 --array 98,196,272,288,325,614,678,723,731,750,761,1014 \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome \
  --out ${PWD}/out \
  ${PWD}/../20201116-preprocess/trimmed/SRR1*_R1.fastq.gz

```



```
BAMoutput.cpp:27:BAMoutput: exiting because of *OUTPUT FILE* error: could not create output file /scratch/gwendt/1511865/outdir/SRR1315842._STARtmp//BAMsort/20/16
SOLUTION: check that the path exists and you have write permission for this file. Also check ulimit -n and increase it to allow more open files.
```

Been here before and can't remember how fixed.
Too many threads tries to create too many files.

--outBAMsortingBinsN 10






```
STAR_array_wrapper.bash --threads 32 --array 98,196,272,288,325,614,678,723,731,750,761,1014 \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome \
  --out ${PWD}/out \
  ${PWD}/../20201116-preprocess/trimmed/SRR1*_R1.fastq.gz

```


