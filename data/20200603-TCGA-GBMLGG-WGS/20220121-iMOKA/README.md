

`/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20210725-iMOKA/README.md`

Reference `/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20220121-iMOKA`





`/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out/TQ-A8XE-10A-01D-A367_R1.fastq.gz`

```
ll /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out/*_R1.fastq.gz | wc -l
278

ll /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out/??-????-01*_R1.fastq.gz | wc -l
125
```


```
while read subject field; do
s=${subject#TCGA-}
f=$( ls /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out/${s}-01*fastq.gz 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
field=${field/,/}
field=${field/ /_}
echo -e "${s}\t${field}\t${f}"
fi
done < <( tail -n +2 TCGA.Glioma.metadata.tsv | awk 'BEGIN{FS=OFS="\t"}{print $1,$8}' ) > source.IDH.all.tsv

wc -l source.IDH.all.tsv
123
```

Create source.IDH.tsv for ALL IDH samples that are either Mutant or Wildtype ...
```
awk -F"\t" '( $2 != "NA" )' source.IDH.all.tsv > source.IDH.tsv
```

```
wc -l source.IDH.*
   123 source.IDH.all.tsv
   122 source.IDH.tsv
```


Preprocess all files for k in 11, 21 and 31 ...
```
./iMOKA_preprocess.bash --source_file source.IDH.tsv --dir ${PWD}/IDH.11 --k 11

./iMOKA_preprocess.bash --source_file source.IDH.tsv --dir ${PWD}/IDH.21 --k 21

./iMOKA_preprocess.bash --source_file source.IDH.tsv --dir ${PWD}/IDH.31 --k 31




./iMOKA_preprocess.bash --source_file source.IDH.21.tsv --dir ${PWD}/IDH.21 --k 21

./iMOKA_preprocess.bash --source_file source.IDH.31.tsv --dir ${PWD}/IDH.31 --k 31
```




Create subdirs
Link preprocess dir from previous runs.
```
for k in 11 21 31 ; do
for s in 80a 80b 80c ; do
mkdir -p IDH.${k}.${s}
ln -s ../IDH.${k}/preprocess IDH.${k}.${s}
done ; done
```





ACTUALLY, NEED TO CREATE SUBSETS OF THE CREATE_MATRIX CREATED IN PREPROCESSING

We want the same subset so use `IDH.11/create_matrix.tsv` as single source

Prepare create_matrix.tsv for each dir

Create base and split by IDH
```
dir1=${PWD}/IDH.11
dir2=${PWD}
sed "s'${dir1}'${dir2}'" ${dir1}/create_matrix.tsv > create_matrix.tsv
awk -F"\t" '( $3 == "Mutant" )' create_matrix.tsv > create_matrix.Mutant.tsv
awk -F"\t" '( $3 == "WT" )' create_matrix.tsv > create_matrix.WT.tsv
```

Create 80% subsets.
```
m=$( cat create_matrix.Mutant.tsv | wc -l )
mc=$( echo "0.8 * ${m}" | bc -l 2> /dev/null)
shuf --head-count ${mc} create_matrix.Mutant.tsv > create_matrix.80a.tsv
shuf --head-count ${mc} create_matrix.Mutant.tsv > create_matrix.80b.tsv
shuf --head-count ${mc} create_matrix.Mutant.tsv > create_matrix.80c.tsv

m=$( cat create_matrix.WT.tsv | wc -l )
mc=$( echo "0.8 * ${m}" | bc -l 2> /dev/null)
shuf --head-count ${mc} create_matrix.WT.tsv >> create_matrix.80a.tsv
shuf --head-count ${mc} create_matrix.WT.tsv >> create_matrix.80b.tsv
shuf --head-count ${mc} create_matrix.WT.tsv >> create_matrix.80c.tsv
```

Disperse.
```
for k in 11 21 31 ; do
for s in 80a 80b 80c ; do
dir1=${PWD}
dir2=${PWD}/IDH.${k}.${s}
sed "s'${dir1}'${dir2}'" ${dir1}/create_matrix.${s}.tsv > ${dir2}/create_matrix.tsv
done ; done
```










Wait until cluster is rebooted Feb 3





There is not enough space on scratch to run 21 and 31.
The script copies all of preprocess to scratch and its more than 2TB.
This needs to be done off scratch.




```
date=$( date "+%Y%m%d%H%M%S" )

for k in 21 31 ; do
for s in a b c ; do
sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL --job-name=D${k}${s} --time=20160 --nodes=1 --ntasks=64 --mem=495G --gres=scratch:1500G \
 --output=${PWD}/IDH.${k}.80${s}/iMOKA_scratch.${date}.txt \
 ${PWD}/iMOKA_scratch.bash --local --dir ${PWD}/IDH.${k}.80${s} -k ${k} --step create
done ; done

```







