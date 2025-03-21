
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

mv tmp8.csv HHV3.csv


head -7 tmp6.csv > tmp7.csv
sed -i 's/^/,,,,,,/' tmp7.csv
join --header -t, /francislab/data1/refs/PhIP-Seq/VIR3_clean.20250207.for_joining.csv <( tail -n +8 tmp6.csv ) >> tmp7.csv

awk -F, '{print NF}' tmp7.csv | uniq
#582

wc -l tmp7.csv 
#126324 tmp7.csv

wc -l /francislab/data1/refs/PhIP-Seq/VIR3_clean.20250207.for_joining.csv 
#128258 /francislab/data1/refs/PhIP-Seq/VIR3_clean.20250207.for_joining.csv

#	lose almost 2000

head -8 tmp7.csv > ALL.csv
tail -n +9 tmp7.csv | sort -t, -k2,2 -k3,3 -k4n,4 -k5n,5 -k6n,6 >> ALL.csv
```



##	20250211

```
dir=out.all.test
cd $dir
./merge_zscores.py -o tmp1.csv ../out.plate{?,??}/All.count.Zscores.csv

head -1 tmp1.csv > tmp2.csv
tail -n +2 tmp1.csv | sort -t, -k1,1 >> tmp2.csv

cat tmp2.csv | datamash transpose -t, > tmp3.csv

head -1 tmp3.csv > tmp4.csv
tail -n +2 tmp3.csv | sort -t, -k1,1 >> tmp4.csv

join --header -t, manifest.csv tmp4.csv > tmp5.csv

cat tmp5.csv | datamash transpose -t, > zscores.csv
```


##	20250212

```
./heatmap.Rmd -i /francislab/data1/working/20250128-Illumina-PhIP/20250128c-PhIP/out.all.test/ALL.csv -o ALL

./heatmap.Rmd -i /francislab/data1/working/20250128-Illumina-PhIP/20250128c-PhIP/out.all.test/cpm_blank_subtracted.csv -o cpm_blank_subtracted

./heatmap.Rmd -i /francislab/data1/working/20250128-Illumina-PhIP/20250128c-PhIP/out.all.test/cpm_blank_subtracted.csv -o glioma_cpm_blank_subtracted
```


##	20250214


Create a Zscores file from multiple plates to run in the multiplate script rather than rewrite the multiplate script

Then create a CPM file to use the same way.

Just needs index with sample and column rows with id and species and a manifest file.
The metadata comes from the manifest file and not the data file.

```
head -1 zscores.csv > tmp1.csv
tail -n +9 zscores.csv >> tmp1.csv

cut -d, -f1,2 /francislab/data1/refs/PhIP-Seq/VIR3_clean.20250207.for_joining.csv > tmp2.csv
join --header -t, tmp2.csv tmp1.csv > tmp3.csv

join --header -t, ../out.3plates/Plibs.id.csv tmp3.csv > tmp4.csv

cat tmp4.csv | datamash transpose -t, > tmp5.csv


sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=test1 --time=1-0 --nodes=1 --ntasks=8 --mem=60G --output=${PWD}/$( date "+%Y%m%d%H%M%S%N" ).out.log --wrap="module load r; Multi_Plate_Case_Control_Peptide_Regression.R -z 11 -a case -b control --zfile_basename tmp5.csv -o ${PWD} -p ${PWD}"

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=test2 --time=1-0 --nodes=1 --ntasks=8 --mem=60G --output=${PWD}/$( date "+%Y%m%d%H%M%S%N" ).out.log --wrap="module load r; Multi_Plate_Case_Control_Peptide_Regression.R -z 10 -a case -b control --zfile_basename Zscores.select6.csv -o ${PWD} -p $( ls -d /francislab/data1/working/20250128-Illumina-PhIP/20250128c-PhIP/out.plate{?,??} 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )"
```


##	20250218


Testing replacement of `read.csv` with `data.frame(data.table::fread`


```
\rm commands

plates=$( ls -d /francislab/data1/working/20250128-Illumina-PhIP/20250128c-PhIP/out.plate[123] 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )
for z in 3.5 10 ; do
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select3.csv -o ${PWD}/MultiPlateTesting -p ${plates}
done >> commands

plates=$( ls -d /francislab/data1/working/20250128-Illumina-PhIP/20250128c-PhIP/out.plate{?,??} 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )
for z in 3.5 10 ; do
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select6.csv -o ${PWD}/MultiPlateTesting -p ${plates}
done >> commands

commands_array_wrapper.bash --array_file commands --time 4-0 --threads 4 --mem 30G
```


```
./PeptideComparison.Rmd \
  -i ${PWD}/MultiPlateTesting/20250218-Multiplate_Peptide_Comparison-Zscores.select3-case-control-Prop_test_results-10.csv \
  -o ${PWD}/MultiPlateTesting/Multiplate_Peptide_Comparison-Zscores.select3

./PeptideComparison.Rmd \
  -i ${PWD}/MultiPlateTesting/20250218-Multiplate_Peptide_Comparison-Zscores.select6-case-control-Prop_test_results-10.csv \
  -o ${PWD}/MultiPlateTesting/Multiplate_Peptide_Comparison-Zscores.select4
```


```
for manifest in out.plate{?,??}/manifest.plate*.csv ; do
  echo phip_seq_aggregate.bash ${manifest} $( dirname ${manifest} )
  phip_seq_aggregate.bash ${manifest} $( dirname ${manifest} )
  box_upload.bash $( dirname ${manifest} )/Counts*csv
done
```


```
\rm commands

plates=$( ls -d /francislab/data1/working/20250128-Illumina-PhIP/20250128c-PhIP/out.plate[123] 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )
for z in 3.5 10 50 100 200 300 400 500 ; do
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Counts.normalized.subtracted.trim.csv -o ${PWD}/MultiPlateTesting3 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select3.csv -o ${PWD}/MultiPlateTesting3 -p ${plates}
done >> commands

plates=$( ls -d /francislab/data1/working/20250128-Illumina-PhIP/20250128c-PhIP/out.plate{?,??} 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )
for z in 3.5 10 50 100 200 300 400 500 ; do
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Counts.normalized.subtracted.trim.csv -o ${PWD}/MultiPlateTesting4 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select6.csv -o ${PWD}/MultiPlateTesting4 -p ${plates}
done >> commands

commands_array_wrapper.bash --array_file commands --time 4-0 --threads 4 --mem 30G
```


```
for f in ${PWD}/MultiPlateTesting?/*-Multiplate_Peptide_Comparison-*csv ; do
./PeptideComparison.Rmd -i ${f} -o ${f%.csv}
done
```






##	20250219


“Select” the tiles used in the Counts files.
Correct the label name so they match the input file

One small tweak- next time you run the HTMLs, could you please fix the axis lables? they still say “interaction” and z-score, just helps to make sure I know what im looking at!

Could you please run the peptide comparison analysis (GBM case/control) on the blank subtracted data? I’d like to compare to the z-score results. I guess we could try the “viral hit fraction” also, right?

Try to run all of Geno’s scripts on the adjusted counts rather than the Zscores
By_virus_plotter -> Manhattan Plots - SKIP
Case_Control_Z_Script -> Tile_Comparison
Count_Viral_Tile_Hit_Fraction -> Viral_Frac_Hits_Z, Viral_Sero_test_results
Seropositivity_Comparison -> Seropositivity_Prop_test_results - SKIP
Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression -> Multiplate_VirFrac_Seropositivity_Comparison_Z
Multi_Plate_Case_Control_Peptide_Regression -> Multiplate_Peptide_Comparison
PeptideComparison -> Multiplate_Peptide_Comparison.html
Multi_Plate_Case_Control_VirScan_Seropositivity_Regression -> Multiplate_VirScan_Seropositivity_Comparison - SKIP




Create SELECT counts
```
#mkdir out.3plates
#merge_all_combined_counts_files.py --int --de_nan --out out.3plates/Plibs.csv /francislab/data1/working/{20241224-Illumina-PhIP/20250110-PhIP,20250128-Illumina-PhIP/20250128c-PhIP}/out.plate[123]/counts/PLib*
#tail -n +2 out.3plates/Plibs.csv | cut -d, -f1 | sort > out.3plates/Plibs.id.csv
#sed -i '1iid' out.3plates/Plibs.id.csv

for manifest in out.plate[123]/manifest.plate*.csv ; do
  dir=$( dirname ${manifest} )
  cat ${dir}/Counts.normalized.subtracted.trim.csv | datamash transpose -t, > ${dir}/tmp1.csv
  head -2 ${dir}/tmp1.csv > ${dir}/tmp2.csv
  join --header -t, out.3plates/Plibs.id.csv <( tail -n +3 ${dir}/tmp1.csv ) >> ${dir}/tmp2.csv
  cat ${dir}/tmp2.csv | datamash transpose -t, > ${dir}/Counts.normalized.subtracted.trim.select3.csv
  box_upload.bash ${dir}/Counts.normalized.subtracted.trim.select3.csv
done


#mkdir out.6plates
#merge_all_combined_counts_files.py --int --de_nan --out out.6plates/Plibs.csv /francislab/data1/working/{20241224-Illumina-PhIP/20250110-PhIP,20250128-Illumina-PhIP/20250128c-PhIP}/out.plate{?,??}/counts/PLib*
#tail -n +2 out.6plates/Plibs.csv | cut -d, -f1 | sort > out.6plates/Plibs.id.csv
#sed -i '1iid' out.6plates/Plibs.id.csv

for manifest in out.plate{?,??}/manifest.plate*.csv ; do
  dir=$( dirname ${manifest} )
  cat ${dir}/Counts.normalized.subtracted.trim.csv | datamash transpose -t, > ${dir}/tmp1.csv
  head -2 ${dir}/tmp1.csv > ${dir}/tmp2.csv
  join --header -t, out.6plates/Plibs.id.csv <( tail -n +3 ${dir}/tmp1.csv ) >> ${dir}/tmp2.csv
  cat ${dir}/tmp2.csv | datamash transpose -t, > ${dir}/Counts.normalized.subtracted.trim.select6.csv
  box_upload.bash ${dir}/Counts.normalized.subtracted.trim.select6.csv
done
```


```
\rm commands
for manifest in out.plate{?,??}/manifest.plate*.csv ; do
dir=$( dirname ${manifest} )
odir=$( dirname ${manifest} )_test ; mkdir -p ${odir}
for z in 3.5 5 10 15 20 30 40 50; do
for base in Zscores.select3.csv Zscores.select6.csv Counts.normalized.subtracted.trim.select3.csv Counts.normalized.subtracted.trim.select6.csv ; do
 echo module load r\; Count_Viral_Tile_Hit_Fraction.R --zscore ${z} --manifest ${manifest}  --output_dir ${odir} -a case -b control --zfilename ${dir}/${base}
 echo module load r\; Case_Control_Z_Script.R --zscore ${z} --manifest ${manifest} --output_dir ${odir} -a case -b control --zfilename ${dir}/${base}
done ; done ; done >> commands

commands_array_wrapper.bash --array_file commands --time 4-0 --threads 2 --mem 15G
```

A lot of failures because of non-existant files.

```
box_upload.bash out.plate*_test/{Tile_Comparison,Viral}*
```


```
\rm commands

plates=$( ls -d ${PWD}/out.plate[123] 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )
for z in 3.5 5 10 15 20 30 40 50; do
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select3.csv -o ${PWD}/MultiPlateTesting3 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select3.csv -o ${PWD}/MultiPlateTesting3 -p ${plates}
done >> commands

plates=$( ls -d ${PWD}/out.plate{?,??} 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )
for z in 3.5 5 10 15 20 30 40 50; do
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select6.csv -o ${PWD}/MultiPlateTesting4 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select6.csv -o ${PWD}/MultiPlateTesting4 -p ${plates}
done >> commands

commands_array_wrapper.bash --array_file commands --time 4-0 --threads 2 --mem 15G
```


```
for f in ${PWD}/MultiPlateTesting?/20250219-Multiplate_Peptide_Comparison-*csv ; do
./PeptideComparison.Rmd -i ${f} -o ${f%.csv}
done
```


##	20250220


```
mkdir out.4plates
merge_all_combined_counts_files.py --int --de_nan --out out.4plates/Plibs.csv ${PWD}/out.plate[1234]/counts/PLib*
tail -n +2 out.4plates/Plibs.csv | cut -d, -f1 | sort > out.4plates/Plibs.id.csv
sed -i '1iid' out.4plates/Plibs.id.csv

for manifest in out.plate[1234]/manifest.plate*.csv ; do
  dir=$( dirname ${manifest} )

  cat ${dir}/Counts.normalized.subtracted.trim.csv | datamash transpose -t, > ${dir}/tmp1.csv
  head -2 ${dir}/tmp1.csv > ${dir}/tmp2.csv
  join --header -t, out.4plates/Plibs.id.csv <( tail -n +3 ${dir}/tmp1.csv ) >> ${dir}/tmp2.csv
  cat ${dir}/tmp2.csv | datamash transpose -t, > ${dir}/Counts.normalized.subtracted.trim.select4.csv
  box_upload.bash ${dir}/Counts.normalized.subtracted.trim.select4.csv

  head -2 ${dir}/Zscores.t.csv > ${dir}/Zscores.select4.t.csv
  join --header -t, out.4plates/Plibs.id.csv <( tail -n +3 ${dir}/Zscores.t.csv ) >> ${dir}/Zscores.select4.t.csv
  cat ${dir}/Zscores.select4.t.csv | datamash transpose -t, > ${dir}/Zscores.select4.csv
  box_upload.bash ${dir}/Zscores.select4{.t,}.csv
done
```



```
\rm commands
mkdir 20250220
for z in 3.5 5 10 15 20 30 40 50; do
for base in Zscores.select4.csv Counts.normalized.subtracted.trim.select4.csv Zscores.select3.csv Zscores.select6.csv Counts.normalized.subtracted.trim.select3.csv Counts.normalized.subtracted.trim.select6.csv ; do
for f in $( ls -1 out.plate?/${base} 2> /dev/null ) ; do
dir=$( dirname ${f} )
manifest=$( ls ${dir}/manifest.plate*.csv )
odir=20250220/${dir} ; mkdir -p ${odir}
echo module load r\; Count_Viral_Tile_Hit_Fraction.R --zscore ${z} --manifest ${manifest}  --output_dir ${odir} -a case -b control --zfilename ${dir}/${base}
echo module load r\; Case_Control_Z_Script.R --zscore ${z} --manifest ${manifest} --output_dir ${odir} -a case -b control --zfilename ${dir}/${base}
done ; done ; done >> commands2

commands_array_wrapper.bash --array_file commands2 --time 4-0 --threads 2 --mem 15G
```



```
\rm commands

plates=$( ls -d ${PWD}/out.plate[123] 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )
for z in 3.5 5 10 15 20 30 40 50; do
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select3.csv -o ${PWD}/20250220/MultiPlate3 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select3.csv -o ${PWD}/20250220/MultiPlate3 -p ${plates}
done >> commands

plates=$( ls -d ${PWD}/out.plate[1234] 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )
for z in 3.5 5 10 15 20 30 40 50; do
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select4.csv -o ${PWD}/20250220/MultiPlate4 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select4.csv -o ${PWD}/20250220/MultiPlate4 -p ${plates}
done >> commands

commands_array_wrapper.bash --array_file commands --time 4-0 --threads 2 --mem 15G
```


```
for f in ${PWD}/20250220/MultiPlate?/*-Multiplate_Peptide_Comparison-*csv ; do
./PeptideComparison.Rmd -i ${f} -o ${f%.csv}
done
```


```
for dir in ${PWD}/out.plate[1234] ; do
cp ${dir}/manifest*csv 20250220/$( basename ${dir} )/
done
```



```
\rm commands
plates=$( ls -d ${PWD}/20250220/out.plate[123] 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )
for z in 3.5 5 10 15 20 30 40 50; do
echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select3.csv -o ${PWD}/20250220/MultiPlate3 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select3.csv -o ${PWD}/20250220/MultiPlate3 -p ${plates}
done >> commands
plates=$( ls -d ${PWD}/20250220/out.plate[1234] 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )
for z in 3.5 5 10 15 20 30 40 50; do
echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select4.csv -o ${PWD}/20250220/MultiPlate4 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select4.csv -o ${PWD}/20250220/MultiPlate4 -p ${plates}
done >> commands

commands_array_wrapper.bash --array_file commands --time 4-0 --threads 2 --mem 15G
```


##	20250225


Testing Multi_Plate_Case_Control_Peptide_Regression.R using continuous counts


```
module load r

plates=$( ls -d ${PWD}/out.plate[123] 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )
Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select3.csv -o ${PWD}/20250225/MultiPlate3 -p ${plates} --counts > ${PWD}/20250225/MultiPlate3/Multiplate_Peptide_Comparison-Counts.normalized.subtracted.trim.select3-case-control-Prop_test_results-Z-0.runlog.txt &

plates=$( ls -d ${PWD}/out.plate[1234] 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )
Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select4.csv -o ${PWD}/20250225/MultiPlate4 -p ${plates} --counts > ${PWD}/20250225/MultiPlate4/Multiplate_Peptide_Comparison-Counts.normalized.subtracted.trim.select4-case-control-Prop_test_results-Z-0.runlog.txt &

```



```
for f in ${PWD}/20250225/MultiPlate?/Multiplate_Peptide_Comparison-*csv ; do
./PeptideComparison.Rmd -i ${f} -o ${f%.x.csv}
done
```

##	20250226


```
for manifest in out.plate{?,??}/manifest.plate*.csv ; do
  echo phip_seq_aggregate.bash ${manifest} $( dirname ${manifest} )
  phip_seq_aggregate.bash ${manifest} $( dirname ${manifest} )
  box_upload.bash $( dirname ${manifest} )/Counts*csv
done
```

```
for manifest in out.plate[123]/manifest.plate*.csv ; do
  dir=$( dirname ${manifest} )
  cat ${dir}/Counts.normalized.subtracted.trim.csv | datamash transpose -t, > ${dir}/tmp1.csv
  head -2 ${dir}/tmp1.csv > ${dir}/tmp2.csv
  join --header -t, out.3plates/Plibs.id.csv <( tail -n +3 ${dir}/tmp1.csv ) >> ${dir}/tmp2.csv
  cat ${dir}/tmp2.csv | datamash transpose -t, > ${dir}/Counts.normalized.subtracted.trim.select3.csv
  box_upload.bash ${dir}/Counts.normalized.subtracted.trim.select3.csv
done

for manifest in out.plate[1234]/manifest.plate*.csv ; do
  dir=$( dirname ${manifest} )
  cat ${dir}/Counts.normalized.subtracted.trim.csv | datamash transpose -t, > ${dir}/tmp1.csv
  head -2 ${dir}/tmp1.csv > ${dir}/tmp2.csv
  join --header -t, out.4plates/Plibs.id.csv <( tail -n +3 ${dir}/tmp1.csv ) >> ${dir}/tmp2.csv
  cat ${dir}/tmp2.csv | datamash transpose -t, > ${dir}/Counts.normalized.subtracted.trim.select4.csv
  box_upload.bash ${dir}/Counts.normalized.subtracted.trim.select4.csv
done
```



```
module load r

plates=$( ls -d ${PWD}/out.plate[123] 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )
mkdir -p 20250226/MultiPlate3
Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select3.csv -o ${PWD}/20250226/MultiPlate3 -p ${plates} --counts > ${PWD}/20250226/MultiPlate3/Multiplate_Peptide_Comparison-Counts.normalized.subtracted.trim.select3-case-control-Prop_test_results-Z-0.runlog.txt &


mkdir -p 20250226/MultiPlate4
plates=$( ls -d ${PWD}/out.plate[1234] 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )
Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select4.csv -o ${PWD}/20250226/MultiPlate4 -p ${plates} --counts > ${PWD}/20250226/MultiPlate4/Multiplate_Peptide_Comparison-Counts.normalized.subtracted.trim.select4-case-control-Prop_test_results-Z-0.runlog.txt &

```






##	20250227


join the counts files ...

```
merge_matrices.py --axis index --de_nan --de_neg \
  --out ${PWD}/20250226/Counts.normalized.subtracted.trim.csv \
  ${PWD}/out.plate[1234]/Counts.normalized.subtracted.trim.csv
```

Drop species name and add case/control status ...

```
head -1 ${PWD}/20250226/Counts.normalized.subtracted.trim.csv > ${PWD}/20250226/tmp1.csv
tail -n +3 ${PWD}/20250226/Counts.normalized.subtracted.trim.csv >> ${PWD}/20250226/tmp1.csv

awk 'BEGIN{FS=OFS=","}{print $1,$2,$5,$8}' ${PWD}/out.all.test/manifest.csv > ${PWD}/20250226/tmp2.csv

join --header -t, -1 1 -2 3 ${PWD}/20250226/tmp2.csv ${PWD}/20250226/tmp1.csv > ${PWD}/20250226/tmp3.csv

cut -d, -f1-4,6- ${PWD}/20250226/tmp3.csv > ${PWD}/20250226/Counts.normalized.subtracted.trim.plus.csv

sbatch --nodes=1 --ntasks=2 --mem=30G --export=None --wrap="python3 -c \"import pandas as pd; pd.read_csv('20250226/Counts.normalized.subtracted.trim.plus.csv', header=[0],index_col=[0,1,2,3,4],low_memory=False).groupby(['subject','group','plate','type'],dropna=False).min().to_csv('20250226/Counts.normalized.subtracted.trim.plus.mins.csv')\""


#sample,subject,group,plate,type,1,10,100,1000,10000,10001,10002,10003,10004,10005,10006,1000
#1403401,1403401,case,3,glioma serum,0.0,0.0,0.0,0.0,7.161216099036505,0.0,3.772326887658032,
#1403401dup,1403401,case,3,glioma serum,0.0,0.0,4.849224673631015,0.0,0.0,0.0,3.6040627444987
```




then ...

```
for f in ${PWD}/20250226/MultiPlate?/Multiplate_Peptide_Comparison-*csv ; do
sbatch --nodes=1 --ntasks=2 --mem=30G --export=None --wrap="module load r; ${PWD}/PeptideComparison.Rmd -i ${f} -o ${f%.csv} -c ${PWD}/20250226/Counts.normalized.subtracted.trim.plus.mins.csv"
done
```




##	20250228



```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 --job-name=predict --time=14-0 --nodes=1 --ntasks=64 --mem=490GB --output=${PWD}/predict.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log ./predict.bash
```


##	20250303

```
cat 20250226/Counts.normalized.subtracted.trim.plus.mins.csv | datamash transpose -t, > tmp1.csv
head -3 tmp1.csv > tmp2.csv
join --header -t, /francislab/data1/refs/PhIP-Seq/VIR3_clean.id_species.uniq.csv <( tail -n +4 tmp1.csv ) >> tmp2.csv
sed -i '1s/^/subject,/' tmp2.csv
sed -i '2s/^/group,/' tmp2.csv
sed -i '3s/^/plate,/' tmp2.csv
sed -i '4s/^id,/type,/' tmp2.csv
cat tmp2.csv | datamash transpose -t, > 20250226/Counts.normalized.subtracted.trim.plus.mins.x.csv

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 --job-name=predict --time=14-0 --nodes=1 --ntasks=64 --mem=490GB --output=${PWD}/predict.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log ./predict.bash
```



```
module load r

plates=$( ls -d ${PWD}/out.plate[123] 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )
mkdir -p 20250304/MultiPlate3
Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select3.csv -o ${PWD}/20250304/MultiPlate3 -p ${plates} --counts > ${PWD}/20250304/MultiPlate3/Multiplate_Peptide_Comparison-Counts.normalized.subtracted.trim.select3-case-control-Prop_test_results-Z-0.runlog.txt &


mkdir -p 20250304/MultiPlate4
plates=$( ls -d ${PWD}/out.plate[1234] 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )
Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select4.csv -o ${PWD}/20250304/MultiPlate4 -p ${plates} --counts > ${PWD}/20250304/MultiPlate4/Multiplate_Peptide_Comparison-Counts.normalized.subtracted.trim.select4-case-control-Prop_test_results-Z-0.runlog.txt &

```




```
for f in ${PWD}/20250304/MultiPlate?/Multiplate_Peptide_Comparison-*Z-0.csv ; do
sbatch --nodes=1 --ntasks=2 --mem=30G --export=None --wrap="module load r pandoc; ${PWD}/PeptideComparison.Rmd -i ${f} -o ${f%.csv} -c ${PWD}/20250226/Counts.normalized.subtracted.trim.plus.mins.csv"
done
```



import numpy as np
import pandas as pd

df=pd.read_csv('20250226/Counts.normalized.subtracted.trim.plus.mins.x.csv',sep=',',index_col=[0,1,2,3],header=[0,1],low_memory=False)
df[df <= 0] = 0.001
df = df.apply(np.log)


##	20250310


```
cat 20250226/Counts.normalized.subtracted.trim.plus.mins.csv | datamash transpose -t, > tmp1.csv
head -3 tmp1.csv > tmp2.csv
join --header -t, /francislab/data1/refs/PhIP-Seq/VIR3_clean.id_species_protein.uniq.csv <( tail -n +4 tmp1.csv ) >> tmp2.csv
sed -i '1s/^/subject,subject,/' tmp2.csv
sed -i '2s/^/group,group,/' tmp2.csv
sed -i '3s/^/plate,plate,/' tmp2.csv
sed -i '4s/^id,/type,/' tmp2.csv
cat tmp2.csv | datamash transpose -t, > 20250226/Counts.normalized.subtracted.trim.plus.mins.xy.csv
```



```

./predict5.bash > commands
commands_array_wrapper.bash --array_file commands --time 30 --threads 2 --mem 15G

```

```

grep --no-filename "^Accuracy3 " logs/commands_array_wrapper.bash.*-534983_*| sort -k3n,3 | tail


```



```

head -1 HHV8-ORF73.csv | datamash transpose -t, | tail -n +4 > HHV8-ORF73.ids.txt
sed -i '1iid' HHV8-ORF73.ids.txt 

head -1 20250304/MultiPlate3/Multiplate_Peptide_Comparison-Counts.normalized.subtracted.trim.select3-case-control-Prop_test_results-Z-0.csv > tmp1.csv
tail -n +3 20250304/MultiPlate3/Multiplate_Peptide_Comparison-Counts.normalized.subtracted.trim.select3-case-control-Prop_test_results-Z-0.csv | sort -t, -k1,1 >> tmp1.csv
join --header -t, HHV8-ORF73.ids.txt tmp1.csv > tmp2.csv

sort -t, -k7n,7 tmp2.csv > 20250304/MultiPlate3/Multiplate_Peptide_Comparison-Counts.normalized.subtracted.trim.select3-case-control-Prop_test_results-Z-0.HHV8-ORF73.csv

```





##	20250311

```
module load r

plates=$( ls -d ${PWD}/out.plate[123] 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )
mkdir -p 20250311/MultiPlate3
sbatch --time 1-0 --nodes=1 --ntasks=2 --mem=30G --export=None --wrap="module load r ; Multi_Plate_Case_Control_Peptide_Regression.extra.R -z 0 -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select3.csv -o ${PWD}/20250311/MultiPlate3 -p ${plates} --counts" --output=${PWD}/20250311/MultiPlate3/Multiplate_Peptide_Comparison-Counts.normalized.subtracted.trim.select3-case-control-Prop_test_results-Z-0.runlog.txt
```

```
for f in ${PWD}/20250311/MultiPlate?/Multiplate_Peptide_Comparison-*Z-0.csv ; do
sbatch --time 1-0 --nodes=1 --ntasks=2 --mem=30G --export=None --wrap="module load r pandoc; ${PWD}/PeptideComparison.Rmd -i ${f} -o ${f%.csv} -c ${PWD}/20250226/Counts.normalized.subtracted.trim.plus.mins.csv"
done
```




##	20250318


Rerun stratifying for sex



```
mkdir -p 20250318/MultiPlate3

plates=$( ls -d ${PWD}/out.plate[123] 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=2 --mem=30G --export=None --job-name=peptide --wrap="module load r ; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select3.csv -o ${PWD}/20250318/MultiPlate3 -p ${plates} --counts" --output=${PWD}/20250318/MultiPlate3/Multiplate_Peptide_Comparison-Counts.normalized.subtracted.trim.select3-case-control-Prop_test_results-Z-0-sex-.runlog.txt

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=2 --mem=30G --export=None --job-name=peptideM --wrap="module load r ; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select3.csv -o ${PWD}/20250318/MultiPlate3 -p ${plates} --counts --sex M" --output=${PWD}/20250318/MultiPlate3/Multiplate_Peptide_Comparison-Counts.normalized.subtracted.trim.select3-case-control-Prop_test_results-Z-0-sex-M.runlog.txt

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=2 --mem=30G --export=None --job-name=peptideF --wrap="module load r ; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select3.csv -o ${PWD}/20250318/MultiPlate3 -p ${plates} --counts --sex F" --output=${PWD}/20250318/MultiPlate3/Multiplate_Peptide_Comparison-Counts.normalized.subtracted.trim.select3-case-control-Prop_test_results-Z-0-sex-F.runlog.txt


sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=2 --mem=30G --export=None --job-name=seropos --wrap="module load r; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z 10 -a case -b control --sfile_basename seropositive.10.csv -o ${PWD}/20250318/MultiPlate3 -p ${plates}" --output=${PWD}/20250318/MultiPlate3/Multiplate_VirScan_Seropositivity_Comparison-case-control-seropositive.10-test_results-Z-10-sex-.runlog.txt

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=2 --mem=30G --export=None --job-name=seroposM --wrap="module load r; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z 10 -a case -b control --sfile_basename seropositive.10.csv -o ${PWD}/20250318/MultiPlate3 -p ${plates} --sex M" --output=${PWD}/20250318/MultiPlate3/Multiplate_VirScan_Seropositivity_Comparison-case-control-seropositive.10-test_results-Z-10-sex-M.runlog.txt

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=2 --mem=30G --export=None --job-name=seroposF --wrap="module load r; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z 10 -a case -b control --sfile_basename seropositive.10.csv -o ${PWD}/20250318/MultiPlate3 -p ${plates} --sex F" --output=${PWD}/20250318/MultiPlate3/Multiplate_VirScan_Seropositivity_Comparison-case-control-seropositive.10-test_results-Z-10-sex-F.runlog.txt



```

```
for f in ${PWD}/20250318/MultiPlate?/Multiplate_Peptide_Comparison-*Z-0-sex*.csv ; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=2 --mem=30G --export=None --job-name=pepcomp --wrap="module load r pandoc; ${PWD}/PeptideComparison.Rmd -i ${f} -o ${f%.csv} -c ${PWD}/20250226/Counts.normalized.subtracted.trim.plus.mins.csv"
done
```


##	20250319

```
mkdir ${PWD}/20250319
#	--index_col subject \
#	--index_col type \
#	--index_col sample \
merge_matrices.py --axis columns --de_nan --de_neg --header_rows 9 \
	--index_col id --index_col species \
  --out ${PWD}/20250319/Counts.normalized.subtracted.csv \
  ${PWD}/out.plate[1234]/Counts.normalized.subtracted.csv
```


Add protein name, gene name, sequence, peptide

Just protein and gene name to aid in selection?

Gotta be unique so need to create a moderated list.


```
head -9 20250319/Counts.normalized.subtracted.csv > 20250319/tmp1.csv
tail -n +10 20250319/Counts.normalized.subtracted.csv | sort -t, -k1,1 >> 20250319/tmp1.csv

head -8 20250319/tmp1.csv > 20250319/tmp2.csv
sed -i 's/^/,,/' 20250319/tmp2.csv

join --header -t, /francislab/data2/refs/PhIP-Seq/VIR3_clean.id_species_protein.uniq.first_protein.join_sorted.csv <( tail -n +9 20250319/tmp1.csv ) >> 20250319/tmp2.csv

cut -d, -f1,3- 20250319/tmp2.csv > 20250319/Counts.normalized.subtracted.protein.csv

python3 -c "import pandas as pd; pd.read_csv('20250319/Counts.normalized.subtracted.protein.csv',header=list(range(9)),index_col=[0,1,2]).droplevel(0,axis='index').groupby(level=[0,1]).sum().to_csv('20250319/Counts.normalized.subtracted.protein.sum.csv')"

```


Prep for use in Multi_Plate_Case_Control_Peptide_Regression.R

```
head -2 20250319/Counts.normalized.subtracted.protein.sum.csv | tail -n 1  > 20250319/tmp1.csv
head -4 20250319/Counts.normalized.subtracted.protein.sum.csv | tail -n 1 >> 20250319/tmp1.csv
head -1 20250319/Counts.normalized.subtracted.protein.sum.csv             >> 20250319/tmp1.csv
tail -n +10 20250319/Counts.normalized.subtracted.protein.sum.csv         >> 20250319/tmp1.csv

cat 20250319/tmp1.csv | datamash transpose -t, > 20250319/tmp2.csv
sed -i '1s/^,,/x,y,id/' 20250319/tmp2.csv
sed -i '2s/^,,/subject,type,species/' 20250319/tmp2.csv
```

While that works, it needs to all be done PER PLATE!


```
for plate in out.plate* ; do
echo $plate
head -9 ${plate}/Counts.normalized.subtracted.csv > ${plate}/tmp1.csv
tail -n +10 ${plate}/Counts.normalized.subtracted.csv | sort -t, -k1,1 >> ${plate}/tmp1.csv

head -8 ${plate}/tmp1.csv > ${plate}/tmp2.csv
sed -i 's/^/,,/' ${plate}/tmp2.csv

join --header -t, /francislab/data2/refs/PhIP-Seq/VIR3_clean.id_species_protein.uniq.first_protein.join_sorted.csv <( tail -n +9 ${plate}/tmp1.csv ) >> ${plate}/tmp2.csv

cut -d, -f1,3- ${plate}/tmp2.csv > ${plate}/Counts.normalized.subtracted.protein.csv

python3 -c "import pandas as pd; pd.read_csv('${plate}/Counts.normalized.subtracted.protein.csv',header=list(range(9)),index_col=[0,1,2]).droplevel(0,axis='index').groupby(level=[0,1]).sum().to_csv('${plate}/Counts.normalized.subtracted.protein.sum.csv')"

head -2 ${plate}/Counts.normalized.subtracted.protein.sum.csv | tail -n 1  > ${plate}/tmp1.csv
head -4 ${plate}/Counts.normalized.subtracted.protein.sum.csv | tail -n 1 >> ${plate}/tmp1.csv
head -1 ${plate}/Counts.normalized.subtracted.protein.sum.csv             >> ${plate}/tmp1.csv
tail -n +10 ${plate}/Counts.normalized.subtracted.protein.sum.csv         >> ${plate}/tmp1.csv

cat ${plate}/tmp1.csv | datamash transpose -t, > ${plate}/tmp2.csv
sed -i '1s/^,,/y,x,id/' ${plate}/tmp2.csv
sed -i '2s/^,,/subject,type,species/' ${plate}/tmp2.csv

mv ${plate}/tmp2.csv ${plate}/Counts.normalized.subtracted.protein.sum.trim.csv

done
```

No filtering on tile ids. Would've had to have done that first before the grouping.
 





```
mkdir -p 20250319/MultiPlate3

plates=$( ls -d ${PWD}/out.plate[123] 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=2 --mem=30G --export=None --job-name=peptide --wrap="module load r ; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.subtracted.protein.sum.trim.csv -o ${PWD}/20250319/MultiPlate3 -p ${plates} --counts" --output=${PWD}/20250319/MultiPlate3/Multiplate_Peptide_Comparison-Counts.normalized.subtracted.protein.sum.trim-case-control-Prop_test_results-Z-0-sex-.runlog.txt

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=2 --mem=30G --export=None --job-name=peptideM --wrap="module load r ; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.subtracted.protein.sum.trim.csv -o ${PWD}/20250319/MultiPlate3 -p ${plates} --counts --sex M" --output=${PWD}/20250319/MultiPlate3/Multiplate_Peptide_Comparison-Counts.normalized.subtracted.protein.sum.trim-case-control-Prop_test_results-Z-0-sex-M.runlog.txt

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=2 --mem=30G --export=None --job-name=peptideF --wrap="module load r ; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.subtracted.protein.sum.trim.csv -o ${PWD}/20250319/MultiPlate3 -p ${plates} --counts --sex F" --output=${PWD}/20250319/MultiPlate3/Multiplate_Peptide_Comparison-Counts.normalized.subtracted.protein.sum.trim-case-control-Prop_test_results-Z-0-sex-F.runlog.txt

```

 -c ${PWD}/20250226/Counts.normalized.subtracted.trim.plus.mins.csv"

```
for f in ${PWD}/20250319/MultiPlate?/Multiplate_Peptide_Comparison-*Z-0-sex*.csv ; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=2 --mem=30G --export=None --job-name=pepcomp --wrap="module load r pandoc; ${PWD}/PeptideComparison.Rmd -i ${f} -o ${f%.csv}"
done
```



Prep a new reference for tensorflow meddling to possibly take age and sex into account

```
cat 20250319/Counts.normalized.subtracted.protein.csv | datamash transpose -t, | cut -d, -f1,2,4,6- > 20250319/Counts.normalized.subtracted.protein.select.t.csv

python3 -c "import pandas as pd; pd.read_csv('20250319/Counts.normalized.subtracted.protein.select.t.csv', header=[0,1,2],index_col=[0,1,2,3,4,5,6],low_memory=False).groupby(level=[1,2,3,4,5,6],dropna=False).min().to_csv('20250319/tmp1.csv')"

head -1 20250319/tmp1.csv > 20250319/Counts.normalized.subtracted.protein.select.t.mins.reorder.csv
head -3 20250319/tmp1.csv | tail -n 1 >> 20250319/Counts.normalized.subtracted.protein.select.t.mins.reorder.csv
head -2 20250319/tmp1.csv | tail -n 1 >> 20250319/Counts.normalized.subtracted.protein.select.t.mins.reorder.csv
tail -n +4 20250319/tmp1.csv >> 20250319/Counts.normalized.subtracted.protein.select.t.mins.reorder.csv

sed -i '1s/,,,,,,/subject,type,group,age,sex,plate,/' 20250319/Counts.normalized.subtracted.protein.select.t.mins.reorder.csv
sed -i '2s/species,,,,,,/subject,type,group,age,sex,species,/' 20250319/Counts.normalized.subtracted.protein.select.t.mins.reorder.csv
sed -i '3s/id,,,,,,/subject,type,group,age,sex,protein,/' 20250319/Counts.normalized.subtracted.protein.select.t.mins.reorder.csv
```

