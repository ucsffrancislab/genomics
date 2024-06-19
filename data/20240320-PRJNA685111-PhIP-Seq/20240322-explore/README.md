
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

for bam in ${PWD}/out/*bam ; do
 echo ${PWD}/count_alignments.bash ${bam}
done > commands
commands_array_wrapper.bash --array_file commands --time 720 --threads 2 --mem 15G 

```


Note: To perform the Z-score analysis, count.combined files are merged into a table, and columns corresponding with no-serum controls are summed in a column called "input".



Create "zero" input column

```

for s in idxstats q20 q30 q40 ; do
 merge_all_combined_counts_files_add_zero.py -o ${s}.Zero.count.csv.gz out/*.${s}.count.csv.gz
 chmod 400 ${s}.Zero.count.csv.gz
done

```




```

r="Zero"
for s in idxstats q20 q30 q40 ; do

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=${s}.${r} --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/Zscore.${s}.${r}.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  --wrap "module load r; elledge_Zscore_analysis.R ${PWD}/${s}.${r}.count.csv.gz"

done

```



I think that the output of the zscore command needs to have the columns reordered.

They are "all of the samples ...,id,group,input"

Not sure if "input" is needed anymore or what "group" is.


```

#awk 'BEGIN{FS=OFS=","}(NR==1){print $5,$6,$1,$2,$3,$4,$7}(NR>1){printf "%d,%d,%.2g,%.2g,%.2g,%.2g,%d\n",$5,$6,$1,$2,$3,$4,$7}' \
#  Elledge/fastq_files/merged.combined.count.Zscores.csv > Elledge/fastq_files/merged.combined.count.Zscores.reordered.csv

```





This is over 3000 commands. Should join the 4 different "s" types

```

r="Zero"

for t in $( tail -n +2 filereport_combined.tsv | cut -f10 | sort | sed 's/_TR.$//' | uniq | grep -vs input ) ; do
 samples=$( grep ${t}_ filereport_combined.tsv | cut -f4 | paste -sd" " )
 echo "module load WitteLab python3/3.9.1; booleanize_Zscore_replicates.py -s ${t} -m ${PWD}/idxstats.${r}.count.Zscores.csv ${samples}; booleanize_Zscore_replicates.py -s ${t} -m ${PWD}/q20.${r}.count.Zscores.csv ${samples}; booleanize_Zscore_replicates.py -s ${t} -m ${PWD}/q30.${r}.count.Zscores.csv ${samples}; booleanize_Zscore_replicates.py -s ${t} -m ${PWD}/q40.${r}.count.Zscores.csv ${samples}"
done > commands

commands_array_wrapper.bash --array_file commands --time 720 --threads 2 --mem 15G 

```




```
mkdir Zscores
mv *.count.Zscores.*.csv Zscores/

for sample in $( tail -n +2 filereport_combined.tsv | cut -f10 | grep -vs input | sed 's/_TR.$//' | sort | uniq ) ; do
 echo ${PWD}/elledge_calc_scores_nofilter.bash $sample
done > commands

commands_array_wrapper.bash --array_file commands --time 720 --threads 2 --mem 15G 

```



```

for f in *.virus_scores.csv ; do
echo $f
join -t, ${f} <( tail -n +2 /c4/home/gwendt/github/ucsffrancislab/PhIP-Seq/Elledge/VirScan_viral_thresholds.csv ) | awk -F, '($2>$3){print $1}' > ${f%.csv}.abovethreshold.txt
done

```






```

r="Zero"

for s in idxstats q20 q30 q40 ; do
 ./merge_lists_to_matrix.py -o ${s}.${r}.above_threshold.csv Zscores/${s}.${r}.*.virus_scores.abovethreshold.txt
done

```




Large variation in bam file size

```

ll -Sr out/*bam | head
-r--r----- 1 gwendt francislab    551773 May 24 20:46 out/SRR13346395.VIR3_clean.1-80.bam
-r--r----- 1 gwendt francislab    553015 May 24 12:33 out/SRR13335598.VIR3_clean.1-80.bam
-r--r----- 1 gwendt francislab    585065 May 24 12:22 out/SRR13335544.VIR3_clean.1-80.bam
-r--r----- 1 gwendt francislab    710357 May 24 12:01 out/SRR13335434.VIR3_clean.1-80.bam
-r--r----- 1 gwendt francislab    721304 May 24 12:13 out/SRR13335503.VIR3_clean.1-80.bam
-r--r----- 1 gwendt francislab    845268 May 24 12:21 out/SRR13335543.VIR3_clean.1-80.bam
-r--r----- 1 gwendt francislab   1020794 May 24 12:13 out/SRR13335502.VIR3_clean.1-80.bam
-r--r----- 1 gwendt francislab   1363639 May 24 20:30 out/SRR13346358.VIR3_clean.1-80.bam
-r--r----- 1 gwendt francislab   1467331 May 24 10:56 out/SRR13335107.VIR3_clean.1-80.bam
-r--r----- 1 gwendt francislab   1659468 May 24 20:45 out/SRR13346394.VIR3_clean.1-80.bam

ll -Sr out/*bam | tail
-r--r----- 1 gwendt francislab 109383257 May 24 19:12 out/SRR13346140.VIR3_clean.1-80.bam
-r--r----- 1 gwendt francislab 110165029 May 24 12:20 out/SRR13335532.VIR3_clean.1-80.bam
-r--r----- 1 gwendt francislab 110413570 May 24 19:25 out/SRR13346203.VIR3_clean.1-80.bam
-r--r----- 1 gwendt francislab 111250323 May 24 17:57 out/SRR13345923.VIR3_clean.1-80.bam
-r--r----- 1 gwendt francislab 111333718 May 24 12:32 out/SRR13335587.VIR3_clean.1-80.bam
-r--r----- 1 gwendt francislab 112397361 May 24 19:26 out/SRR13346206.VIR3_clean.1-80.bam
-r--r----- 1 gwendt francislab 113121208 May 24 11:00 out/SRR13335122.VIR3_clean.1-80.bam
-r--r----- 1 gwendt francislab 116288308 May 24 17:06 out/SRR13335993.VIR3_clean.1-80.bam
-r--r----- 1 gwendt francislab 124019110 May 24 11:15 out/SRR13335190.VIR3_clean.1-80.bam
-r--r----- 1 gwendt francislab 130445817 May 24 17:10 out/SRR13336010.VIR3_clean.1-80.bam

```







##	20240614






```

join -t, --header /francislab/data1/refs/PhIP-Seq/VIR3_clean.circos_framework.uniq.clean.csv <( zcat idxstats.Zero.count.csv.gz ) | head


join -t, --header /francislab/data1/refs/PhIP-Seq/VIR3_clean.circos_framework.uniq.clean.csv <( zcat idxstats.Zero.count.csv.gz ) | cut -d, -f1-1599 | gzip > idxstats.withNames.count.csv.gz

```



