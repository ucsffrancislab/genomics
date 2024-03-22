
#	20240320-PRJNA685111-PhIP-Seq/20240322-explore


1596 fastq (798 samples all with 2 replicates)


```
bowtie2_array_wrapper.bash --no-unal --sort --very-sensitive --all --threads 8  \
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


