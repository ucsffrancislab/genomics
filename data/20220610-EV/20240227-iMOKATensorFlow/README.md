
#	20220610-EV/20240227-iMOKATensorFlow

20220610-EV/20240208-TensorFlow

```
mkdir -p in
for f in /francislab/data1/working/20210428-EV/20240221-preprocess/out/SFHH005*.deduped.S0.fastq.gz \
  /francislab/data1/working/20220610-EV/20240221-preprocess/out/*.deduped.[RO]?.fastq.gz ; do
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

awk 'BEGIN{FS=OFS=","}($7=="case control" || $8=="GBM"){print $1,"IDH-WT",$7,$8,$9}' /francislab/data1/raw/20220610-EV/Sample\ covariate\ file_ids\ and\ indexes_for\ QB3_NovSeq\ SP\ 150PE_SFHH011\ S\ Francis_5-2-22hmh.csv > 20220610.metadata.csv
```


```
\rm source.all.tsv
awk -v pwd=${PWD} 'BEGIN{FS=",";OFS="\t"}{ if(system("test -f in/"$1"_S0.fastq.gz")==0){ print $1,$2,pwd"/in/"$1"_S0.fastq.gz" } }' 20210428.metadata.csv >> source.all.tsv

awk -v pwd=${PWD} 'BEGIN{FS=",";OFS="\t"}{ if(system("test -f in/"$1"_R1.fastq.gz")==0){ print $1,$2,pwd"/in/"$1"_R1.fastq.gz;"pwd"/in/"$1"_R2.fastq.gz;"pwd"/in/"$1"_O1.fastq.gz;"pwd"/in/"$1"_O2.fastq.gz" } }' 20220610.metadata.csv >> source.all.tsv
```


```
for k in 9 10 11 12 13 14 15 16 17 18 19 20 21 25 31 ; do
  iMOKA_count.bash -k ${k} --threads 16 --mem 120
done
```




```
ln -s ../20240208-TensorFlow/train_ids.tsv
ln -s ../20240208-TensorFlow/test_ids.tsv
```




