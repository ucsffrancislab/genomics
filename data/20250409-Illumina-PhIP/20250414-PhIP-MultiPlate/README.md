
#	20250409-Illumina-PhIP/20250414-PhIP-MultiPlate


Separating the multiplate processing for the individual (pairs) of plates.

This will just be the GBM plates: 1,2,3,4,5 and 6

Plate 4 was off, so some analyses may exclude it.

Reference 20250128-Illumina-PhIP/20250128c-PhIP/README.md

```
ln -s /francislab/data1/working/20241204-Illumina-PhIP/20250411-PhIP/out.plate1
ln -s /francislab/data1/working/20241224-Illumina-PhIP/20250411-PhIP/out.plate2
ln -s /francislab/data1/working/20250128-Illumina-PhIP/20250411-PhIP/out.plate3
ln -s /francislab/data1/working/20250128-Illumina-PhIP/20250411-PhIP/out.plate4
ln -s /francislab/data1/working/20250409-Illumina-PhIP/20250411-PhIP/out.plate5
ln -s /francislab/data1/working/20250409-Illumina-PhIP/20250411-PhIP/out.plate6
```


Create lists of tile ids that have been found in any of the Phage Library plates.

```
mkdir out.123456
merge_all_combined_counts_files.py --int --de_nan --out out.123456/Plibs.csv out.plate[123456]/counts/PLib*

tail -n +2 out.123456/Plibs.csv | cut -d, -f1 | sort > out.123456/Plibs.id.csv
sed -i '1iid' out.123456/Plibs.id.csv

mkdir out.12356
merge_all_combined_counts_files.py --int --de_nan --out out.12356/Plibs.csv out.plate[12356]/counts/PLib*

tail -n +2 out.12356/Plibs.csv | cut -d, -f1 | sort > out.12356/Plibs.id.csv
sed -i '1iid' out.12356/Plibs.id.csv
```




```
for i in 1 2 3 5 6; do
  dir=out.plate${i}
	echo $dir
  cat ${dir}/Counts.normalized.subtracted.trim.csv | datamash transpose -t, > ${dir}/tmp1.csv
  head -2 ${dir}/tmp1.csv > ${dir}/tmp2.csv
  join --header -t, out.12356/Plibs.id.csv <( tail -n +3 ${dir}/tmp1.csv ) >> ${dir}/tmp2.csv
  cat ${dir}/tmp2.csv | datamash transpose -t, > ${dir}/Counts.normalized.subtracted.trim.select-12356.csv
  box_upload.bash ${dir}/Counts.normalized.subtracted.trim.select-12356.csv

  head -2 ${dir}/Zscores.t.csv > ${dir}/Zscores.select-12356.t.csv
  join --header -t, out.12356/Plibs.id.csv <( tail -n +3 ${dir}/Zscores.t.csv ) >> ${dir}/Zscores.select-12356.t.csv
  cat ${dir}/Zscores.select-12356.t.csv | datamash transpose -t, > ${dir}/Zscores.select-12356.csv
  box_upload.bash ${dir}/Zscores.select-12356.csv

  head -2 ${dir}/Zscores.minimums.t.csv > ${dir}/Zscores.select-12356.minimums.t.csv
  join --header -t, out.12356/Plibs.id.csv <( tail -n +3 ${dir}/Zscores.minimums.t.csv ) >> ${dir}/Zscores.select-12356.minimums.t.csv
  cat ${dir}/Zscores.select-12356.minimums.t.csv | datamash transpose -t, > ${dir}/Zscores.select-12356.minimums.csv
  box_upload.bash ${dir}/Zscores.select-12356.minimums.csv
done

for i in 1 2 3 4 5 6; do
  dir=out.plate${i}
	echo $dir
  cat ${dir}/Counts.normalized.subtracted.trim.csv | datamash transpose -t, > ${dir}/tmp1.csv
  head -2 ${dir}/tmp1.csv > ${dir}/tmp2.csv
  join --header -t, out.123456/Plibs.id.csv <( tail -n +3 ${dir}/tmp1.csv ) >> ${dir}/tmp2.csv
  cat ${dir}/tmp2.csv | datamash transpose -t, > ${dir}/Counts.normalized.subtracted.trim.select-123456.csv
  box_upload.bash ${dir}/Counts.normalized.subtracted.trim.select-123456.csv

  head -2 ${dir}/Zscores.t.csv > ${dir}/Zscores.select-123456.t.csv
  join --header -t, out.123456/Plibs.id.csv <( tail -n +3 ${dir}/Zscores.t.csv ) >> ${dir}/Zscores.select-123456.t.csv
  cat ${dir}/Zscores.select-123456.t.csv | datamash transpose -t, > ${dir}/Zscores.select-123456.csv
  box_upload.bash ${dir}/Zscores.select-123456.csv

  head -2 ${dir}/Zscores.minimums.t.csv > ${dir}/Zscores.select-123456.minimums.t.csv
  join --header -t, out.123456/Plibs.id.csv <( tail -n +3 ${dir}/Zscores.minimums.t.csv ) >> ${dir}/Zscores.select-123456.minimums.t.csv
  cat ${dir}/Zscores.select-123456.minimums.t.csv | datamash transpose -t, > ${dir}/Zscores.select-123456.minimums.csv
  box_upload.bash ${dir}/Zscores.select-123456.minimums.csv
done

```



```
\rm commands

for i in 1 2 3 5 6 ; do
dir=out.plate${i}
manifest=${dir}/manifest.plate${i}.csv
odir=${dir}
for z in 3.5 5 10 15 20 30 40 50; do
for base in Zscores.select-12356.csv Counts.normalized.subtracted.trim.select-12356.csv ; do
echo module load r\; Seropositivity_Comparison.R --zscore ${z} --manifest ${manifest}  --output_dir ${odir} -a case -b control --sfilename ${dir}/seropositive.${z}.csv
echo module load r\; Count_Viral_Tile_Hit_Fraction.R --zscore ${z} --manifest ${manifest}  --output_dir ${odir} -a case -b control --zfilename ${dir}/${base}
echo module load r\; Case_Control_Z_Script.R --zscore ${z} --manifest ${manifest} --output_dir ${odir} -a case -b control --zfilename ${dir}/${base}
done ; done ; done >> commands

for i in 1 2 3 4 5 6 ; do
dir=out.plate${i}
manifest=${dir}/manifest.plate${i}.csv
odir=${dir}
for z in 3.5 5 10 15 20 30 40 50; do
for base in Zscores.select-123456.csv Counts.normalized.subtracted.trim.select-123456.csv ; do
echo module load r\; Seropositivity_Comparison.R --zscore ${z} --manifest ${manifest}  --output_dir ${odir} -a case -b control --sfilename ${dir}/seropositive.${z}.csv
echo module load r\; Count_Viral_Tile_Hit_Fraction.R --zscore ${z} --manifest ${manifest}  --output_dir ${odir} -a case -b control --zfilename ${dir}/${base}
echo module load r\; Case_Control_Z_Script.R --zscore ${z} --manifest ${manifest} --output_dir ${odir} -a case -b control --zfilename ${dir}/${base}

done ; done ; done >> commands

commands_array_wrapper.bash --array_file commands --time 4-0 --threads 2 --mem 15G
```




Plate6 Case_Control_Z_Script.R failed due to grep issues. Quick fixed and reran.

Many failed (expectedly) due to missing seropositive.ZSCORE.csv files (only have 3.5 and 10)





```
box_upload.bash out.plate?/{Tile_Comparison,Viral_Ser,Viral_Frac_Hits,Seropositivity}*
```




```
\rm commands

plates=$( ls -d ${PWD}/out.plate[12356] 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )
for z in 3.5 5 10 15 20 30 40 50; do
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select-12356.csv -o ${PWD}/out.12356 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select-12356.csv -o ${PWD}/out.12356 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select-12356.csv -o ${PWD}/out.12356 -p ${plates} --sex M
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select-12356.csv -o ${PWD}/out.12356 -p ${plates} --sex M
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select-12356.csv -o ${PWD}/out.12356 -p ${plates} --sex F
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select-12356.csv -o ${PWD}/out.12356 -p ${plates} --sex F
echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} -a case -b control -o ${PWD}/out.12356 -p ${plates}  --zfile_basename Counts.normalized.subtracted.trim.select-12356.csv
echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} -a case -b control -o ${PWD}/out.12356 -p ${plates} --zfile_basename Zscores.select-12356.csv
done >> commands
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z 3.5 -a case -b control --sfile_basename seropositive.3.5.csv -o ${PWD}/out.12356 -p ${plates} >> commands
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z 3.5 -a case -b control --sfile_basename seropositive.3.5.csv -o ${PWD}/out.12356 -p ${plates} --sex M >> commands
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z 3.5 -a case -b control --sfile_basename seropositive.3.5.csv -o ${PWD}/out.12356 -p ${plates} --sex F >> commands
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z 10 -a case -b control --sfile_basename seropositive.10.csv -o ${PWD}/out.12356 -p ${plates} >> commands
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z 10 -a case -b control --sfile_basename seropositive.10.csv -o ${PWD}/out.12356 -p ${plates} --sex M >> commands
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z 10 -a case -b control --sfile_basename seropositive.10.csv -o ${PWD}/out.12356 -p ${plates} --sex F >> commands

plates=$( ls -d ${PWD}/out.plate[123456] 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )
for z in 3.5 5 10 15 20 30 40 50; do
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select-123456.csv -o ${PWD}/out.123456 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select-123456.csv -o ${PWD}/out.123456 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select-123456.csv -o ${PWD}/out.123456 -p ${plates} --sex M
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select-123456.csv -o ${PWD}/out.123456 -p ${plates} --sex M
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select-123456.csv -o ${PWD}/out.123456 -p ${plates} --sex F
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select-123456.csv -o ${PWD}/out.123456 -p ${plates} --sex F
echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} -a case -b control -o ${PWD}/out.123456 -p ${plates} --zfile_basename Counts.normalized.subtracted.trim.select-123456.csv
echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} -a case -b control -o ${PWD}/out.123456 -p ${plates} --zfile_basename Zscores.select-123456.csv
done >> commands
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z 3.5 -a case -b control --sfile_basename seropositive.3.5.csv -o ${PWD}/out.123456 -p ${plates} >> commands
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z 3.5 -a case -b control --sfile_basename seropositive.3.5.csv -o ${PWD}/out.123456 -p ${plates} --sex M >> commands
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z 3.5 -a case -b control --sfile_basename seropositive.3.5.csv -o ${PWD}/out.123456 -p ${plates} --sex F >> commands
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z 10 -a case -b control --sfile_basename seropositive.10.csv -o ${PWD}/out.123456 -p ${plates} >> commands
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z 10 -a case -b control --sfile_basename seropositive.10.csv -o ${PWD}/out.123456 -p ${plates} --sex M >> commands
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z 10 -a case -b control --sfile_basename seropositive.10.csv -o ${PWD}/out.123456 -p ${plates} --sex F >> commands

commands_array_wrapper.bash --array_file commands --time 4-0 --threads 2 --mem 15G
```


```
box_upload.bash out.{12356,123456}/Multiplate*
```


```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=vs12356 --wrap="module load r pandoc; virus_scores.Rmd -d ${PWD}/out.plate1 -d ${PWD}/out.plate2 -d ${PWD}/out.plate3 -d ${PWD}/out.plate5 -d ${PWD}/out.plate6 -o ${PWD}/out.12356/virus_scores"

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=vs123456 --wrap="module load r pandoc; virus_scores.Rmd -d ${PWD}/out.plate1 -d ${PWD}/out.plate2 -d ${PWD}/out.plate3 -d ${PWD}/out.plate4 -d ${PWD}/out.plate5 -d ${PWD}/out.plate6 -o ${PWD}/out.123456/virus_scores"

```


```
box_upload.bash out.{12356,123456}/virus_score*
```



```
merge_matrices.py --axis index --de_nan --de_neg \
  --header_rows 2 --index_col subject --index_col type --index_col species \
  --out ${PWD}/out.123456/Counts.normalized.subtracted.trim.csv \
  ${PWD}/out.plate[123456]/Counts.normalized.subtracted.trim.csv

merge_matrices.py --axis index --de_nan --de_neg \
  --header_rows 2 --index_col subject --index_col type --index_col species \
  --out ${PWD}/out.12356/Counts.normalized.subtracted.trim.csv \
  ${PWD}/out.plate[12356]/Counts.normalized.subtracted.trim.csv
```



```
tail -q -n +2 out.plate[123456]/manifest.plate*.csv > out.123456/tmp1.csv
sed -i '1isubject,sample,bampath,type,study,group,age,sex,plate' out.123456/tmp1.csv
awk 'BEGIN{FS=OFS=","}{print $2,$1,$4,$5,$6,$7,$8,$9}' out.123456/tmp1.csv > out.123456/tmp2.csv
head -1 out.123456/tmp2.csv > out.123456/manifest.csv
tail -n +2 out.123456/tmp2.csv | sort -t, -k1,1 >> out.123456/manifest.csv
chmod -w out.123456/manifest.csv
\rm out.123456/tmp?.csv

tail -q -n +2 out.plate[12356]/manifest.plate*.csv > out.12356/tmp1.csv
sed -i '1isubject,sample,bampath,type,study,group,age,sex,plate' out.12356/tmp1.csv
awk 'BEGIN{FS=OFS=","}{print $2,$1,$4,$5,$6,$7,$8,$9}' out.12356/tmp1.csv > out.12356/tmp2.csv
head -1 out.12356/tmp2.csv > out.12356/manifest.csv
tail -n +2 out.12356/tmp2.csv | sort -t, -k1,1 >> out.12356/manifest.csv
chmod -w out.12356/manifest.csv
\rm out.12356/tmp?.csv
```


Drop species name and add case/control status ...

```
for dir in out.123456 out.12356 ; do
head -1 ${PWD}/${dir}/Counts.normalized.subtracted.trim.csv > ${PWD}/${dir}/tmp1.csv
tail -n +3 ${PWD}/${dir}/Counts.normalized.subtracted.trim.csv >> ${PWD}/${dir}/tmp1.csv
awk 'BEGIN{FS=OFS=","}{print $1,$2,$5,$8}' ${PWD}/${dir}/manifest.csv > ${PWD}/${dir}/tmp2.csv
join --header -t, -1 1 -2 3 ${PWD}/${dir}/tmp2.csv ${PWD}/${dir}/tmp1.csv > ${PWD}/${dir}/tmp3.csv
cut -d, -f1-4,6- ${PWD}/${dir}/tmp3.csv > ${PWD}/${dir}/Counts.normalized.subtracted.trim.plus.csv
\rm ${dir}/tmp?.csv
done
```


```
sbatch --nodes=1 --ntasks=2 --mem=30G --export=None --wrap="python3 -c \"import pandas as pd; pd.read_csv('out.123456/Counts.normalized.subtracted.trim.plus.csv', header=[0],index_col=[0,1,2,3,4],low_memory=False).groupby(['subject','group','plate','type'],dropna=False).min().to_csv('out.123456/Counts.normalized.subtracted.trim.plus.mins.csv')\""

sbatch --nodes=1 --ntasks=2 --mem=30G --export=None --wrap="python3 -c \"import pandas as pd; pd.read_csv('out.12356/Counts.normalized.subtracted.trim.plus.csv', header=[0],index_col=[0,1,2,3,4],low_memory=False).groupby(['subject','group','plate','type'],dropna=False).min().to_csv('out.12356/Counts.normalized.subtracted.trim.plus.mins.csv')\""
```




```
for f in ${PWD}/out.123*/Multiplate_Peptide_Comparison-*-Prop_test_results*.csv ; do
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=4 --mem=60G --export=None --wrap="module load r pandoc; PeptideComparison.Rmd -i ${f} -o ${f%.csv} -c $(dirname ${f})/Counts.normalized.subtracted.trim.plus.mins.csv"
done

```













---








This requires Zscores.select.minimums.csv and a virus species
./Zscores.Rmd -s "Human herpesvirus 3" \

```

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=Zs12356 --wrap="module load r pandoc; Zscores.Rmd -d ${PWD}/out.plate1 -d ${PWD}/out.plate2 -d ${PWD}/out.plate3 -d ${PWD}/out.plate5 -d ${PWD}/out.plate6 -o ${PWD}/out.12356/Zscores"

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=Zs123456 --wrap="module load r pandoc; Zscores.Rmd -d ${PWD}/out.plate1 -d ${PWD}/out.plate2 -d ${PWD}/out.plate3 -d ${PWD}/out.plate4 -d ${PWD}/out.plate5 -d ${PWD}/out.plate6 -o ${PWD}/out.123456/Zscores"

```



./heatmap.Rmd -i /francislab/data1/working/20250128-Illumina-PhIP/20250128c-PhIP/out.all.test/cpm_blank_subtracted.csv -o glioma_cpm_blank_subtracted
