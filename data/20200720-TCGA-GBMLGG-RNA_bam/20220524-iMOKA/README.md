
could you run our standard iMOKA pipeline on the TCGA RNA data?
Restricted to IDH mutant samples, this will be a two group analysis: "astrocytoma" and "oligodendroglioma" (just grep from the primary_diagnosis column is sufficient).  The 80/20 split and k = 11, 21 and 31 will suffice!


Reference `/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20210725-iMOKA`
Reference `/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20220121-iMOKA`

```
ln -s /francislab/data1/raw/20200720-TCGA-GBMLGG-RNA_bam/TCGA.Glioma.metadata.tsv 

while read subject field; do
s=${subject#TCGA-}
f=$( ls /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/${s}-01*fastq.gz 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
field=${field/,/}
field=${field/ /_}
echo -e "${s}\t${field}\t${f}"
fi
done < <( awk -F"\t" '( ( $8 == "Mutant" ) && ( ( $3 ~ /Astrocytoma/ ) || ( $3 ~ /Oligodendroglioma/ ) ) ){split($3,a,",");print $1,a[1]}' /francislab/data1/raw/20200720-TCGA-GBMLGG-RNA_bam/TCGA.Glioma.metadata.tsv | sort ) > source.IDHMutant.tsv
```


Preprocess all files for k in 11, 21 and 31 ...
```
./iMOKA_preprocess.bash --source_file source.IDHMutant.tsv --dir ${PWD}/IDH.11 --k 11

./iMOKA_preprocess.bash --source_file source.IDHMutant.tsv --dir ${PWD}/IDH.21 --k 21

./iMOKA_preprocess.bash --source_file source.IDHMutant.tsv --dir ${PWD}/IDH.31 --k 31
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

Create base and split by primary
```
dir1=${PWD}/IDH.11
dir2=${PWD}
sed "s'${dir1}'${dir2}'" ${dir1}/create_matrix.tsv > create_matrix.tsv
awk -F"\t" '( $3 == "Astrocytoma" )' create_matrix.tsv > create_matrix.Astrocytoma.tsv
awk -F"\t" '( $3 == "Oligodendroglioma" )' create_matrix.tsv > create_matrix.Oligodendroglioma.tsv
```

Create 80% subsets.
```
m=$( cat create_matrix.Astrocytoma.tsv | wc -l )
mc=$( echo "0.8 * ${m}" | bc -l 2> /dev/null)
shuf --head-count ${mc} create_matrix.Astrocytoma.tsv > create_matrix.80a.tsv
shuf --head-count ${mc} create_matrix.Astrocytoma.tsv > create_matrix.80b.tsv
shuf --head-count ${mc} create_matrix.Astrocytoma.tsv > create_matrix.80c.tsv

m=$( cat create_matrix.Oligodendroglioma.tsv | wc -l )
mc=$( echo "0.8 * ${m}" | bc -l 2> /dev/null)
shuf --head-count ${mc} create_matrix.Oligodendroglioma.tsv >> create_matrix.80a.tsv
shuf --head-count ${mc} create_matrix.Oligodendroglioma.tsv >> create_matrix.80b.tsv
shuf --head-count ${mc} create_matrix.Oligodendroglioma.tsv >> create_matrix.80c.tsv
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


Run iMOKA
```
date=$( date "+%Y%m%d%H%M%S" )

for k in 11 21 31; do
for s in a b c ; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=R${k}${s} --time=1440 --nodes=1 --ntasks=64 --mem=495G --gres=scratch:1500G \
 --output=${PWD}/IDH.${k}.80${s}/iMOKA_scratch.${date}.txt \
 ${PWD}/iMOKA_scratch.bash --dir ${PWD}/IDH.${k}.80${s} -k ${k} --step create
done ; done
```




Predict.
```
nohup ./predict.bash > predict.out &
```

Better matrix of important kmers.
```
nohup ./matrices_of_select_kmers.bash > matrices_of_select_kmers.out &
```



Upload.
```
./upload.bash
```


