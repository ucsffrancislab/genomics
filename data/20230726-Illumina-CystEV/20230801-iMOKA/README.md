

#	20230726-Illumina-CystEV/20230801-iMOKA


reference /francislab/data1/working/20210428-EV/20230606-iMOKA/README.md 


```
#  $( tail -n +2 /francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_with_analysis_groups_8-1-23hmhmz.Kirkwood.csv | cut -d, -f1 | paste -s ) ; do

mkdir -p in
for id in \
  $( awk -F, '($7=="Kirkwood Cyst Study" && $8=="cyst fluid" && $NF!=""){print $1}' \
  /francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_with_analysis_groups_8-1-23hmhmz.csv ) ; do
  #echo $id
  for f in $( ls ../20230801-cutadapt/out/${id}_R?.fastq.gz 2> /dev/null ) ; do
    echo $f
    ln -s ../${f} in/	
  done
done
```


Paired data, so R1;R2

NO SPACES IN GROUP NAMES

```
awk -v pwd=${PWD} 'BEGIN{FS=",";OFS="\t"}($7=="Kirkwood Cyst Study" && $8=="cyst fluid" && $NF!=""){ if(system("test -f in/"$1"_R1.fastq.gz")==0){ print $1,$NF,pwd"/in/"$1"_R1.fastq.gz;"pwd"/in/"$1"_R2.fastq.gz" } }' /francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_with_analysis_groups_8-1-23hmhmz.csv | sed 's/ /_/g' > source.all.tsv

awk -v pwd=${PWD} 'BEGIN{FS=",";OFS="\t"}(NR>1){ if(system("test -f in/"$1"_R1.fastq.gz")==0){ print $1,$NF,pwd"/in/"$1"_R1.fastq.gz;"pwd"/in/"$1"_R2.fastq.gz" } }' /francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_with_analysis_groups_8-1-23hmhmz.Kirkwood.csv | sed 's/ /_/g' > source.all.tsv

```


```
for k in 13 16 21 31 35 39 43 ; do
  iMOKA_count.bash -k ${k} --threads 64 --mem 490
done
```


```
chmod -w out/*/preprocess/*/*bin
```


```
for k in 13 16 21 31 35 39 43 ; do
  mkdir -p out/grade_collapsed-${k}
  ln -s ../${k}/preprocess out/grade_collapsed-${k}/preprocess
  ln -s ../${k}/create_matrix.tsv out/grade_collapsed-${k}/
done

```


```

for k in 13 16 21 31 35 39 43 ; do
 for s in grade_collapsed-${k} ; do
  sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="${s}" \
   --output="${PWD}/logs/iMOKA.${s}.$( date "+%Y%m%d%H%M%S%N" ).out" \
   --time=720 --nodes=1 --ntasks=32 --mem=240G \
   ~/.local/bin/iMOKA.bash --dir ${PWD}/out/${s} --k ${k} --step create 
done ; done

```


All failed with ...
```
tail -n 1 logs/iMOKA.grade_collapsed-*.2023080*.out 
==> logs/iMOKA.grade_collapsed-13.20230802204804397584613.out <==
ValueError: n_splits=10 cannot be greater than the number of members in each class.

==> logs/iMOKA.grade_collapsed-16.20230802204804588237664.out <==
ValueError: n_splits=10 cannot be greater than the number of members in each class.

==> logs/iMOKA.grade_collapsed-21.20230802204804636830227.out <==
ValueError: n_splits=10 cannot be greater than the number of members in each class.

==> logs/iMOKA.grade_collapsed-31.20230802204804682404900.out <==
ValueError: n_splits=10 cannot be greater than the number of members in each class.

==> logs/iMOKA.grade_collapsed-35.20230802204804729428205.out <==
ValueError: n_splits=10 cannot be greater than the number of members in each class.

==> logs/iMOKA.grade_collapsed-39.20230802204804762434133.out <==
ValueError: n_splits=10 cannot be greater than the number of members in each class.

==> logs/iMOKA.grade_collapsed-43.20230802204804903777242.out <==
ValueError: n_splits=10 cannot be greater than the number of members in each class.
```
This is due to the fact that there are only 7 members of each class.

Rerun with a number less than 10 with which parameter?

```
#  -m MAX_FEATURES, --max-features MAX_FEATURES
#                        The maximum number of features to use. Default: 10
#  -c CROSS_VALIDATION, --cross-validation CROSS_VALIDATION
#                        Cross validation used to determine the metrics of the models. Default: 1
```

```

for k in 13 16 21 31 35 39 43 ; do
 for s in grade_collapsed-${k} ; do
  sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="${s}" \
   --output="${PWD}/logs/iMOKA.${s}.$( date "+%Y%m%d%H%M%S%N" ).out" \
   --time=720 --nodes=1 --ntasks=32 --mem=240G \
   ~/.local/bin/iMOKA.bash --dir ${PWD}/out/${s} --k ${k} --step random_forest --random_forest --max-features 5
done ; done

```

Nope


```

for k in 13 16 21 31 35 39 43 ; do
 for s in grade_collapsed-${k} ; do
  sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="${s}" \
   --output="${PWD}/logs/iMOKA.${s}.$( date "+%Y%m%d%H%M%S%N" ).out" \
   --time=720 --nodes=1 --ntasks=32 --mem=240G \
   ~/.local/bin/iMOKA.bash --dir ${PWD}/out/${s} --k ${k} --step random_forest --random_forest --cross-validation 5
done ; done

```

```

for k in 13 16 21 31 35 39 43 ; do
 for s in grade_collapsed-${k} ; do
  if [ -f out/${s}/output.json ] ; then
   iMOKA_upload.bash out/${s}
  fi
done ; done

```




Let's predict the SE

```
mkdir -p in
for id in \
  $( awk -F, '($7=="Kirkwood Cyst Study" && $8=="SE" && $NF!=""){print $1}' \
  /francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_with_analysis_groups_8-1-23hmhmz.csv ) ; do
  #echo $id
  for f in $( ls ../20230801-cutadapt/out/${id}_R?.fastq.gz 2> /dev/null ) ; do
    echo $f
    ln -s ../${f} in/	
  done
done
```


```

awk -v pwd=${PWD} 'BEGIN{FS=",";OFS="\t"}($7=="Kirkwood Cyst Study" && $8=="SE" && $NF!=""){ if(system("test -f in/"$1"_R1.fastq.gz")==0){ print $1,$NF,pwd"/in/"$1"_R1.fastq.gz;"pwd"/in/"$1"_R2.fastq.gz" } }' /francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_with_analysis_groups_8-1-23hmhmz.csv | sed 's/ /_/g' > source.predict.tsv

```

```
date=$( date "+%Y%m%d%H%M%S%N" )
for k in 13 16 21 31 35 39 43 ; do
  iMOKA_count.bash -k ${k} --threads 64 --mem 490 --source_file ${PWD}/source.predict.tsv --dir ${PWD}/predictions
done
```


```
chmod -w predictions/*/preprocess/*/*bin
```





```
ssh d1
/francislab/data1/working/20230726-Illumina-CystEV/20230801-iMOKA

./predict.bash

```

Nothing great

```
for f in predictions/grade_collapsed-??/* ; do
echo $f
~/.local/bin/box_upload.bash ${f}
done
```





##	20230808


Run the old cyst fluid EV data from the last batch through this prediction model also?  20211208-EV

```
/francislab/data1/working/20211208-EV/20221024-preprocessing-paired/
```

```
##          id condition  libsize
## 1  SFHH009H       Low  7117958
## 2  SFHH009L       Low  4469587
## 3  SFHH009E HighAdeno  1075103
## 4  SFHH009G       Low  7348242
## 5  SFHH009I HighAdeno  4649449
## 6  SFHH009F       Low  7524770
## 7  SFHH009D HighAdeno  1458794
## 8  SFHH009N HighAdeno 15905847
## 9  SFHH009C HighAdeno  8819837
## 10 SFHH009M HighAdeno 10380729
```



Given that this is crossing projects, create generic predict script that takes input params ...

Don't need to pass k, but k would very likely be part of the loop calling this ..

different naming convention for grades will likely make all look like the failed


```
out_base=${PWD}/20211208-EV-predictions
for d in /francislab/data1/working/20211208-EV/20221026-iMOKA-paired/out/?? ; do
echo $d
k=$(basename ${d})
var=grade_collapsed
model_base=${PWD}/out/${var}-${k}
if [ -d ${model_base} ]; then
echo ${model_base} exists. Predicting.
predict_out=${out_base}/$( basename ${model_base} )
mkdir -p ${predict_out}
echo "Creating predict_matrix.tsv from create_matrix.tsv"
sed -E -e 's/Low/LGD_or_No_HGD\/Carcinoma_seen/' \
  -e 's/(High|Adenocarcinoma)/HGD_or_Invasive_Cancer/' \
  ${d}/create_matrix.tsv > ${predict_out}/predict_matrix.tsv
iMOKA_predict.bash \
  --model_base ${model_base} \
  --predict_matrix ${predict_out}/predict_matrix.tsv \
  --predict_out ${predict_out}
else
echo ${model_base} does not exist. Skipping.
fi
done
```



