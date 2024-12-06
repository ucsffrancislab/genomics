
#	20241204-Illumina-PhIP/20241204c-PhIP



```
awk 'BEGIN{FS=OFS=","}(NR>1 && ( $5 ~ /glioma/ || $5 ~ /blank/ )){subject=$2;sub(/_1$/,"",subject);sub(/_2$/,"",subject);sub(/dup$/,"",subject); print subject,$2,"/francislab/data1/working/20241203-Illumina-PhIP/20241203d-bowtie2/out/"$1".VIR3_clean.1-84.bam",$5}' /francislab/data1/raw/20241203-Illumina-PhIP/L1\ Sample\ groups\ with\ caco_12-4-24hmh\(in\).csv | sort -t, -k1,2 > manifest.gbm.csv

sed -i '1isubject,sample,bampath,type' manifest.gbm.csv
sed -i 's/pbs blank/input/' manifest.gbm.csv 
chmod -w manifest.gbm.csv
```


TOO MANY SO SPLIT INTO SEPARATE OVERLAPPING GROUPS




```
mkdir logs
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.gbm1.csv --output ${PWD}/out.gbm1 --stop_after_zscore

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.gbm2.csv --output ${PWD}/out.gbm2 --stop_after_zscore

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.gbm3.csv --output ${PWD}/out.gbm3 --stop_after_zscore

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.gbm4.csv --output ${PWD}/out.gbm4 --stop_after_zscore
```


```
tail -q -n +2 out.gbm?/*.count.Zscores.hits.csv | sort -t, -k1,1 \
  | awk -F, '($2=="True")' > mergedgbm.All.count.Zscores.merged_trues.csv
	
sed -i '1iid,all' mergedgbm.All.count.Zscores.merged_trues.csv

join --header -t, mergedgbm.All.count.Zscores.merged_trues.csv \
  /francislab/data1/refs/PhIP-Seq/VIR3_clean.virus_score.join_sorted.csv > tmp

awk -F, '(NR>1){print $3}' tmp | sort | uniq -c | sort -k1nr,1 | sed 's/^ *//' | cut -d' ' -f2- > gbm_species_order.txt
```




```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.gbm1.csv --output ${PWD}/out.gbm1 --species_order gbm_species_order.txt

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.gbm2.csv --output ${PWD}/out.gbm2 --species_order gbm_species_order.txt

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.gbm3.csv --output ${PWD}/out.gbm3 --species_order gbm_species_order.txt

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.gbm4.csv --output ${PWD}/out.gbm4 --species_order gbm_species_order.txt
```



```
box_upload.bash out.gbm?/All* out.gbm?/m*

```







##	Merge the results


```
mkdir out.gbm

for i in 1 2 3 4 ; do
echo $i
echo out.gbm${i}/merged.seropositive.csv
head -1 out.gbm${i}/merged.seropositive.csv | sed -e '1s/\(,[^,]*\)_./\1/g' -e '1s/^id/subject/' > out.gbm/${i}.merged.seropositive.csv
sed -e '1s/\(,[^,]*\)/\1'${i}'/g' out.gbm${i}/merged.seropositive.csv >> out.gbm/${i}.merged.seropositive.csv
done

./merge_batches.py --int -o tmp.csv out.gbm/*.merged.seropositive.csv
cat tmp.csv | datamash transpose -t, | head -1 > tmp2.csv
cat tmp.csv | datamash transpose -t, | tail -n +2 | sort -t, -k1,2 >> tmp2.csv

join --header -t, <( cut -d, -f1,4 manifest.gbm.csv | uniq ) tmp2.csv > out.gbm/seropositive.csv
join --header -t, <( cut -d, -f1,4 manifest.gbm.csv | uniq ) tmp2.csv | datamash transpose -t, > out.gbm/seropositive.t.csv

box_upload.bash out.gbm/seropositive*csv
```

seropositive is the virus score if greater than threshold




##	20241205



```
mkdir out.gbm

for i in 1 2 3 4 ; do
echo $i
echo out.gbm${i}/All.count.Zscores.reordered.join_sorted.csv
head -1 out.gbm${i}/All.count.Zscores.reordered.join_sorted.csv | sed -e '1s/dup//g' -e '1s/^id/subject/' > out.gbm/${i}.All.count.Zscores.reordered.join_sorted.csv
head -1 out.gbm${i}/All.count.Zscores.reordered.join_sorted.csv | sed -e '1s/\(,[^,]*\)/\1_'${i}'/g' >> out.gbm/${i}.All.count.Zscores.reordered.join_sorted.csv
tail -q -n +2 out.gbm${i}/All.count.Zscores.reordered.join_sorted.csv | sort -t, -k1,1 >> out.gbm/${i}.All.count.Zscores.reordered.join_sorted.csv
done

./merge_batches.py -o tmp1.csv out.gbm/*.All.count.Zscores.reordered.join_sorted.csv


cat tmp1.csv | datamash transpose -t, | head -1 > tmp2.csv
cat tmp1.csv | datamash transpose -t, | tail -n +2 | sort -t, -k1,2 >> tmp2.csv

cat tmp2.csv | datamash transpose -t, > tmp3.csv

head -2 tmp3.csv > tmp4.csv
tail -n +3 tmp3.csv | sort -t, -k1,1 >> tmp4.csv

echo -n "x," > tmp5.csv
head -1 tmp4.csv >> tmp5.csv
join --header -t, /francislab/data1/refs/PhIP-Seq/VIR3_clean.id_species.uniq.csv <( tail -n +2 tmp4.csv ) >> tmp5.csv

cat tmp5.csv | datamash transpose -t, > tmp6.csv

echo -n "y," > out.gbm/Zscores.csv
head -1 tmp6.csv >> out.gbm/Zscores.csv
join --header -t, <( cut -d, -f1,4 manifest.gbm.csv | uniq ) <( tail -n +2 tmp6.csv ) >> out.gbm/Zscores.csv
cat Zscores.csv | datamash transpose -t, > out.gbm/Zscores.t.csv

box_upload.bash out.gbm/Zscores*csv
```










##	QC run

All blanks, commercial serum and PLibs


```
awk 'BEGIN{FS=OFS=","}(/^(Blank|CSE|PLib)/){subject=$2;sub(/_1$/,"",subject);sub(/_2$/,"",subject);print subject,$2,"/francislab/data1/working/20241204-Illumina-PhIP/20241204b-bowtie2/out/S"$22".VIR3_clean.1-84.bam",$5}' /francislab/data1/raw/20241204-Illumina-PhIP/L1_full\ covariates_Vir3\ phip-seq_GBM\ p1\ MENPEN\ p13_12-4-24hmh\(Sheet1\).csv | sort -t, -k1,2 > manifest.qc.csv

sed -i '1isubject,sample,bampath,type' manifest.qc.csv
sed -i 's/commercial serum control/serum/' manifest.qc.csv 
sed -i 's/phage library (blank)/serum/' manifest.qc.csv 
sed -i 's/PBS blank/input/' manifest.qc.csv 
chmod -w manifest.qc.csv


mkdir logs
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.qc.csv --output ${PWD}/out.qc

box_upload.bash out.qc/All* out.qc/m*
```

