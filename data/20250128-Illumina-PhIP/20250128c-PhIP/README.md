
#	20250128-Illumina-PhIP/20250128c-PhIP

##	All

```
awk 'BEGIN{FS=OFS=","}(NR>1){subject=$3;sub(/dup$/,"",subject);s=$1;sub(/S/,"",s);s=int(s); print subject,$3,"/francislab/data1/working/20250128-Illumina-PhIP/20250128b-bowtie2/out/S"s".VIR3_clean.1-84.bam",$7,$8,$9,$11,$12,$23}' /francislab/data1/raw/20250128-Illumina-PhIP/L3_full_covariates_Vir3_phip-seq_GBM_p3_and_p4_1-28-25hmh.csv > manifest.all.csv

sed -i '1isubject,sample,bampath,type,study,group,age,sex,plate' manifest.all.csv
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
awk 'BEGIN{FS=OFS=","}(NR>1){subject=$3;sub(/dup$/,"",subject);s=$1;sub(/S/,"",s);s=int(s); print subject,$3,"/francislab/data1/working/20250128-Illumina-PhIP/20250128b-bowtie2/out/S"s".VIR3_clean.1-84.bam",$7,$8,$9,$11,$12,$23 > "manifest.plate"$23".csv" }' /francislab/data1/raw/20250128-Illumina-PhIP/L3_full_covariates_Vir3_phip-seq_GBM_p3_and_p4_1-28-25hmh.csv 

for manifest in manifest.plate*.csv ; do
sed -i '1isubject,sample,bampath,type,study,group,age,sex,plate' ${manifest}
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







##	20250203


```
for m in /francislab/data1/working/{20241224-Illumina-PhIP/20250110-PhIP,20250128-Illumina-PhIP/20250128c-PhIP}/out.plate[1234]/manifest* ; do
d=$( dirname ${m} )
echo module load r\; By_virus_plotter.R --manifest ${m} --virus \"Human herpesvirus 3\" --groups_to_compare case,control \
--output_dir ${d} \
--zfilename ${d}/Zscores.csv \
--public_eps_filename ${d}/All.public_epitope_annotations.Zscores.csv
done > commands

commands_array_wrapper.bash --array_file commands --time 4-0 --threads 4 --mem 30G 

```




```

./virus_scores.Rmd \
  -d ${PWD}/out.plate1 \
  -d ${PWD}/out.plate2 \
  -d ${PWD}/out.plate3 \
  -o ${PWD}/virus_scores3.gbm

./virus_scores.Rmd \
  -d ${PWD}/out.plate1 \
  -d ${PWD}/out.plate2 \
  -d ${PWD}/out.plate3 \
  -d ${PWD}/out.plate4 \
  -o ${PWD}/virus_scores4.gbm

./Zscores.Rmd -s "Human herpesvirus 3" \
  -d ${PWD}/out.plate1 \
  -d ${PWD}/out.plate2 \
  -d ${PWD}/out.plate3 \
  -o Zscores3.gbm.HHV3

./Zscores.Rmd -s "Human herpesvirus 3" \
  -d ${PWD}/out.plate1 \
  -d ${PWD}/out.plate2 \
  -d ${PWD}/out.plate3 \
  -d ${PWD}/out.plate4 \
  -o Zscores4.gbm.HHV3

./PeptideComparison.Rmd \
  -i ${PWD}/3plates/20250130-Multiplate_Peptide_Comparison-case-control-Prop_test_results-10.csv \
  -o Multiplate_Peptide_Comparison3

./PeptideComparison.Rmd \
  -i ${PWD}/6plates/20250130-Multiplate_Peptide_Comparison-case-control-Prop_test_results-10.csv \
  -o Multiplate_Peptide_Comparison4

```



##	20250205



```
mkdir out.all.test
tail -q -n +2 out.plate{?,??}/manifest.plate*.csv > out.all.test/tmp1.csv
sed -i '1isubject,sample,bampath,type,study,group,age,sex,plate' out.all.test/tmp1.csv
awk 'BEGIN{FS=OFS=","}{print $2,$1,$4,$5,$6,$7,$8,$9}' out.all.test/tmp1.csv > out.all.test/tmp2.csv
head -1 out.all.test/tmp2.csv > out.all.test/manifest.csv
tail -n +2 out.all.test/tmp2.csv | sort -t, -k1,1 >> out.all.test/manifest.csv
sed -i -e 's/VIR phage Library/Phage Lib/' -e 's/phage library (blank)/Phage Lib/' out.all.test/manifest.csv
chmod -w out.all.test/manifest.csv
\rm out.all.test/tmp?.csv
```



```
dir=out.all.test
Q=40
merge_all_combined_counts_files.py --de_nan --int -o ${dir}/tmp1.csv \
  out.plate{?,??}/counts/*.q${Q}.count.csv.gz out.plate{?,??}/counts/input/*.q${Q}.count.csv.gz 

cd $dir

awk -F, '{print NF}' tmp1.csv | uniq
#576

wc -l tmp1.csv 
#113826 tmp1.csv

head -1 tmp1.csv > tmp2.csv
tail -n +2 tmp1.csv | sort -t, -k1,1 >> tmp2.csv

cat tmp2.csv | datamash transpose -t, > tmp3.csv
head -1 tmp3.csv > tmp4.csv
tail -n +2 tmp3.csv | sort -t, -k1,1 >> tmp4.csv

join --header -t, manifest.csv tmp4.csv > tmp5.csv

cat tmp5.csv | datamash transpose -t, > tmp6.csv

head -7 tmp6.csv > tmp7.csv
sed -i 's/^/,,,,,,/' tmp7.csv
join --header -t, /francislab/data1/refs/PhIP-Seq/VIR3_clean.20250205.HHV3.for_joining.csv <( tail -n +8 tmp6.csv ) >> tmp7.csv

awk -F, '{print NF}' tmp7.csv | uniq
#582

wc -l tmp7.csv 
#1655 tmp7.csv

wc -l /francislab/data1/refs/PhIP-Seq/VIR3_clean.20250205.HHV3.for_joining.csv 
#1654 /francislab/data1/refs/PhIP-Seq/VIR3_clean.20250205.HHV3.for_joining.csv

head -8 tmp7.csv > tmp8.csv
tail -n +9 tmp7.csv | sort -t, -k2,2 -k3,3 -k4n,4 -k5n,5 -k6n,6 >> tmp8.csv

wc -l tmp8.csv 
#1655 tmp8.csv

awk -F, '{print NF}' tmp8.csv | uniq
#582

head -12 tmp8.csv | cut -c1-110
#,,,,,,sample,024JCM,024JCMdup,043MPL,043MPLdup,074KBP,074KBPdup,101VKC,101VKCdup,1301,1301dup,1302,1302dup,130
#,,,,,,subject,024JCM,024JCM,043MPL,043MPL,074KBP,074KBP,101VKC,101VKC,1301,1301,1302,1302,1303,1303,1304,1304,
#,,,,,,type,pemphigus serum,pemphigus serum,pemphigus serum,pemphigus serum,pemphigus serum,pemphigus serum,pem
#,,,,,,study,PEMS,PEMS,PEMS,PEMS,PEMS,PEMS,PEMS,PEMS,MENS,MENS,MENS,MENS,MENS,MENS,MENS,MENS,MENS,MENS,MENS,MEN
#,,,,,,group,Non Endemic Control,Non Endemic Control,Non Endemic Control,Non Endemic Control,Non Endemic Contro
#,,,,,,age,62,62,61,61,44,44,46,46,33,33,67,67,61,61,60,60,54,54,72,72,50,50,65,65,51,51,39,39,46,46,39,39,50,5
#,,,,,,sex,M,M,F,F,F,F,F,F,F,F,M,M,M,M,M,M,F,F,M,M,M,M,F,F,F,F,F,F,M,M,F,F,M,M,M,M,M,M,F,F,M,M,M,M,F,F,F,F,F,F,
#id,Species,Protein names,Version (entry),Version (sequence),start,end,14,14,13,13,14,14,13,13,13,13,13,13,13,1
#25844,Human herpesvirus 3,Alkaline nuclease (EC 3.1.-.-),47.0,1.0,1,56,2,0,1,0,11,7,0,27,3,2,1,3,0,0,0,3,0,4,0
#25848,Human herpesvirus 3,Alkaline nuclease (EC 3.1.-.-),47.0,1.0,113,168,0,0,2,0,0,0,0,0,1,4,3,8,1,0,1,1,0,18
#25849,Human herpesvirus 3,Alkaline nuclease (EC 3.1.-.-),47.0,1.0,141,196,0,28,93,8,0,4,0,0,13,2,43,1,25,5,19,
#25850,Human herpesvirus 3,Alkaline nuclease (EC 3.1.-.-),47.0,1.0,169,224,0,0,3,14,2,2,3,6,5,8,5,21,3,2,0,14,0
```






