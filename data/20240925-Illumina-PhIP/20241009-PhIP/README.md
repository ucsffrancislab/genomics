
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





##	20241203 - test



subject,sample,bampath,type



head /francislab/data1/raw/20240925-Illumina-PhIP/manifest.csv 
Library,Sample,Item NO,IDNO,LabNO,condition,BSA blocked plate,Protein A/G beads (uL),Phage Library ,Index,Sequence,Qubit Concentration(ng/uL),pool volume(uL),Total amount(ng)
L1,SE,66562,4343,13830,1,Yes,10,Vir 3,IDX19,CAAGCAGAAGACGGCATACGAGATgcttattGTGACTGGAGTTCAGACGTGT,9.4,60,564
L2,SE,66562,4343,13830,1,Yes,10,Vir 3,IDX39,CAAGCAGAAGACGGCATACGAGATccgtagtGTGACTGGAGTTCAGACGTGT,9.4,60,564
L3,SE,66562,4343,13830,1,Yes,10,Vir 3,IDX46,CAAGCAGAAGACGGCATACGAGATtaattctGTGACTGGAGTTCAGACGTGT,9.4,60,564


```
awk 'BEGIN{OFS=FS=","}(NR>1){print $6,$1,"/francislab/data1/working/20240925-Illumina-PhIP/20240925b-bowtie2/out/"$1".VIR3_clean.1-160.bam",$2}' /francislab/data1/raw/20240925-Illumina-PhIP/manifest.csv > manifest.csv

sed -i '1isubject,sample,bampath,type' manifest.csv
sed -i 's/PBS/input/' manifest.csv 
chmod -w manifest.csv
```

```
mkdir logs
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 00 --manifest ${PWD}/manifest.csv --output ${PWD}/out
```






