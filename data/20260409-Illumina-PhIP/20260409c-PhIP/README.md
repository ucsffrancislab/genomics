
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

box_upload.bash out.plate*/Zscores*csv out.plate*/seropositive*csv out.plate*/All* out.plate*/m*

```


















I think that these scripts internally check for common peptides and such
Nevertheless



```bash
mkdir out.1718
merge_all_combined_counts_files.py --int --de_nan --out out.1718/Plibs.csv out.plate{17,18}/counts/PLib*

tail -n +2 out.1718/Plibs.csv | cut -d, -f1 | sort > out.1718/Plibs.id.csv
sed -i '1iid' out.1718/Plibs.id.csv
```


```bash
for i in 17 18; do
  dir=out.plate${i}
  echo $dir
  cat ${dir}/Counts.normalized.subtracted.trim.csv | datamash transpose -t, > ${dir}/tmp1.csv
  head -2 ${dir}/tmp1.csv > ${dir}/tmp2.csv
  join --header -t, out.1718/Plibs.id.csv <( tail -n +3 ${dir}/tmp1.csv ) >> ${dir}/tmp2.csv
  cat ${dir}/tmp2.csv | datamash transpose -t, > ${dir}/Counts.normalized.subtracted.trim.select-1718.csv
  box_upload.bash ${dir}/Counts.normalized.subtracted.trim.select-1718.csv

  head -2 ${dir}/Zscores.t.csv > ${dir}/Zscores.select-1718.t.csv
  join --header -t, out.1718/Plibs.id.csv <( tail -n +3 ${dir}/Zscores.t.csv ) >> ${dir}/Zscores.select-1718.t.csv
  cat ${dir}/Zscores.select-1718.t.csv | datamash transpose -t, > ${dir}/Zscores.select-1718.csv
  box_upload.bash ${dir}/Zscores.select-1718.csv

  head -2 ${dir}/Zscores.minimums.t.csv > ${dir}/Zscores.select-1718.minimums.t.csv
  join --header -t, out.1718/Plibs.id.csv <( tail -n +3 ${dir}/Zscores.minimums.t.csv ) >> ${dir}/Zscores.select-1718.minimums.t.csv
  cat ${dir}/Zscores.select-1718.minimums.t.csv | datamash transpose -t, > ${dir}/Zscores.select-1718.minimums.csv
  box_upload.bash ${dir}/Zscores.select-1718.minimums.csv
done
```


```bash
\rm commands

for p in 17 18 ; do 
plate=out.plate${p}
manifest=${plate}/manifest.plate${p}.csv
for z in 3.5 5 10 ; do 
echo module load r\; Count_Viral_Tile_Hit_Fraction.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} --type \"glioma serum\" -a case -b control --zfilename ${plate}/Zscores.select-1718.csv
echo module load r\; Case_Control_Z_Script.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} --type \"glioma serum\" -a case -b control --zfilename ${plate}/Zscores.select-1718.csv
echo module load r\; Seropositivity_Comparison.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} --type \"glioma serum\" -a case -b control --sfilename ${plate}/seropositive.${z}.csv
echo module load r\; Count_Viral_Tile_Hit_Fraction.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} --study PRN --type \"ALL maternal serum\" -a case -b control --zfilename ${plate}/Zscores.select-1718.csv
echo module load r\; Case_Control_Z_Script.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} --study PRN --type \"ALL maternal serum\" -a case -b control --zfilename ${plate}/Zscores.select-1718.csv
echo module load r\; Seropositivity_Comparison.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} --study PRN --type \"ALL maternal serum\" -a case -b control --sfilename ${plate}/seropositive.${z}.csv
done ; done >> commands

commands_array_wrapper.bash --jobname individual --array_file commands --time 1-0 --threads 2 --mem 15G
```



```bash
\rm commands

plates=$( ls -d ${PWD}/out.plate{17,18} 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )

echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 --study PRN --type \"ALL maternal serum\" -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select-1718.csv -o ${PWD}/out.1718 -p ${plates} --counts >> commands

echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 --type \"glioma serum\" -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select-1718.csv -o ${PWD}/out.1718 -p ${plates} --counts >> commands
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 --type \"glioma serum\" -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select-1718.csv -o ${PWD}/out.1718 -p ${plates} --counts --sex M >> commands
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z 0 --type \"glioma serum\" -a case -b control --zfile_basename Counts.normalized.subtracted.trim.select-1718.csv -o ${PWD}/out.1718 -p ${plates} --counts --sex F >> commands

for z in 3.5 5 10 ; do

echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} --study PRN --type \"ALL maternal serum\" -a case -b control --zfile_basename Zscores.select-1718.csv -o ${PWD}/out.1718 -p ${plates}

echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} --study PRN --type \"ALL maternal serum\" -a case -b control -o ${PWD}/out.1718 -p ${plates} --zfile_basename Zscores.select-1718.csv
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} --study PRN --type \"ALL maternal serum\" -a case -b control --sfile_basename seropositive.${z}.csv -o ${PWD}/out.1718 -p ${plates}

echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} --type \"glioma serum\" -a case -b control --zfile_basename Zscores.select-1718.csv -o ${PWD}/out.1718 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} --type \"glioma serum\" -a case -b control --zfile_basename Zscores.select-1718.csv -o ${PWD}/out.1718 -p ${plates} --sex M
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} --type \"glioma serum\" -a case -b control --zfile_basename Zscores.select-1718.csv -o ${PWD}/out.1718 -p ${plates} --sex F

echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} --type \"glioma serum\" -a case -b control -o ${PWD}/out.1718 -p ${plates} --zfile_basename Zscores.select-1718.csv
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} --type \"glioma serum\" -a case -b control --sfile_basename seropositive.${z}.csv -o ${PWD}/out.1718 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} --type \"glioma serum\" -a case -b control --sfile_basename seropositive.${z}.csv -o ${PWD}/out.1718 -p ${plates} --sex M
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} --type \"glioma serum\" -a case -b control --sfile_basename seropositive.${z}.csv -o ${PWD}/out.1718 -p ${plates} --sex F

done >> commands

commands_array_wrapper.bash --jobname MultiPlate --array_file commands --time 1-0 --threads 4 --mem 30G
```





```bash

box_upload.bash out.plate*/{Viral_,Seropositivity}* out.1718/*

```





##	202050902


Create subsets of files for VZV (HHV3) only


```bash
for f in out.1718/Multiplate_Peptide_Comparison-*csv ; do
head -1 $f > tmp1.csv
tail -n +2 $f | sort -t, -k1,1 >> tmp1.csv
join --header -t, <( awk -F, '(NR==1 || $2=="Human herpesvirus 3")' /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_species.uniq.csv ) tmp1.csv > tmp2.csv
head -1 tmp2.csv > ${f%.csv}.VZV.csv
tail -n +2 tmp2.csv | awk -F, '($8!="NA")' | sort -t, -k8n,8 >> ${f%.csv}.VZV.csv
tail -n +2 tmp2.csv | awk -F, '($8=="NA")' >> ${f%.csv}.VZV.csv
done

```






By_virus_plotter.R --manifest out.plate17/manifest.plate17.csv --virus "Human herpesvirus 3" -a case -b control --zfilename out.plate17/Zscores.select-1718.csv --public_eps_filename out.plate17/All.public_epitope_annotations.Zscores.csv



