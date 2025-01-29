
#	20250128-Illumina-PhIP/20250128c-PhIP

##	All


```
awk 'BEGIN{FS=OFS=","}(NR>1){subject=$5;sub(/-1$/,"",subject);sub(/-2$/,"",subject);sub(/_1$/,"",subject);sub(/_2$/,"",subject);sub(/dup$/,"",subject);s=$7;sub(/IDX/,"",s);s=int(s); print subject,$5,"/francislab/data1/working/20250128-Illumina-PhIP/20250128b-bowtie2/out/S"s".VIR3_clean.1-84.bam",$4,$14,$15,$16,$17}' /francislab/data1/raw/20250128-Illumina-PhIP/manifest.csv > manifest.all.csv

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


join -t, --header out.all/All4Plibs.csv out.all/All.count.Zscores.csv | wc -l
#68955 up from ...53061

join -t, --header out.all/All4Plibs.csv /francislab/data1/refs/PhIP-Seq/VIR3_clean.virus_score.join_sorted.csv | cut -d, -f2 | tail -n +2 | sort | uniq -c | sed -e 's/^\s*//' -e 's/ /,/' -e '1icount,species' > out.all/All4Plibs.species_counts.csv

box_upload.bash out.all/Plibs.csv out.all/All4Plibs.csv out.all/All4Plibs.species_counts.csv
```

























##	GBM (All of plate 2)


```
awk 'BEGIN{FS=OFS=","}(NR>1 && $1 == 2 ){subject=$5;sub(/-1$/,"",subject);sub(/-2$/,"",subject);sub(/_1$/,"",subject);sub(/_2$/,"",subject);sub(/dup$/,"",subject);s=$7;sub(/IDX/,"",s);s=int(s); print subject,$5,"/francislab/data1/working/20241224-Illumina-PhIP/20241224b-bowtie2/out/S"s".VIR3_clean.1-84.bam",$4,$14,$15,$16,$17}' /francislab/data1/raw/20241224-Illumina-PhIP/manifest.csv > manifest.gbm.csv

sed -i '1isubject,sample,bampath,type,study,group,age,sex' manifest.gbm.csv
sed -i 's/,PBS blank,/,input,/' manifest.gbm.csv
chmod -w manifest.gbm.csv



sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.gbm.csv --threshold 10 --output ${PWD}/out.gbm

```


Prep for tensorflow testing
```
cut -d, -f2,6 manifest.gbm.csv | grep -E "case|control" | sort -t, -k1,1 > gbm_case_control.csv
sed -i '1isample,group' gbm_case_control.csv

cat out.gbm/All.count.Zscores.csv | datamash transpose -t, > tmp1.csv
head -1 tmp1.csv > tmp2.csv
tail -n +2 tmp1.csv | sort -t, -k1,1 >> tmp2.csv

join -t, --header gbm_case_control.csv tmp2.csv > gbm.csv


./predict_gbm_case_control_2.Rmd
```


```
dir=out.gbm

#	make sure manifest has the right columns in the right places
phip_seq_aggregate.bash manifest.gbm.csv ${dir}

box_upload.bash ${dir}/Zscores*csv ${dir}/seropositive*csv ${dir}/All* ${dir}/m* ${dir}/Zscores.minimums.filtered*csv 

```




```
echo module load r\; Case_Control_Z_Script.R --manifest manifest.gbm.csv --working_dir out.gbm --groups_to_compare case,control > commands.gbm
echo module load r\; Count_Viral_Tile_Hit_Fraction.R --manifest manifest.gbm.csv  --working_dir out.gbm >> commands.gbm
echo module load r\; Case_Control_Seropositivity_Frac.R --manifest manifest.gbm.csv  --working_dir out.gbm --groups_to_compare case,control >> commands.gbm
echo module load r\; Seropositivity_Comparison.R --manifest manifest.gbm.csv  --working_dir out.gbm --groups_to_compare case,control >> commands.gbm
while read virus ; do
echo module load r \; By_virus_plotter.R --manifest manifest.gbm.csv --working_dir out.gbm --virus \"${virus}\" --groups_to_compare case,control
done < <( tail -n +2 out.gbm/merged.seropositive.csv | cut -d, -f1 ) >> commands.gbm

commands_array_wrapper.bash --array_file commands.gbm --time 4-0 --threads 4 --mem 30G 
```




```
dir=out.gbm
box_upload.bash ${dir}/Tile_Comparison* ${dir}/Viral_* ${dir}/Seropositivity* ${dir}/Manhattan_plots*
```






##	Men Pem (All of plate 14)


```
awk 'BEGIN{FS=OFS=","}(NR>1 && $1 == 14 ){subject=$5;sub(/-1$/,"",subject);sub(/-2$/,"",subject);sub(/_1$/,"",subject);sub(/_2$/,"",subject);sub(/dup$/,"",subject);s=$7;sub(/IDX/,"",s);s=int(s); print subject,$5,"/francislab/data1/working/20241224-Illumina-PhIP/20241224b-bowtie2/out/S"s".VIR3_clean.1-84.bam",$4,$14,$15,$16,$17}' /francislab/data1/raw/20241224-Illumina-PhIP/manifest.csv > manifest.menpem.csv

sed -i '1isubject,sample,bampath,type,study,group,age,sex' manifest.menpem.csv
sed -i 's/,PBS blank,/,input,/' manifest.menpem.csv
chmod -w manifest.menpem.csv


sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.menpem.csv --threshold 10 --output ${PWD}/out.menpem

```


```
dir=out.menpem

#	make sure manifest has the right columns in the right places
phip_seq_aggregate.bash manifest.menpem.csv ${dir}

box_upload.bash ${dir}/Zscores*csv ${dir}/seropositive*csv ${dir}/All* ${dir}/m* ${dir}/Zscores.minimums.filtered*csv 

```




The only way that I could get this to work is piping to sh. No matter what I did, R would break the
arguments as `-a "PF` and `Patient"`

```
module load r

Count_Viral_Tile_Hit_Fraction.R --manifest manifest.menpem.csv  --working_dir out.menpem

for groups in '-a "PF Patient" -b "Endemic Control"' '-a "PF Patient" -b "Non Endemic Control"' '-a "Endemic Control" -b "Non Endemic Control"' ; do
echo $groups
echo Case_Control_Z_Script.R --manifest manifest.menpem.csv --working_dir out.menpem ${groups} | sh
echo Case_Control_Seropositivity_Frac.R --manifest manifest.menpem.csv  --working_dir out.menpem ${groups} | sh
echo Seropositivity_Comparison.R --manifest manifest.menpem.csv  --working_dir out.menpem ${groups} | sh
done

while read virus ; do 
echo $virus
By_virus_plotter.R --manifest manifest.menpem.csv --working_dir out.menpem --virus "${virus}" --groups_to_compare "PF Patient","Endemic Control","Non Endemic Control"
done < <( tail -n +2 out.menpem/merged.seropositive.csv | cut -d, -f1 )

```


```
dir=out.menpem
box_upload.bash ${dir}/Tile_Comparison* ${dir}/Viral_* ${dir}/Seropositivity* ${dir}/Manhattan_plots*
```




For meningioma, we can compare them to the AGS controls and the GBM cases. (We are going to need to add batch to these models)













##	QC run

All blanks, commercial serum and PLibs

```
head -1 manifest.all.csv > manifest.qc.csv
grep "commercial serum" manifest.all.csv >> manifest.qc.csv
grep "phage library" manifest.all.csv >> manifest.qc.csv
grep blank manifest.all.csv >> manifest.qc.csv


sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.qc.csv --threshold 10 --output ${PWD}/out.qc

```


```
dir=out.qc
box_upload.bash ${dir}/Zscores*csv ${dir}/seropositive*csv ${dir}/All* ${dir}/m* ${dir}/Zscores.minimums.filtered*csv 
```







##	20250102


Testing new scripts from Geno

```
ln -s ../manifest.gbm.csv out.gbm/
ln -s ../manifest.menpem.csv out.menpem/

ln -s ../manifest.gbm.csv /francislab/data1/working/20241204-Illumina-PhIP/20241204c-PhIP/out.gbm.test7/
ln -s ../manifest.menpem.csv /francislab/data1/working/20241204-Illumina-PhIP/20241204c-PhIP/out.menpem.test7/

```


```
\rm commands.multiplate

echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -a case -b control -o ${PWD}/MultiPlate -p /francislab/data1/working/20241204-Illumina-PhIP/20241204c-PhIP/out.gbm.test7,${PWD}/out.gbm >> commands.multiplate
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -a case -b control -o ${PWD}/MultiPlate -p /francislab/data1/working/20241204-Illumina-PhIP/20241204c-PhIP/out.gbm.test7,${PWD}/out.gbm >> commands.multiplate
for groups in '-a "PF Patient" -b "Endemic Control"' '-a "PF Patient" -b "Non Endemic Control"' '-a "Endemic Control" -b "Non Endemic Control"' ; do
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R ${groups} -o ${PWD}/MultiPlate -p /francislab/data1/working/20241204-Illumina-PhIP/20241204c-PhIP/out.menpem.test7,${PWD}/out.menpem >> commands.multiplate
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R ${groups} -o ${PWD}/MultiPlate -p /francislab/data1/working/20241204-Illumina-PhIP/20241204c-PhIP/out.menpem.test7,${PWD}/out.menpem >> commands.multiplate
done

echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 10 -a case -b control -o ${PWD}/MultiPlate -p /francislab/data1/working/20241204-Illumina-PhIP/20241204c-PhIP/out.gbm.test7,${PWD}/out.gbm >> commands.multiplate
for groups in '-a "PF Patient" -b "Endemic Control"' '-a "PF Patient" -b "Non Endemic Control"' '-a "Endemic Control" -b "Non Endemic Control"' ; do
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 10 ${groups} -o ${PWD}/MultiPlate -p /francislab/data1/working/20241204-Illumina-PhIP/20241204c-PhIP/out.menpem.test7,${PWD}/out.menpem >> commands.multiplate
done

commands_array_wrapper.bash --array_file commands.multiplate --time 4-0 --threads 4 --mem 30G 
```











##	20250103

Reprocess with zscore thresholds of 3.5 and 10.



```
mkdir out.gbm.multiz
mkdir out.menpem.multiz

ln -s ../out.gbm/counts out.gbm.multiz/
ln -s ../manifest.gbm.csv out.gbm.multiz/
ln -s ../out.menpem/counts out.menpem.multiz/
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
  echo module load r\; Case_Control_Z_Script.R --zscore ${z} --manifest manifest.menpem.csv --working_dir out.menpem.multiz ${groups}
  echo module load r\; Count_Viral_Tile_Hit_Fraction.R --zscore ${z} --manifest manifest.menpem.csv  --working_dir out.menpem.multiz ${groups}
  echo module load r\; Seropositivity_Comparison.R --zscore ${z} --manifest manifest.menpem.csv  --working_dir out.menpem.multiz ${groups}
 done
done >> commands

while read virus ; do
 echo module load r\; By_virus_plotter.R --manifest manifest.menpem.csv --working_dir out.menpem.multiz --virus \"${virus}\" --groups_to_compare \"PF Patient\",\"Endemic Control\",\"Non Endemic Control\"
done < <( tail -q -n +2 out.menpem.multiz/merged.*.seropositive.csv | cut -d, -f1 | sort | uniq ) >> commands

commands_array_wrapper.bash --array_file commands --time 4-0 --threads 4 --mem 30G



box_upload.bash out.*.multiz/Tile_Comparison* out.*.multiz/Viral_* out.*.multiz/Seropositivity* out.*.multiz/Manhattan_plots*

```







```
\rm commands.multiz.multiplate

for z in 3.5 10 ; do

 echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control -o ${PWD}/MultiZMultiPlate -p /francislab/data1/working/20241204-Illumina-PhIP/20241204c-PhIP/out.gbm.multiz,${PWD}/out.gbm.multiz

 echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} -a case -b control -o ${PWD}/MultiZMultiPlate -p /francislab/data1/working/20241204-Illumina-PhIP/20241204c-PhIP/out.gbm.multiz,${PWD}/out.gbm.multiz

 for groups in '-a "PF Patient" -b "Endemic Control"' '-a "PF Patient" -b "Non Endemic Control"' '-a "Endemic Control" -b "Non Endemic Control"' ; do
  echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} ${groups} -o ${PWD}/MultiZMultiPlate -p /francislab/data1/working/20241204-Illumina-PhIP/20241204c-PhIP/out.menpem.multiz,${PWD}/out.menpem.multiz
  echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} ${groups} -o ${PWD}/MultiZMultiPlate -p /francislab/data1/working/20241204-Illumina-PhIP/20241204c-PhIP/out.menpem.multiz,${PWD}/out.menpem.multiz
 done

done >> commands.multiz.multiplate

commands_array_wrapper.bash --array_file commands.multiz.multiplate --time 4-0 --threads 4 --mem 30G 

box_upload.bash MultiZMultiPlate/*
```



