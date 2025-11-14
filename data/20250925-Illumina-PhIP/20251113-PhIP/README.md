
#	20250925-Illumina-PhIP/20251113-PhIP


DO NOT USE the following samples ...





##	All

```BASH
awk 'BEGIN{FS=OFS=","}(NR>1){print $6,$7,"/francislab/data1/working/20250925-Illumina-PhIP/20251113-downsample/out/"$1".VIR3_clean.id_upper_oligo.uniq.1-80.bam",$8,$9,$10,$13,$12,$26,$25}' /francislab/data1/raw/20250925-Illumina-PhIP/manifest.csv > manifest.all.csv

sed -i '1isubject,sample,bampath,type,study,group,age,sex,plate,lane' manifest.all.csv
sed -i 's/,PBS blank,/,input,/' manifest.all.csv
#sed -i '/Blank24dup/d' manifest.all.csv
chmod -w manifest.all.csv
```

```BASH
#mkdir logs/
#sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
#  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
#  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
#  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.all.csv --threshold 10 --output ${PWD}/out.all
```


##	Per Plate


```BASH
awk 'BEGIN{FS=OFS=","}(NR>1){print $6,$7,"/francislab/data1/working/20250925-Illumina-PhIP/20251113-downsample/out/"$1".VIR3_clean.id_upper_oligo.uniq.1-80.bam",$8,$9,$10,$13,$12,$26,$25 > "manifest.plate"$26".csv" }' /francislab/data1/raw/20250925-Illumina-PhIP/manifest.csv

for manifest in manifest.plate*.csv ; do
sed -i '1isubject,sample,bampath,type,study,group,age,sex,plate,lane' ${manifest}
sed -i 's/,PBS blank,/,input,/' ${manifest}
#sed -i '/Blank24dup/d' ${manifest}
chmod -w ${manifest}
done

```


```BASH
mkdir logs

for manifest in manifest.plate*.csv ; do
num=${manifest%.csv}
num=${num#manifest.plate}
echo $num

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq_process_${num} --time=1-0 --nodes=1 --ntasks=8 --mem=60G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --thresholds 3.5,5,10  \
  --manifest ${PWD}/${manifest} --output ${PWD}/out.plate${num}

done
```


THAT CAN TAKE BETWEEN 2 and 24+ hours.



```BASH
for manifest in manifest.plate*.csv ; do
  plate=${manifest%.csv}
  plate=${plate#manifest.plate}
  echo $plate
  cp ${manifest} out.plate${plate}/
  sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
    --job-name=phip_seq_agg_${plate} --time=1-0 --nodes=1 --ntasks=8 --mem=60G \
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

