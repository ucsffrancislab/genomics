
#	20220610-EV/20240201-iMOKA



```
20210428-EV/20240130-preprocess/out/*.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.S0.fastq.gz
20220610-EV/20240131-preprocess/out/*.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.??.fastq.gz
20230726-Illumina-CystEV/20240131-preprocess/out/*.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.??.fastq.gz
```

R? and O? or just R?



Analyze both Glioma datasets, plus blanks from a third, together 

Remove kmers based on presence in blanks or phipseq zscore

Like ...
```
20230726-Illumina-CystEV/20230815-iMOKA/README.md 
```


```
single end
/francislab/data1/working/20210428-EV/20240130-preprocess/out/SFHH005*.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.S0.fastq.gz

paired end
/francislab/data1/working/20220610-EV/20240131-preprocess/out/SFHH011*.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.R1.fastq.gz

paired end
/francislab/data1/working/20230726-Illumina-CystEV/20240131-preprocess/out/*.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.R1.fastq.gz
```

```
mkdir -p in
for f in /francislab/data1/working/20210428-EV/20240130-preprocess/out/SFHH005*.deduped.S0.fastq.gz \
  /francislab/data1/working/20230726-Illumina-CystEV/20240131-preprocess/out/*.deduped.[RO]?.fastq.gz \
  /francislab/data1/working/20220610-EV/20240131-preprocess/out/*.deduped.[RO]?.fastq.gz ; do
echo $f
l=$(basename $f)
l=${l/.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped./_}
l=${l/.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped./_}
ln -s $f in/${l}
done
```





```
awk 'BEGIN{FS=OFS=","}(NR>1){print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12}' /francislab/data1/raw/20220610-EV/Sample\ covariate\ file_ids\ and\ indexes_for\ QB3_NovSeq\ SP\ 150PE_SFHH011\ S\ Francis_5-2-22hmh.csv > 20220610.metadata.csv

tail -n +2 /francislab/data1/raw/20210428-EV/metadata.csv | tr -d \" | awk 'BEGIN{FS=OFS=","}{ print $2,$4,$5,$6 }' | sed -e 's/, /,/g' -e 's/ /-/g' > 20210428.metadata.csv

awk 'BEGIN{OFS=FS=","}(NR>1){print $1,$6,$7,$NF}' /francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_with_analysis_groups_8-1-23hmhmz.csv > 20230727.metadata.csv
```

```
FPAT="([^,]+)|(\"[^\"]+\")"
FPAT="([^,]*)|(\"[^\"]+\")"
```





```
\rm source.all.tsv
awk -v pwd=${PWD} 'BEGIN{FS=",";OFS="\t"}{ if(system("test -f in/"$1"_S0.fastq.gz")==0){ print $1,$2,pwd"/in/"$1"_S0.fastq.gz" } }' 20210428.metadata.csv >> source.all.tsv

awk -v pwd=${PWD} 'BEGIN{FS=",";OFS="\t"}{ if(system("test -f in/"$1"_R1.fastq.gz")==0){ print $1,$8,pwd"/in/"$1"_R1.fastq.gz;"pwd"/in/"$1"_R2.fastq.gz;"pwd"/in/"$1"_O1.fastq.gz;"pwd"/in/"$1"_O2.fastq.gz" } }' 20220610.metadata.csv >> source.all.tsv


awk -v pwd=${PWD} 'BEGIN{FS=",";OFS="\t"}($3=="blank"){ if(system("test -f in/"$1"_R1.fastq.gz")==0){ print $1,"blank",pwd"/in/"$1"_R1.fastq.gz;"pwd"/in/"$1"_R2.fastq.gz;"pwd"/in/"$1"_O1.fastq.gz;"pwd"/in/"$1"_O2.fastq.gz" } }' 20230727.metadata.csv >> source.all.tsv

```



NOTE these are 23-400 MB
```
/francislab/data1/working/20210428-EV/20240130-preprocess/out/SFHH005*.deduped.bam
```

and these are bigger 145-983MB (1 is 419k)

```
/francislab/data1/working/20220610-EV/20240131-preprocess/out/SFHH011*deduped.bam
```


```
95-847 MB
/francislab/data1/working/20230726-Illumina-CystEV/20240131-preprocess/out/SFHH011*deduped.bam
```


```
for k in 9 10 11 12 13 14 15 16 17 18 19 20 21 25 31 35 39 43 47 51; do
  iMOKA_count.bash -k ${k} --threads 16 --mem 120
done
```















Lets try this in iMOKA first. How about we add these two blanks to the previous blank pool and use that filter the kmer table using the z-score like approach we just did for the cyst samples.

Then, as a first pass, lets try to make an IDH classifier.

Lets group:

10 astros, 10 oligos, 10gbm IDH-MT

2) 10 GBM IDG-WT and 10 of  "18 case control,GBM,Primary"

We can use the remaining 8 as an testing set.

Sound good?






IDH-MT (all from 20210428) - 8/10 Astro, 8/10 Oligo, 8/10 GBM IDHMT 

IDT-WT - 8/10 IDHWT from 20210428, 10/18 "case control,GBM,Primary" from 20220610

Test - 2/10 Astro, 2/10 Oligo, 2/10 GBM IDHMT, 2/10 GBM IDHWT, 8/18 "case control,GBM,Primary"




```
\rm train_ids.tsv test_ids.tsv blank_ids.tsv
awk 'BEGIN{FS=",";OFS="\t"}($2=="Diffuse-Astrocytoma"){print $1,"IDH-MT"}' 20210428.metadata.csv | shuf|shuf|shuf | tee >(head -8 >> train_ids.tsv) | tail -n 2 >> test_ids.tsv
awk 'BEGIN{FS=",";OFS="\t"}($2=="Oligodendroglioma"){print $1,"IDH-MT"}' 20210428.metadata.csv | shuf|shuf|shuf | tee >(head -8 >> train_ids.tsv) | tail -n 2 >> test_ids.tsv
awk 'BEGIN{FS=",";OFS="\t"}($2=="GBM" && $3=="IDH-mutant"){print $1,"IDH-MT"}' 20210428.metadata.csv | shuf|shuf|shuf | tee >(head -8 >> train_ids.tsv) | tail -n 2 >> test_ids.tsv
awk 'BEGIN{FS=",";OFS="\t"}($2=="GBM" && $3=="IDH1R132H-WT"){print $1,"IDH-WT"}' 20210428.metadata.csv | shuf|shuf|shuf | tee >(head -8 >> train_ids.tsv) | tail -n 2 >> test_ids.tsv
awk 'BEGIN{FS=",";OFS="\t"}($7=="case control" && $8=="GBM" && $9=="Primary"){print $1,"IDH-WT"}' 20220610.metadata.csv | shuf|shuf|shuf | tee >(head -10 >> train_ids.tsv) | tail -n 8 >> test_ids.tsv
awk 'BEGIN{FS=",";OFS="\t"}($2~/^blank/){print $1,"blank"}' 20210428.metadata.csv >> blank_ids.tsv
awk 'BEGIN{FS=",";OFS="\t"}($3=="blank"){print $1,$3}' 20230727.metadata.csv >> blank_ids.tsv
```








##	Z-score filter and predict ...



```
for k in 9 10 11 12 13 14 15 16 17 18 19 20 21 25 31 35 39 43 47 51; do
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="${k}" \
  --output="${PWD}/logs/iMOKA.zscore_filter.${k}.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=14000 --nodes=1 --ntasks=32 --mem=240G \
  ${PWD}/iMOKA_zscore_filter.bash --k ${k} --random_forest --cross-validation 2
done
```



























k>=12 are failing to keep many mers. These are heavily trimmed short EV miRNA so not surprising.



zscore analysis failing on k>=35 deep in the virscan module. (I think this happened in the previously tried dataset)

```
Error in vecseq(f__, len__, if (allow.cartesian || notjoin || !anyDuplicated(f__,  : 
  Join results in 32301984 rows; more than 2019069 = nrow(x)+nrow(i). Check for duplicate key values in i each of which join to the same group in x over and over again. If that's ok, try by=.EACHI to run j for each group to avoid the large allocation. If you are sure you wish to proceed, rerun with allow.cartesian=TRUE. Otherwise, please search for this error message in the FAQ, Wiki, Stack Overflow and data.table issue tracker for advice.
Calls: <Anonymous> -> vs.makeGroups -> [ -> [.data.table -> vecseq
Execution halted
```







```

for k in 9 10 11 12 13 ; do

mkdir -p ${PWD}/predictions/${k}

join -1 2 -2 1 <( sort -k2,2 ${PWD}/out/${k}/create_matrix.tsv)  <( sort -k1,1 ${PWD}/test_ids.tsv ) \
  | awk 'BEGIN{OFS="\t"}{print $2,$1,$4}' > ${PWD}/predictions/${k}/predict_matrix.tsv

~/.local/bin/iMOKA_predict.bash --threads 8 \
--model_base ${PWD}/zscores_filtered/${k} \
--predict_matrix  ${PWD}/predictions/${k}/predict_matrix.tsv \
--predict_out ${PWD}/predictions/${k}

done

```








##	Blank filter and predict

    --random_forest --max-features 5

```
for k in 9 10 11 12 13 14 15 16 21 25 31 35 39 43 47 51; do
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="${k}" \
  --output="${PWD}/logs/iMOKA.blank_filter.${k}.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=14000 --nodes=1 --ntasks=32 --mem=240G \
  ${PWD}/iMOKA_blank_filter.bash --k ${k} \
    --random_forest --cross-validation 2
done
```



```

for k in 9 10 11 12 13 14 15 16 21; do

mkdir -p ${PWD}/blank_predictions/${k}

join -1 2 -2 1 <( sort -k2,2 ${PWD}/out/${k}/create_matrix.tsv)  <( sort -k1,1 ${PWD}/test_ids.tsv ) \
  | awk 'BEGIN{OFS="\t"}{print $2,$1,$4}' > ${PWD}/blank_predictions/${k}/predict_matrix.tsv

~/.local/bin/iMOKA_predict.bash --threads 8 \
--model_base ${PWD}/blanks_filtered/${k} \
--predict_matrix  ${PWD}/blank_predictions/${k}/predict_matrix.tsv \
--predict_out ${PWD}/blank_predictions/${k}

done

```




##	20240129


Loop though kmer counts and take median of samples and blanks


```
zcat dump/13/kmers.raw.tsv.gz | tail -n +3 | awk 'function median(nums)
{ asort(nums); l=length(nums); return ((l % 2 == 0) ? ( nums[l/2] + nums[(l/2) + 1] ) / 2 : nums[int(l/2) + 1]) }{ 
s=$2;for(i=3;i<=NF-6;i++){s=s","$i}
split(s,z,",")
a=median(z)
s=$(NF-5);for(i=(NF-4);i<=NF;i++){s=s","$i}
split(s,z,",")
b=median(z)
print $1,a,b
}' | sort -k3nr | head



zcat dump/13/kmers.raw.tsv.gz | tail -n +3 | awk 'function median(nums)
{ asort(nums); l=length(nums); return ((l % 2 == 0) ? ( nums[l/2] + nums[(l/2) + 1] ) / 2 : nums[int(l/2) + 1]) }{ 
s=$2;for(i=3;i<=NF-6;i++){s=s","$i}
split(s,z,",")
a=median(z)
s=$(NF-5);for(i=(NF-4);i<=NF;i++){s=s","$i}
split(s,z,",")
b=median(z)
print $1,a,b
}' | sort -k2nr | head

```




