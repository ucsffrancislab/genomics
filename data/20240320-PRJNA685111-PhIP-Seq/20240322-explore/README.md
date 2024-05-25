
#	20240320-PRJNA685111-PhIP-Seq/20240322-explore


1596 fastq (798 samples all with 2 replicates)


```
bowtie2_array_wrapper.bash --no-unal --sort --very-sensitive --threads 8  \
  -x /francislab/data1/refs/PhIP-Seq/VIR3_clean \
  --single --extension .fastq.gz --outdir ${PWD}/out \
  /francislab/data1/raw/20240320-PRJNA685111-PhIP-Seq/fastq/*fastq.gz
```


Looks like VIR3_clean is appropriate here.


Just note that these are 75bp reads.



```
module load WitteLab python3/3.9.1

python3 ~/.local/bin/merge_uniq-c.py --int -o merged.raw.csv out/*.aligned_sequence_counts.txt


for f in out/*.aligned_count.txt ; do
echo $f
sum=$( cat $f )
awk -v sum=${sum} '{$1=100000*$1/sum;print}' ${f%%aligned_count.txt}aligned_sequence_counts.txt > ${f%%aligned_count.txt}normalized_aligned_sequence_counts.txt
done

python3 ~/.local/bin/merge_uniq-c.py -o merged.normalized.csv out/*.normalized_aligned_sequence_counts.txt

chmod 400 merged.*.csv
gzip merged.*.csv
```




join wants alphabetic, not numeric, sorting



```
ln -s /francislab/data1/raw/20240320-PRJNA685111-PhIP-Seq/filereport_combined.tsv
ln -s /francislab/data1/refs/PhIP-Seq/VIR3_clean.csv.gz 



zcat VIR3_clean.csv.gz | head -1 | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")"}{print $17","$12}' > tmp1
zcat VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")"}{print $17","$12}' | uniq | sort -t, -k1b,1 | uniq >> tmp1

zcat merged.normalized.csv.gz | head -1 > tmp2
zcat merged.normalized.csv.gz | tail -n +2 | sort -t, -k1b,1 >> tmp2

join --header -t, tmp1 tmp2 > tmp3


cat tmp3 | datamash transpose -t, > tmp4


cut --output-delimiter=, -f4,10 filereport_combined.tsv | sort -t, -k1b,1 > tmp5


echo -n , > tmp6
head -1 tmp4 >> tmp6

join --header -t, tmp5 <( tail -n +2 tmp4 ) >> tmp6

cat tmp6 | datamash transpose -t, > tmp7

head -2 tmp7 > tmp8
tail -n +3 tmp7 | sort -t, -k1n,1 >> tmp8


mv tmp8 final.matrix.normalized.csv
chmod 400 final.matrix.normalized.csv
gzip final.matrix.normalized.csv

```





##	Notes


Reference of sequences with lengths to match reads?

Normalize by raw read count or aligned read count?

Preprocessing at all here or use as is?

Align with --all?







##	20240524

Let's have a go at the actual phip-seq processing pipeline.


based on ...
```
elledge_process_sample.bash --sample_id ${s} --index ~/github/ucsffrancislab/PhIP-Seq/Elledge/vir3 ${f} 
```

Looks like the read lenghts are about 75 so using an 80bp reference

bowtie2

```
/francislab/data1/refs/PhIP-Seq/VIR3_clean.1-80
```

```
bowtie2_array_wrapper.bash --norc --single --very-sensitive --sort --extension .fastq.gz --threads 8 \
  -x /francislab/data1/refs/PhIP-Seq/VIR3_clean.1-80 --outdir ${PWD}/out \
  /francislab/data1/raw/20240320-PRJNA685111-PhIP-Seq/fastq/*fastq.gz

```


```
samtools view out/SRR13277039.VIR3_clean.1-80.bam | cut -f5 | sort -k1n | uniq -c
  65728 0
      2 2
  35985 3
     12 4
     20 5
  50286 8
     22 14
     49 16
      2 21
    164 22
  87108 23
  53204 24
     12 25
    195 26
    213 27
     14 32
     21 33
     21 34
     30 35
    206 36
    435 37
   1809 38
   2576 39
  35245 40
 577703 42
```


samtools idxstats will treat all these the same.
Its much faster, yes.


```

samtools idxstats $bam | cut -f 1,3 | sed -e '/^\*\t/d' -e "1 i id\t${SAMPLE_ID}" | tr "\\t" "," > ${bam%.bam}.idxstats.count.csv
samtools  $bam | cut -f 1,3 | sed -e '/^\*\t/d' -e "1 i id\t${SAMPLE_ID}" | tr "\\t" "," > ${bam%.bam}.idxstats.count.csv


```


```
SAMPLE_ID=.......

#	Not sure why the `samtools view -u` is needed.
#	  -u, --uncompressed         Uncompressed BAM output (and default to --bam)

bowtie -3 25 -n 3 -l 30 -e 1000 --tryhard --nomaqround --norc --best --sam --quiet \
	-x ${INDEX} \
	$fq \
	| samtools view -u - \
	| samtools sort -T ${fq%.fastq.gz}.2.temp.bam -o ${fq%.fastq.gz}.bam


bam=${fq%.fastq.gz}.bam
samtools index $bam


#samtools idxstats $bam | cut -f 1,3 | sed -e '/^\*\t/d' -e '1 i id\tSAMPLE_ID' | tr "\\t" "," > ${bam%.bam}.count.csv
samtools idxstats $bam | cut -f 1,3 | sed -e '/^\*\t/d' -e "1 i id\t${SAMPLE_ID}" | tr "\\t" "," > ${bam%.bam}.count.csv


csv=${bam%.bam}.count.csv
gzip $csv
```

