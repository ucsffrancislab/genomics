
#	20240802-Illumina-PhIP/20240805-PhIP




```
module load samtools
mkdir out
for bam in ${PWD}/../20240803-bowtie2/out/*bam ; do
echo $bam
base=$( basename ${bam} .VIR3_clean.1-160.bam )
samtools idxstats $bam | cut -f 1,3 | sed -e '/^\*\t/d' | sort -k1n | sed -e "1 i id\t${base}" | tr "\\t" "," | gzip > out/${base}.idxstats.count.csv.gz
done

```


Note: To perform the Z-score analysis, count.combined files are merged into a table, and columns corresponding with no-serum controls are summed in a column called "input".


Separate the "input" samples

```

mkdir out/input

for sample in $( awk -F, '($3=="blank"){print $1}' /francislab/data1/raw/20240802-Illumina-PhIP/manifest.csv ) ; do
 mv out/${sample}.idxstats.count.csv.gz out/input
done

```


Then sum them with `sum_counts_files.py`

```
module load WitteLab python3/3.9.1
sum_counts_files.py -o out/input/All.count.csv out/input/*.idxstats.count.csv.gz
sed -i '1s/sum/input/' out/input/All.count.csv
gzip out/input/All.count.csv

```



Create count matrices to feed to Z-score

```

merge_all_combined_counts_files.py -o All.count.csv.gz out/*.idxstats.count.csv.gz out/input/All.count.csv.gz
chmod 400 All.count.csv.gz

```





```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=zscore --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/Zscore.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  --wrap "module load r; elledge_Zscore_analysis.R ${PWD}/All.count.csv.gz"

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
module load WitteLab python3/3.9.1
booleanize_Zscore_replicates.py -s SE1 -m ${PWD}/All.count.Zscores.csv S1 S2
booleanize_Zscore_replicates.py -s SE2 -m ${PWD}/All.count.Zscores.csv S5 S6
booleanize_Zscore_replicates.py -s SE3 -m ${PWD}/All.count.Zscores.csv S9 S10

```




```

elledge_calc_scores_nofilter.py All.count.Zscores.SE1.csv /francislab/data1/refs/PhIP-Seq/VIR3_clean.csv.gz Species 7 > tmp
head -1 tmp > All.count.Zscores.SE1.virus_scores.csv
tail -n +2 tmp | sort -t, -k1,1 >> All.count.Zscores.SE1.virus_scores.csv
elledge_calc_scores_nofilter.py All.count.Zscores.SE2.csv /francislab/data1/refs/PhIP-Seq/VIR3_clean.csv.gz Species 7 > tmp
head -1 tmp > All.count.Zscores.SE2.virus_scores.csv
tail -n +2 tmp | sort -t, -k1,1 >> All.count.Zscores.SE2.virus_scores.csv
elledge_calc_scores_nofilter.py All.count.Zscores.SE3.csv /francislab/data1/refs/PhIP-Seq/VIR3_clean.csv.gz Species 7 > tmp
head -1 tmp > All.count.Zscores.SE3.virus_scores.csv
tail -n +2 tmp | sort -t, -k1,1 >> All.count.Zscores.SE3.virus_scores.csv

```




Why some have big numbers, big zscore and True, but 0 in virus score

The calc score script processes in an the order of most found which biases those with more in the library.


