
#	20260409-Illumina-PhIP/20260409c-PhIP


DO NOT USE the following samples ...



##	All
snumber,sample,subject,type,study,sex,age,casecontrol,plate,well


```bash
awk 'BEGIN{FS=OFS=","}(NR>1){print $3,$2,"/francislab/data1/working/20260409-Illumina-PhIP/20260409b-bowtie2/out/"$1".VIR3_clean.id_upper_oligo.uniq.1-80.bam",$4,$5,$8,$7,$6,$9}' /francislab/data1/raw/20260409-Illumina-PhIP/select_covariates.csv > manifest.all.csv

sed -i '1isubject,sample,bampath,type,study,group,age,sex,plate' manifest.all.csv
chmod -w manifest.all.csv
```

```bash
#mkdir logs/
#sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
#  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
#  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
#  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.all.csv --threshold 10 --output ${PWD}/out.all
```


##	Per Plate


```bash
awk 'BEGIN{FS=OFS=","}(NR>1){print $3,$2,"/francislab/data1/working/20260409-Illumina-PhIP/20260409b-bowtie2/out/"$1".VIR3_clean.id_upper_oligo.uniq.1-80.bam",$4,$5,$8,$7,$6,$9 > "manifest.plate"$9".csv" }' /francislab/data1/raw/20260409-Illumina-PhIP/select_covariates.csv

for manifest in manifest.plate*.csv ; do
sed -i '1isubject,sample,bampath,type,study,group,age,sex,plate' ${manifest}
chmod -w ${manifest}
done

```


```bash
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



```bash
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
```


WAIT UNTIL THEY COMPLETE



```bash

#box_upload.bash out.plate*/Zscores*csv out.plate*/seropositive*csv out.plate*/All* out.plate*/m*

module load rclone
rclone sync out.plate21 box:Francis\ _Lab_Share/20260409-Illumina-PhIP/20260409c-PhIP/out.plate21 \
  --filter "+ {{^(Zscores|seropositive|All|m).*csv}}" --filter "- **"
rclone sync out.plate22 box:Francis\ _Lab_Share/20260409-Illumina-PhIP/20260409c-PhIP/out.plate22 \
  --filter "+ {{^(Zscores|seropositive|All|m).*csv}}" --filter "- **"

```


##	20260421

```bash
\rm commands

for datetype in $( cut -d, -f4 manifest.all.csv | sort | uniq | grep -Evs "^(type|Phage Library|input)$" ) ; do
echo ${datatype}
done


for p in 21 22 ; do 
plate=out.plate${p}
manifest=${plate}/manifest.plate${p}.csv
for z in 3.5 5 10 ; do 

echo module load r\; Count_Viral_Tile_Hit_Fraction.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} --type \"pemphigus serum\" -a case -b \"endemic control\" --zfilename ${plate}/Zscores.csv
echo module load r\; Count_Viral_Tile_Hit_Fraction.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} --type \"pemphigus serum\" -a case -b \"nonendemic control\" --zfilename ${plate}/Zscores.csv
echo module load r\; Count_Viral_Tile_Hit_Fraction.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} --type \"pemphigus serum\" -a \"endemic control\" -b \"nonendemic control\" --zfilename ${plate}/Zscores.csv

echo module load r\; Case_Control_Z_Script.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} --type \"pemphigus serum\" -a case -b \"endemic control\" --zfilename ${plate}/Zscores.csv
echo module load r\; Case_Control_Z_Script.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} --type \"pemphigus serum\" -a case -b \"nonendemic control\" --zfilename ${plate}/Zscores.csv
echo module load r\; Case_Control_Z_Script.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} --type \"pemphigus serum\" -a \"endemic control\" -b \"nonendemic control\" --zfilename ${plate}/Zscores.csv

echo module load r\; Seropositivity_Comparison.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} --type \"pemphigus serum\" -a case -b \"endemic control\" --sfilename ${plate}/seropositive.${z}.csv
echo module load r\; Seropositivity_Comparison.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} --type \"pemphigus serum\" -a case -b \"nonendemic control\" --sfilename ${plate}/seropositive.${z}.csv
echo module load r\; Seropositivity_Comparison.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} --type \"pemphigus serum\" -a \"endemic control\" -b \"nonendemic control\" --sfilename ${plate}/seropositive.${z}.csv

done ; done >> commands

commands_array_wrapper.bash --jobname individual --array_file commands --time 1-0 --threads 2 --mem 15G
```

```bash
#box_upload.bash out.plate2?/{Viral,Tile,Sero}*

module load rclone
rclone sync out.plate21 box:Francis\ _Lab_Share/20260409-Illumina-PhIP/20260409c-PhIP/out.plate21 \
  --filter "+ {{^(Viral|Tile|Sero).*}}" --filter "- **"
rclone sync out.plate22 box:Francis\ _Lab_Share/20260409-Illumina-PhIP/20260409c-PhIP/out.plate22 \
  --filter "+ {{^(Viral|Tile|Sero).*}}" --filter "- **"

```




```bash
\rm commands

plates=$( ls -d ${PWD}/out.plate{21,22} 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )

for z in 3.5 5 10 ; do

echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} --type \"pemphigus serum\" -a case -b \"endemic control\" --zfile_basename Zscores.csv -o ${PWD}/out.2122 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} --type \"pemphigus serum\" -a case -b \"endemic control\" --zfile_basename Zscores.csv -o ${PWD}/out.2122 -p ${plates} --sex M
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} --type \"pemphigus serum\" -a case -b \"endemic control\" --zfile_basename Zscores.csv -o ${PWD}/out.2122 -p ${plates} --sex F
echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} --type \"pemphigus serum\" -a case -b \"endemic control\" -o ${PWD}/out.2122 -p ${plates} --zfile_basename Zscores.csv
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} --type \"pemphigus serum\" -a case -b \"endemic control\" --sfile_basename seropositive.${z}.csv -o ${PWD}/out.2122 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} --type \"pemphigus serum\" -a case -b \"endemic control\" --sfile_basename seropositive.${z}.csv -o ${PWD}/out.2122 -p ${plates} --sex M
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} --type \"pemphigus serum\" -a case -b \"endemic control\" --sfile_basename seropositive.${z}.csv -o ${PWD}/out.2122 -p ${plates} --sex F

echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} --type \"pemphigus serum\" -a case -b \"nonendemic control\" --zfile_basename Zscores.csv -o ${PWD}/out.2122 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} --type \"pemphigus serum\" -a case -b \"nonendemic control\" --zfile_basename Zscores.csv -o ${PWD}/out.2122 -p ${plates} --sex M
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} --type \"pemphigus serum\" -a case -b \"nonendemic control\" --zfile_basename Zscores.csv -o ${PWD}/out.2122 -p ${plates} --sex F
echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} --type \"pemphigus serum\" -a case -b \"nonendemic control\" -o ${PWD}/out.2122 -p ${plates} --zfile_basename Zscores.csv
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} --type \"pemphigus serum\" -a case -b \"nonendemic control\" --sfile_basename seropositive.${z}.csv -o ${PWD}/out.2122 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} --type \"pemphigus serum\" -a case -b \"nonendemic control\" --sfile_basename seropositive.${z}.csv -o ${PWD}/out.2122 -p ${plates} --sex M
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} --type \"pemphigus serum\" -a case -b \"nonendemic control\" --sfile_basename seropositive.${z}.csv -o ${PWD}/out.2122 -p ${plates} --sex F

echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} --type \"pemphigus serum\" -a \"endemic control\" -b \"nonendemic control\" --zfile_basename Zscores.csv -o ${PWD}/out.2122 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} --type \"pemphigus serum\" -a \"endemic control\" -b \"nonendemic control\" --zfile_basename Zscores.csv -o ${PWD}/out.2122 -p ${plates} --sex M
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} --type \"pemphigus serum\" -a \"endemic control\" -b \"nonendemic control\" --zfile_basename Zscores.csv -o ${PWD}/out.2122 -p ${plates} --sex F
echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} --type \"pemphigus serum\" -a \"endemic control\" -b \"nonendemic control\" -o ${PWD}/out.2122 -p ${plates} --zfile_basename Zscores.csv
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} --type \"pemphigus serum\" -a \"endemic control\" -b \"nonendemic control\" --sfile_basename seropositive.${z}.csv -o ${PWD}/out.2122 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} --type \"pemphigus serum\" -a \"endemic control\" -b \"nonendemic control\" --sfile_basename seropositive.${z}.csv -o ${PWD}/out.2122 -p ${plates} --sex M
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} --type \"pemphigus serum\" -a \"endemic control\" -b \"nonendemic control\" --sfile_basename seropositive.${z}.csv -o ${PWD}/out.2122 -p ${plates} --sex F

done >> commands

commands_array_wrapper.bash --jobname MultiPlate --array_file commands --time 1-0 --threads 4 --mem 30G
```



```bash
#box_upload.bash out.21222/*

module load rclone
rclone sync out.2122 box:Francis\ _Lab_Share/20260409-Illumina-PhIP/20260409c-PhIP/out.2122

```

