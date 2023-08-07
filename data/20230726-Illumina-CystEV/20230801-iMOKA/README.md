

#	20230726-Illumina-CystEV/20230801-iMOKA


reference /francislab/data1/working/20210428-EV/20230606-iMOKA/README.md 


```
mkdir -p in
for id in \
  $( tail -n +2 /francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_with_analysis_groups_8-1-23hmhmz.Kirkwood.csv | cut -d, -f1 | paste -s ) ; do
  #echo $id
  for f in $( ls ../20230801-cutadapt/out/${id}_R?.fastq.gz 2> /dev/null ) ; do
    echo $f
    #b=$( basename ${f} )
    #l=${b%_071323*}
    #r=${b%_001.fastq.gz}
    #r=${r#*_L001_}
    #echo $f ${l}_${r}.fastq.gz
    ln -s ../${f} in/	
    #${l}_${r}.fastq.gz
  done
done
```


Paired data, so R1;R2

NO SPACES IN GROUP NAMES

```
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












---


Predict those not in the models

```
#../../20220610-EV/20221025-iMOKA-trim-R1-nr-14/predict.bash
```

```
#../../20220610-EV/20221025-iMOKA-trim-R1-nr-14/matrices_of_select_kmers.bash
```



```
for k in 13 16 21 31 35 39 43 ; do
for s in GBM-CATS-${k} GBM-Lexogen-${k} IDH-CATS-${k} IDH-Lexogen-${k} GBM-CATS-${k}-withControl GBM-Lexogen-${k}-withControl IDH-CATS-${k}-withControl IDH-Lexogen-${k}-withControl ; do
if [ -f out/${s}/output.json ] ; then
iMOKA_upload.bash out/${s}
fi
done ; done

```



