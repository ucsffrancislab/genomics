
#	20201006-GTEx/20230714-STAR




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




