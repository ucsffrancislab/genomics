
#	20250822-Illumina-PhIP/20250822c-PhIP


DO NOT USE ...



#	1 Sequencer S# 
#	2 Avera Sample_ID
#	3 Avera RunName
#	4 Index primer
#	5 Index 'READ'
#	6 UCSF sample name (PRN BlindID/PLCO liid)
#	7 UCSF sample name for sequencing (PRN BlindID/PLCO liid)
#	8 Sample type
#	9 Study
#	10 Analysis group (PLCO and PRN)
#	11 PLCO barcode [GBM]/PRN tube no [ALL] /IPS kitno [Plate 4 IPS GBM repeats]
#	12 sex
#	13 age
#	14 best_draw_label (PLCO)
#	15 match_race7 (PLCO)
#	16 self-identified race/ethnicity (PRN)
#	17 M_BLINDID (PRN)
#	18 BIRTH_YEAR (PRN)
#	19 Matching Race (IPS case)
#	20 IDH mut (IPS case)
#	21 dex_draw (IPS case)
#	22 dex_prior_month (IPS case)
#	23 Timepoint (IPS cases)
#	24 192 sequencing Lane
#	25 Plate


##	All

```
awk 'BEGIN{FS=OFS=","}(NR>1){print $6,$7,"/francislab/data1/working/20250822-Illumina-PhIP/20250822b-bowtie2/out/"$1".VIR3_clean.id_upper_oligo.uniq.1-80.bam",$8,$9,$10,$13,$12,$25}' /francislab/data1/raw/20250822-Illumina-PhIP/manifest.csv > manifest.all.csv

sed -i '1isubject,sample,bampath,type,study,group,age,sex,plate' manifest.all.csv
sed -i 's/,PBS blank,/,input,/' manifest.all.csv
#sed -i '/Blank24dup/d' manifest.all.csv
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
awk 'BEGIN{FS=OFS=","}(NR>1){print $6,$7,"/francislab/data1/working/20250822-Illumina-PhIP/20250822b-bowtie2/out/"$1".VIR3_clean.id_upper_oligo.uniq.1-80.bam",$8,$9,$10,$13,$12,$25 > "manifest.plate"$25".csv" }' /francislab/data1/raw/20250822-Illumina-PhIP/manifest.csv

for manifest in manifest.plate*.csv ; do
sed -i '1isubject,sample,bampath,type,study,group,age,sex,plate' ${manifest}
sed -i 's/,PBS blank,/,input,/' ${manifest}
#sed -i '/Blank24dup/d' ${manifest}
chmod -w ${manifest}
done

```


```
mkdir logs

for manifest in manifest.plate*.csv ; do
num=${manifest%.csv}
num=${num#manifest.plate}
echo $num

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq_plate${num} --time=1-0 --nodes=1 --ntasks=8 --mem=60G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --thresholds 3.5,5,10  \
  --manifest ${PWD}/${manifest} --output ${PWD}/out.plate${num}

done
```








```
for manifest in manifest.plate*.csv ; do
  plate=${manifest%.csv}
  plate=${plate#manifest.plate}
  echo $plate
  cp ${manifest} out.plate${plate}/
  sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
    --job-name=phip_seq_plate${plate} --time=1-0 --nodes=1 --ntasks=8 --mem=60G \
    --output=${PWD}/logs/phip_seq.aggregate.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
    /c4/home/gwendt/.local/bin/phip_seq_aggregate.bash ${manifest} out.plate${plate}/
done

for manifest in manifest.plate*.csv ; do
  plate=${manifest%.csv}
  plate=${plate#manifest.plate}
  echo $plate
  box_upload.bash out.plate${plate}/Zscores*csv out.plate${plate}/seropositive*csv out.plate${plate}/All* out.plate${plate}/m*
done
```


















I think that these scripts internally check for common peptides and such
Nevertheless



```
mkdir out.1516
merge_all_combined_counts_files.py --int --de_nan --out out.1516/Plibs.csv out.plate{15,16}/counts/PLib*

tail -n +2 out.1516/Plibs.csv | cut -d, -f1 | sort > out.1516/Plibs.id.csv
sed -i '1iid' out.1516/Plibs.id.csv
```


```
for i in 15 16; do
  dir=out.plate${i}
  echo $dir
  cat ${dir}/Counts.normalized.subtracted.trim.csv | datamash transpose -t, > ${dir}/tmp1.csv
  head -2 ${dir}/tmp1.csv > ${dir}/tmp2.csv
  join --header -t, out.1516/Plibs.id.csv <( tail -n +3 ${dir}/tmp1.csv ) >> ${dir}/tmp2.csv
  cat ${dir}/tmp2.csv | datamash transpose -t, > ${dir}/Counts.normalized.subtracted.trim.select-1516.csv
  box_upload.bash ${dir}/Counts.normalized.subtracted.trim.select-1516.csv

  head -2 ${dir}/Zscores.t.csv > ${dir}/Zscores.select-1516.t.csv
  join --header -t, out.1516/Plibs.id.csv <( tail -n +3 ${dir}/Zscores.t.csv ) >> ${dir}/Zscores.select-1516.t.csv
  cat ${dir}/Zscores.select-1516.t.csv | datamash transpose -t, > ${dir}/Zscores.select-1516.csv
  box_upload.bash ${dir}/Zscores.select-1516.csv

  head -2 ${dir}/Zscores.minimums.t.csv > ${dir}/Zscores.select-1516.minimums.t.csv
  join --header -t, out.1516/Plibs.id.csv <( tail -n +3 ${dir}/Zscores.minimums.t.csv ) >> ${dir}/Zscores.select-1516.minimums.t.csv
  cat ${dir}/Zscores.select-1516.minimums.t.csv | datamash transpose -t, > ${dir}/Zscores.select-1516.minimums.csv
  box_upload.bash ${dir}/Zscores.select-1516.minimums.csv
done
```


```
\rm commands

for p in 15 16 ; do 
plate=out.plate${p}
manifest=${plate}/manifest.plate${p}.csv
for z in 3.5 5 10 ; do 
echo module load r\; Count_Viral_Tile_Hit_Fraction.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} -a case -b control --zfilename ${plate}/Zscores.select-1516.csv
echo module load r\; Case_Control_Z_Script.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} -a case -b control --zfilename ${plate}/Zscores.select-1516.csv
echo module load r\; Seropositivity_Comparison.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} -a case -b control --sfilename ${plate}/seropositive.${z}.csv
done ; done >> commands

commands_array_wrapper.bash --array_file commands --time 4-0 --threads 4 --mem 30G
```



```
\rm commands

plates=$( ls -d ${PWD}/out.plate{15,16} 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )

echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select-1516.csv -o ${PWD}/out.1516 -p ${plates} --counts >> commands
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select-1516.csv -o ${PWD}/out.1516 -p ${plates} --counts --sex M >> commands
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select-1516.csv -o ${PWD}/out.1516 -p ${plates} --counts --sex F >> commands

for z in 3.5 5 10 ; do

echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select-1516.csv -o ${PWD}/out.1516 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select-1516.csv -o ${PWD}/out.1516 -p ${plates} --sex M
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select-1516.csv -o ${PWD}/out.1516 -p ${plates} --sex F

echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} -a case -b control -o ${PWD}/out.1516 -p ${plates} --zfile_basename Zscores.select-1516.csv
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} -a case -b control --sfile_basename seropositive.${z}.csv -o ${PWD}/out.1516 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} -a case -b control --sfile_basename seropositive.${z}.csv -o ${PWD}/out.1516 -p ${plates} --sex M
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} -a case -b control --sfile_basename seropositive.${z}.csv -o ${PWD}/out.1516 -p ${plates} --sex F

done >> commands

commands_array_wrapper.bash --jobname MultiPlate --array_file commands --time 4-0 --threads 4 --mem 30G
```


