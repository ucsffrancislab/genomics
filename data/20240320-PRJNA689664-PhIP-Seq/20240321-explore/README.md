
#	20240320-PRJNA689664-PhIP-Seq/20240321-explore


540 fastq (270 samples most with 2 replicates)

232 children plus some other stuff


```
bowtie2_array_wrapper.bash --no-unal --sort --very-sensitive --all --threads 8  \
  -x /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome+viral+bacteria+protozoa \
  --single --extension .fastq.gz --outdir ${PWD}/out \
  /francislab/data1/raw/20240320-PRJNA689664-PhIP-Seq/fastq/*fastq.gz
```

Nope



Removed --all


```
bowtie2_array_wrapper.bash --no-unal --sort --very-sensitive --threads 8  \
  -x /francislab/data1/refs/PhIP-Seq/VIR3_clean \
  --single --extension .fastq.gz --outdir ${PWD}/out \
  /francislab/data1/raw/20240320-PRJNA689664-PhIP-Seq/fastq/*fastq.gz
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
ln -s /francislab/data1/raw/20240320-PRJNA689664-PhIP-Seq/filereport_read_run_PRJNA689664_tsv.txt 
ln -s /francislab/data1/refs/PhIP-Seq/VIR3_clean.csv.gz 



zcat VIR3_clean.csv.gz | head -1 | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")"}{print $17","$12}' > tmp1
zcat VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")"}{print $17","$12}' | uniq | sort -t, -k1b,1 | uniq >> tmp1

zcat merged.normalized.csv.gz | head -1 > tmp2
zcat merged.normalized.csv.gz | tail -n +2 | sort -t, -k1b,1 >> tmp2

join --header -t, tmp1 tmp2 > tmp3


cat tmp3 | datamash transpose -t, > tmp4


cut --output-delimiter=, -f4,10 filereport_read_run_PRJNA689664_tsv.txt | sort -t, -k1b,1 > tmp5


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
  /francislab/data1/raw/20240320-PRJNA689664-PhIP-Seq/fastq/*fastq.gz

```




```

for bam in ${PWD}/out/*bam ; do
 echo ${PWD}/count_alignments.bash ${bam}
done > commands
commands_array_wrapper.bash --array_file commands --time 720 --threads 2 --mem 15G 

```


Note: To perform the Z-score analysis, count.combined files are merged into a table, and columns corresponding with no-serum controls are summed in a column called "input".


Separate the "input" samples

```

mkdir out/input
for sample in $( grep input filereport_read_run_PRJNA689664_tsv.txt | cut -f4 ) ; do
 mv out/${sample}.* out/input
done

```


Then sum them with `sum_counts_files.py`

This dataset has 4 input samples each with a technical replicate.
Sum all 8? Not exactly sure what to do here.
The other dataset doesn't have any input samples. Really not sure what to do there.


Sum all 8
Sum TR1
Sum TR2
Just use 0 (no sum at all) (later in the processing not here)


```

for s in idxstats q20 q30 q40 ; do
 sum_counts_files.py -o out/input/${s}.All8.count.csv out/input/*.${s}.count.csv.gz
 sed -i '1s/sum/input/' out/input/${s}.All8.count.csv
 gzip out/input/${s}.All8.count.csv
done

```


```
for s in idxstats q20 q30 q40 ; do
 echo $s
 for r in TR1 TR2 ; do
  echo $r
  command="sum_counts_files.py -o out/input/${s}.${r}.count.csv"
  for t in $( grep _${r} filereport_read_run_PRJNA689664_tsv.txt | grep input | cut -f4 | paste -sd" " ) ; do
   echo $t
   command="${command} out/input/${t}.${s}.count.csv.gz"
  done
  echo $command
  eval $command
  sed -i '1s/sum/input/' out/input/${s}.${r}.count.csv
  gzip out/input/${s}.${r}.count.csv
 done
done

```


Create count matrices to feed to Z-score

```

for s in idxstats q20 q30 q40 ; do
 for r in All8 TR1 TR2 ; do
  merge_all_combined_counts_files.py -o ${s}.${r}.count.csv.gz out/*.${s}.count.csv.gz out/input/${s}.${r}.count.csv.gz
  chmod 400 ${s}.${r}.count.csv.gz
 done
done

```


Create "zero" input column

```

for s in idxstats q20 q30 q40 ; do
 merge_all_combined_counts_files_add_zero.py -o ${s}.Zero.count.csv.gz out/*.${s}.count.csv.gz
 chmod 400 ${s}.Zero.count.csv.gz
done

```




```

for s in idxstats q20 q30 q40 ; do
 for r in All8 TR1 TR2 Zero ; do

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=${s}.${r} --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/Zscore.${s}.${r}.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  --wrap "module load r; elledge_Zscore_analysis.R ${PWD}/${s}.${r}.count.csv.gz"

 done
done

```



I think that the output of the zscore command needs to have the columns reordered.

They are "all of the samples ...,id,group,input"

Not sure if "input" is needed anymore or what "group" is.


```

#awk 'BEGIN{FS=OFS=","}(NR==1){print $5,$6,$1,$2,$3,$4,$7}(NR>1){printf "%d,%d,%.2g,%.2g,%.2g,%.2g,%d\n",$5,$6,$1,$2,$3,$4,$7}' \
#  Elledge/fastq_files/merged.combined.count.Zscores.csv > Elledge/fastq_files/merged.combined.count.Zscores.reordered.csv

```





This is over 4000 commands. Should join the 4 different "s" types

```

for t in $( tail -n +2 filereport_read_run_PRJNA689664_tsv.txt | cut -f10 | sort | sed 's/_TR.$//' | uniq | grep -vs input ) ; do
 samples=$( grep ${t}_ filereport_read_run_PRJNA689664_tsv.txt | cut -f4 | paste -sd" " )
 for s in idxstats q20 q30 q40 ; do
  for r in All8 TR1 TR2 Zero ; do
   echo "module load WitteLab python3/3.9.1; booleanize_Zscore_replicates.py -s ${t} -m ${PWD}/${s}.${r}.count.Zscores.csv ${samples}"
  done
 done
done > commands

commands_array_wrapper.bash --array_file commands --time 720 --threads 2 --mem 15G 

```




```

for sample in $( tail -n +2 filereport_read_run_PRJNA689664_tsv.txt | cut -f10 | grep -vs input | sed 's/_TR.$//' | sort | uniq ) ; do
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

