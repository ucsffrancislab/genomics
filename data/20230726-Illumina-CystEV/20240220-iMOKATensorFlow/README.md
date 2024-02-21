

#	20230726-Illumina-CystEV/20240220-iMOKATensorFlow

Similar to 20220610-EV/20240201-iMOKA - 20220610-EV/20240208-TensorFlow

```
mkdir -p in
for f in \
  /francislab/data1/working/20230726-Illumina-CystEV/20240131-preprocess/out/*.deduped.[RO]?.fastq.gz \
  /francislab/data1/working/20211208-EV/20240220-preprocess/out/*.deduped.[RO]?.fastq.gz ; do
echo $f
l=$(basename $f)
l=${l/.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped./_}
ln -s $f in/${l}
done
```

HGD/AN vs LGD
H/A v Low

```
awk 'BEGIN{OFS=",";FS="\t"}(NR>1){if($5~/High|Adenocarcinoma/)$5="HiAd";if($5=="Low")$5="LoNo";print $1,"CF",$5}' /francislab/data1/raw/20211208-EV/plot_2.csv > 20211208.metadata.csv

awk 'BEGIN{OFS=FS=","}(NR>1 && $6~/^Kirkwood Cyst Study/ && $NF!=""){if($NF=="HGD or Invasive Cancer")$NF="HiAd";if($NF=="LGD or No HGD/Carcinoma seen")$NF="LoNo";if($8=="cyst fluid")$8="CF"; print $1,$8,$NF}' /francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_with_analysis_groups_8-1-23hmhmz.csv > 20230727.metadata.csv
```

















```
\rm source.all.tsv

awk -v pwd=${PWD} 'BEGIN{FS=",";OFS="\t"}{ if(system("test -f in/"$1"_R1.fastq.gz")==0){ print $1,$3,pwd"/in/"$1"_R1.fastq.gz;"pwd"/in/"$1"_R2.fastq.gz;"pwd"/in/"$1"_O1.fastq.gz;"pwd"/in/"$1"_O2.fastq.gz" } }' 20211208.metadata.csv >> source.all.tsv

awk -v pwd=${PWD} 'BEGIN{FS=",";OFS="\t"}{ if(system("test -f in/"$1"_R1.fastq.gz")==0){ print $1,$3,pwd"/in/"$1"_R1.fastq.gz;"pwd"/in/"$1"_R2.fastq.gz;"pwd"/in/"$1"_O1.fastq.gz;"pwd"/in/"$1"_O2.fastq.gz" } }' 20230727.metadata.csv >> source.all.tsv

```


1- the best prediction for the serum based on the cyst EVs

Train on cyst fluid ONLY. Test on serum.
```
\rm -f train_ids.tsv test_ids.tsv

awk -v pwd=${PWD} 'BEGIN{FS=",";OFS="\t"}{ if(system("test -f in/"$1"_R1.fastq.gz")==0){ print $1,$2,$3 } }' 20211208.metadata.csv >> train_ids.tsv

awk -v pwd=${PWD} 'BEGIN{FS=",";OFS="\t"}{ if(system("test -f in/"$1"_R1.fastq.gz")==0 && $2=="CF"){ print $1,$2,$3 } }' 20230727.metadata.csv >> train_ids.tsv

awk -v pwd=${PWD} 'BEGIN{FS=",";OFS="\t"}{ if(system("test -f in/"$1"_R1.fastq.gz")==0 && $2=="SE"){ print $1,$2,$3 } }' 20230727.metadata.csv >> test_ids.tsv

chmod -w train_ids.tsv test_ids.tsv
```



2- an 80/20 split of cyst EVs to see how well tensor flow can predict.

20211208 - 10 samples - 8 / 2
20230727 - 14 samples - 11 / 3
```
\rm -f cf_train_ids.tsv cf_test_ids.tsv

awk -v pwd=${PWD} 'BEGIN{FS=",";OFS="\t"}{ if(system("test -f in/"$1"_R1.fastq.gz")==0){ print $1,$2,$3 } }' 20211208.metadata.csv |shuf|shuf|shuf| tee >(head -8 >> cf_train_ids.tsv) | tail -n 2 >> cf_test_ids.tsv

awk -v pwd=${PWD} 'BEGIN{FS=",";OFS="\t"}{ if(system("test -f in/"$1"_R1.fastq.gz")==0 && $2=="CF"){ print $1,$2,$3 } }' 20230727.metadata.csv |shuf|shuf|shuf| tee >(head -11 >> cf_train_ids.tsv) | tail -n 3 >> cf_test_ids.tsv

chmod -w cf_train_ids.tsv cf_test_ids.tsv
```



```
for k in 9 18 ; do
  iMOKA_count.bash -k ${k} --threads 16 --mem 120
done
```


```
for k in 9 18 ; do
  tf.bash ${k}
done

```




Test
```
k=9 && sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name="${k}tf" --output="${PWD}/tf_nn.nested_wrapper.${k}.$( date "+%Y%m%d%H%M%S%N" ).out" --time=14000 --nodes=1 --ntasks=64 --mem=490G --exclude=c4-n37,c4-n38 --wrap="module load WitteLab python3/3.9.1; ${PWD}/tf_nn.nested_wrapper.py ${k}"


Run
```
k=18 && sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name="${k}tf" --output="${PWD}/tf_nn.nested_wrapper.${k}.$( date "+%Y%m%d%H%M%S%N" ).out" --time=14000 --nodes=1 --ntasks=64 --mem=490G --exclude=c4-n37,c4-n38 --wrap="module load WitteLab python3/3.9.1; ${PWD}/tf_nn.nested_wrapper.py ${k}"

```

Modify the script to use the other set of train and test ids and rerun.

Nothing really found



##	Retry with several k but no long iterations


```
for k in 11 13 15 17 19 21 23 ; do
  iMOKA_count.bash -k ${k} --threads 16 --mem 120
done
```


```
for k in 11 13 15 17 19 21 23 ; do
  tf.bash ${k}
done

```



Run CF-SE first

```
for k in 11 13 15 17 19 21 23 ; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name="${k}tf" --output="${PWD}/tf_nn.nested_wrapper.${k}.$( date "+%Y%m%d%H%M%S%N" ).out" --time=14000 --nodes=1 --ntasks=64 --mem=490G --exclude=c4-n37,c4-n38 --wrap="module load WitteLab python3/3.9.1; ${PWD}/tf_nn.nested_wrapper.py ${k}"
done

```

Once done, change train/test files and redo for CF-only



