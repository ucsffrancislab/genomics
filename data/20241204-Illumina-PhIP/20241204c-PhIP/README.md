
#	20241204-Illumina-PhIP/20241204c-PhIP



```
awk 'BEGIN{FS=OFS=","}(NR>1 && ( $5 ~ /glioma/ || $5 ~ /blank/ )){subject=$2;sub(/_1$/,"",subject);sub(/_2$/,"",subject);sub(/dup$/,"",subject); print subject,$2,"/francislab/data1/working/20241203-Illumina-PhIP/20241203d-bowtie2/out/"$1".VIR3_clean.1-84.bam",$5}' /francislab/data1/raw/20241203-Illumina-PhIP/L1\ Sample\ groups\ with\ caco_12-4-24hmh\(in\).csv | sort -t, -k1,1 > manifest.gbm.csv

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
cat out.gbm/Zscores.csv | datamash transpose -t, > out.gbm/Zscores.t.csv

box_upload.bash out.gbm/Zscores*csv
```










##	QC run

All blanks, commercial serum and PLibs


```
awk 'BEGIN{FS=OFS=","}(/^(Blank|CSE|PLib)/){subject=$2;sub(/_1$/,"",subject);sub(/_2$/,"",subject);print subject,$2,"/francislab/data1/working/20241204-Illumina-PhIP/20241204b-bowtie2/out/S"$22".VIR3_clean.1-84.bam",$5}' /francislab/data1/raw/20241204-Illumina-PhIP/L1_full\ covariates_Vir3\ phip-seq_GBM\ p1\ MENPEN\ p13_12-4-24hmh\(Sheet1\).csv | sort -t, -k1,2 > manifest.qc.csv

sed -i '1isubject,sample,bampath,type' manifest.qc.csv
#sed -i 's/commercial serum control/serum/' manifest.qc.csv 
#sed -i 's/phage library (blank)/serum/' manifest.qc.csv 
sed -i 's/PBS blank/input/' manifest.qc.csv 
chmod -w manifest.qc.csv


mkdir logs
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.qc.csv --output ${PWD}/out.qc

box_upload.bash out.qc/All* out.qc/m*
```



```
for i in 1 2 3 4 ; do
echo $i
echo out.gbm${i}/merged.public_epitopes_BEFORE.csv
head -1 out.gbm${i}/merged.public_epitopes_BEFORE.csv | sed -e '1s/\(,[^,]*\)_./\1/g' -e '1s/^id/subject/' > out.gbm/${i}.merged.public_epitopes_BEFORE.csv
sed -e '1s/\(,[^,]*\)/\1_'${i}'/g' out.gbm${i}/merged.public_epitopes_BEFORE.csv >> out.gbm/${i}.merged.public_epitopes_BEFORE.csv
done

./merge_batches.py --de_nan --int -o tmp.csv out.gbm/*.merged.public_epitopes_BEFORE.csv

cat tmp.csv | datamash transpose -t, | head -1 > tmp2.csv
cat tmp.csv | datamash transpose -t, | tail -n +2 | sort -t, -k1,2 >> tmp2.csv

join --header -t, <( cut -d, -f1,4 manifest.gbm.csv | uniq ) tmp2.csv > out.gbm/public_epitopes_BEFORE.csv
join --header -t, <( cut -d, -f1,4 manifest.gbm.csv | uniq ) tmp2.csv | datamash transpose -t, > out.gbm/public_epitopes_BEFORE.t.csv

for i in 1 2 3 4 ; do
echo $i
echo out.gbm${i}/merged.public_epitopes_AFTER.csv
head -1 out.gbm${i}/merged.public_epitopes_AFTER.csv | sed -e '1s/\(,[^,]*\)_./\1/g' -e '1s/^id/subject/' > out.gbm/${i}.merged.public_epitopes_AFTER.csv
sed -e '1s/\(,[^,]*\)/\1_'${i}'/g' out.gbm${i}/merged.public_epitopes_AFTER.csv >> out.gbm/${i}.merged.public_epitopes_AFTER.csv
done

./merge_batches.py --de_nan --int -o tmp.csv out.gbm/*.merged.public_epitopes_AFTER.csv

cat tmp.csv | datamash transpose -t, | head -1 > tmp2.csv
cat tmp.csv | datamash transpose -t, | tail -n +2 | sort -t, -k1,2 >> tmp2.csv

join --header -t, <( cut -d, -f1,4 manifest.gbm.csv | uniq ) tmp2.csv > out.gbm/public_epitopes_AFTER.csv
join --header -t, <( cut -d, -f1,4 manifest.gbm.csv | uniq ) tmp2.csv | datamash transpose -t, > out.gbm/public_epitopes_AFTER.t.csv

box_upload.bash out.gbm/public_epitopes_*
```







##	20241210


testing my Zscore script

```
for i in 1 2 3 4 ; do
zscoring.py --input out.gbm${i}/All.count.csv --output out.gbm${i}/All.count.Zscores.TEST.csv 
done
```



#head -1 out.gbm${i}/All.count.Zscores.TEST.csv | sed -e 's/\(,[^,]*\)/\1_'${i}'/g' > out.gbm${i}/All.count.Zscores.TEST.reordered.join_sorted.csv
```
for i in $( seq 1 4 ) ; do
echo $i
head -1 out.gbm${i}/All.count.Zscores.TEST.csv > out.gbm${i}/All.count.Zscores.TEST.reordered.join_sorted.csv
tail -n +2 out.gbm${i}/All.count.Zscores.TEST.csv | sort -t, -k1,1 >> out.gbm${i}/All.count.Zscores.TEST.reordered.join_sorted.csv
done
```

#cat tmp.merged.csv | datamash -t, transpose > tmp
#head -1 tmp > merged.Zscores.TEST.csv
#tail -n +2 tmp | sort -t, -k1,1 >> merged.Zscores.TEST.csv
#
#cat merged.Zscores.TEST.csv | datamash -t, transpose > merged.Zscores.t.TEST.csv



```
mkdir out.gbm

for i in 1 2 3 4 ; do
echo $i
echo out.gbm${i}/All.count.Zscores.TEST.reordered.join_sorted.csv
head -1 out.gbm${i}/All.count.Zscores.TEST.reordered.join_sorted.csv | sed -e '1s/dup//g' -e '1s/^id/subject/' > out.gbm/${i}.All.count.Zscores.TEST.reordered.join_sorted.csv
head -1 out.gbm${i}/All.count.Zscores.TEST.reordered.join_sorted.csv | sed -e '1s/\(,[^,]*\)/\1_'${i}'/g' >> out.gbm/${i}.All.count.Zscores.TEST.reordered.join_sorted.csv
tail -q -n +2 out.gbm${i}/All.count.Zscores.TEST.reordered.join_sorted.csv | sort -t, -k1,1 >> out.gbm/${i}.All.count.Zscores.TEST.reordered.join_sorted.csv
done

./merge_batches.py -o tmp1.csv out.gbm/*.All.count.Zscores.TEST.reordered.join_sorted.csv


cat tmp1.csv | datamash transpose -t, | head -1 > tmp2.csv
cat tmp1.csv | datamash transpose -t, | tail -n +2 | sort -t, -k1,2 >> tmp2.csv

cat tmp2.csv | datamash transpose -t, > tmp3.csv

head -2 tmp3.csv > tmp4.csv
tail -n +3 tmp3.csv | sort -t, -k1,1 >> tmp4.csv

echo -n "x," > tmp5.csv
head -1 tmp4.csv >> tmp5.csv
join --header -t, /francislab/data1/refs/PhIP-Seq/VIR3_clean.id_species.uniq.csv <( tail -n +2 tmp4.csv ) >> tmp5.csv

cat tmp5.csv | datamash transpose -t, > tmp6.csv

echo -n "y," > out.gbm/Zscores.TEST.csv
head -1 tmp6.csv >> out.gbm/Zscores.TEST.csv
join --header -t, <( cut -d, -f1,4 manifest.gbm.csv | uniq ) <( tail -n +2 tmp6.csv ) >> out.gbm/Zscores.TEST.csv
cat out.gbm/Zscores.TEST.csv | datamash transpose -t, > out.gbm/Zscores.t.TEST.csv

box_upload.bash out.gbm/Zscores*TEST.csv
```





```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.gbm.csv --output ${PWD}/out.gbm.test
```

```
box_upload.bash out.gbm.test/All* out.gbm.test/m*
```



##	20241211

Updated zscoring binning

```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.gbm.csv --output ${PWD}/out.gbm.test2
```






Annotate GBM seropositives

```
dir=out.gbm.test2
head -1 ${dir}/merged.seropositive.csv | sed -e '1s/\(,[^,]*\)_./\1/g' -e '1s/^id/subject/' > tmp1.csv
sed -e '1s/\(,[^,]*\)/\1'${i}'/g' ${dir}/merged.seropositive.csv >> tmp1.csv
cat tmp1.csv | datamash transpose -t, | head -1 > tmp2.csv
cat tmp1.csv | datamash transpose -t, | tail -n +2 | sort -t, -k1,2 >> tmp2.csv
join --header -t, <( cut -d, -f1,4 manifest.gbm.csv | uniq ) tmp2.csv > ${dir}/seropositive.csv
join --header -t, <( cut -d, -f1,4 manifest.gbm.csv | uniq ) tmp2.csv | datamash transpose -t, > ${dir}/seropositive.t.csv
box_upload.bash ${dir}/seropositive*csv
```



Annotate GBM Zscores

```
dir=out.gbm.test2
head -1 ${dir}/All.count.Zscores.csv | sed -e '1s/dup//g' -e '1s/^id/subject/' > tmp1.csv
head -1 ${dir}/All.count.Zscores.csv >> tmp1.csv
tail -q -n +2 ${dir}/All.count.Zscores.csv | sort -t, -k1,1 >> tmp1.csv
cat tmp1.csv | datamash transpose -t, | head -1 > tmp2.csv
cat tmp1.csv | datamash transpose -t, | tail -n +2 | sort -t, -k1,2 >> tmp2.csv
cat tmp2.csv | datamash transpose -t, > tmp3.csv
head -2 tmp3.csv > tmp4.csv
tail -n +3 tmp3.csv | sort -t, -k1,1 >> tmp4.csv
echo -n "x," > tmp5.csv
head -1 tmp4.csv >> tmp5.csv
join --header -t, /francislab/data1/refs/PhIP-Seq/VIR3_clean.id_species.uniq.csv <( tail -n +2 tmp4.csv ) >> tmp5.csv
cat tmp5.csv | datamash transpose -t, > tmp6.csv
echo -n "y," > ${dir}/Zscores.csv
head -1 tmp6.csv >> ${dir}/Zscores.csv
join --header -t, <( cut -d, -f1,4 manifest.gbm.csv | uniq ) <( tail -n +2 tmp6.csv ) >> ${dir}/Zscores.csv
cat ${dir}/Zscores.csv | datamash transpose -t, > ${dir}/Zscores.t.csv
box_upload.bash ${dir}/Zscores*csv
```



Lets go a head and run your z-score’s for the Meningioma and pemphigus data.

```
24 meningioma serum
16 PBS blank
60 pemphigus serum
```


```
#awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}($5~/(meningioma|pemphigus|PBS blank)/){subject=$2;sub(/_1$/,"",subject);sub(/_2$/,"",subject);print subject,$2,"/francislab/data1/working/20241204-Illumina-PhIP/20241204b-bowtie2/out/S"$22".VIR3_clean.1-84.bam",$5}' /francislab/data1/raw/20241204-Illumina-PhIP/L1_full_covariates_Vir3_phip-seq_GBM_p1_MENPEN_p13_12-4-24hmh.csv | sort -t, -k1,1 > manifest.menpem.csv

awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}(NR>1 && ($5~/(meningioma|pemphigus|PBS blank)/)){subject=$2;sub(/_1$/,"",subject);sub(/_2$/,"",subject);sub(/dup$/,"",subject); print subject,$2,"/francislab/data1/working/20241203-Illumina-PhIP/20241203d-bowtie2/out/S"$22".VIR3_clean.1-84.bam",$5}' /francislab/data1/raw/20241204-Illumina-PhIP/L1_full_covariates_Vir3_phip-seq_GBM_p1_MENPEN_p13_12-4-24hmh.csv | sort -t, -k1,1 > manifest.menpem.csv

sed -i '1isubject,sample,bampath,type' manifest.menpem.csv
sed -i 's/PBS blank/input/' manifest.menpem.csv
chmod -w manifest.menpem.csv
```

```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=14-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.menpem.csv --output ${PWD}/out.menpem.test2
```





```
dir=out.menpem.test2
box_upload.bash ${dir}/All* ${dir}/m*
```

Annotate MenPem seropositives

```
dir=out.menpem.test2
head -1 ${dir}/merged.seropositive.csv | sed -e '1s/\(,[^,]*\)_./\1/g' -e '1s/^id/subject/' > tmp1.csv
sed -e '1s/\(,[^,]*\)/\1'${i}'/g' ${dir}/merged.seropositive.csv >> tmp1.csv
cat tmp1.csv | datamash transpose -t, | head -1 > tmp2.csv
cat tmp1.csv | datamash transpose -t, | tail -n +2 | sort -t, -k1,1 >> tmp2.csv
join --header -t, <( cut -d, -f1,4 manifest.menpem.csv | uniq ) tmp2.csv > ${dir}/seropositive.csv
join --header -t, <( cut -d, -f1,4 manifest.menpem.csv | uniq ) tmp2.csv | datamash transpose -t, > ${dir}/seropositive.t.csv
box_upload.bash ${dir}/seropositive*csv
```



Annotate menpem Zscores

```
dir=out.menpem.test2
head -1 ${dir}/All.count.Zscores.csv | sed -e '1s/dup//g' -e '1s/^id/subject/' > tmp1.csv
head -1 ${dir}/All.count.Zscores.csv >> tmp1.csv
tail -q -n +2 ${dir}/All.count.Zscores.csv | sort -t, -k1,1 >> tmp1.csv
cat tmp1.csv | datamash transpose -t, | head -1 > tmp2.csv
cat tmp1.csv | datamash transpose -t, | tail -n +2 | sort -t, -k1,1 >> tmp2.csv
cat tmp2.csv | datamash transpose -t, > tmp3.csv
head -2 tmp3.csv > tmp4.csv
tail -n +3 tmp3.csv | sort -t, -k1,1 >> tmp4.csv
echo -n "x," > tmp5.csv
head -1 tmp4.csv >> tmp5.csv
join --header -t, /francislab/data1/refs/PhIP-Seq/VIR3_clean.id_species.uniq.csv <( tail -n +2 tmp4.csv ) >> tmp5.csv
cat tmp5.csv | datamash transpose -t, > tmp6.csv
echo -n "y," > ${dir}/Zscores.csv
head -1 tmp6.csv >> ${dir}/Zscores.csv
join --header -t, <( cut -d, -f1,4 manifest.menpem.csv | uniq ) <( tail -n +2 tmp6.csv ) >> ${dir}/Zscores.csv
cat ${dir}/Zscores.csv | datamash transpose -t, > ${dir}/Zscores.t.csv
box_upload.bash ${dir}/Zscores*csv
```




##	20241213



```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.gbm.csv --output ${PWD}/out.gbm.test3

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.menpem.csv --output ${PWD}/out.menpem.test3
```




##	20241216




Redo menpem with just blanks from plate 13

Redo GBM with just blanks from plate 1

```
awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}(NR>1 && ($20==1)){ subject=$2;sub(/_1$/,"",subject);sub(/_2$/,"",subject);sub(/dup$/,"",subject); print subject,$2,"/francislab/data1/working/20241203-Illumina-PhIP/20241203d-bowtie2/out/S"$22".VIR3_clean.1-84.bam",$5,$6,$7,$8,$9}' /francislab/data1/raw/20241204-Illumina-PhIP/L1_full_covariates_Vir3_phip-seq_GBM_p1_MENPEN_p13_12-4-24hmh.csv | sort -t, -k1,1 > manifest.gbm.csv

sed -i '1isubject,sample,bampath,type,study,group,age,sex' manifest.gbm.csv
sed -i 's/pbs blank/input/i' manifest.gbm.csv 
chmod -w manifest.gbm.csv


awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}(NR>1 && ($20==13)){ subject=$2;sub(/_1$/,"",subject);sub(/_2$/,"",subject);sub(/dup$/,"",subject); print subject,$2,"/francislab/data1/working/20241203-Illumina-PhIP/20241203d-bowtie2/out/S"$22".VIR3_clean.1-84.bam",$5,$6,$7,$8,$9}' /francislab/data1/raw/20241204-Illumina-PhIP/L1_full_covariates_Vir3_phip-seq_GBM_p1_MENPEN_p13_12-4-24hmh.csv | sort -t, -k1,1 > manifest.menpem.csv


sed -i '1isubject,sample,bampath,type,study,group,age,sex' manifest.menpem.csv
sed -i 's/PBS blank/input/i' manifest.menpem.csv
chmod -w manifest.menpem.csv
```



```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.gbm.csv --output ${PWD}/out.gbm.test4

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.menpem.csv --output ${PWD}/out.menpem.test4
```


modify merge_batches.py first to only have 1 header line.

```
./merge_batches.py --int --de_nan --out Plibs.csv out.*.test4/counts/PLib* 
head Plibs.csv
wc -l Plibs.csv 
grep -vs ",0" Plibs.csv | head

echo "id" > All4Plibs.csv
grep -vs ",0" Plibs.csv | tail -n +2 | cut -d, -f1 | sort >> All4Plibs.csv

join -t, --header All4Plibs.csv $dir/All.count.Zscores.csv | wc -l
53061
```



```
for s in menpem gbm ; do
dir=out.${s}.test4
join -t, --header All4Plibs.csv $dir/All.count.Zscores.minimums.csv > tmp0.csv
head -1 tmp0.csv > tmp1.csv
tail -q -n +2 tmp0.csv | sort -t, -k1,1 >> tmp1.csv
cat tmp1.csv | datamash transpose -t, | head -1 > tmp2.csv
cat tmp1.csv | datamash transpose -t, | tail -n +2 | sort -t, -k1,1 >> tmp2.csv
cat tmp2.csv | datamash transpose -t, > tmp3.csv
head -2 tmp3.csv > tmp4.csv
tail -n +3 tmp3.csv | sort -t, -k1,1 >> tmp4.csv
join --header -t, <( cut -d, -f1,2 /francislab/data1/refs/PhIP-Seq/VIR3_clean.virus_score.join_sorted.csv ) tmp4.csv > tmp5.csv
cat tmp5.csv | datamash transpose -t, > tmp6.csv
echo -n "y,z," > ${dir}/Zscores.minimums.filtered.csv
head -1 tmp6.csv >> ${dir}/Zscores.minimums.filtered.csv
join --header -t, <( cut -d, -f1,4,6 manifest.${s}.csv | uniq ) <( tail -n +2 tmp6.csv ) >> ${dir}/Zscores.minimums.filtered.csv
cat ${dir}/Zscores.minimums.filtered.csv | datamash transpose -t, > ${dir}/Zscores.minimums.filtered.t.csv
box_upload.bash ${dir}/Zscores.minimums.filtered*csv
done
```



##	20241218 - Z score 3.5 -> 10


Increase the Z score threshold from 3.5 to 10.


```
mkdir out.menpem.test5
mkdir out.gbm.test5
cp -r out.menpem.test4/counts/ out.menpem.test5/
cp -r out.gbm.test4/counts/ out.gbm.test5/


sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.gbm.csv --threshold 10 --output ${PWD}/out.gbm.test5

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.menpem.csv --threshold 10 --output ${PWD}/out.menpem.test5
```



```
for s in menpem gbm ; do
phip_seq_aggregate.bash manifest.${s}.csv out.${s}.test5
done
```

```
for s in menpem gbm ; do
dir=out.${s}.test5
box_upload.bash ${dir}/Zscores*csv ${dir}/seropositive*csv ${dir}/All* ${dir}/m* ${dir}/Zscores.minimums.filtered*csv 
done
```



##	20241218 B - Z-scoring drop the 1's during zscoring



```
mkdir out.menpem.test6
mkdir out.gbm.test6
cp -r out.menpem.test4/counts/ out.menpem.test6/
cp -r out.gbm.test4/counts/ out.gbm.test6/


sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.gbm.csv --threshold 10 --output ${PWD}/out.gbm.test6

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.menpem.csv --threshold 10 --output ${PWD}/out.menpem.test6
```

```
for s in menpem gbm ; do
phip_seq_aggregate.bash manifest.${s}.csv out.${s}.test6
done
```

```
for s in menpem gbm ; do
dir=out.${s}.test6
box_upload.bash ${dir}/Zscores*csv ${dir}/seropositive*csv ${dir}/All* ${dir}/m* ${dir}/Zscores.minimums.filtered*csv 
done
```


```
join -t, --header All4Plibs.csv /francislab/data1/refs/PhIP-Seq/VIR3_clean.virus_score.join_sorted.csv | cut -d, -f2 | tail -n +2 | sort | uniq -c | sed -e 's/^\s*//' -e 's/ /,/' -e '1icount,species' > All4Plibs.species_counts.csv

box_upload.bash All4Plibs.species_counts.csv
```



##	20241220 - Geno script testing



```

Case_Control_Z_Script.R --manifest manifest.gbm.csv --working_dir out.gbm.test6 --groups_to_compare case,control

Count_Viral_Tile_Hit_Fraction.R --manifest manifest.gbm.csv  --working_dir out.gbm.test6

Case_Control_Seropositivity_Frac.R --manifest manifest.gbm.csv  --working_dir out.gbm.test6 --groups_to_compare case,control

Seropositivity_Comparison.R --manifest manifest.gbm.csv  --working_dir out.gbm.test6 --groups_to_compare case,control

By_virus_plotter.R --manifest manifest.gbm.csv --working_dir out.gbm.test6 --virus "Human adenovirus E" --groups_to_compare case,control

```





```

Case_Control_Z_Script.R --manifest manifest.menpem.csv --working_dir out.menpem.test6 --groups_to_compare "PF Patient","Endemic Control","Non Endemic Control"

Count_Viral_Tile_Hit_Fraction.R --manifest manifest.menpem.csv  --working_dir out.menpem.test6

Case_Control_Seropositivity_Frac.R --manifest manifest.menpem.csv  --working_dir out.menpem.test6 --groups_to_compare "PF Patient","Endemic Control","Non Endemic Control"

Seropositivity_Comparison.R --manifest manifest.menpem.csv  --working_dir out.menpem.test6 --groups_to_compare "PF Patient","Endemic Control","Non Endemic Control"

By_virus_plotter.R --manifest manifest.menpem.csv --working_dir out.menpem.test6 --virus "Human adenovirus E" --groups_to_compare "PF Patient","Endemic Control","Non Endemic Control"


```








Prep for tensorflow

```
cut -d, -f2,6 manifest.gbm.csv | grep -E "case|control" | sort -t, -k1,1 > gbm_case_control.csv
sed -i '1isample,group' gbm_case_control.csv

cat out.gbm.test6/All.count.Zscores.csv | datamash transpose -t, > tmp1.csv
head -1 tmp1.csv > tmp2.csv
tail -n +2 tmp1.csv | sort -t, -k1,1 >> tmp2.csv

join -t, --header gbm_case_control.csv tmp2.csv > gbm.csv
```









##	20250102



```
mkdir out.menpem.test7
mkdir out.gbm.test7
cp -r out.menpem.test6/counts/ out.menpem.test7/
cp -r out.gbm.test6/counts/ out.gbm.test7/


sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.gbm.csv --threshold 10 --output ${PWD}/out.gbm.test7

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.menpem.csv --threshold 10 --output ${PWD}/out.menpem.test7
```






```
mkdir out.all
merge_all_combined_counts_files.py --int --de_nan --out out.all/Plibs.csv out.*.test7/counts/PLib* 

head out.all/Plibs.csv
wc -l out.all/Plibs.csv 
grep -vs ",0" out.all/Plibs.csv | head


echo "id" > out.all/All4Plibs.csv
grep -vs ",0" out.all/Plibs.csv | tail -n +2 | cut -d, -f1 | sort >> out.all/All4Plibs.csv

#join -t, --header out.all/All4Plibs.csv out.all/All.count.Zscores.csv | wc -l
#68955 up from ...53061

join -t, --header out.all/All4Plibs.csv /francislab/data1/refs/PhIP-Seq/VIR3_clean.virus_score.join_sorted.csv | cut -d, -f2 | tail -n +2 | sort | uniq -c | sed -e 's/^\s*//' -e 's/ /,/' -e '1icount,species' > out.all/All4Plibs.species_counts.csv
```







```
for s in menpem gbm ; do
phip_seq_aggregate.bash manifest.${s}.csv out.${s}.test7
done
```

```
for s in menpem gbm ; do
dir=out.${s}.test7
box_upload.bash ${dir}/Zscores*csv ${dir}/seropositive*csv ${dir}/All* ${dir}/m* ${dir}/Zscores.minimums.filtered*csv 
done
```




```
echo module load r\; Count_Viral_Tile_Hit_Fraction.R --manifest manifest.gbm.csv  --working_dir out.gbm.test7 > commands
echo module load r\; Case_Control_Z_Script.R --manifest manifest.gbm.csv --working_dir out.gbm.test7 -a case -b control >> commands
echo module load r\; Case_Control_Seropositivity_Frac.R --manifest manifest.gbm.csv  --working_dir out.gbm.test7 -a case -b control >> commands
echo module load r\; Seropositivity_Comparison.R --manifest manifest.gbm.csv  --working_dir out.gbm.test7 -a case -b control >> commands
while read virus ; do
echo module load r\; By_virus_plotter.R --manifest manifest.gbm.csv --working_dir out.gbm.test7 --virus \"${virus}\" --groups_to_compare case,control
done < <( tail -n +2 out.gbm.test7/merged.seropositive.csv | cut -d, -f1 ) >> commands

echo module load r\; Count_Viral_Tile_Hit_Fraction.R --manifest manifest.menpem.csv  --working_dir out.menpem.test7 >> commands

for groups in '-a "PF Patient" -b "Endemic Control"' '-a "PF Patient" -b "Non Endemic Control"' '-a "Endemic Control" -b "Non Endemic Control"' ; do
echo module load r\; Case_Control_Z_Script.R --manifest manifest.menpem.csv --working_dir out.menpem.test7 ${groups}
echo module load r\; Case_Control_Seropositivity_Frac.R --manifest manifest.menpem.csv  --working_dir out.menpem.test7 ${groups}
echo module load r\; Seropositivity_Comparison.R --manifest manifest.menpem.csv  --working_dir out.menpem.test7 ${groups}
done >> commands

while read virus ; do 
echo module load r\; By_virus_plotter.R --manifest manifest.menpem.csv --working_dir out.menpem.test7 --virus \"${virus}\" --groups_to_compare \"PF Patient\",\"Endemic Control\",\"Non Endemic Control\"
done < <( tail -n +2 out.menpem.test7/merged.seropositive.csv | cut -d, -f1 ) >> commands

commands_array_wrapper.bash --array_file commands --time 4-0 --threads 4 --mem 30G 
```



```
box_upload.bash out.*.test7/*pdf
```










##	20250103

Reprocess with zscore thresholds of 3.5 and 10.


```
mkdir out.gbm.multiz
mkdir out.menpem.multiz

ln -s ../out.gbm.test7/counts out.gbm.multiz/
ln -s ../manifest.gbm.csv out.gbm.multiz/
ln -s ../out.menpem.test7/counts out.menpem.multiz/
ln -s ../manifest.menpem.csv out.menpem.multiz/


sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.gbm.csv --thresholds 3.5,10 --output ${PWD}/out.gbm.multiz


sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.menpem.csv --thresholds 3.5,10 --output ${PWD}/out.menpem.multiz


for s in menpem gbm ; do
phip_seq_aggregate.bash manifest.${s}.csv out.${s}.multiz
done

box_upload.bash out.*.multiz/Zscores*csv out.*.multiz/seropositive*csv out.*.multiz/All* out.*.multiz/m*

```






```
\rm commands
for z in 3.5 10 ; do
 echo module load r\; Count_Viral_Tile_Hit_Fraction.R --zscore ${z} --manifest manifest.gbm.csv  --working_dir out.gbm.multiz -a case -b control
 echo module load r\; Case_Control_Z_Script.R --zscore ${z} --manifest manifest.gbm.csv --working_dir out.gbm.multiz -a case -b control
 echo module load r\; Seropositivity_Comparison.R --zscore ${z} --manifest manifest.gbm.csv  --working_dir out.gbm.multiz -a case -b control
done >> commands
while read virus ; do
 echo module load r\; By_virus_plotter.R --manifest manifest.gbm.csv --working_dir out.gbm.multiz --virus \"${virus}\" --groups_to_compare case,control
done < <( tail -q -n +2 out.gbm.multiz/merged.*.seropositive.csv | cut -d, -f1 | sort | uniq ) >> commands


for z in 3.5 10 ; do
 for groups in '-a "PF Patient" -b "Endemic Control"' '-a "PF Patient" -b "Non Endemic Control"' '-a "Endemic Control" -b "Non Endemic Control"' ; do
  echo module load r\; Count_Viral_Tile_Hit_Fraction.R --zscore ${z} --manifest manifest.menpem.csv  --working_dir out.menpem.multiz ${groups}
  echo module load r\; Case_Control_Z_Script.R --zscore ${z} --manifest manifest.menpem.csv --working_dir out.menpem.multiz ${groups}
  echo module load r\; Seropositivity_Comparison.R --zscore ${z} --manifest manifest.menpem.csv  --working_dir out.menpem.multiz ${groups}
 done
done >> commands

while read virus ; do
 echo module load r\; By_virus_plotter.R --manifest manifest.menpem.csv --working_dir out.menpem.multiz --virus \"${virus}\" --groups_to_compare \"PF Patient\",\"Endemic Control\",\"Non Endemic Control\"
done < <( tail -q -n +2 out.menpem.multiz/merged.*.seropositive.csv | cut -d, -f1 | sort | uniq ) >> commands

commands_array_wrapper.bash --array_file commands --time 4-0 --threads 4 --mem 30G


box_upload.bash out.*.multiz/Tile_Comparison* out.*.multiz/Viral_* out.*.multiz/Seropositivity* out.*.multiz/Manhattan_plots*
```



