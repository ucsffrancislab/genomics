
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


















##	20250131

* Can you try to make some PhIP-seq VZV related graphics? Like a combined (grouped by case, and grouped by control) manhattan plots, heatmaps, or volcano plots. Just trying to get at ways to visualize the data and VZV is a good place to start since that was the initial driver of the whole project.


PeptideComparison.Rmd

Need a merged manifest, Zscores.csv, All.public_epitope_annotations.Zscores.csv

Probably easier just to create a new manifest with all 4 plates (perhaps just 3?) and reprocess them

echo module load r\; By_virus_plotter.R --manifest manifest.gbm.csv --working_dir out.gbm.multiz --virus \"Human herpesvirus 3\" --groups_to_compare case,control


commands_array_wrapper.bash --array_file commands.multiz.multiplate --time 4-0 --threads 4 --mem 30G 




















