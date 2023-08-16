

#	20230726-Illumina-CystEV/20230815-iMOKA


ONLY DEDUPED READS THAT ALIGNED TO HUMAN


```
mkdir -p in
for id in \
  $( awk -F, '($7=="Kirkwood Cyst Study" && $8=="cyst fluid" && $NF!=""){print $1}' \
  /francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_with_analysis_groups_8-1-23hmhmz.csv ) ; do
  #echo $id
  for f in $( ls ../20230809-preprocess/out/${id}.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.??.fastq.gz 2> /dev/null ) ; do
    echo $f
    l=$( basename ${f} .fastq.gz )
    r=${l#*.deduped.}
    l=${l%.format.*}
    ln -s ../${f} in/${l}_${r}.fastq.gz
  done
done



for id in \
  $( awk -F, '($6=="CF"){print $1}' /francislab/data1/raw/20211208-EV/adapter\ and\ indexes\ for\ QB3_NovaSeq\ SP\ 150PE_SFHH009\ S\ Francis_11-16-2021.csv ); do
  for f in $( ls ../../20211208-EV/20230815-preprocess/out/${id}.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.??.fastq.gz 2> /dev/null ) ; do
    echo $f
    l=$( basename ${f} .fastq.gz )
    r=${l#*.deduped.}
    l=${l%.format.*}
    ln -s ../${f} in/${l}_${r}.fastq.gz
  done
done
```






Paired data, so R1;R2 and also O1;O2 (never any S0)

NO SPACES IN GROUP NAMES

```
#awk -v pwd=${PWD} 'BEGIN{FS=",";OFS="\t"}($7=="Kirkwood Cyst Study" && $8=="cyst fluid" && $NF!=""){ if(system("test -f in/"$1"_R1.fastq.gz")==0){ print $1,$NF,pwd"/in/"$1"_R1.fastq.gz;"pwd"/in/"$1"_R2.fastq.gz;"pwd"/in/"$1"_O1.fastq.gz;"pwd"/in/"$1"_O2.fastq.gz" } }' /francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_with_analysis_groups_8-1-23hmhmz.csv | sed 's/ /_/g' > source.all.tsv

#awk -v pwd=${PWD} 'BEGIN{FS=",";OFS="\t"}($6=="CF"){ if(system("test -f in/"$1"_R1.fastq.gz")==0){ print $1,$NF,pwd"/in/"$1"_R1.fastq.gz;"pwd"/in/"$1"_R2.fastq.gz;"pwd"/in/"$1"_O1.fastq.gz;"pwd"/in/"$1"_O2.fastq.gz" } }' /francislab/data1/raw/20211208-EV/adapter\ and\ indexes\ for\ QB3_NovaSeq\ SP\ 150PE_SFHH009\ S\ Francis_11-16-2021.csv | sed 's/ /_/g' >> source.all.tsv

awk -v pwd=${PWD} 'BEGIN{FS=OFS="\t"}{ if(system("test -f in/"$1"_R1.fastq.gz")==0){ print $1,$NF,pwd"/in/"$1"_R1.fastq.gz;"pwd"/in/"$1"_R2.fastq.gz;"pwd"/in/"$1"_O1.fastq.gz;"pwd"/in/"$1"_O2.fastq.gz" } }' metadata.tsv | sed 's/ /_/g' > source.all.tsv
```


```
for k in 11 13 16 21 25 31 35 39 43 47 51; do
  iMOKA_count.bash -k ${k} --threads 64 --mem 490
done
```

```
chmod -w out/*/preprocess/*/*bin
```


```
for k in 11 13 16 21 25 31 35 39 43 47 51; do
  mkdir -p out/grade_collapsed-${k}
  ln -s ../${k}/preprocess out/grade_collapsed-${k}/preprocess
  ln -s ../${k}/create_matrix.tsv out/grade_collapsed-${k}/
done

```



Group sizes are 11 and 13

Using cross validation of 7

```

for k in 11 13 16 21 25 31 35 39 43 47 51; do
 for s in grade_collapsed-${k} ; do
  sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="${s}" \
   --output="${PWD}/logs/iMOKA.${s}.$( date "+%Y%m%d%H%M%S%N" ).out" \
   --time=720 --nodes=1 --ntasks=32 --mem=240G \
   ~/.local/bin/iMOKA.bash --dir ${PWD}/out/${s} --k ${k} --step create --random_forest --cross-validation 7
done ; done

```




```

for k in 11 13 16 21 25 31 35 39 43 47 51; do
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
  for f in $( ls ../20230809-preprocess/out/${id}.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.??.fastq.gz 2> /dev/null ) ; do
    echo $f
    l=$( basename ${f} .fastq.gz )
    r=${l#*.deduped.}
    l=${l%.format.*}
    ln -s ../${f} in/${l}_${r}.fastq.gz
  done
done

```

```

awk -v pwd=${PWD} 'BEGIN{FS=",";OFS="\t"}($7=="Kirkwood Cyst Study" && $8=="SE" && $NF!=""){ if(system("test -f in/"$1"_R1.fastq.gz")==0){ print $1,$NF,pwd"/in/"$1"_R1.fastq.gz;"pwd"/in/"$1"_R2.fastq.gz;"pwd"/in/"$1"_O1.fastq.gz;"pwd"/in/"$1"_O2.fastq.gz" } }' /francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_with_analysis_groups_8-1-23hmhmz.csv | sed 's/ /_/g' > source.predict.tsv

```

```
date=$( date "+%Y%m%d%H%M%S%N" )
for k in 11 13 16 21 25 31 35 39 43 47 51; do
  iMOKA_count.bash -k ${k} --threads 64 --mem 490 --source_file ${PWD}/source.predict.tsv --dir ${PWD}/predictions
done
```


```
chmod -w predictions/*/preprocess/*/*bin
```





```
ssh d1
cd /francislab/data1/working/20230726-Illumina-CystEV/20230815-iMOKA

./predict.bash

```



```
for f in predictions/grade_collapsed-??/* ; do
echo $f
~/.local/bin/box_upload.bash ${f}
done
```


