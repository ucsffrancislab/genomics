
#	20250128-Illumina-PhIP/20250128c-PhIP

##	All

```
awk 'BEGIN{FS=OFS=","}(NR>1){subject=$3;sub(/dup$/,"",subject);s=$1;sub(/S/,"",s);s=int(s); print subject,$3,"/francislab/data1/working/20250128-Illumina-PhIP/20250128b-bowtie2/out/S"s".VIR3_clean.1-84.bam",$7,$8,$9,$11,$12}' /francislab/data1/raw/20250128-Illumina-PhIP/L3_full_covariates_Vir3_phip-seq_GBM_p3_and_p4_1-28-25hmh.csv > manifest.all.csv

sed -i '1isubject,sample,bampath,type,study,group,age,sex' manifest.all.csv
sed -i 's/,PBS blank,/,input,/' manifest.all.csv
chmod -w manifest.all.csv

```

```
#mkdir logs/
#sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
#  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
#  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
#  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.all.csv --threshold 10 --output ${PWD}/out.all
```





##	Per Plate


```
awk 'BEGIN{FS=OFS=","}(NR>1){subject=$3;sub(/dup$/,"",subject);s=$1;sub(/S/,"",s);s=int(s); print subject,$3,"/francislab/data1/working/20250128-Illumina-PhIP/20250128b-bowtie2/out/S"s".VIR3_clean.1-84.bam",$7,$8,$9,$11,$12 > "manifest.plate"$23".csv" }' /francislab/data1/raw/20250128-Illumina-PhIP/L3_full_covariates_Vir3_phip-seq_GBM_p3_and_p4_1-28-25hmh.csv 

for manifest in manifest.plate*.csv ; do
sed -i '1isubject,sample,bampath,type,study,group,age,sex' ${manifest}
sed -i 's/,PBS blank,/,input,/' ${manifest}
chmod -w ${manifest}
done

```


```
for manifest in manifest.plate*.csv ; do
num=${manifest%.csv}
num=${num#manifest.plate}
echo $num

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq_plate${num} --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --thresholds 3.5,10  \
  --manifest ${PWD}/${manifest} --output ${PWD}/out.plate${num}

done
```




```
for manifest in manifest.plate*.csv ; do
  plate=${manifest%.csv}
  plate=${plate#manifest.plate}
  echo $plate
  cp ${manifest} out.plate${plate}/
  phip_seq_aggregate.bash ${manifest} out.plate${plate}/
  box_upload.bash out.plate${plate}/Zscores*csv out.plate${plate}/seropositive*csv out.plate${plate}/All* out.plate${plate}/m*
done
```






```
mkdir out.all
merge_all_combined_counts_files.py --int --de_nan --out out.all/Plibs.csv out.plate*/counts/PLib*

tail -n +2 out.all/Plibs.csv | cut -d, -f1 | sort > out.all/Plibs.id.csv
sed -i '1iid' out.all/Plibs.id.csv

grep -vs ",0" out.all/Plibs.csv | tail -n +2 | cut -d, -f1 | sort > out.all/All4Plibs.csv
sed -i '1iid' out.all/All4Plibs.csv


#join -t, --header out.all/All4Plibs.csv out.all/All.count.Zscores.csv | wc -l
#68955 up from ...53061
#	35002 - way down

join -t, --header out.all/All4Plibs.csv /francislab/data1/refs/PhIP-Seq/VIR3_clean.virus_score.join_sorted.csv | cut -d, -f2 | tail -n +2 | sort | uniq -c | sed -e 's/^\s*//' -e 's/ /,/' -e '1icount,species' > out.all/All4Plibs.species_counts.csv

box_upload.bash out.all/Plibs.csv out.all/All4Plibs.csv out.all/All4Plibs.species_counts.csv

for manifest in manifest.plate*.csv ; do
  plate=${manifest%.csv}
  plate=${plate#manifest.plate}

  head -2 out.plate${plate}/Zscores.t.csv > out.plate${plate}/Zscores.select.t.csv
  join --header -t, out.all/Plibs.id.csv <( tail -n +3 out.plate${plate}/Zscores.t.csv ) >> out.plate${plate}/Zscores.select.t.csv
  cat out.plate${plate}/Zscores.select.t.csv | datamash transpose -t, > out.plate${plate}/Zscores.select.csv

  head -2 out.plate${plate}/Zscores.minimums.t.csv > out.plate${plate}/Zscores.select.minimums.t.csv
  join --header -t, out.all/Plibs.id.csv <( tail -n +3 out.plate${plate}/Zscores.minimums.t.csv ) >> out.plate${plate}/Zscores.select.minimums.t.csv
  cat out.plate${plate}/Zscores.select.minimums.t.csv | datamash transpose -t, > out.plate${plate}/Zscores.select.minimums.csv

done

box_upload.bash out.plate*/Zscores.select{.t,}.csv out.plate*/Zscores.select.minimums{.t,}.csv

```











```
\rm commands
for manifest in manifest.plate*.csv ; do
 plate=${manifest%.csv}
 plate=${plate#manifest.plate}
for z in 3.5 10 ; do
 echo module load r\; Count_Viral_Tile_Hit_Fraction.R --zscore ${z} --manifest ${manifest}  --output_dir out.plate${plate} -a case -b control --zfilename out.plate${plate}/Zscores.select.csv
 echo module load r\; Case_Control_Z_Script.R --zscore ${z} --manifest ${manifest} --output_dir out.plate${plate} -a case -b control --zfilename out.plate${plate}/Zscores.select.csv
 echo module load r\; Seropositivity_Comparison.R --zscore ${z} --manifest ${manifest}  --output_dir out.plate${plate} -a case -b control --sfilename out.plate${plate}/seropositive.${z}.csv
done ; done >> commands

commands_array_wrapper.bash --array_file commands --time 4-0 --threads 4 --mem 30G
```


```
box_upload.bash out.plate*/{Seropositivity,Tile_Comparison,Viral}*
```









```
\rm commands
plates=$( ls -d ${PWD}/out.plate* | paste -sd, | sed 's/,/ -p /g' )
for z in 3.5 10 ; do

echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} -a case -b control -o ${PWD}/Recent2Plates -p ${plates}

echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select.csv -o ${PWD}/Recent2Plates -p ${plates}

echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} -a case -b control --sfile_basename seropositive.${z}.csv -o ${PWD}/Recent2Plates -p ${plates}

done >> commands

commands_array_wrapper.bash --array_file commands --time 4-0 --threads 4 --mem 30G
```

```
box_upload.bash Recent2Plates/*
```



```
mkdir out.6plates
merge_all_combined_counts_files.py --int --de_nan --out out.6plates/Plibs.csv /francislab/data1/working/{20241224-Illumina-PhIP/20250110-PhIP,20250128-Illumina-PhIP/20250128c-PhIP}/out.plate{?,??}/counts/PLib*

tail -n +2 out.6plates/Plibs.csv | cut -d, -f1 | sort > out.6plates/Plibs.id.csv
sed -i '1iid' out.6plates/Plibs.id.csv

```

```
for manifest in $( ls -1 /francislab/data1/working/{20241224-Illumina-PhIP/20250110-PhIP,20250128-Illumina-PhIP/20250128c-PhIP}/out.plate{?,??}/manifest.plate*.csv 2> /dev/null ) ; do
  echo $manifest
  plate=$( basename $manifest .csv )
  plate=${plate#manifest.plate}

	dir=$( dirname ${manifest} )

  head -2 ${dir}/Zscores.t.csv > ${dir}/Zscores.select6.t.csv
  join --header -t, out.6plates/Plibs.id.csv <( tail -n +3 ${dir}/Zscores.t.csv ) >> ${dir}/Zscores.select6.t.csv
  cat ${dir}/Zscores.select6.t.csv | datamash transpose -t, > ${dir}/Zscores.select6.csv

  box_upload.bash ${dir}/Zscores.select6{.t,}.csv
done


```



Which Zscore.select? The same tiles for all runs?


```
\rm commands

plates=$( ls -d /francislab/data1/working/{20241224-Illumina-PhIP/20250110-PhIP,20250128-Illumina-PhIP/20250128c-PhIP}/out.plate{?,??} 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )

for z in 3.5 10 ; do

echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} -a case -b control -o ${PWD}/6plates -p ${plates}

echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select6.csv -o ${PWD}/6plates -p ${plates}

echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} -a case -b control --sfile_basename seropositive.${z}.csv -o ${PWD}/6plates -p ${plates}

done >> commands

commands_array_wrapper.bash --array_file commands --time 4-0 --threads 4 --mem 30G
```

```
box_upload.bash 6plates/*
```








```
mkdir out.3plates
merge_all_combined_counts_files.py --int --de_nan --out out.3plates/Plibs.csv /francislab/data1/working/{20241224-Illumina-PhIP/20250110-PhIP,20250128-Illumina-PhIP/20250128c-PhIP}/out.plate[123]/counts/PLib*

tail -n +2 out.3plates/Plibs.csv | cut -d, -f1 | sort > out.3plates/Plibs.id.csv
sed -i '1iid' out.3plates/Plibs.id.csv

```

```
for manifest in $( ls -1 /francislab/data1/working/{20241224-Illumina-PhIP/20250110-PhIP,20250128-Illumina-PhIP/20250128c-PhIP}/out.plate[123]/manifest.plate[123].csv 2> /dev/null ) ; do
  echo $manifest
  plate=$( basename $manifest .csv )
  plate=${plate#manifest.plate}

	dir=$( dirname ${manifest} )

  head -2 ${dir}/Zscores.t.csv > ${dir}/Zscores.select3.t.csv
  join --header -t, out.3plates/Plibs.id.csv <( tail -n +3 ${dir}/Zscores.t.csv ) >> ${dir}/Zscores.select3.t.csv
  cat ${dir}/Zscores.select3.t.csv | datamash transpose -t, > ${dir}/Zscores.select3.csv

  box_upload.bash ${dir}/Zscores.select3{.t,}.csv
done
```


```
\rm commands

plates=$( ls -d /francislab/data1/working/{20241224-Illumina-PhIP/20250110-PhIP,20250128-Illumina-PhIP/20250128c-PhIP}/out.plate[123] 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )

for z in 3.5 10 ; do

echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} -a case -b control -o ${PWD}/3plates -p ${plates}

echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select3.csv -o ${PWD}/3plates -p ${plates}

echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} -a case -b control --sfile_basename seropositive.${z}.csv -o ${PWD}/3plates -p ${plates}

done >> commands

commands_array_wrapper.bash --array_file commands --time 4-0 --threads 4 --mem 30G
```

```
box_upload.bash 3plates/*
```

























---









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



