
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

mkdir out.123
merge_all_combined_counts_files.py --int --de_nan --out out.123/Plibs.csv out.plate[123]/counts/PLib*

tail -n +2 out.123/Plibs.csv | cut -d, -f1 | sort > out.123/Plibs.id.csv
sed -i '1iid' out.123/Plibs.id.csv
```




```

for i in 1 2 3; do
  dir=out.plate${i}
	echo $dir
  cat ${dir}/Counts.normalized.subtracted.trim.csv | datamash transpose -t, > ${dir}/tmp1.csv
  head -2 ${dir}/tmp1.csv > ${dir}/tmp2.csv
  join --header -t, out.123/Plibs.id.csv <( tail -n +3 ${dir}/tmp1.csv ) >> ${dir}/tmp2.csv
  cat ${dir}/tmp2.csv | datamash transpose -t, > ${dir}/Counts.normalized.subtracted.trim.select-123.csv
  box_upload.bash ${dir}/Counts.normalized.subtracted.trim.select-123.csv

  head -2 ${dir}/Zscores.t.csv > ${dir}/Zscores.select-123.t.csv
  join --header -t, out.123/Plibs.id.csv <( tail -n +3 ${dir}/Zscores.t.csv ) >> ${dir}/Zscores.select-123.t.csv
  cat ${dir}/Zscores.select-123.t.csv | datamash transpose -t, > ${dir}/Zscores.select-123.csv
  box_upload.bash ${dir}/Zscores.select-123.csv

  head -2 ${dir}/Zscores.minimums.t.csv > ${dir}/Zscores.select-123.minimums.t.csv
  join --header -t, out.123/Plibs.id.csv <( tail -n +3 ${dir}/Zscores.minimums.t.csv ) >> ${dir}/Zscores.select-123.minimums.t.csv
  cat ${dir}/Zscores.select-123.minimums.t.csv | datamash transpose -t, > ${dir}/Zscores.select-123.minimums.csv
  box_upload.bash ${dir}/Zscores.select-123.minimums.csv
done

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

for i in 1 2 3 ; do
dir=out.plate${i}
manifest=${dir}/manifest.plate${i}.csv
odir=${dir}
for z in 3.5 5 10 15 20 30 40 50; do
for base in Zscores.select-123.csv Counts.normalized.subtracted.trim.select-123.csv ; do
echo module load r\; Seropositivity_Comparison.R --zscore ${z} --manifest ${manifest}  --output_dir ${odir} -a case -b control --sfilename ${dir}/seropositive.${z}.csv
echo module load r\; Count_Viral_Tile_Hit_Fraction.R --zscore ${z} --manifest ${manifest}  --output_dir ${odir} -a case -b control --zfilename ${dir}/${base}
echo module load r\; Case_Control_Z_Script.R --zscore ${z} --manifest ${manifest} --output_dir ${odir} -a case -b control --zfilename ${dir}/${base}
done ; done ; done >> commands

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


plates=$( ls -d ${PWD}/out.plate[123] 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )

echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select-123.csv -o ${PWD}/out.123 -p ${plates} --counts >> commands
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select-123.csv -o ${PWD}/out.123 -p ${plates} --counts --sex M >> commands
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select-123.csv -o ${PWD}/out.123 -p ${plates} --counts --sex F >> commands

for z in 3.5 5 10 15 20 30 40 50; do
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select-123.csv -o ${PWD}/out.123 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select-123.csv -o ${PWD}/out.123 -p ${plates} --sex M
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select-123.csv -o ${PWD}/out.123 -p ${plates} --sex F
echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} -a case -b control -o ${PWD}/out.123 -p ${plates}  --zfile_basename Counts.normalized.subtracted.trim.select-123.csv
echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} -a case -b control -o ${PWD}/out.123 -p ${plates} --zfile_basename Zscores.select-123.csv
done >> commands

echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z 3.5 -a case -b control --sfile_basename seropositive.3.5.csv -o ${PWD}/out.123 -p ${plates} >> commands
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z 3.5 -a case -b control --sfile_basename seropositive.3.5.csv -o ${PWD}/out.123 -p ${plates} --sex M >> commands
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z 3.5 -a case -b control --sfile_basename seropositive.3.5.csv -o ${PWD}/out.123 -p ${plates} --sex F >> commands
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z 10 -a case -b control --sfile_basename seropositive.10.csv -o ${PWD}/out.123 -p ${plates} >> commands
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z 10 -a case -b control --sfile_basename seropositive.10.csv -o ${PWD}/out.123 -p ${plates} --sex M >> commands
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z 10 -a case -b control --sfile_basename seropositive.10.csv -o ${PWD}/out.123 -p ${plates} --sex F >> commands







plates=$( ls -d ${PWD}/out.plate[12356] 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )

echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select-12356.csv -o ${PWD}/out.12356 -p ${plates} --counts >> commands
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select-12356.csv -o ${PWD}/out.12356 -p ${plates} --counts --sex M >> commands
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select-12356.csv -o ${PWD}/out.12356 -p ${plates} --counts --sex F >> commands

for z in 3.5 5 10 15 20 30 40 50; do
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select-12356.csv -o ${PWD}/out.12356 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select-12356.csv -o ${PWD}/out.12356 -p ${plates} --sex M
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

echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select-123456.csv -o ${PWD}/out.123456 -p ${plates} --counts >> commands
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select-123456.csv -o ${PWD}/out.123456 -p ${plates} --counts --sex M >> commands
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select-123456.csv -o ${PWD}/out.123456 -p ${plates} --counts --sex F >> commands

for z in 3.5 5 10 15 20 30 40 50; do
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select-123456.csv -o ${PWD}/out.123456 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select-123456.csv -o ${PWD}/out.123456 -p ${plates} --sex M
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
box_upload.bash out.{123,12356,123456}/Multiplate*
```


```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=vs123 --wrap="module load r pandoc; virus_scores.Rmd -d ${PWD}/out.plate1 -d ${PWD}/out.plate2 -d ${PWD}/out.plate3 -o ${PWD}/out.123/virus_scores"

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=vs12356 --wrap="module load r pandoc; virus_scores.Rmd -d ${PWD}/out.plate1 -d ${PWD}/out.plate2 -d ${PWD}/out.plate3 -d ${PWD}/out.plate5 -d ${PWD}/out.plate6 -o ${PWD}/out.12356/virus_scores"

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=vs123456 --wrap="module load r pandoc; virus_scores.Rmd -d ${PWD}/out.plate1 -d ${PWD}/out.plate2 -d ${PWD}/out.plate3 -d ${PWD}/out.plate4 -d ${PWD}/out.plate5 -d ${PWD}/out.plate6 -o ${PWD}/out.123456/virus_scores"

```


```
box_upload.bash out.{123,12356,123456}/virus_score*
```



```
merge_matrices.py --axis index --de_nan --de_neg \
  --header_rows 2 --index_col subject --index_col type --index_col species \
  --out ${PWD}/out.123/Counts.normalized.subtracted.trim.csv \
  ${PWD}/out.plate[123]/Counts.normalized.subtracted.trim.csv

merge_matrices.py --axis index --de_nan --de_neg \
  --header_rows 2 --index_col subject --index_col type --index_col species \
  --out ${PWD}/out.12356/Counts.normalized.subtracted.trim.csv \
  ${PWD}/out.plate[12356]/Counts.normalized.subtracted.trim.csv

merge_matrices.py --axis index --de_nan --de_neg \
  --header_rows 2 --index_col subject --index_col type --index_col species \
  --out ${PWD}/out.123456/Counts.normalized.subtracted.trim.csv \
  ${PWD}/out.plate[123456]/Counts.normalized.subtracted.trim.csv


merge_matrices.py --axis index --de_nan --de_neg \
  --header_rows 2 --index_col subject --index_col type --index_col species \
  --out ${PWD}/out.123/Zscores.csv \
  ${PWD}/out.plate[123]/Zscores.csv

merge_matrices.py --axis index --de_nan --de_neg \
  --header_rows 2 --index_col subject --index_col type --index_col species \
  --out ${PWD}/out.12356/Zscores.csv \
  ${PWD}/out.plate[12356]/Zscores.csv

merge_matrices.py --axis index --de_nan --de_neg \
  --header_rows 2 --index_col subject --index_col type --index_col species \
  --out ${PWD}/out.123456/Zscores.csv \
  ${PWD}/out.plate[123456]/Zscores.csv

```



```
tail -q -n +2 out.plate[123]/manifest.plate*.csv > out.123/tmp1.csv
sed -i '1isubject,sample,bampath,type,study,group,age,sex,plate' out.123/tmp1.csv
awk 'BEGIN{FS=OFS=","}{print $2,$1,$4,$5,$6,$7,$8,$9}' out.123/tmp1.csv > out.123/tmp2.csv
head -1 out.123/tmp2.csv > out.123/manifest.csv
tail -n +2 out.123/tmp2.csv | sort -t, -k1,1 >> out.123/manifest.csv
chmod -w out.123/manifest.csv
\rm out.123/tmp?.csv

tail -q -n +2 out.plate[12356]/manifest.plate*.csv > out.12356/tmp1.csv
sed -i '1isubject,sample,bampath,type,study,group,age,sex,plate' out.12356/tmp1.csv
awk 'BEGIN{FS=OFS=","}{print $2,$1,$4,$5,$6,$7,$8,$9}' out.12356/tmp1.csv > out.12356/tmp2.csv
head -1 out.12356/tmp2.csv > out.12356/manifest.csv
tail -n +2 out.12356/tmp2.csv | sort -t, -k1,1 >> out.12356/manifest.csv
chmod -w out.12356/manifest.csv
\rm out.12356/tmp?.csv

tail -q -n +2 out.plate[123456]/manifest.plate*.csv > out.123456/tmp1.csv
sed -i '1isubject,sample,bampath,type,study,group,age,sex,plate' out.123456/tmp1.csv
awk 'BEGIN{FS=OFS=","}{print $2,$1,$4,$5,$6,$7,$8,$9}' out.123456/tmp1.csv > out.123456/tmp2.csv
head -1 out.123456/tmp2.csv > out.123456/manifest.csv
tail -n +2 out.123456/tmp2.csv | sort -t, -k1,1 >> out.123456/manifest.csv
chmod -w out.123456/manifest.csv
\rm out.123456/tmp?.csv

#tail -q -n +2 out.plate{13,14}/manifest.plate*.csv > out.1314/tmp1.csv
tail -q -n +2 out.plate{13,14}/original.mani.plate*.csv > out.1314/tmp1.csv
sed -i '1isubject,sample,bampath,type,study,group,age,sex,plate' out.1314/tmp1.csv
awk 'BEGIN{FS=OFS=","}{print $2,$1,$4,$5,$6,$7,$8,$9}' out.1314/tmp1.csv > out.1314/tmp2.csv
head -1 out.1314/tmp2.csv > out.1314/manifest.csv
tail -n +2 out.1314/tmp2.csv | sort -t, -k1,1 >> out.1314/manifest.csv
chmod -w out.1314/manifest.csv
\rm out.1314/tmp?.csv




```


Drop species name and add case/control status ...

```
for dir in out.123 out.12356 out.123456 ; do
head -1 ${PWD}/${dir}/Counts.normalized.subtracted.trim.csv > ${PWD}/${dir}/tmp1.csv
tail -n +3 ${PWD}/${dir}/Counts.normalized.subtracted.trim.csv >> ${PWD}/${dir}/tmp1.csv
awk 'BEGIN{FS=OFS=","}{print $1,$2,$5,$8}' ${PWD}/${dir}/manifest.csv > ${PWD}/${dir}/tmp2.csv
join --header -t, -1 1 -2 3 ${PWD}/${dir}/tmp2.csv ${PWD}/${dir}/tmp1.csv > ${PWD}/${dir}/tmp3.csv
cut -d, -f1-4,6- ${PWD}/${dir}/tmp3.csv > ${PWD}/${dir}/Counts.normalized.subtracted.trim.plus.csv
\rm ${dir}/tmp?.csv
done
```


```
sbatch --nodes=1 --ntasks=2 --mem=30G --export=None --wrap="python3 -c \"import pandas as pd; pd.read_csv('out.123/Counts.normalized.subtracted.trim.plus.csv', header=[0],index_col=[0,1,2,3,4],low_memory=False).groupby(['subject','group','plate','type'],dropna=False).min().to_csv('out.123/Counts.normalized.subtracted.trim.plus.mins.csv')\""

sbatch --nodes=1 --ntasks=2 --mem=30G --export=None --wrap="python3 -c \"import pandas as pd; pd.read_csv('out.12356/Counts.normalized.subtracted.trim.plus.csv', header=[0],index_col=[0,1,2,3,4],low_memory=False).groupby(['subject','group','plate','type'],dropna=False).min().to_csv('out.12356/Counts.normalized.subtracted.trim.plus.mins.csv')\""

sbatch --nodes=1 --ntasks=2 --mem=30G --export=None --wrap="python3 -c \"import pandas as pd; pd.read_csv('out.123456/Counts.normalized.subtracted.trim.plus.csv', header=[0],index_col=[0,1,2,3,4],low_memory=False).groupby(['subject','group','plate','type'],dropna=False).min().to_csv('out.123456/Counts.normalized.subtracted.trim.plus.mins.csv')\""
```




```
for f in ${PWD}/out.123*/Multiplate_Peptide_Comparison-*-Prop_test_results*.csv ; do
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=4 --mem=60G --export=None --wrap="module load r pandoc; PeptideComparison.Rmd -i ${f} -o ${f%.csv} -c $(dirname ${f})/Counts.normalized.subtracted.trim.plus.mins.csv"
done

```




Run with JUST public epitopes

```
for counts in ${PWD}/out.plate[123456]/Counts.normalized.subtracted.trim.select-{123,12356,123456}.csv 
${PWD}/out.plate[123456]/Zscores.select-{123,12356,123456}.csv ; do 
echo $counts
d=$( dirname ${counts} )
cat ${counts} | datamash transpose -t, > ${d}/tmp1.csv
head -2 ${d}/tmp1.csv > ${d}/tmp2.csv
join --header -t, /francislab/data1/refs/PhIP-Seq/VirScan/public_epitope_annotations.ids.join_sorted.txt <( tail -n +3 ${d}/tmp1.csv) >> ${d}/tmp2.csv
cat ${d}/tmp2.csv | datamash transpose -t, > ${counts%.csv}.public.csv
done
```









```
\rm commands

plates=$( ls -d ${PWD}/out.plate[123] 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )

echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select-123.public.csv -o ${PWD}/out.123 -p ${plates} --counts >> commands
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select-123.public.csv -o ${PWD}/out.123 -p ${plates} --counts --sex M >> commands
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select-123.public.csv -o ${PWD}/out.123 -p ${plates} --counts --sex F >> commands

for z in 3.5 5 10 15 20 30 40 50; do
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select-123.public.csv -o ${PWD}/out.123 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select-123.public.csv -o ${PWD}/out.123 -p ${plates} --sex M
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select-123.public.csv -o ${PWD}/out.123 -p ${plates} --sex F
done >> commands

plates=$( ls -d ${PWD}/out.plate[12356] 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )

echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select-12356.public.csv -o ${PWD}/out.12356 -p ${plates} --counts >> commands
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select-12356.public.csv -o ${PWD}/out.12356 -p ${plates} --counts --sex M >> commands
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select-12356.public.csv -o ${PWD}/out.12356 -p ${plates} --counts --sex F >> commands

for z in 3.5 5 10 15 20 30 40 50; do
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select-12356.public.csv -o ${PWD}/out.12356 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select-12356.public.csv -o ${PWD}/out.12356 -p ${plates} --sex M
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select-12356.public.csv -o ${PWD}/out.12356 -p ${plates} --sex F
done >> commands

plates=$( ls -d ${PWD}/out.plate[123456] 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )

echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select-123456.public.csv -o ${PWD}/out.123456 -p ${plates} --counts >> commands
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select-123456.public.csv -o ${PWD}/out.123456 -p ${plates} --counts --sex M >> commands
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select-123456.public.csv -o ${PWD}/out.123456 -p ${plates} --counts --sex F >> commands

for z in 3.5 5 10 15 20 30 40 50; do
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select-123456.public.csv -o ${PWD}/out.123456 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select-123456.public.csv -o ${PWD}/out.123456 -p ${plates} --sex M
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select-123456.public.csv -o ${PWD}/out.123456 -p ${plates} --sex F
done >> commands

commands_array_wrapper.bash --array_file commands --time 4-0 --threads 2 --mem 15G
```


```
box_upload.bash out.{123,12356,123456}/Multiplate*public-case-control*.csv
```



```
for f in ${PWD}/out.123*/Multiplate_Peptide_Comparison-*.public-case-control-Prop_test_results*.csv ; do
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=4 --mem=60G --export=None --wrap="module load r pandoc; PeptideComparison.Rmd -i ${f} -o ${f%.csv} -c $(dirname ${f})/Counts.normalized.subtracted.trim.plus.mins.csv"
done
```
















Compare AGS control's seropositivity with that from covariates file
```
join --header -t, <( grep -h -o -E "AGS[[:digit:]]{5}" /francislab/data1/raw/202*-Illumina-PhIP/L*csv | sort | uniq | sed '1iAGSid' ) <( awk 'BEGIN{OFS=","}{print $1,$27,$28,$29,$30}' /francislab/data1/users/gguerra/20241126-Geno-Scripts-Data-Notes/AGS_Ig_Analysis/Cleaned_Covariates_with_HLA.tsv )


join --header -t, <( grep -h -o -E "AGS[[:digit:]]{5}" /francislab/data1/raw/202*-Illumina-PhIP/L*csv | sort | uniq | sed '1iAGSid' ) <( awk 'BEGIN{OFS=","}{print $1,$27,$28,$29,$30}' /francislab/data1/users/gguerra/20241126-Geno-Scripts-Data-Notes/AGS_Ig_Analysis/Cleaned_Covariates_with_HLA.tsv ) | grep -vs ",NA,NA,NA,NA"

| wc -l
82



awk 'BEGIN{OFS=","}{print $1,$27,$28,$29,$30}' /francislab/data1/users/gguerra/20241126-Geno-Scripts-Data-Notes/AGS_Ig_Analysis/Cleaned_Covariates_with_HLA.tsv > AGS_calls.csv

awk 'BEGIN{FS=OFS=","}(NR>1 && $8!=""){print $8,$2,$9,$10,$21}' /francislab/data1/raw/20241204-Illumina-PhIP/L1_full_covariatesv2_Vir3_phip-seq_GBM_p1_MENPEN_p13_12-6-24hmh.csv >> tmp.csv
awk 'BEGIN{FS=OFS=","}(NR>1 && $10!=""){print $10,$3,$11,$12,$23}' /francislab/data1/raw/20241224-Illumina-PhIP/L2_full_covariates_Vir3_phip-seq_GBM_p2_MENPEN_p14_12-29-24hmh_L2_Covar.csv >> tmp.csv
awk 'BEGIN{FS=OFS=","}(NR>1 && $10!=""){print $10,$3,$11,$12,$23}' /francislab/data1/raw/20250128-Illumina-PhIP/L3_full_covariates_Vir3_phip-seq_GBM_p3_and_p4_1-28-25hmh.csv >> tmp.csv
awk 'BEGIN{FS=OFS=","}(NR>1 && $10!=""){print $10,$3,$11,$12,$23}' /francislab/data1/raw/20250409-Illumina-PhIP/L4_full_covariates_Vir3_phip-seq_GBM_p5_and_p6_4-10-25hmh.csv >> tmp.csv
sort -t, -k1,1 tmp.csv > AGS_manifest.csv
sed -i '1iAGSid,UCSFid,age,sex,plate' AGS_manifest.csv

join --header -t, AGS_manifest.csv AGS_calls.csv | awk 'BEGIN{FS=OFS=","}{print $2,$1,$3,$4,$5,$6,$7,$8,$9 }' > tmp.csv
head -1 tmp.csv > AGS.csv
tail -n +2 tmp.csv | sort -t, -k1,1 >> AGS.csv

merge_matrices.py --axis index --de_nan --de_neg --int \
  --header_rows 1 --index_col subject --index_col type --index_col id \
  --out ${PWD}/out.123456/seropositive.10.csv \
  ${PWD}/out.plate?/seropositive.10.csv

merge_matrices.py --axis index --de_nan --de_neg --int \
  --header_rows 1 --index_col subject --index_col type --index_col id \
  --out ${PWD}/out.123456/seropositive.3.5.csv \
  ${PWD}/out.plate?/seropositive.3.5.csv

join --header -t, AGS.csv out.123456/seropositive.10.csv | cut -d, -f1-11,39-47 > out.123456/AGS.seropositive.10.csv
join --header -t, AGS.csv out.123456/seropositive.3.5.csv | cut -d, -f1-11,39-47 > out.123456/AGS.seropositive.3.5.csv
```

















##	20250507



Reset....

Meningiomas are on 13 and 14. Controls are on 1-6

Merge all 8 plates (or just 7)

Change Meningioma groups all to "meningioma"

Then run meningioma / control




please run the analysis comparing the meningioma samples to the AGS controls? Same analyses (public virscan seropositivity, and peptides , etc). Please put it in a separate folder.

While we are messing with these, could you please convert the HTML script to exp() the beta and print the Odds Ratio on the x-axis of the volcano plots.

Please do this for the GBM Phip data as well. I have to use these in a talk in a few weeks







```
ln -s /francislab/data1/working/20241204-Illumina-PhIP/20250411-PhIP/out.plate13
ln -s /francislab/data1/working/20241224-Illumina-PhIP/20250411-PhIP/out.plate14
```



```
mkdir out.123561314
merge_all_combined_counts_files.py --int --de_nan --out out.123561314/Plibs.csv out.plate{1,2,3,5,6,13,14}/counts/PLib*

tail -n +2 out.123561314/Plibs.csv | cut -d, -f1 | sort > out.123561314/Plibs.id.csv
sed -i '1iid' out.123561314/Plibs.id.csv
```


```
for i in 1 2 3 5 6 13 14; do
  dir=out.plate${i}
	echo $dir
  cat ${dir}/Counts.normalized.subtracted.trim.csv | datamash transpose -t, > ${dir}/tmp1.csv
  head -2 ${dir}/tmp1.csv > ${dir}/tmp2.csv
  join --header -t, out.123561314/Plibs.id.csv <( tail -n +3 ${dir}/tmp1.csv ) >> ${dir}/tmp2.csv
  cat ${dir}/tmp2.csv | datamash transpose -t, > ${dir}/Counts.normalized.subtracted.trim.select-123561314.csv
  box_upload.bash ${dir}/Counts.normalized.subtracted.trim.select-123561314.csv

  head -2 ${dir}/Zscores.t.csv > ${dir}/Zscores.select-123561314.t.csv
  join --header -t, out.123561314/Plibs.id.csv <( tail -n +3 ${dir}/Zscores.t.csv ) >> ${dir}/Zscores.select-123561314.t.csv
  cat ${dir}/Zscores.select-123561314.t.csv | datamash transpose -t, > ${dir}/Zscores.select-123561314.csv
  box_upload.bash ${dir}/Zscores.select-123561314.csv

  head -2 ${dir}/Zscores.minimums.t.csv > ${dir}/Zscores.select-123561314.minimums.t.csv
  join --header -t, out.123561314/Plibs.id.csv <( tail -n +3 ${dir}/Zscores.minimums.t.csv ) >> ${dir}/Zscores.select-123561314.minimums.t.csv
  cat ${dir}/Zscores.select-123561314.minimums.t.csv | datamash transpose -t, > ${dir}/Zscores.select-123561314.minimums.csv
  box_upload.bash ${dir}/Zscores.select-123561314.minimums.csv
done
```






Individual plate runs here are not really usable. No plate has Meningioma and Control on them.

```
#	\rm commands
#	
#	for i in 13 14 ; do
#	dir=out.plate${i}
#	manifest=${dir}/manifest.plate${i}.csv
#	odir=${dir}
#	for z in 3.5 5 10 15 20 30 40 50; do
#	for base in Zscores.select-1314.csv Counts.normalized.subtracted.trim.select-1314.csv ; do
#	echo module load r\; Seropositivity_Comparison.R --zscore ${z} --manifest ${manifest}  --output_dir ${odir} -a case -b control --sfilename ${dir}/seropositive.${z}.csv
#	echo module load r\; Count_Viral_Tile_Hit_Fraction.R --zscore ${z} --manifest ${manifest}  --output_dir ${odir} -a case -b control --zfilename ${dir}/${base}
#	echo module load r\; Case_Control_Z_Script.R --zscore ${z} --manifest ${manifest} --output_dir ${odir} -a case -b control --zfilename ${dir}/${base}
#	done ; done ; done >> commands
#	
#	commands_array_wrapper.bash --array_file commands --time 4-0 --threads 2 --mem 15G
```

```
#	box_upload.bash out.plate1[34]/{Tile_Comparison,Viral_Ser,Viral_Frac_Hits,Seropositivity}*
```





Need to modify manifests

Meningioma isn't Case/Control

```
cp out.plate13/manifest.plate13.csv out.plate13/original.mani.plate13.csv
sed -i 's/\(Hypermitotic\|Immune-enriched\|Merlin-intact\)/meningioma/g' out.plate13/manifest.plate13.csv 

cp out.plate14/manifest.plate14.csv out.plate14/original.mani.plate14.csv
sed -i 's/\(Hypermitotic\|Immune-enriched\|Merlin-intact\)/meningioma/g' out.plate14/manifest.plate14.csv 
```




```
\rm commands


plates=$( ls -d ${PWD}/out.plate{1,2,3,5,6,13,14} 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )

echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a meningioma -b control --zfile_basename Counts.normalized.subtracted.trim.select-123561314.csv -o ${PWD}/out.123561314 -p ${plates} --counts >> commands
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a meningioma -b control --zfile_basename Counts.normalized.subtracted.trim.select-123561314.csv -o ${PWD}/out.123561314 -p ${plates} --counts --sex M >> commands
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a meningioma -b control --zfile_basename Counts.normalized.subtracted.trim.select-123561314.csv -o ${PWD}/out.123561314 -p ${plates} --counts --sex F >> commands

for z in 3.5 5 10 15 20 30 40 50; do
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a meningioma -b control --zfile_basename Zscores.select-123561314.csv -o ${PWD}/out.123561314 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a meningioma -b control --zfile_basename Zscores.select-123561314.csv -o ${PWD}/out.123561314 -p ${plates} --sex M
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a meningioma -b control --zfile_basename Zscores.select-123561314.csv -o ${PWD}/out.123561314 -p ${plates} --sex F
#echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} -a meningioma -b control -o ${PWD}/out.123561314 -p ${plates}  --zfile_basename Counts.normalized.subtracted.trim.select-123561314.csv
#echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} -a meningioma -b control -o ${PWD}/out.123561314 -p ${plates} --zfile_basename Zscores.select-123561314.csv
done >> commands

echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z 3.5 -a meningioma -b control --sfile_basename seropositive.3.5.csv -o ${PWD}/out.123561314 -p ${plates} >> commands
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z 3.5 -a meningioma -b control --sfile_basename seropositive.3.5.csv -o ${PWD}/out.123561314 -p ${plates} --sex M >> commands
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z 3.5 -a meningioma -b control --sfile_basename seropositive.3.5.csv -o ${PWD}/out.123561314 -p ${plates} --sex F >> commands
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z 10 -a meningioma -b control --sfile_basename seropositive.10.csv -o ${PWD}/out.123561314 -p ${plates} >> commands
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z 10 -a meningioma -b control --sfile_basename seropositive.10.csv -o ${PWD}/out.123561314 -p ${plates} --sex M >> commands
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z 10 -a meningioma -b control --sfile_basename seropositive.10.csv -o ${PWD}/out.123561314 -p ${plates} --sex F >> commands


commands_array_wrapper.bash --array_file commands --time 4-0 --threads 2 --mem 15G
```


16 failures since the individual plates weren't run

Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R Missing Viral_Frac_Hits



```
box_upload.bash out.123561314/Multiplate*
```











```
merge_matrices.py --axis index --de_nan --de_neg \
  --header_rows 2 --index_col subject --index_col type --index_col species \
  --out ${PWD}/out.123561314/Counts.normalized.subtracted.trim.csv \
  ${PWD}/out.plate{1,2,3,5,6,13,14}/Counts.normalized.subtracted.trim.csv

merge_matrices.py --axis index --de_nan --de_neg \
  --header_rows 2 --index_col subject --index_col type --index_col species \
  --out ${PWD}/out.123561314/Zscores.csv \
  ${PWD}/out.plate{1,2,3,5,6,13,14}/Zscores.csv

```


```
tail -q -n +2 out.plate{1,2,3,5,6,13,14}/manifest.plate*.csv > out.123561314/tmp1.csv
sed -i '1isubject,sample,bampath,type,study,group,age,sex,plate' out.123561314/tmp1.csv
awk 'BEGIN{FS=OFS=","}{print $2,$1,$4,$5,$6,$7,$8,$9}' out.123561314/tmp1.csv > out.123561314/tmp2.csv
head -1 out.123561314/tmp2.csv > out.123561314/manifest.csv
tail -n +2 out.123561314/tmp2.csv | sort -t, -k1,1 >> out.123561314/manifest.csv
chmod -w out.123561314/manifest.csv
\rm out.123561314/tmp?.csv
```


Drop species name and add case/control status ...

```
for dir in out.123561314 ; do
head -1 ${PWD}/${dir}/Counts.normalized.subtracted.trim.csv > ${PWD}/${dir}/tmp1.csv
tail -n +3 ${PWD}/${dir}/Counts.normalized.subtracted.trim.csv >> ${PWD}/${dir}/tmp1.csv
awk 'BEGIN{FS=OFS=","}{print $1,$2,$5,$8}' ${PWD}/${dir}/manifest.csv > ${PWD}/${dir}/tmp2.csv
join --header -t, -1 1 -2 3 ${PWD}/${dir}/tmp2.csv ${PWD}/${dir}/tmp1.csv > ${PWD}/${dir}/tmp3.csv
cut -d, -f1-4,6- ${PWD}/${dir}/tmp3.csv > ${PWD}/${dir}/Counts.normalized.subtracted.trim.plus.csv
\rm ${dir}/tmp?.csv
done
```


```
sbatch --nodes=1 --ntasks=2 --mem=30G --export=None --wrap="python3 -c \"import pandas as pd; pd.read_csv('out.123561314/Counts.normalized.subtracted.trim.plus.csv', header=[0],index_col=[0,1,2,3,4],low_memory=False).groupby(['subject','group','plate','type'],dropna=False).min().to_csv('out.123561314/Counts.normalized.subtracted.trim.plus.mins.csv')\""
```


```
for f in ${PWD}/out.123561314/Multiplate_Peptide_Comparison-*-Prop_test_results*.csv ; do
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=4 --mem=30G --export=None --wrap="module load r pandoc; PeptideComparison.Rmd -i ${f} -o ${f%.csv} -c $(dirname ${f})/Counts.normalized.subtracted.trim.plus.mins.csv"
done
```

```
box_upload.bash out.123561314/Multiplate_Peptide_Comparison*html
```






```
for f in ${PWD}/out.123*/Multiplate_Peptide_Comparison-*-Prop_test_results*.csv ; do
echo "module load r pandoc; PeptideComparison.Rmd -i ${f} -o ${f%.csv} -c $(dirname ${f})/Counts.normalized.subtracted.trim.plus.mins.csv"
done > commands

commands_array_wrapper.bash --array_file commands --time 4-0 --threads 4 --mem 30G
```






Awful. P-values all almost 1. Will need to investigate where things went bad.












REDO. THIS RMD IS HARD CODED TO CASE CONTROL. NEED TO ADD OPTIONS?


```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=vs123561314 --wrap="module load r pandoc; virus_scores.Rmd -d ${PWD}/out.plate1 -d ${PWD}/out.plate2 -d ${PWD}/out.plate3 -d ${PWD}/out.plate4 -d ${PWD}/out.plate5 -d ${PWD}/out.plate13 -d ${PWD}/out.plate14 -o ${PWD}/out.123561314/virus_scores"
```

```
box_upload.bash out.123561314/virus_score*
```


##	20250512


Hey hey- Could you please make a a couple files for me? Basically I want the public epitopes for your “normalized subtracted” version and the Z=10 for the z score.

Id like them for all the subjects cases and controls (put 1/0 to denote) and age, sex, plate, CMV, EBV, HSV, VZV. Basically just like the attached version, but with all the subjects and case status and for the Z score and the subtracted. Make sense?


```
merge_matrices.py --axis columns --de_nan --de_neg   --header_rows 9 --index_col id --index_col species   --out ${PWD}/out.123456/Counts.normalized.subtracted.csv   ${PWD}/out.plate{1,2,3,4,5,6}/Counts.normalized.subtracted.csv

head -2 ${PWD}/out.123456/Counts.normalized.subtracted.csv > tmp1.csv
tail -n +4 ${PWD}/out.123456/Counts.normalized.subtracted.csv | head -1 >> tmp1.csv
tail -n +6 ${PWD}/out.123456/Counts.normalized.subtracted.csv | head -3 >> tmp1.csv
tail -n +9 ${PWD}/out.123456/Counts.normalized.subtracted.csv | head -1 > tmp2.csv
tail -n +10 ${PWD}/out.123456/Counts.normalized.subtracted.csv | sort -t, -k1,1 >> tmp2.csv
join --header -t, /francislab/data1/refs/PhIP-Seq/VirScan/public_epitope_annotations.ids.join_sorted.txt tmp2.csv >> tmp1.csv
cat tmp1.csv | datamash transpose -t, > tmp3.csv
head -2 tmp3.csv > tmp4.csv
tail -n +3 tmp3.csv | grep ",glioma serum," | sort -t, -k1,1 >> tmp4.csv
l=$( head -n 1 AGS.csv )
echo -n ${l}, > tmp5.csv
head -1 tmp4.csv | cut -d, -f2- >> tmp5.csv
join --header -t, -a 2 -o auto AGS.csv <( tail -n +2 tmp4.csv ) >> tmp5.csv
cut -d, -f1,2,6-10,12- tmp5.csv > ${PWD}/out.123456/Counts.normalized.subtracted.glioma.AGS.csv
sed -i '1s/,id,id,id,id,id,/,subject,group,age,sex,plate,/' ${PWD}/out.123456/Counts.normalized.subtracted.glioma.AGS.csv
sed -i '2s/,species,species,species,species,species,/,subject,group,age,sex,plate,/' ${PWD}/out.123456/Counts.normalized.subtracted.glioma.AGS.csv
box_upload.bash ${PWD}/out.123456/Counts.normalized.subtracted.glioma.AGS.csv
```


```
merge_matrices.py --axis columns --de_nan --de_neg   --header_rows 3 --index_col id --index_col species   --out ${PWD}/out.123456/Zscores.t.csv   ${PWD}/out.plate{1,2,3,4,5,6}/Zscores.t.csv

head -3 ${PWD}/out.123456/Zscores.t.csv | tail -n 1 > tmp1.csv
head -2 ${PWD}/out.123456/Zscores.t.csv >> tmp1.csv
tail -n +4 ${PWD}/out.123456/Zscores.t.csv | sort -t, -k1,1 >> tmp1.csv
head -2 tmp1.csv > tmp2.csv
join --header -t, /francislab/data1/refs/PhIP-Seq/VirScan/public_epitope_annotations.ids.join_sorted.txt <( tail -n +3 tmp1.csv ) >> tmp2.csv
cat tmp2.csv | datamash transpose -t, > tmp3.csv
head -2 tmp3.csv > tmp4.csv
tail -n +3 tmp3.csv | sort -t, -k1,1 >> tmp4.csv
l=$( head -n 1 out.123456/manifest.csv )
echo -n ${l}, > tmp5.csv
head -1 tmp4.csv | cut -d, -f2- >> tmp5.csv
join --header -t, out.123456/manifest.csv <( tail -n +2 tmp4.csv ) >> tmp5.csv
head -2 tmp5.csv > tmp6.csv
tail -n +3 tmp5.csv | grep ",glioma serum," >> tmp6.csv
l=$( head -n 1 AGS.csv )
echo -n ${l}, > tmp7.csv
head -1 tmp6.csv | cut -d, -f2- >> tmp7.csv
join --header -t, -a 2 -o auto AGS.csv <( tail -n +2 tmp6.csv ) >> tmp7.csv
cut -d, -f1,2,6-10,13-16,19- tmp7.csv > ${PWD}/out.123456/Zscores.glioma.AGS.csv
box_upload.bash ${PWD}/out.123456/Zscores.glioma.AGS.csv

```


Could you also do the same export of the PEs with basic data (like type of meng) for the the meningioma subjects. (but just the meningioma, not controls)


```
merge_matrices.py --axis columns --de_nan --de_neg   --header_rows 9 --index_col id --index_col species   --out ${PWD}/out.1314/Counts.normalized.subtracted.csv   ${PWD}/out.plate{13,14}/Counts.normalized.subtracted.csv

head -2 ${PWD}/out.1314/Counts.normalized.subtracted.csv > tmp1.csv
tail -n +4 ${PWD}/out.1314/Counts.normalized.subtracted.csv | head -1 >> tmp1.csv
tail -n +6 ${PWD}/out.1314/Counts.normalized.subtracted.csv | head -3 >> tmp1.csv
tail -n +9 ${PWD}/out.1314/Counts.normalized.subtracted.csv | head -1 > tmp2.csv
tail -n +10 ${PWD}/out.1314/Counts.normalized.subtracted.csv | sort -t, -k1,1 >> tmp2.csv
join --header -t, /francislab/data1/refs/PhIP-Seq/VirScan/public_epitope_annotations.ids.join_sorted.txt tmp2.csv >> tmp1.csv
cat tmp1.csv | datamash transpose -t, > tmp3.csv
head -2 tmp3.csv > tmp4.csv
tail -n +3 tmp3.csv | grep ",meningioma serum," | sort -t, -k1,1 >> tmp4.csv
mv tmp4.csv ${PWD}/out.1314/Counts.normalized.subtracted.meningioma.csv 
sed -i '1s/^id,id,id,id,id,id,id,/sample,subject,group,type,age,sex,plate,/' ${PWD}/out.1314/Counts.normalized.subtracted.meningioma.csv
sed -i '2s/^species,species,species,species,species,species,species,/sample,subject,group,type,age,sex,plate,/' ${PWD}/out.1314/Counts.normalized.subtracted.meningioma.csv
box_upload.bash ${PWD}/out.1314/Counts.normalized.subtracted.meningioma.csv
```


```
merge_matrices.py --axis columns --de_nan --de_neg   --header_rows 3 --index_col id --index_col species   --out ${PWD}/out.1314/Zscores.t.csv  ${PWD}/out.plate{13,14}/Zscores.t.csv

head -3 ${PWD}/out.1314/Zscores.t.csv | tail -n 1 > tmp1.csv
head -2 ${PWD}/out.1314/Zscores.t.csv >> tmp1.csv
tail -n +4 ${PWD}/out.1314/Zscores.t.csv | sort -t, -k1,1 >> tmp1.csv
head -2 tmp1.csv > tmp2.csv
join --header -t, /francislab/data1/refs/PhIP-Seq/VirScan/public_epitope_annotations.ids.join_sorted.txt <( tail -n +3 tmp1.csv ) >> tmp2.csv
cat tmp2.csv | datamash transpose -t, > tmp3.csv
head -2 tmp3.csv > tmp4.csv
tail -n +3 tmp3.csv | sort -t, -k1,1 >> tmp4.csv
l=$( head -n 1 out.1314/manifest.csv )
echo -n ${l}, > tmp5.csv
head -1 tmp4.csv | cut -d, -f2- >> tmp5.csv
join --header -t, out.1314/manifest.csv <( tail -n +2 tmp4.csv ) >> tmp5.csv
head -2 tmp5.csv > tmp6.csv
tail -n +3 tmp5.csv | grep ",meningioma serum," >> tmp6.csv
cut -d, -f1,2,5-8,10- tmp6.csv > ${PWD}/out.1314/Zscores.meningioma.csv
box_upload.bash ${PWD}/out.1314/Zscores.meningioma.csv

```










##	20250515



```

for i in 1 2 3 4 5 6 13 14; do
  dir=out.plate${i}
	phip_seq_phagelib_normalize_counts.py -i ${dir}/Counts.csv
done
#sed -i '1s/^subject,type,sample/y,x,id/' out.plate*/Counts.normalized.normalized.trim.csv 
#sed -i '2s/^,,/subject,type,species/' out.plate*/Counts.normalized.normalized.trim.csv 
sed -i '1s/^subject,type,sample/y,x,id/' out.plate*/Counts.normalized.normalized.subtracted.trim.csv 
sed -i '2s/^,,/subject,type,species/' out.plate*/Counts.normalized.normalized.subtracted.trim.csv 

```

```
#\rm commands
#plates=$( ls -d ${PWD}/out.plate[123456] 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )
#echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.normalized.trim.csv -o ${PWD}/out.123456 -p ${plates} --counts >> commands
#echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.normalized.trim.csv -o ${PWD}/out.123456 -p ${plates} --counts --sex M >> commands
#echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.normalized.trim.csv -o ${PWD}/out.123456 -p ${plates} --counts --sex F >> commands
#commands_array_wrapper.bash --array_file commands --time 4-0 --threads 4 --mem 30G
```


```
\rm commands
plates=$( ls -d ${PWD}/out.plate[123456] 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.normalized.subtracted.trim.csv -o ${PWD}/out.123456 -p ${plates} --counts >> commands
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.normalized.subtracted.trim.csv -o ${PWD}/out.123456 -p ${plates} --counts --sex M >> commands
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.normalized.subtracted.trim.csv -o ${PWD}/out.123456 -p ${plates} --counts --sex F >> commands

plates=$( ls -d ${PWD}/out.plate[12356] 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.normalized.subtracted.trim.csv -o ${PWD}/out.12356 -p ${plates} --counts >> commands
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.normalized.subtracted.trim.csv -o ${PWD}/out.12356 -p ${plates} --counts --sex M >> commands
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.normalized.subtracted.trim.csv -o ${PWD}/out.12356 -p ${plates} --counts --sex F >> commands

commands_array_wrapper.bash --array_file commands --time 4-0 --threads 4 --mem 30G
```



create out.123456/Counts.normalized.normalized.trim.plus.mins.csv

```
#merge_matrices.py --axis index --de_nan --de_neg \
#  --header_rows 2 --index_col subject --index_col type --index_col species \
#  --out ${PWD}/out.12356/Counts.normalized.normalized.trim.csv \
#  ${PWD}/out.plate[12356]/Counts.normalized.normalized.trim.csv
#
#merge_matrices.py --axis index --de_nan --de_neg \
#  --header_rows 2 --index_col subject --index_col type --index_col species \
#  --out ${PWD}/out.123456/Counts.normalized.normalized.trim.csv \
#  ${PWD}/out.plate[123456]/Counts.normalized.normalized.trim.csv
#
#for dir in out.12356 out.123456 ; do
#head -1 ${PWD}/${dir}/Counts.normalized.normalized.trim.csv > ${PWD}/${dir}/tmp1.csv
#tail -n +3 ${PWD}/${dir}/Counts.normalized.normalized.trim.csv >> ${PWD}/${dir}/tmp1.csv
#awk 'BEGIN{FS=OFS=","}{print $1,$2,$5,$8}' ${PWD}/${dir}/manifest.csv > ${PWD}/${dir}/tmp2.csv
#join --header -t, -1 1 -2 3 ${PWD}/${dir}/tmp2.csv ${PWD}/${dir}/tmp1.csv > ${PWD}/${dir}/tmp3.csv
#cut -d, -f1-4,6- ${PWD}/${dir}/tmp3.csv > ${PWD}/${dir}/Counts.normalized.normalized.trim.plus.csv
#\rm ${dir}/tmp?.csv
#done
#
#sbatch --nodes=1 --ntasks=2 --mem=30G --export=None --wrap="python3 -c \"import pandas as pd; pd.read_csv('out.123456/Counts.normalized.normalized.trim.plus.csv', header=[0],index_col=[0,1,2,3,4],low_memory=False).groupby(['subject','group','plate','type'],dropna=False).min().to_csv('out.123456/Counts.normalized.normalized.trim.plus.mins.csv')\""
#
#for f in ${PWD}/out.123456/Multiplate_Peptide_Comparison-Counts.normalized.normalized.*-Prop_test_results*.csv ; do
#sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=4 --mem=30G --export=None --wrap="module load r pandoc; PeptideComparison.Rmd -i ${f} -o ${f%.csv} -c $(dirname ${f})/Counts.normalized.normalized.trim.plus.mins.csv"
#done
```





create out.123456/Counts.normalized.normalized.subtracted.trim.plus.mins.csv

```
merge_matrices.py --axis index --de_nan --de_neg \
  --header_rows 2 --index_col subject --index_col type --index_col species \
  --out ${PWD}/out.12356/Counts.normalized.normalized.subtracted.trim.csv \
  ${PWD}/out.plate[12356]/Counts.normalized.normalized.subtracted.trim.csv

merge_matrices.py --axis index --de_nan --de_neg \
  --header_rows 2 --index_col subject --index_col type --index_col species \
  --out ${PWD}/out.123456/Counts.normalized.normalized.subtracted.trim.csv \
  ${PWD}/out.plate[123456]/Counts.normalized.normalized.subtracted.trim.csv

for dir in out.12356 out.123456 ; do
head -1 ${PWD}/${dir}/Counts.normalized.normalized.subtracted.trim.csv > ${PWD}/${dir}/tmp1.csv
tail -n +3 ${PWD}/${dir}/Counts.normalized.normalized.subtracted.trim.csv >> ${PWD}/${dir}/tmp1.csv
awk 'BEGIN{FS=OFS=","}{print $1,$2,$5,$8}' ${PWD}/${dir}/manifest.csv > ${PWD}/${dir}/tmp2.csv
join --header -t, -1 1 -2 3 ${PWD}/${dir}/tmp2.csv ${PWD}/${dir}/tmp1.csv > ${PWD}/${dir}/tmp3.csv
cut -d, -f1-4,6- ${PWD}/${dir}/tmp3.csv > ${PWD}/${dir}/Counts.normalized.normalized.subtracted.trim.plus.csv
\rm ${dir}/tmp?.csv
done

sbatch --nodes=1 --ntasks=2 --mem=30G --export=None --wrap="python3 -c \"import pandas as pd; pd.read_csv('out.12356/Counts.normalized.normalized.subtracted.trim.plus.csv', header=[0],index_col=[0,1,2,3,4],low_memory=False).groupby(['subject','group','plate','type'],dropna=False).min().to_csv('out.12356/Counts.normalized.normalized.subtracted.trim.plus.mins.csv')\""

sbatch --nodes=1 --ntasks=2 --mem=30G --export=None --wrap="python3 -c \"import pandas as pd; pd.read_csv('out.123456/Counts.normalized.normalized.subtracted.trim.plus.csv', header=[0],index_col=[0,1,2,3,4],low_memory=False).groupby(['subject','group','plate','type'],dropna=False).min().to_csv('out.123456/Counts.normalized.normalized.subtracted.trim.plus.mins.csv')\""
```


```
for f in ${PWD}/out.12356/Multiplate_Peptide_Comparison-Counts.normalized.normalized.subtracted.*-Prop_test_results*.csv ; do
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=4 --mem=30G --export=None --wrap="module load r pandoc; PeptideComparison.Rmd -i ${f} -o ${f%.csv} -c $(dirname ${f})/Counts.normalized.normalized.subtracted.trim.plus.mins.csv"
done

for f in ${PWD}/out.123456/Multiplate_Peptide_Comparison-Counts.normalized.normalized.subtracted.*-Prop_test_results*.csv ; do
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=4 --mem=30G --export=None --wrap="module load r pandoc; PeptideComparison.Rmd -i ${f} -o ${f%.csv} -c $(dirname ${f})/Counts.normalized.normalized.subtracted.trim.plus.mins.csv"
done
```




##	20250519


Run with JUST public epitopes

```
for counts in ${PWD}/out.plate[123456]/Counts.normalized.normalized.subtracted.trim.csv  ; do
echo $counts
d=$( dirname ${counts} )
cat ${counts} | datamash transpose -t, > ${d}/tmp1.csv
head -3 ${d}/tmp1.csv > ${d}/tmp2.csv
tail -n +4 ${d}/tmp1.csv | sort -t, -k1,1 >> ${d}/tmp2.csv
head -2 ${d}/tmp2.csv > ${d}/tmp3.csv
join --header -t, /francislab/data1/refs/PhIP-Seq/VirScan/public_epitope_annotations.ids.join_sorted.txt <( tail -n +3 ${d}/tmp2.csv) >> ${d}/tmp3.csv
cat ${d}/tmp3.csv | datamash transpose -t, > ${counts%.csv}.public.csv
done
```



```
\rm commands
plates=$( ls -d ${PWD}/out.plate[123456] 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.normalized.subtracted.trim.public.csv -o ${PWD}/out.123456 -p ${plates} --counts >> commands
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.normalized.subtracted.trim.public.csv -o ${PWD}/out.123456 -p ${plates} --counts --sex M >> commands
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.normalized.subtracted.trim.public.csv -o ${PWD}/out.123456 -p ${plates} --counts --sex F >> commands

plates=$( ls -d ${PWD}/out.plate[12356] 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.normalized.subtracted.trim.public.csv -o ${PWD}/out.12356 -p ${plates} --counts >> commands
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.normalized.subtracted.trim.public.csv -o ${PWD}/out.12356 -p ${plates} --counts --sex M >> commands
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a case -b control --zfile_basename Counts.normalized.normalized.subtracted.trim.public.csv -o ${PWD}/out.12356 -p ${plates} --counts --sex F >> commands

commands_array_wrapper.bash --array_file commands --time 4-0 --threads 4 --mem 30G
```





```
for f in ${PWD}/out.12356/Multiplate_Peptide_Comparison-Counts.normalized.normalized.subtracted.trim.public*-Prop_test_results*.csv ; do
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=4 --mem=30G --export=None --wrap="module load r pandoc; PeptideComparison.Rmd -i ${f} -o ${f%.csv} -c $(dirname ${f})/Counts.normalized.normalized.subtracted.trim.plus.mins.csv"
done

for f in ${PWD}/out.123456/Multiplate_Peptide_Comparison-Counts.normalized.normalized.subtracted.trim.public*-Prop_test_results*.csv ; do
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=4 --mem=30G --export=None --wrap="module load r pandoc; PeptideComparison.Rmd -i ${f} -o ${f%.csv} -c $(dirname ${f})/Counts.normalized.normalized.subtracted.trim.plus.mins.csv"
done
```






##	20250530


```
mkdir out.1234561314
merge_matrices.py --axis columns --de_nan --de_neg \
  --header_rows 9 --index_col id --index_col species \
  --out ${PWD}/out.1234561314/Counts.csv \
  ${PWD}/out.plate*/Counts.csv

merge_matrices.py --axis columns --de_nan --de_neg \
  --header_rows 9 --index_col id --index_col species \
  --out ${PWD}/out.123561314/Counts.csv \
  ${PWD}/out.plate1?/Counts.csv ${PWD}/out.plate[12356]/Counts.csv

merge_matrices.py --axis columns --de_nan --de_neg \
  --header_rows 9 --index_col id --index_col species \
  --out ${PWD}/out.12356/Counts.normalized.normalized.subtracted.csv \
  ${PWD}/out.plate[12356]/Counts.normalized.normalized.subtracted.csv

```


df = pd.read_csv('out.1234561314/Counts.csv', header=list(range(9)),index_col=[0,1],low_memory=False)

```
python3 

import pandas as pd
df = pd.read_csv('out.123561314/Counts.csv', header=list(range(9)),index_col=[0,1],low_memory=False)
df=df.droplevel([1,2,4,5,6,7,8],axis=1)
df[df < 10] = 0
df[df >= 10] = 1
df.columns = pd.MultiIndex.from_tuples([(col[0], col[1] if(col[1]=='input') else 'notblank'  ) for i, col in enumerate(df.columns)])
df.columns=df.columns.set_names(['sample','group'])

df=df.T.groupby(['group'],dropna=False).sum().T
df[df['input']==0].sort_values(by='notblank')



df.columns.get_level_values(1).value_counts()
id
glioma serum                504
pemphigus serum             120
meningioma serum             48
commercial serum control     16
Phage Library                16
input                        62

notblank 704
blank 62



glioma serum                420
pemphigus serum             120
meningioma serum             48
commercial serum control     14
Phage Library                14
input                        54

notblank 616
blank 54


10

>>> df[df['input']==0].sort_values(by='notblank').tail(10)
group                                     input  notblank
6977   Human respiratory syncytial virus    0.0     263.0
125114 Streptococcus dysgalactiae           0.0     267.0
20956  Human herpesvirus 4                  0.0     281.0
17599  Human respiratory syncytial virus    0.0     284.0
33024  Human herpesvirus 4                  0.0     303.0
63941  Enterovirus B                        0.0     307.0
15935  Cowpox virus                         0.0     340.0
52913  Human herpesvirus 4                  0.0     355.0
22261  Human respiratory syncytial virus    0.0     374.0
7041   Human respiratory syncytial virus    0.0     400.0


1

81003  Influenza A virus                                     0.0     195.0
121343 Cryptomeria japonica (Japanese cedar) (Cupressu...    0.0     197.0
6385   Hepatitis E virus                                     0.0     197.0
69594  Parainfluenza virus 5                                 0.0     198.0
96041  Influenza A virus                                     0.0     200.0
79421  Hepatitis B virus                                     0.0     207.0
34208  Human herpesvirus 5                                   0.0     210.0
71294  Camelpox virus                                        0.0     219.0
53070  Human herpesvirus 4                                   0.0     226.0
4340   Chapare virus                                         0.0     228.0
```




##	20250605

Which proteins of CMV and VZV were actually reactive?

```
python3 

import pandas as pd
df = pd.read_csv('out.123561314/Counts.csv', header=list(range(9)),index_col=[0,1],low_memory=False)
df=df.droplevel([1,2,3,4,5,6,7,8],axis=1)
sums=df.loc[pd.IndexSlice[:, 'Human herpesvirus 5'], :].sum(axis='columns')
sums=df.loc[pd.IndexSlice[:, 'Human herpesvirus 5'], :].sum(axis='columns')
sums[sums>19000].reset_index().to_csv("testing.csv",index=False)
```

```
cut -d, -f1 testing.csv | tail -n +2 | sort | sed '1iid' > list
join --header -t, list /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_species_protein.uniq.csv | cut -d, -f3 | sort | uniq | wc -l
127
grep "Human herpesvirus 5" /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_species_protein.uniq.csv | cut -d, -f3 | sort | uniq | wc -l
357
```
Not really helpful






```
python3 

import pandas as pd
df = pd.read_csv('out.123561314/Counts.csv', header=list(range(9)),index_col=[0,1],low_memory=False)
df=df.droplevel([1,2,4,6,7,8],axis=1)
df=df.loc[pd.IndexSlice[:, 'Human herpesvirus 5'], pd.IndexSlice[:,'glioma serum',:]]
df=df.droplevel([1],axis='columns')
df=df.droplevel([1],axis='index')

df.columns=df.columns.set_names(['sample','group'])
df=df.T.groupby(['group'],dropna=False).sum().T

```

```
python3 

import pandas as pd
df = pd.read_csv('out.12356/Counts.normalized.normalized.subtracted.csv', header=list(range(9)),index_col=[0,1],low_memory=False)
df=df.droplevel([1,2,4,6,7,8],axis=1)
df=df.loc[pd.IndexSlice[:, 'Human herpesvirus 5'], pd.IndexSlice[:,'glioma serum',:]]
df=df.droplevel([1],axis='columns')
df=df.droplevel([1],axis='index')

df.columns=df.columns.set_names(['sample','group'])
sums=df.T.groupby(['group']).sum().T
medians=df.T.groupby(['group']).median().T

((1+sums['case'])/(1+sums['control'])).sort_values()
((1+medians['case'])/(1+medians['control'])).sort_values()
```


Using something like
```
grep ",Human herpesvirus 5," out.12356/Multiplate_Peptide_Comparison-Counts.normalized.normalized.subtracted.trim-case-control-Prop_test_results-Z-0-sex-F.csv | head -100
grep ",Human herpesvirus 5," out.12356/Multiplate_Peptide_Comparison-Counts.normalized.normalized.subtracted.trim-case-control-Prop_test_results-Z-0-sex-M.csv | head -100
```




---

This requires Zscores.select.minimums.csv and a virus species
./Zscores.Rmd -s "Human herpesvirus 3" \

```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=Zs12356 --wrap="module load r pandoc; Zscores.Rmd -d ${PWD}/out.plate1 -d ${PWD}/out.plate2 -d ${PWD}/out.plate3 -d ${PWD}/out.plate5 -d ${PWD}/out.plate6 -o ${PWD}/out.12356/Zscores"
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=Zs123456 --wrap="module load r pandoc; Zscores.Rmd -d ${PWD}/out.plate1 -d ${PWD}/out.plate2 -d ${PWD}/out.plate3 -d ${PWD}/out.plate4 -d ${PWD}/out.plate5 -d ${PWD}/out.plate6 -o ${PWD}/out.123456/Zscores"
```
./heatmap.Rmd -i /francislab/data1/working/20250128-Illumina-PhIP/20250128c-PhIP/out.all.test/cpm_blank_subtracted.csv -o glioma_cpm_blank_subtracted














##	20250822


Can you do me a favor and turn to the PHIP-seq for the meningioma data real quick?

I need to look at it for a potential small grant application next week.

lets start with what we already did- I believe we did the meningioma/AGS control comparison, is that correct?

Can you please go ahead and do that?

We can try using just the controls that were on the mengingioma plate (if there were) or all the controls we have done so far, ignoring plate.

I don’t think we can adjust for plate because there is no cross over, but thats ok for preliminary data


All pvalues ~1 when including plate in the formula as its a "perfect predictor".



```
\rm commands

plates=$( ls -d ${PWD}/out.plate{1,2,3,5,6,13,14} 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )

echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a meningioma -b control --zfile_basename Counts.normalized.subtracted.trim.select-123561314.csv -o ${PWD}/out.123561314 -p ${plates} --counts --ignore_plate >> commands
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a meningioma -b control --zfile_basename Counts.normalized.subtracted.trim.select-123561314.csv -o ${PWD}/out.123561314 -p ${plates} --counts --sex M --ignore_plate >> commands
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 -a meningioma -b control --zfile_basename Counts.normalized.subtracted.trim.select-123561314.csv -o ${PWD}/out.123561314 -p ${plates} --counts --sex F --ignore_plate >> commands

for z in 3.5 5 10 ; do
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a meningioma -b control --zfile_basename Zscores.select-123561314.csv -o ${PWD}/out.123561314 -p ${plates} --ignore_plate
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a meningioma -b control --zfile_basename Zscores.select-123561314.csv -o ${PWD}/out.123561314 -p ${plates} --sex M --ignore_plate
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a meningioma -b control --zfile_basename Zscores.select-123561314.csv -o ${PWD}/out.123561314 -p ${plates} --sex F --ignore_plate
done >> commands

commands_array_wrapper.bash --array_file commands --time 4-0 --threads 2 --mem 15G --array 1-12%12
```





##	20250827

There aren't meningioma and controls on each plate so these may all fail at some point.


Count_Viral_Tile_Hit_Fraction.R fails AFTER writing Viral_Frac_Hits-\*

Case_Control_Z_Script.R writes Tile_Comparison

Seropositivity_Comparison.R fails so no Seropositivity_Prop_test_results-\*



```
\rm commands

for p in 1 2 3 5 6 13 14 ; do
plate=out.plate${p}
manifest=${plate}/manifest.plate${p}.csv
for z in 3.5 10 ; do
echo module load r\; Count_Viral_Tile_Hit_Fraction.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} -a meningioma -b control --zfilename ${plate}/Zscores.select-123561314.csv
echo module load r\; Case_Control_Z_Script.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} -a meningioma -b control --zfilename ${plate}/Zscores.select-123561314.csv
echo module load r\; Seropositivity_Comparison.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} -a meningioma -b control --sfilename ${plate}/seropositive.${z}.csv
done ; done >> commands

commands_array_wrapper.bash --array_file commands --time 4-0 --threads 4 --mem 30G
```

```
box_upload.bash out.plate*/{Seropositivity,Tile_Comparison,Viral}*meningioma*
```

```
\rm commands
plates=$( ls -d ${PWD}/out.plate{1,2,3,5,6,13,14} 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )

for z in 3.5 10 ; do
echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} -a meningioma -b control -o ${PWD}/out.123561314 -p ${plates} --ignore_plate --zfile_basename Zscores.select-123561314.csv
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} -a meningioma -b control --sfile_basename seropositive.${z}.csv -o ${PWD}/out.123561314 -p ${plates} --ignore_plate
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} -a meningioma -b control --sfile_basename seropositive.${z}.csv -o ${PWD}/out.123561314 -p ${plates} --ignore_plate --sex M
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} -a meningioma -b control --sfile_basename seropositive.${z}.csv -o ${PWD}/out.123561314 -p ${plates} --ignore_plate --sex F
done >> commands

commands_array_wrapper.bash --array_file commands --time 4-0 --threads 4 --mem 30G
```


```
box_upload.bash out.123561314/Multiplate_*meningioma*{log,csv}
```


##	20250828


Cross plate analysis of Phage Library samples, CSE samples and Blank samples.


T-test grid?



How to force include ALL tile ids?

```
mkdir out.12345613141516
merge_all_combined_counts_files.py --de_nan --out out.12345613141516/Plibs.csv /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_oligo.uniq.1-80.csv out.plate*/counts/PLib*.q40.count.csv.gz
sed -i 's/\.0//g' out.12345613141516/Plibs.csv 
merge_all_combined_counts_files.py --de_nan --out out.12345613141516/CSEs.csv /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_oligo.uniq.1-80.csv out.plate*/counts/CSE*.q40.count.csv.gz
sed -i 's/\.0//g' out.12345613141516/CSEs.csv 
merge_all_combined_counts_files.py --de_nan --out out.12345613141516/Blanks.csv /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_oligo.uniq.1-80.csv out.plate*/counts/input/Blank*.q40.count.csv.gz
sed -i 's/\.0//g' out.12345613141516/Blanks.csv 
```



##	20250909

```BASH
merge_all_combined_counts_files.py --de_nan --out out.12345613141516/AllSamples.csv /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_oligo.uniq.1-80.csv out.plate*/counts/input/*.q40.count.csv.gz out.plate*/counts/*.q40.count.csv.gz
sed -i 's/\.0//g' out.12345613141516/AllSamples.csv 
merge_all_combined_counts_files.py --de_nan --out out.12345613141516/AllActualSamples.csv /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_oligo.uniq.1-80.csv $( ls -1 out.plate*/counts/*.q40.count.csv.gz | grep -vs PLib | grep -vs CSE | paste -s )
sed -i 's/\.0//g' out.12345613141516/AllActualSamples.csv 
```

```BASH
wc -l out.12345613141516/{Blanks,CSEs,Plibs,AllSamples,AllActualSamples}.csv

for csv in out.12345613141516/{Blanks,CSEs,Plibs,AllSamples,AllActualSamples}.csv ; do
echo $csv
head -1 ${csv} | tr ',' '\n' | tail -n +3 | wc -l
done
```


Write sums?

```BASH
for csv in out.12345613141516/{Blanks,CSEs,Plibs,AllSamples,AllActualSamples}.csv ; do

python3 -c "import pandas as pd;df=pd.read_csv('"${csv}"',header=0,index_col=[0,1]);sums=df.sum(axis='columns');print(len(sums[sums<10]));print(len(sums[sums<1]))"

done
```


Create small subsets of these csvs by: public epitopes, viral species, ???

```BASH
for csv in out.12345613141516/{Blanks,CSEs,Plibs,AllSamples,AllActualSamples}.csv ; do
for hhv in 1 2 3 4 5 6 6A 6B 7 8 ; do
join --header -t, <( awk -v hhv=${hhv} -F, '(NR==1 || $2 == "Human herpesvirus "hhv ){print $1}' /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_species.uniq.csv ) <(head -n 1 ${csv}; tail -n +2 ${csv} | sort -t, -k1,1 ) | cut -d, -f1,3- > ${csv%.csv}.HHV${hhv}.csv
done
join --header -t, /francislab/data1/refs/PhIP-Seq/VirScan/public_epitope_annotations.ids.join_sorted.txt <(head -n 1 ${csv}; tail -n +2 ${csv} | sort -t, -k1,1 ) | cut -d, -f1,3- > ${csv%.csv}.public.csv
done
```


Shiny app to load csv, show plot, color sections by never found, always found



python3 -c "import pandas as pd;df=pd.read_csv('out.12345613141516/AllSamples.csv',header=0,index_col=[0,1]);sums=df.sum(axis='columns')"







##	20250912



1,2,3,5,6,15,16

```BASH
\rm commands

for p in 1 2 3 5 6 15 16 ; do 
plate=out.plate${p}
manifest=${plate}/manifest.plate${p}.csv
for z in 3.5 10 ; do 
echo module load r\; Count_Viral_Tile_Hit_Fraction.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} --type \"glioma serum\" -a case -b control --zfilename ${plate}/Zscores.csv
echo module load r\; Case_Control_Z_Script.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} --type \"glioma serum\" -a case -b control --zfilename ${plate}/Zscores.csv
echo module load r\; Seropositivity_Comparison.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} --type \"glioma serum\" -a case -b control --sfilename ${plate}/seropositive.${z}.csv
done ; done >> commands

commands_array_wrapper.bash --jobname individual --array_file commands --time 4-0 --threads 4 --mem 30G
```






```BASH
\rm commands

plates=$( ls -d ${PWD}/out.plate{1,2,3,5,6,15,16} 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )

echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 --type \"glioma serum\" -a case -b control --zfile_basename Counts.normalized.subtracted.trim.csv -o ${PWD}/out.123561516 -p ${plates} --counts >> commands
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 --type \"glioma serum\" -a case -b control --zfile_basename Counts.normalized.subtracted.trim.csv -o ${PWD}/out.123561516 -p ${plates} --counts --sex M >> commands
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 --type \"glioma serum\" -a case -b control --zfile_basename Counts.normalized.subtracted.trim.csv -o ${PWD}/out.123561516 -p ${plates} --counts --sex F >> commands

for z in 3.5 10 ; do

echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} --type \"glioma serum\" -a case -b control --zfile_basename Zscores.csv -o ${PWD}/out.123561516 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} --type \"glioma serum\" -a case -b control --zfile_basename Zscores.csv -o ${PWD}/out.123561516 -p ${plates} --sex M
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} --type \"glioma serum\" -a case -b control --zfile_basename Zscores.csv -o ${PWD}/out.123561516 -p ${plates} --sex F

echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} --type \"glioma serum\" -a case -b control -o ${PWD}/out.123561516 -p ${plates} --zfile_basename Zscores.csv
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} --type \"glioma serum\" -a case -b control --sfile_basename seropositive.${z}.csv -o ${PWD}/out.123561516 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} --type \"glioma serum\" -a case -b control --sfile_basename seropositive.${z}.csv -o ${PWD}/out.123561516 -p ${plates} --sex M
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} --type \"glioma serum\" -a case -b control --sfile_basename seropositive.${z}.csv -o ${PWD}/out.123561516 -p ${plates} --sex F

done >> commands

commands_array_wrapper.bash --jobname MultiPlate --array_file commands --time 1-0 --threads 4 --mem 30G
```

















##	20250930 Compare just PLCO glioma case controls

```BASH
ln -s /francislab/data1/working/20250925-Illumina-PhIP/20250925c-PhIP/out.plate17
ln -s /francislab/data1/working/20250925-Illumina-PhIP/20250925c-PhIP/out.plate18
```

```BASH
\rm commands

for p in 15 16 17 18 ; do
plate=out.plate${p}
manifest=${plate}/manifest.plate${p}.csv
for z in 3.5 5 10 ; do
echo module load r\; Count_Viral_Tile_Hit_Fraction.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} --study PLCO --type \"glioma serum\" -a case -b control --zfilename ${plate}/Zscores.csv
echo module load r\; Case_Control_Z_Script.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} --study PLCO --type \"glioma serum\" -a case -b control --zfilename ${plate}/Zscores.csv
echo module load r\; Seropositivity_Comparison.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} --study PLCO --type \"glioma serum\" -a case -b control --sfilename ${plate}/seropositive.${z}.csv
done ; done >> commands

commands_array_wrapper.bash --jobname individual --array_file commands --time 1-0 --threads 2 --mem 15G
```



```BASH
\rm commands

plates=$( ls -d ${PWD}/out.plate{15,16,17,18} 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )

echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 --study PLCO --type \"glioma serum\" -a case -b control --zfile_basename Counts.normalized.subtracted.trim.csv -o ${PWD}/out.15161718 -p ${plates} --counts >> commands
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 --study PLCO --type \"glioma serum\" -a case -b control --zfile_basename Counts.normalized.subtracted.trim.csv -o ${PWD}/out.15161718 -p ${plates} --counts --sex M >> commands
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 --study PLCO --type \"glioma serum\" -a case -b control --zfile_basename Counts.normalized.subtracted.trim.csv -o ${PWD}/out.15161718 -p ${plates} --counts --sex F >> commands

for z in 3.5 5 10 ; do

echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} --study PLCO --type \"glioma serum\" -a case -b control --zfile_basename Zscores.csv -o ${PWD}/out.15161718 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} --study PLCO --type \"glioma serum\" -a case -b control --zfile_basename Zscores.csv -o ${PWD}/out.15161718 -p ${plates} --sex M
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} --study PLCO --type \"glioma serum\" -a case -b control --zfile_basename Zscores.csv -o ${PWD}/out.15161718 -p ${plates} --sex F

echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} --study PLCO --type \"glioma serum\" -a case -b control -o ${PWD}/out.15161718 -p ${plates} --zfile_basename Zscores.csv
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} --study PLCO --type \"glioma serum\" -a case -b control --sfile_basename seropositive.${z}.csv -o ${PWD}/out.15161718 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} --study PLCO --type \"glioma serum\" -a case -b control --sfile_basename seropositive.${z}.csv -o ${PWD}/out.15161718 -p ${plates} --sex M
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} --study PLCO --type \"glioma serum\" -a case -b control --sfile_basename seropositive.${z}.csv -o ${PWD}/out.15161718 -p ${plates} --sex F

done >> commands

commands_array_wrapper.bash --jobname MultiPlate --array_file commands --time 1-0 --threads 4 --mem 30G
```






##	20250930 Compare ALL maternal case controls

```BASH
\rm commands

for p in 15 16 17 18 ; do
plate=out.plate${p}
manifest=${plate}/manifest.plate${p}.csv
for z in 3.5 5 10 ; do
echo module load r\; Count_Viral_Tile_Hit_Fraction.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} --study PRN --type \"ALL maternal serum\" -a case -b control --zfilename ${plate}/Zscores.csv
echo module load r\; Case_Control_Z_Script.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} --study PRN --type \"ALL maternal serum\" -a case -b control --zfilename ${plate}/Zscores.csv
echo module load r\; Seropositivity_Comparison.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} --study PRN --type \"ALL maternal serum\" -a case -b control --sfilename ${plate}/seropositive.${z}.csv
done ; done >> commands

commands_array_wrapper.bash --jobname individual --array_file commands --time 1-0 --threads 2 --mem 15G
```






```BASH
\rm commands

plates=$( ls -d ${PWD}/out.plate{15,16,17,18} 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )

echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 --study PRN --type \"ALL maternal serum\" -a case -b control --zfile_basename Counts.normalized.subtracted.trim.csv -o ${PWD}/out.15161718 -p ${plates} --counts >> commands

for z in 3.5 5 10 ; do

echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} --study PRN --type \"ALL maternal serum\" -a case -b control --zfile_basename Zscores.csv -o ${PWD}/out.15161718 -p ${plates}

echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} --study PRN --type \"ALL maternal serum\" -a case -b control -o ${PWD}/out.15161718 -p ${plates} --zfile_basename Zscores.csv
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} --study PRN --type \"ALL maternal serum\" -a case -b control --sfile_basename seropositive.${z}.csv -o ${PWD}/out.15161718 -p ${plates}

done >> commands

commands_array_wrapper.bash --jobname MultiPlate --array_file commands --time 1-0 --threads 4 --mem 30G
```







##	20250930 Glioma Serum in AGS or IPS case/control


```BASH
\rm commands

for p in 1 2 3 4 5 6 ; do
plate=out.plate${p}
manifest=${plate}/manifest.plate${p}.csv
for z in 3.5 5 10 ; do
echo module load r\; Count_Viral_Tile_Hit_Fraction.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} --study AGS --study IPS --type \"glioma serum\" -a case -b control --zfilename ${plate}/Zscores.csv
echo module load r\; Case_Control_Z_Script.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} --study AGS --study IPS --type \"glioma serum\" -a case -b control --zfilename ${plate}/Zscores.csv
echo module load r\; Seropositivity_Comparison.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} --study AGS --study IPS --type \"glioma serum\" -a case -b control --sfilename ${plate}/seropositive.${z}.csv
done ; done >> commands

commands_array_wrapper.bash --jobname individual --array_file commands --time 1-0 --threads 2 --mem 15G
```



```BASH
\rm commands

plates=$( ls -d ${PWD}/out.plate{1,2,3,4,5,6} 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )

echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 --study AGS --study IPS --type \"glioma serum\" -a case -b control --zfile_basename Counts.normalized.subtracted.trim.csv -o ${PWD}/out.1234561718 -p ${plates} --counts >> commands
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 --study AGS --study IPS --type \"glioma serum\" -a case -b control --zfile_basename Counts.normalized.subtracted.trim.csv -o ${PWD}/out.1234561718 -p ${plates} --counts --sex M >> commands
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 --study AGS --study IPS --type \"glioma serum\" -a case -b control --zfile_basename Counts.normalized.subtracted.trim.csv -o ${PWD}/out.1234561718 -p ${plates} --counts --sex F >> commands

for z in 3.5 5 10 ; do

echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} --study AGS --study IPS --type \"glioma serum\" -a case -b control --zfile_basename Zscores.csv -o ${PWD}/out.1234561718 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} --study AGS --study IPS --type \"glioma serum\" -a case -b control --zfile_basename Zscores.csv -o ${PWD}/out.1234561718 -p ${plates} --sex M
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} --study AGS --study IPS --type \"glioma serum\" -a case -b control --zfile_basename Zscores.csv -o ${PWD}/out.1234561718 -p ${plates} --sex F

echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} --study AGS --study IPS --type \"glioma serum\" -a case -b control -o ${PWD}/out.1234561718 -p ${plates} --zfile_basename Zscores.csv
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} --study AGS --study IPS --type \"glioma serum\" -a case -b control --sfile_basename seropositive.${z}.csv -o ${PWD}/out.1234561718 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} --study AGS --study IPS --type \"glioma serum\" -a case -b control --sfile_basename seropositive.${z}.csv -o ${PWD}/out.1234561718 -p ${plates} --sex M
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} --study AGS --study IPS --type \"glioma serum\" -a case -b control --sfile_basename seropositive.${z}.csv -o ${PWD}/out.1234561718 -p ${plates} --sex F

done >> commands

commands_array_wrapper.bash --jobname MultiPlate --array_file commands --time 1-0 --threads 4 --mem 30G
```



##	20251001

```BASH
mkdir out.123456131415161718
merge_all_combined_counts_files.py --de_nan --out out.123456131415161718/Plibs.csv /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_oligo.uniq.1-80.csv out.plate*/counts/PLib*.q40.count.csv.gz
sed -i 's/\.0//g' out.123456131415161718/Plibs.csv
merge_all_combined_counts_files.py --de_nan --out out.123456131415161718/CSEs.csv /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_oligo.uniq.1-80.csv out.plate*/counts/CSE*.q40.count.csv.gz
sed -i 's/\.0//g' out.123456131415161718/CSEs.csv
merge_all_combined_counts_files.py --de_nan --out out.123456131415161718/Blanks.csv /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_oligo.uniq.1-80.csv out.plate*/counts/input/Blank*.q40.count.csv.gz
sed -i 's/\.0//g' out.123456131415161718/Blanks.csv
```

##	20251006

```BASH
merge_all_combined_counts_files.py --de_nan --out out.123456131415161718/AllSamples.csv /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_oligo.uniq.1-80.csv out.plate*/counts/input/*.q40.count.csv.gz out.plate*/counts/*.q40.count.csv.gz
sed -i 's/\.0//g' out.123456131415161718/AllSamples.csv 
merge_all_combined_counts_files.py --de_nan --out out.123456131415161718/AllActualSamples.csv /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_oligo.uniq.1-80.csv $( ls -1 out.plate*/counts/*.q40.count.csv.gz | grep -vs PLib | grep -vs CSE | paste -s )
sed -i 's/\.0//g' out.123456131415161718/AllActualSamples.csv 
```

