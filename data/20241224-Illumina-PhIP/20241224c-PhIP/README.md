
#	20241224-Illumina-PhIP/20241224c-PhIP


##	All

```
#awk 'BEGIN{FS=OFS=","}(NR>1){subject=$2;sub(/-1$/,"",subject);sub(/-2$/,"",subject);sub(/_1$/,"",subject);sub(/_2$/,"",subject);sub(/dup$/,"",subject); print subject,$2,"/francislab/data1/working/20241224-Illumina-PhIP/20241224b-bowtie2/out/"$1".VIR3_clean.1-84.bam","uktype","ukstudy","ukgroup","ukage","uksex"}' /francislab/data1/raw/20241224-Illumina-PhIP/manifest.csv > manifest.all.csv

##sed -i '1isubject,sample,bampath,type' manifest.all.csv
#sed -i '1isubject,sample,bampath,type,study,group,age,sex' manifest.all.csv
#sed -i '/Blank/s/uktype/input/' manifest.all.csv 
#chmod -w manifest.all.csv
```


```
awk 'BEGIN{FS=OFS=","}(NR>1){subject=$5;sub(/-1$/,"",subject);sub(/-2$/,"",subject);sub(/_1$/,"",subject);sub(/_2$/,"",subject);sub(/dup$/,"",subject);s=$7;sub(/IDX/,"",s);s=int(s); print subject,$5,"/francislab/data1/working/20241224-Illumina-PhIP/20241224b-bowtie2/out/S"s".VIR3_clean.1-84.bam",$4,$14,$15,$16,$17}' /francislab/data1/raw/20241224-Illumina-PhIP/manifest.csv > manifest.all.csv

sed -i '1isubject,sample,bampath,type,study,group,age,sex' manifest.all.csv
sed -i 's/,PBS blank,/,input,/' manifest.all.csv
chmod -w manifest.all.csv

```



```
mkdir logs/
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.all.csv --threshold 10 --output ${PWD}/out.all

```


```
merge_all_combined_counts_files.py --int --de_nan --out out.all/Plibs.csv out.all/counts/PLib* 

head out.all/Plibs.csv
wc -l out.all/Plibs.csv 
grep -vs ",0" out.all/Plibs.csv | head


echo "id" > out.all/All4Plibs.csv
grep -vs ",0" out.all/Plibs.csv | tail -n +2 | cut -d, -f1 | sort >> out.all/All4Plibs.csv
```

##	GBM

```
head -1 manifest.all.csv > manifest.gbm.csv
grep glioma manifest.all.csv >> manifest.gbm.csv
grep blank manifest.all.csv >> manifest.gbm.csv

mkdir out.gbm
ln -s ../out.all/counts out.gbm/

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.gbm.csv --threshold 10 --output ${PWD}/out.gbm

```


```
dir=out.gbm
join -t, --header out.all/All4Plibs.csv out.all/All.count.Zscores.csv | wc -l
#68955 up from ...53061

join -t, --header out.all/All4Plibs.csv /francislab/data1/refs/PhIP-Seq/VIR3_clean.virus_score.join_sorted.csv | cut -d, -f2 | tail -n +2 | sort | uniq -c | sed -e 's/^\s*//' -e 's/ /,/' -e '1icount,species' > out.all/All4Plibs.species_counts.csv

box_upload.bash out.all/Plibs.csv out.all/All4Plibs.csv out.all/All4Plibs.species_counts.csv

#	make sure manifest has the right columns in the right places
phip_seq_aggregate.bash manifest.gbm.csv ${dir}

dir=out.gbm
box_upload.bash ${dir}/Zscores*csv ${dir}/seropositive*csv ${dir}/All* ${dir}/m* ${dir}/Zscores.minimums.filtered*csv 

```



```
module load r

Case_Control_Z_Script.R --manifest manifest.gbm.csv --working_dir out.gbm --groups_to_compare case,control

Count_Viral_Tile_Hit_Fraction.R --manifest manifest.gbm.csv  --working_dir out.gbm

Case_Control_Seropositivity_Frac.R --manifest manifest.gbm.csv  --working_dir out.gbm --groups_to_compare case,control

Seropositivity_Comparison.R --manifest manifest.gbm.csv  --working_dir out.gbm --groups_to_compare case,control

By_virus_plotter.R --manifest manifest.gbm.csv --working_dir out.gbm --virus "Human adenovirus E" --groups_to_compare case,control
```















##	QC run

All blanks, commercial serum and PLibs

```
head -1 manifest.all.csv > manifest.qc.csv
grep "commercial serum" manifest.all.csv >> manifest.qc.csv
grep "phage library" manifest.all.csv >> manifest.qc.csv
grep blank manifest.all.csv >> manifest.qc.csv

mkdir out.qc
ln -s ../out.all/counts out.qc/

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.qc.csv --threshold 10 --output ${PWD}/out.qc

```


```
dir=out.qc
box_upload.bash ${dir}/Zscores*csv ${dir}/seropositive*csv ${dir}/All* ${dir}/m* ${dir}/Zscores.minimums.filtered*csv 
```














---


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





