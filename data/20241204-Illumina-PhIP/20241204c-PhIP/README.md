
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
mkdir merging

for i in 1 2 3 4 ; do
echo $i
echo out.gbm${i}/merged.seropositive.csv
head -1 out.gbm${i}/merged.seropositive.csv | sed -e '1s/\(,[^,]*\)_./\1/g' -e '1s/^id/subject/' > merging/${i}.merged.seropositive.csv
sed -e '1s/\(,[^,]*\)/\1'${i}'/g' out.gbm${i}/merged.seropositive.csv >> merging/${i}.merged.seropositive.csv
done

./merge_batches.py --int -o tmp.csv merging/*.merged.seropositive.csv
cat tmp.csv | datamash transpose -t, | head -1 > tmp2.csv
cat tmp.csv | datamash transpose -t, | tail -n +2 | sort -t, -k1,2 >> tmp2.csv

join --header -t, <( cut -d, -f1,4 manifest.gbm.csv | uniq ) tmp2.csv > seropositive.csv
join --header -t, <( cut -d, -f1,4 manifest.gbm.csv | uniq ) tmp2.csv | datamash transpose -t, > seropositive.t.csv

box_upload.bash seropositive*csv
```

seropositive is the virus score if greater than threshold




##	20241205


head out.gbm1/All.count.Zscores.reordered.join_sorted.csv | cut -c1-80

id,14431-01dup,14431-01,14471-01dup,14471-01,14566-01dup,14566-01,14627-01dup,14
10,-0.233462745877358,-0.224821641105051,-0.27853623966324,-0.289140603346513,-0
100,0.0247620530719089,-0.221414554978616,-0.338121960601749,-0.365598035061799,
1000,-0.141472987181561,,-0.08086901385478,-0.0695070842896433,-0.24334765008192
10000,34.6024345740261,-0.17006048027559,-0.185936172283737,-0.19126377708827,-0
10001,-0.174151440310927,-0.0413738594212227,-0.13124434193584,-0.12433779986168




```
mkdir merging

for i in 1 2 3 4 ; do
echo $i
echo out.gbm${i}/All.count.Zscores.reordered.join_sorted.csv
head -1 out.gbm${i}/All.count.Zscores.reordered.join_sorted.csv | sed -e '1s/dup//g' -e '1s/^id/subject/' > merging/${i}.All.count.Zscores.reordered.join_sorted.csv
head -1 out.gbm${i}/All.count.Zscores.reordered.join_sorted.csv | sed -e '1s/\(,[^,]*\)/\1_'${i}'/g' >> merging/${i}.All.count.Zscores.reordered.join_sorted.csv
tail -q -n +2 out.gbm${i}/All.count.Zscores.reordered.join_sorted.csv | sort -t, -k1,1 >> merging/${i}.All.count.Zscores.reordered.join_sorted.csv
done

./merge_batches.py --int -o tmp.csv merging/*.All.count.Zscores.reordered.join_sorted.csv
cat tmp.csv | datamash transpose -t, | head -1 > tmp2.csv
cat tmp.csv | datamash transpose -t, | tail -n +2 | sort -t, -k1,2 >> tmp2.csv

join --header -t, <( cut -d, -f1,4 manifest.gbm.csv | uniq ) tmp2.csv > Zscores.csv
join --header -t, <( cut -d, -f1,4 manifest.gbm.csv | uniq ) tmp2.csv | datamash transpose -t, > Zscores.t.csv

box_upload.bash Zscores*csv
```






