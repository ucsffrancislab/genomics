

#	20220610-EV/20221025-iMOKA-trim-R1-nr ( 20221019-preprocess-trim-R1only-bowtie2correction )


Quality 15 TRIMMED, paired-end R1 ONLY



Link raw files as fasta.gz
```
DIR=/francislab/data1/working/20220610-EV/20221019-preprocess-trim-R1only-bowtie2correction/out
RAW=${PWD}/raw
mkdir -p $RAW
suffix=format.umi.quality15.t2.t3.hg38.name.marked.deduped.fa.gz
for f in ${DIR}/*.${suffix} ; do
l=$( basename $f .${suffix} )
ln -s $f ${RAW}/${l}.fasta.gz
done



ln -s /francislab/data1/raw/20220610-EV/Sample\ covariate\ file_ids\ and\ indexes_for\ QB3_NovSeq\ SP\ 150PE_SFHH011\ S\ Francis_5-2-22hmh.csv metadata.csv

DIR=${PWD}/raw
while read subject field; do
f=$( ls ${DIR}/${subject}.fasta.gz 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
echo -e "${subject}\t${field}\t${f}"
fi
done < <( awk 'BEGIN{FS=",";OFS="\t"}( /SFHH/ ){print $1,$9}' /francislab/data1/raw/20220610-EV/Sample\ covariate\ file_ids\ and\ indexes_for\ QB3_NovSeq\ SP\ 150PE_SFHH011\ S\ Francis_5-2-22hmh.csv ) > source.all.tsv

```








Preprocess all so can predict later
```
#iMOKA_count.bash -k 11 -k 16 -k 21 -k 31

mkdir out
PREDIR=/francislab/data1/working/20220610-EV/20221025-iMOKA-trim-R1-nr
ln -s ${PREDIR}/out/11 ${PWD}/out/
ln -s ${PREDIR}/out/16 ${PWD}/out/
ln -s ${PREDIR}/out/21 ${PWD}/out/
ln -s ${PREDIR}/out/31 ${PWD}/out/

```


 





WAIT UNTIL COMPLETE and then Create models

```

./iMOKA_prep_create_matrices.bash

```







```
mkdir logs
./iMOKA_actual.bash

```





















Predict those not used in models


```
./predict.bash
```


```
./matrices_of_select_kmers.bash
```



```
nohup ./upload.bash > upload.out.txt 2>1&
```

