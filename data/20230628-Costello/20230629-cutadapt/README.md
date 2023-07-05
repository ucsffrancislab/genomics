
#	20230628-Costello/20230629-cutadapt

Gonna write cutadapt_array_wrapper.bash



Then ...
-e 0.1 -q 20 -O 1 -a AGATCGGAAGAGC 

```

./cutadapt_array_wrapper.bash --threads 4 --extension _R1.fastq.gz \
  --out /francislab/data1/working/20230628-Costello/20230629-cutadapt/out \
  --trim-n --match-read-wildcards --times 7 \
  --error-rate 0.1 --overlap 5 --minimum-length 15 --quality-cutoff 25 \
  -a "A{10}" -a "G{10}" -a "T{10}" -a "C{10}" \
  -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA -a GGAAGAGCACACGTCTGAACTCCAGTCA -a ATCTCGTATGCCGTCTTCTGCTTG \
  -A "A{10}" -A "G{10}" -A "T{10}" -A "C{10}" \
  -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAG    -A GGAAGAGCGTCGTGTAGGGAAAGAG    -A TGTAGATCTCGGTGGTCGCCGTATCATT \
    /francislab/data1/raw/20230628-Costello/fastq/*R1.fastq.gz

```






```


zcat /costellolab/data2/jocostello/rna_all/CH02/2p300SF10711v1_S2_L001_R2_001.fastq.gz | sed -n '2~4p' | grep -c "AAAAAAAAAA"
81660
zcat /costellolab/data2/jocostello/rna_all/CH02/2p300SF10711v1_S2_L001_R2_001.fastq.gz | sed -n '2~4p' | grep -c "TTTTTTTTTT"
120278
zcat /costellolab/data2/jocostello/rna_all/CH02/2p300SF10711v1_S2_L001_R2_001.fastq.gz | sed -n '2~4p' | grep -c "CCCCCCCCCC"
65975
zcat /costellolab/data2/jocostello/rna_all/CH02/2p300SF10711v1_S2_L001_R2_001.fastq.gz | sed -n '2~4p' | grep -c "GGGGGGGGGG"
5464

zcat /costellolab/data2/jocostello/rna_all/CH02/2p300SF10711v1_S2_L001_R1_001.fastq.gz | sed -n '2~4p' | grep -c "AAAAAAAAAA"
56273
zcat /costellolab/data2/jocostello/rna_all/CH02/2p300SF10711v1_S2_L001_R1_001.fastq.gz | sed -n '2~4p' | grep -c "TTTTTTTTTT"
246341
zcat /costellolab/data2/jocostello/rna_all/CH02/2p300SF10711v1_S2_L001_R1_001.fastq.gz | sed -n '2~4p' | grep -c "CCCCCCCCCC"
4700
zcat /costellolab/data2/jocostello/rna_all/CH02/2p300SF10711v1_S2_L001_R1_001.fastq.gz | sed -n '2~4p' | grep -c "GGGGGGGGGG"
5612



```
