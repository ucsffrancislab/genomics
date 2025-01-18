
#	20241224-Illumina-PhIP/20250110-PhIP


202412 - per plate, sum of blanks
20250107 - all plates, sum of blanks
20250108 - all plates, median of blanks


Same as 20250107 but use the median's of the input blanks, rather than the sums

Same as 20250108 but dropping the bad blank and processing each plate separately.

Also, adding plate to the manifest for use later


Manually drop Blank03_2 sample


```
awk 'BEGIN{FS=OFS=","}(NR>1 && $21=="1"){subject=$2;sub(/_1$/,"",subject);sub(/_2$/,"",subject);sub(/dup$/,"",subject);s=$4;sub(/IDX/,"",s);s=int(s);print subject,$2,"/francislab/data1/working/20241204-Illumina-PhIP/20241204b-bowtie2/out/S"s".VIR3_clean.1-84.bam",$5,$6,$7,$9,$10,$21}' /francislab/data1/raw/20241204-Illumina-PhIP/L1_full_covariatesv2_Vir3_phip-seq_GBM_p1_MENPEN_p13_12-6-24hmh.csv | sort -t, -k1,1 > manifest.plate1.csv

sed -i '1isubject,sample,bampath,type,study,group,age,sex,plate' manifest.plate1.csv
sed -i 's/PBS blank/input/i' manifest.plate1.csv
sed -i 's/VIR phage Library/Phage Lib/i' manifest.plate1.csv
sed -i 's/phage library \(blank\)/Phage Lib/i' manifest.plate1.csv
sed -i '/Blank03_2/d' manifest.plate1.csv
chmod -w manifest.plate1.csv

awk 'BEGIN{FS=OFS=","}(NR>1 && $21=="13"){subject=$2;sub(/_1$/,"",subject);sub(/_2$/,"",subject);sub(/dup$/,"",subject);s=$4;sub(/IDX/,"",s);s=int(s);print subject,$2,"/francislab/data1/working/20241204-Illumina-PhIP/20241204b-bowtie2/out/S"s".VIR3_clean.1-84.bam",$5,$6,$7,$9,$10,$21}' /francislab/data1/raw/20241204-Illumina-PhIP/L1_full_covariatesv2_Vir3_phip-seq_GBM_p1_MENPEN_p13_12-6-24hmh.csv | sort -t, -k1,1 > manifest.plate13.csv

sed -i '1isubject,sample,bampath,type,study,group,age,sex,plate' manifest.plate13.csv
sed -i 's/PBS blank/input/i' manifest.plate13.csv
sed -i 's/VIR phage Library/Phage Lib/i' manifest.plate1.csv
sed -i 's/phage library \(blank\)/Phage Lib/i' manifest.plate1.csv
chmod -w manifest.plate13.csv

awk 'BEGIN{FS=OFS=","}(NR>1 && $23=="2"){subject=$3;sub(/_1$/,"",subject);sub(/_2$/,"",subject);sub(/dup$/,"",subject);print subject,$3,"/francislab/data1/working/20241224-Illumina-PhIP/20241224b-bowtie2/out/"$1".VIR3_clean.1-84.bam",$7,$8,$9,$11,$12,$23}' /francislab/data1/raw/20241224-Illumina-PhIP/L2_full_covariates_Vir3_phip-seq_GBM_p2_MENPEN_p14_12-29-24hmh_L2_Covar.csv | sort -t, -k1,1 > manifest.plate2.csv

sed -i '1isubject,sample,bampath,type,study,group,age,sex,plate' manifest.plate2.csv
sed -i 's/PBS blank/input/i' manifest.plate2.csv
sed -i 's/VIR phage Library/Phage Lib/i' manifest.plate1.csv
sed -i 's/phage library \(blank\)/Phage Lib/i' manifest.plate1.csv
chmod -w manifest.plate2.csv

awk 'BEGIN{FS=OFS=","}(NR>1 && $23=="14"){subject=$3;sub(/_1$/,"",subject);sub(/_2$/,"",subject);sub(/dup$/,"",subject);print subject,$3,"/francislab/data1/working/20241224-Illumina-PhIP/20241224b-bowtie2/out/"$1".VIR3_clean.1-84.bam",$7,$8,$9,$11,$12,$23}' /francislab/data1/raw/20241224-Illumina-PhIP/L2_full_covariates_Vir3_phip-seq_GBM_p2_MENPEN_p14_12-29-24hmh_L2_Covar.csv | sort -t, -k1,1 > manifest.plate14.csv

sed -i '1isubject,sample,bampath,type,study,group,age,sex,plate' manifest.plate14.csv
sed -i 's/PBS blank/input/i' manifest.plate14.csv
sed -i 's/VIR phage Library/Phage Lib/i' manifest.plate1.csv
sed -i 's/phage library \(blank\)/Phage Lib/i' manifest.plate1.csv
chmod -w manifest.plate14.csv

```





```
mkdir logs

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq_plate1 --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.plate1.csv --thresholds 3.5,10 --output ${PWD}/out.plate1

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq_plate2 --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.plate2.csv --thresholds 3.5,10 --output ${PWD}/out.plate2

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq_plate13 --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.plate13.csv --thresholds 3.5,10 --output ${PWD}/out.plate13

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq_plate14 --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.plate14.csv --thresholds 3.5,10 --output ${PWD}/out.plate14


```




```
mkdir out.all
merge_all_combined_counts_files.py --int --de_nan --out out.all/Plibs.csv out.*/counts/PLib*

head out.all/Plibs.csv
wc -l out.all/Plibs.csv
grep -vs ",0" out.all/Plibs.csv | head


echo "id" > out.all/AllPlibs.csv
grep -vs ",0" out.all/Plibs.csv | tail -n +2 | cut -d, -f1 | sort >> out.all/AllPlibs.csv

box_upload.bash out.all/Plibs.csv out.all/AllPlibs.csv




#join -t, --header out.all/AllPlibs.csv out.all/All.count.Zscores.csv | wc -l
##50567 - 68955 up from ...53061
#
#join -t, --header out.all/AllPlibs.csv /francislab/data1/refs/PhIP-Seq/VIR3_clean.virus_score.join_sorted.csv | cut -d, -f2 | tail -n +2 | sort | uniq -c | sed -e 's/^\s*//' -e 's/ /,/' -e '1icount,species' > out.all/AllPlibs.species_counts.csv
#
#box_upload.bash out.all/Plibs.csv out.all/AllPlibs.csv out.all/AllPlibs.species_counts.csv
```





```
for plate in 1 2 13 14 ; do
  cp manifest.plate${plate}.csv out.plate${plate}/

  phip_seq_aggregate.bash manifest.plate${plate}.csv out.plate${plate}

  box_upload.bash out.plate${plate}/Zscores*csv out.plate${plate}/seropositive*csv out.plate${plate}/All* out.plate${plate}/m*
done
```





```
\rm commands
for plate in 1 2 13 14 ; do

for z in 3.5 10 ; do
 echo module load r\; Count_Viral_Tile_Hit_Fraction.R --zscore ${z} --manifest manifest.plate${plate}.csv  --working_dir out.plate${plate} -a case -b control
 echo module load r\; Case_Control_Z_Script.R --zscore ${z} --manifest manifest.plate${plate}.csv --working_dir out.plate${plate} -a case -b control
 echo module load r\; Seropositivity_Comparison.R --zscore ${z} --manifest manifest.plate${plate}.csv  --working_dir out.plate${plate} -a case -b control

 for groups in '-a "PF Patient" -b "Endemic Control"' '-a "PF Patient" -b "Non Endemic Control"' '-a "Endemic Control" -b "Non Endemic Control"' ; do
  echo module load r\; Case_Control_Z_Script.R --zscore ${z} --manifest manifest.plate${plate}.csv --working_dir out.plate${plate} ${groups}
  echo module load r\; Count_Viral_Tile_Hit_Fraction.R --zscore ${z} --manifest manifest.plate${plate}.csv  --working_dir out.plate${plate} ${groups}
  echo module load r\; Seropositivity_Comparison.R --zscore ${z} --manifest manifest.plate${plate}.csv  --working_dir out.plate${plate} ${groups}
 done
done >> commands
done

commands_array_wrapper.bash --array_file commands --time 4-0 --threads 4 --mem 30G



box_upload.bash out.plate*/Tile_Comparison* out.plate*/Viral_* out.plate*/Seropositivity*

```





Will need to change this up a bit if called again as I've updated the Multi_Plate*R scripts to use the append action for plates

```
\rm commands.multiz.multiplate

plates=$( ls -d ${PWD}/out.plate* | paste -sd, )
for z in 3.5 10 ; do

 echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a case -b control -o ${PWD}/MultiZMultiPlate -p ${plates}

 echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} -a case -b control -o ${PWD}/MultiZMultiPlate -p ${plates}

 for groups in '-a "PF Patient" -b "Endemic Control"' '-a "PF Patient" -b "Non Endemic Control"' '-a "Endemic Control" -b "Non Endemic Control"' ; do
  echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} ${groups} -o ${PWD}/MultiZMultiPlate -p ${plates}
  echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} ${groups} -o ${PWD}/MultiZMultiPlate -p ${plates}
 done

done >> commands.multiz.multiplate

commands_array_wrapper.bash --array_file commands.multiz.multiplate --time 4-0 --threads 4 --mem 30G

box_upload.bash MultiZMultiPlate/*
```




Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R




```
\rm commands.multiz.multiplate2

#plates=$( ls -d ${PWD}/out.plate* | paste -sd, )
plates=$( ls -d ${PWD}/out.plate* | paste -sd, | sed 's/,/ -p /g' )
for z in 3.5 10 ; do

 echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} -a case -b control -o ${PWD}/MultiZMultiPlate -p ${plates}

 for groups in '-a "PF Patient" -b "Endemic Control"' '-a "PF Patient" -b "Non Endemic Control"' '-a "Endemic Control" -b "Non Endemic Control"' ; do
  echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} ${groups} -o ${PWD}/MultiZMultiPlate -p ${plates}
 done

done >> commands.multiz.multiplate2

commands_array_wrapper.bash --array_file commands.multiz.multiplate2 --time 4-0 --threads 4 --mem 30G

#box_upload.bash MultiZMultiPlate/*
```



##	20250114


```
tail -n +2 out.all/Plibs.csv | cut -d, -f1 | sort > out.all/Plibs.id.csv
sed -i '1iid' out.all/Plibs.id.csv

for plate in 1 2 13 14 ; do
  head -2 out.plate${plate}/Zscores.t.csv > out.plate${plate}/Zscores.select.t.csv
  join --header -t, out.all/Plibs.id.csv <( tail -n +3 out.plate${plate}/Zscores.t.csv ) >> out.plate${plate}/Zscores.select.t.csv
  cat out.plate${plate}/Zscores.select.t.csv | datamash transpose -t, > out.plate${plate}/Zscores.select.csv
done

for plate in 1 2 13 14 ; do
  head -2 out.plate${plate}/Zscores.minimums.t.csv > out.plate${plate}/Zscores.select.minimums.t.csv
  join --header -t, out.all/Plibs.id.csv <( tail -n +3 out.plate${plate}/Zscores.minimums.t.csv ) >> out.plate${plate}/Zscores.select.minimums.t.csv
  cat out.plate${plate}/Zscores.select.minimums.t.csv | datamash transpose -t, > out.plate${plate}/Zscores.select.minimums.csv
done
```


```
\rm commands.test

for plate in 1 2 13 14 ; do
for z in 3.5 10 ; do
 echo module load r\; Count_Viral_Tile_Hit_Fraction.R --zscore ${z} --manifest manifest.plate${plate}.csv  --zfilename out.plate${plate}/Zscores.select.csv -a case -b control --output_dir out.plate${plate}.test

 for groups in '-a "PF Patient" -b "Endemic Control"' '-a "PF Patient" -b "Non Endemic Control"' '-a "Endemic Control" -b "Non Endemic Control"' ; do
  echo module load r\; Count_Viral_Tile_Hit_Fraction.R --zscore ${z} --manifest manifest.plate${plate}.csv  --zfilename out.plate${plate}/Zscores.select.csv ${groups} --output_dir out.plate${plate}.test
 done
done
done >> commands.test

commands_array_wrapper.bash --array_file commands.test --time 4-0 --threads 4 --mem 30G

```



```
for plate in 1 2 13 14 ; do
  cp manifest.plate${plate}.csv out.plate${plate}.test/
done
```


```
\rm commands.multiz.multiplate.test

plates=$( ls -d ${PWD}/out.plate* | paste -sd, | sed 's/,/ -p /g' )
for z in 3.5 10 ; do

 echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} -a case -b control -o ${PWD}/MultiZMultiPlate.test -p ${plates}

 for groups in '-a "PF Patient" -b "Endemic Control"' '-a "PF Patient" -b "Non Endemic Control"' '-a "Endemic Control" -b "Non Endemic Control"' ; do
  echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} ${groups} -o ${PWD}/MultiZMultiPlate.test -p ${plates}
 done

done >> commands.multiz.multiplate.test

commands_array_wrapper.bash --array_file commands.multiz.multiplate.test --time 4-0 --threads 4 --mem 30G

box_upload.bash MultiZMultiPlate.test/*
```







##	20250115


Modify the 3 pemphigus groups into 2 different group comparisons

Endemic ( PF Patient + Endemic Control ) vs Non Endemic ( Non Endemic Controls )

Case ( PF Patient ) vs Control ( Endemic Controls + Non Endemic Controls )


manifest.plate13.csv manifest.plate14.csv


```
sed -e "s/,PF Patient,/,Endemic,/" -e "s/,Endemic Control,/,Endemic,/" -e "s/,Non Endemic Control,/,NonEndemic,/" manifest.plate13.csv  > manifest.plate13.endemic.csv
sed -e "s/,PF Patient,/,Endemic,/" -e "s/,Endemic Control,/,Endemic,/" -e "s/,Non Endemic Control,/,NonEndemic,/" manifest.plate14.csv  > manifest.plate14.endemic.csv

sed -e "s/,PF Patient,/,PFCase,/" -e "s/,Endemic Control,/,PFControl,/" -e "s/,Non Endemic Control,/,PFControl,/" manifest.plate13.csv > manifest.plate13.pfcase.csv
sed -e "s/,PF Patient,/,PFCase,/" -e "s/,Endemic Control,/,PFControl,/" -e "s/,Non Endemic Control,/,PFControl,/" manifest.plate14.csv > manifest.plate14.pfcase.csv
```


```
for plate in 13 14 ; do
mkdir out.plate${plate}.endemic/
cp manifest.plate${plate}.endemic.csv out.plate${plate}.endemic/
sed -e "s/,PF Patient,/,Endemic,/" -e "s/,Endemic Control,/,Endemic,/" -e "s/,Non Endemic Control,/,NonEndemic,/" out.plate${plate}/Zscores.select.csv > out.plate${plate}.endemic/Zscores.select.csv
sed -e "s/,PF Patient,/,Endemic,/" -e "s/,Endemic Control,/,Endemic,/" -e "s/,Non Endemic Control,/,NonEndemic,/" out.plate${plate}/Zscores.select.minimums.csv > out.plate${plate}.endemic/Zscores.select.minimums.csv
mkdir out.plate${plate}.pfcase/
cp manifest.plate${plate}.pfcase.csv out.plate${plate}.pfcase/
sed -e "s/,PF Patient,/,PFCase,/" -e "s/,Endemic Control,/,PFControl,/" -e "s/,Non Endemic Control,/,PFControl,/" out.plate${plate}/Zscores.select.csv > out.plate${plate}.pfcase/Zscores.select.csv
sed -e "s/,PF Patient,/,PFCase,/" -e "s/,Endemic Control,/,PFControl,/" -e "s/,Non Endemic Control,/,PFControl,/" out.plate${plate}/Zscores.select.minimums.csv > out.plate${plate}.pfcase/Zscores.select.minimums.csv
done
```



```
for plate in 13 14 ; do
for z in 3.5 10 ; do
for s in endemic pfcase ; do
merge_results.py --int -o out.plate${plate}.${s}/merged.${z}.virus_scores.csv \
  out.plate${plate}/*.${z}.hits.virus_scores.csv
merge_results.py --int -o out.plate${plate}.${s}/merged.${z}.seropositive.csv \
  out.plate${plate}/*.${z}.hits.found_public_epitopes.*_scoring.seropositive.csv
phip_seq_aggregate.bash manifest.plate${plate}.${s}.csv out.plate${plate}.${s}
done ; done ; done
```


```
\rm commands
for plate in 13 14 ; do
for z in 3.5 10 ; do

echo module load r\; Count_Viral_Tile_Hit_Fraction.R --zscore ${z} --manifest manifest.plate${plate}.pfcase.csv  --output_dir out.plate${plate}.pfcase -a PFCase -b PFControl --zfilename out.plate${plate}/Zscores.select.csv
echo module load r\; Case_Control_Z_Script.R --zscore ${z} --manifest manifest.plate${plate}.pfcase.csv --output_dir out.plate${plate}.pfcase -a PFCase -b PFControl --zfilename out.plate${plate}/Zscores.select.csv
echo module load r\; Seropositivity_Comparison.R --zscore ${z} --manifest manifest.plate${plate}.pfcase.csv  --output_dir out.plate${plate}.pfcase -a PFCase -b PFControl --sfilename out.plate${plate}/seropositive.${z}.csv

echo module load r\; Count_Viral_Tile_Hit_Fraction.R --zscore ${z} --manifest manifest.plate${plate}.endemic.csv  --output_dir out.plate${plate}.endemic -a Endemic -b NonEndemic --zfilename out.plate${plate}/Zscores.select.csv
echo module load r\; Case_Control_Z_Script.R --zscore ${z} --manifest manifest.plate${plate}.endemic.csv --output_dir out.plate${plate}.endemic -a Endemic -b NonEndemic --zfilename out.plate${plate}/Zscores.select.csv
echo module load r\; Seropositivity_Comparison.R --zscore ${z} --manifest manifest.plate${plate}.endemic.csv  --output_dir out.plate${plate}.endemic -a Endemic -b NonEndemic --sfilename out.plate${plate}/seropositive.${z}.csv

done ; done >> commands

commands_array_wrapper.bash --array_file commands --time 4-0 --threads 4 --mem 30G
```

```
\rm commands
for z in 3.5 10 ; do

echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} -a Endemic -b NonEndemic -o ${PWD}/MultiZMultiPlate.endemic -p out.plate13.endemic -p out.plate14.endemic

echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a Endemic -b NonEndemic -o ${PWD}/MultiZMultiPlate.endemic -p out.plate13.endemic -p out.plate14.endemic --zfile_basename Zscores.select.csv

echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} -a Endemic -b NonEndemic -o ${PWD}/MultiZMultiPlate.endemic -p out.plate13.endemic -p out.plate14.endemic --sfile_basename seropositive.${z}.csv

echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} -a PFCase -b PFControl -o ${PWD}/MultiZMultiPlate.pfcase -p out.plate13.pfcase -p out.plate14.pfcase

echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} -a PFCase -b PFControl -o ${PWD}/MultiZMultiPlate.pfcase -p out.plate13.pfcase -p out.plate14.pfcase --zfile_basename Zscores.select.csv

echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} -a PFCase -b PFControl -o ${PWD}/MultiZMultiPlate.pfcase -p out.plate13.pfcase -p out.plate14.pfcase --sfile_basename seropositive.${z}.csv

done >> commands

commands_array_wrapper.bash --array_file commands --time 4-0 --threads 4 --mem 30G
```




```

box_upload.bash out.plate*{pfcase,endemic}/{Tile,Viral,Sero,virus,manifest}*

```






```
./virus_scores.Rmd -d /francislab/data1/working/20241224-Illumina-PhIP/20250110-PhIP/out.plate13.pfcase -d /francislab/data1/working/20241224-Illumina-PhIP/20250110-PhIP/out.plate14.pfcase -o ${PWD}/virus_scores.pfcase
./virus_scores.Rmd -d /francislab/data1/working/20241224-Illumina-PhIP/20250110-PhIP/out.plate13.endemic -d /francislab/data1/working/20241224-Illumina-PhIP/20250110-PhIP/out.plate14.endemic -o ${PWD}/virus_scores.endemic
box_upload.bash virus_scores.*.html


./Zscores.Rmd -d /francislab/data1/working/20241224-Illumina-PhIP/20250110-PhIP/out.plate13.pfcase -d /francislab/data1/working/20241224-Illumina-PhIP/20250110-PhIP/out.plate14.pfcase -o Zscores.HHV1.pfcase -s "Human herpesvirus 1"
./Zscores.Rmd -d /francislab/data1/working/20241224-Illumina-PhIP/20250110-PhIP/out.plate13.pfcase -d /francislab/data1/working/20241224-Illumina-PhIP/20250110-PhIP/out.plate14.pfcase -o Zscores.HHV2.pfcase -s "Human herpesvirus 2"
./Zscores.Rmd -d /francislab/data1/working/20241224-Illumina-PhIP/20250110-PhIP/out.plate13.pfcase -d /francislab/data1/working/20241224-Illumina-PhIP/20250110-PhIP/out.plate14.pfcase -o Zscores.HHV6A.pfcase -s "Human herpesvirus 6A"
box_upload.bash Zscores.*.pfcase.html

./Zscores.Rmd -d /francislab/data1/working/20241224-Illumina-PhIP/20250110-PhIP/out.plate13.endemic -d /francislab/data1/working/20241224-Illumina-PhIP/20250110-PhIP/out.plate14.endemic -o Zscores.HHV1.endemic -s "Human herpesvirus 1"
./Zscores.Rmd -d /francislab/data1/working/20241224-Illumina-PhIP/20250110-PhIP/out.plate13.endemic -d /francislab/data1/working/20241224-Illumina-PhIP/20250110-PhIP/out.plate14.endemic -o Zscores.HHV2.endemic -s "Human herpesvirus 2"
./Zscores.Rmd -d /francislab/data1/working/20241224-Illumina-PhIP/20250110-PhIP/out.plate13.endemic -d /francislab/data1/working/20241224-Illumina-PhIP/20250110-PhIP/out.plate14.endemic -o Zscores.HHV6A.endemic -s "Human herpesvirus 6A"
box_upload.bash Zscores.*.endemic.html



```



##	20250117

```
for plate in 13 14 ; do
for z in 3.5 10 ; do

Seropositivity_Comparison.R -a Endemic -b NonEndemic --manifest manifest.plate${plate}.endemic.csv --sfilename out.plate${plate}.endemic/virus_scores.${z}.csv --zscore ${z} --output_dir testing 
b=$( basename testing/Seropositivity_Prop_test_results-*csv .csv )
echo $b
mv testing/${b}.csv out.plate${plate}.endemic/${b}-virus_score.csv

Seropositivity_Comparison.R -a PFCase -b PFControl --manifest manifest.plate${plate}.pfcase.csv --sfilename out.plate${plate}.pfcase/virus_scores.${z}.csv --zscore ${z} --output_dir testing 
b=$( basename testing/Seropositivity_Prop_test_results-*csv .csv )
echo $b
mv testing/${b}.csv out.plate${plate}.pfcase/${b}-virus_score.csv

done ; done


```



```
\rm commands
for z in 3.5 10 ; do

echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} -a Endemic -b NonEndemic -o ${PWD}/MultiZMultiPlate.endemic -p out.plate13.endemic -p out.plate14.endemic --sfile_basename virus_scores.${z}.csv

echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} -a PFCase -b PFControl -o ${PWD}/MultiZMultiPlate.pfcase -p out.plate13.pfcase -p out.plate14.pfcase --sfile_basename virus_scores.${z}.csv

done >> commands

commands_array_wrapper.bash --array_file commands --time 4-0 --threads 4 --mem 30G
```





