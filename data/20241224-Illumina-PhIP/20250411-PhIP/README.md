
#	20241224-Illumina-PhIP/20250411-PhIP



##  All

```
awk 'BEGIN{FS=OFS=","}(NR>1){subject=$3;sub(/dup$/,"",subject);s=$1;sub(/S/,"",s);s=int(s); print subject,$3,"/francislab/data1/working/20241224-Illumina-PhIP/20250410-bowtie2/out/S"s".VIR3_clean.id_upper_oligo.uniq.1-80.bam",$7,$8,$9,$11,$12,$23}' /francislab/data1/raw/20241224-Illumina-PhIP/manifest.csv > manifest.all.csv

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


##  Per Plate


```

awk 'BEGIN{FS=OFS=","}(NR>1){subject=$3;sub(/dup$/,"",subject);s=$1;sub(/S/,"",s);s=int(s); print subject,$3,"/francislab/data1/working/20241224-Illumina-PhIP/20250410-bowtie2/out/S"s".VIR3_clean.id_upper_oligo.uniq.1-80.bam",$7,$8,$9,$11,$12,$23 > "manifest.plate"$23".csv" }' /francislab/data1/raw/20241224-Illumina-PhIP/manifest.csv

for manifest in manifest.plate*.csv ; do 
sed -i '1isubject,sample,bampath,type,study,group,age,sex,plate' ${manifest}
sed -i 's/,PBS blank,/,input,/' ${manifest}
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



##	20250930

Include Zscore=5 filter

```BASH
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


