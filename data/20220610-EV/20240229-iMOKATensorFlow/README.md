
#	20220610-EV/20240228-iMOKATensorFlow

Similar to ...
20220610-EV/20240227-iMOKATensorFlow

but single ended treatment of 20220610-EV



```
mkdir -p in
for f in /francislab/data1/working/20210428-EV/20240229-preprocess/out/SFHH005*.deduped.S0.fastq.gz \
  /francislab/data1/working/20220610-EV/20240228-preprocess-single/out/*.deduped.S0.fastq.gz ; do
echo $f
l=$(basename $f)
l=${l/.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped./_}
l=${l/.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped./_}
ln -s $f in/${l}
done
```



All of 20220610 is IDH-WT

Even controls? I think so.

```
tail -n +2 /francislab/data1/raw/20210428-EV/metadata.csv | sed -e 's/\"//g' -e 's/, /,/g' -e 's/ /-/g' | awk 'BEGIN{FS=OFS=","}($5~/IDH/){ if($5=="IDH1R132H-WT"){idh="IDH-WT"}if($5=="IDH-mutant"){idh="IDH-MT"};print $2,idh,$4,$5 }' > 20210428.metadata.csv

awk 'BEGIN{FS=OFS=","}($7=="case control" && $8=="GBM"){print $1,"IDH-WT",$7,$8,$9}' /francislab/data1/raw/20220610-EV/Sample\ covariate\ file_ids\ and\ indexes_for\ QB3_NovSeq\ SP\ 150PE_SFHH011\ S\ Francis_5-2-22hmh.csv > 20220610.metadata.csv
awk 'BEGIN{FS=OFS=","}($7=="case control" && $8=="control"){print $1,"control",$7,$8,$9}' /francislab/data1/raw/20220610-EV/Sample\ covariate\ file_ids\ and\ indexes_for\ QB3_NovSeq\ SP\ 150PE_SFHH011\ S\ Francis_5-2-22hmh.csv >> 20220610.metadata.csv
```


```
\rm source.all.tsv
awk -v pwd=${PWD} 'BEGIN{FS=",";OFS="\t"}{ if(system("test -f in/"$1"_S0.fastq.gz")==0){ print $1,$2,pwd"/in/"$1"_S0.fastq.gz" } }' 20210428.metadata.csv >> source.all.tsv

awk -v pwd=${PWD} 'BEGIN{FS=",";OFS="\t"}{ if(system("test -f in/"$1"_S0.fastq.gz")==0){ print $1,$2,pwd"/in/"$1"_S0.fastq.gz" } }' 20220610.metadata.csv >> source.all.tsv
```


```
for k in 9 10 11 12 13 14 15 16 17 18 19 20 21 25 31 ; do
  iMOKA_count.bash -k ${k} --threads 16 --mem 120
done
```




```
for k in 9 10 11 12 13 14 15 16 17 18 19 20 21 25 31 ; do
  sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name="${k}tf" --output="${PWD}/tf.${k}.$( date "+%Y%m%d%H%M%S%N" ).out" --time=14000 --nodes=1 --ntasks=4 --mem=30G --exclude=c4-n37,c4-n38,c4-n39 ${PWD}/tf.bash ${k}
done
```




```
ln -s ../20240208-TensorFlow/train_ids.tsv
ln -s ../20240208-TensorFlow/test_ids.tsv
```



```
k=9 && sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name="${k}t" --output="${PWD}/tf_nn.nested.${k}.$( date "+%Y%m%d%H%M%S%N" ).out" --time=14000 --nodes=1 --ntasks=64 --mem=490G --exclude=c4-n37,c4-n38,c4-n39 --wrap="module load WitteLab python3/3.9.1; ${PWD}/tf_nn.nested.py -k ${k} --kmer_matrix=${PWD}/tf/${k}/kmers.rescaled.tsv.gz --train_ids=${PWD}/train_ids.tsv --test_ids=${PWD}/test_ids.tsv --out_dir=${PWD}/tf_nn/${k}/ --iterations=10 --epochs=10"



k=13 && sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name="${k}t" --output="${PWD}/tf_nn.nested.${k}.$( date "+%Y%m%d%H%M%S%N" ).out" --time=14000 --nodes=1 --ntasks=64 --mem=490G --exclude=c4-n37,c4-n38,c4-n39 --wrap="module load WitteLab python3/3.9.1; ${PWD}/tf_nn.nested.py -k ${k} --kmer_matrix=${PWD}/tf/${k}/kmers.rescaled.tsv.gz --train_ids=${PWD}/train_ids.tsv --test_ids=${PWD}/test_ids.tsv --out_dir=${PWD}/tf_nn/${k}/"

k=17 && sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name="${k}t" --output="${PWD}/tf_nn.nested.${k}.$( date "+%Y%m%d%H%M%S%N" ).out" --time=14000 --nodes=1 --ntasks=64 --mem=490G --exclude=c4-n37,c4-n38,c4-n39 --wrap="module load WitteLab python3/3.9.1; ${PWD}/tf_nn.nested.py -k ${k} --kmer_matrix=${PWD}/tf/${k}/kmers.rescaled.tsv.gz --train_ids=${PWD}/train_ids.tsv --test_ids=${PWD}/test_ids.tsv --out_dir=${PWD}/tf_nn/${k}/"
```



k=13 has a matrix which is effectively too large and as such crashes.










Should we just build models using the 20210428 data too? To see if even with that small sample, we can generate something positive.  Leave out like 5 IDH MT and 3 IDH WT for testing?



k=9 && sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name="${k}t" --output="${PWD}/tf_nn.nested.5.${k}.$( date "+%Y%m%d%H%M%S%N" ).out" --time=14000 --nodes=1 --ntasks=64 --mem=490G --exclude=c4-n37,c4-n38,c4-n39 --wrap="module load WitteLab python3/3.9.1; ${PWD}/tf_nn.nested.py -k ${k} --kmer_matrix=${PWD}/tf/${k}/kmers.rescaled.tsv.gz --train_ids=${PWD}/train_ids_5.tsv --test_ids=${PWD}/test_ids_5.tsv --out_dir=${PWD}/tf_nn_5/${k}/"









##	20240307

Create multiple pairs of training and testing ids.


```

for i in 5a 5b 5c 5d ; do
echo $i
\rm train_ids_${i}.tsv test_ids_${i}.tsv
awk 'BEGIN{FS=",";OFS="\t"}($3=="Diffuse-Astrocytoma"){print $1,"IDH-MT"}' 20210428.metadata.csv | shuf|shuf|shuf | tee >(head -8 >> train_ids_${i}.tsv) | tail -n 2 >> test_ids_${i}.tsv
awk 'BEGIN{FS=",";OFS="\t"}($3=="Oligodendroglioma"){print $1,"IDH-MT"}' 20210428.metadata.csv | shuf|shuf|shuf | tee >(head -8 >> train_ids_${i}.tsv) | tail -n 2 >> test_ids_${i}.tsv
awk 'BEGIN{FS=",";OFS="\t"}($3=="GBM" && $4=="IDH-mutant"){print $1,"IDH-MT"}' 20210428.metadata.csv | shuf|shuf|shuf | tee >(head -8 >> train_ids_${i}.tsv) | tail -n 2 >> test_ids_${i}.tsv
awk 'BEGIN{FS=",";OFS="\t"}($3=="GBM" && $4=="IDH1R132H-WT"){print $1,"IDH-WT"}' 20210428.metadata.csv | shuf|shuf|shuf | tee >(head -8 >> train_ids_${i}.tsv) | tail -n 2 >> test_ids_${i}.tsv
done
```


```
for k in 16 17 18 19 ; do
for i in 5a 5b 5c 5d ; do
echo $i
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name="${k}-${i}" --output="${PWD}/tf_nn.nested.${k}-${i}.$( date "+%Y%m%d%H%M%S%N" ).out" --time=14000 --nodes=1 --ntasks=64 --mem=490G --exclude=c4-n37,c4-n38,c4-n39 --wrap="module load WitteLab python3/3.9.1; ${PWD}/tf_nn.nested.py -k ${k} --kmer_matrix=${PWD}/tf/${k}/kmers.rescaled.tsv.gz --train_ids=${PWD}/train_ids_${i}.tsv --test_ids=${PWD}/test_ids_${i}.tsv --out_dir=${PWD}/tf_nn_${i}/${k}/"
done ; done
```




