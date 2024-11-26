
#	20240925-Illumina-PhIP/20241125-PhIP-test


This is solely to create the All.counts.csv matrix




```
mkdir logs
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash --manifest ${PWD}/manifest.csv --output ${PWD}/out
```





```
sum_counts_files.py --int -o Sum.count.csv *.q40.count.csv.gz
tail -n +2 Sum.count.csv | sort -t, -k2n,2 | cut -d, -f2 | uniq -c
```


```
head -1 out2/counts/Sum.count.csv > out2/counts/Sum.count.join_sorted.csv
tail -n +2 out2/counts/Sum.count.csv | sort -t, -k1,1 >> out2/counts/Sum.count.join_sorted.csv


join --header -e0 -a1 -t, -o 0 2.2 VIR3_clean.uniq.sequences.join_sorted out2/counts/Sum.count.join_sorted.csv > tmp

head -1 tmp > TileCounts.csv
tail -n +2 tmp | sort -t, -k2n,2 >> TileCounts.csv


```


