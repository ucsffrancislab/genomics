
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




				most Case_Control_Z_Script.R failed due to grep issues ( plate6 )

				many failed (expectedly) due to missing seropositive.ZSCORE.csv files (only have 3.5 and 10)





```
box_upload.bash out.plate?/{Tile_Comparison,Viral_Ser,Viral_Frac_Hits,Seropositivity}*
```




```
\rm commands

plates=$( ls -d ${PWD}/out.plate[12356] 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )
for z in 3.5 5 10 15 20 30 40 50; do
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select-12356.csv -o ${PWD}/out.12356 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control --zfile_basename Zscores.select-12356.csv -o ${PWD}/out.12356 -p ${plates}
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


Check Rmds and possibly move to core ares


```
box_upload.bash out.{12356,123456}/Multiplate*
```





































./heatmap.Rmd -i /francislab/data1/working/20250128-Illumina-PhIP/20250128c-PhIP/out.all.test/cpm_blank_subtracted.csv -o glioma_cpm_blank_subtracted
```

./PeptideComparison.Rmd \
  -i ${PWD}/MultiPlateTesting/20250218-Multiplate_Peptide_Comparison-Zscores.select3-case-control-Prop_test_results-10.csv \
  -o ${PWD}/MultiPlateTesting/Multiplate_Peptide_Comparison-Zscores.select3

./PeptideComparison.Rmd \
  -i ${PWD}/MultiPlateTesting/20250218-Multiplate_Peptide_Comparison-Zscores.select6-case-control-Prop_test_results-10.csv \
  -o ${PWD}/MultiPlateTesting/Multiplate_Peptide_Comparison-Zscores.select4
```


```
for f in ${PWD}/20250220/MultiPlate?/*-Multiplate_Peptide_Comparison-*csv ; do
./PeptideComparison.Rmd -i ${f} -o ${f%.csv}
done
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
for f in ${PWD}/20250304/MultiPlate?/Multiplate_Peptide_Comparison-*Z-0.csv ; do
sbatch --nodes=1 --ntasks=2 --mem=30G --export=None --wrap="module load r pandoc; ${PWD}/PeptideComparison.Rmd -i ${f} -o ${f%.csv} -c ${PWD}/20250226/Counts.normalized.subtracted.trim.plus.mins.csv"
done
```

