
#	20240925-Illumina-PhIP/20241009-PhIP



REDO but drop half of the reads using 
```
samtools view --subsample 0.5
```



ONLY PRIMARY READS
ONLY WITH START NEAR 1
ONLY QUALITY > 40?
NOT idxstats




```
mkdir logs
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  ${PWD}/phip_seq_process.bash
```

##	20241010

```

f=processed_all_together/All.count.Zscores.csv
awk 'BEGIN{FS=OFS=","}{print $13,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12}' ${f} > tmp
head -1 tmp > ${f%.csv}.reordered.join_sorted.csv
tail -n +2 tmp | sort -t, -k1,1 >> ${f%.csv}.reordered.join_sorted.csv
join --header -t, /francislab/data1/refs/PhIP-Seq/VIR3_clean.virus_score.join_sorted.csv ${f%.csv}.reordered.join_sorted.csv > ${f%.csv}.species_peptides.Zscores.csv 

for f in processed_separately/?.count.Zscores.csv ; do
awk 'BEGIN{FS=OFS=","}{print $4,$1,$2,$3}' ${f} > tmp
head -1 tmp > ${f%.csv}.reordered.join_sorted.csv
tail -n +2 tmp | sort -t, -k1,1 >> ${f%.csv}.reordered.join_sorted.csv
join --header -t, /francislab/data1/refs/PhIP-Seq/VIR3_clean.virus_score.join_sorted.csv ${f%.csv}.reordered.join_sorted.csv > ${f%.csv}.species_peptides.Zscores.csv 
done

```



```
box_upload.bash processed_*/merged.*.csv
box_upload.bash processed_*/*Zscores.csv
box_upload.bash processed_*/*count.csv*
box_upload.bash processed_*/*species_peptides.Zscores.csv 
```


