

Reference `/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20210725-iMOKA`


`/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/WY-A85E-01A-11R-A36H-07+1_R1.fastq.gz`

Tumors only. Did I check this? Make sure that these samples are only 01
```
while read subject field; do
s=${subject#TCGA-}
f=$( ls ${PWD}/raw/${s}-01*fastq.gz 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
field=${field/,/}
field=${field/ /_}
echo -e "${s}\t${field}\t${f}"
fi
done < <( tail -n +2 TCGA.Glioma.metadata.tsv | awk 'BEGIN{FS=OFS="\t"}{print $1,$8}' ) > source.IDH.check.tsv
```



Create source.IDH.tsv for ALL IDH samples that are either Mutant or Wildtype ...
```
awk -F"\t" '( $2 != "NA" )' /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20210725-iMOKA/source.IDH.tsv > source.IDH.tsv
awk -F"\t" '( $2 == "Mutant" )' source.IDH.tsv > source.IDH.Mutant.tsv
awk -F"\t" '( $2 == "WT" )' source.IDH.tsv > source.IDH.WT.tsv
```


Preprocess all files for k in 11, 21 and 31 ...
```
./iMOKA_preprocess.bash --source_file source.IDH.tsv --dir ${PWD}/IDH.11 --k 11

./iMOKA_preprocess.bash --source_file source.IDH.tsv --dir ${PWD}/IDH.21 --k 21

./iMOKA_preprocess.bash --source_file source.IDH.tsv --dir ${PWD}/IDH.31 --k 31
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


Run iMOKA
```
date=$( date "+%Y%m%d%H%M%S" )

for k in 11 21 31; do
for s in a b c ; do
sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL --job-name=R${k}${s} --time=1440 --nodes=1 --ntasks=64 --mem=495G --gres=scratch:1500G \
 --output=${PWD}/IDH.${k}.80${s}/iMOKA_scratch.${date}.txt \
 ${PWD}/iMOKA_scratch.bash --dir ${PWD}/IDH.${k}.80${s} -k ${k} --step create
done ; done
```




Do not use this anymore.
Extract mers in feature importance file. (Raw and Scaled)
Assuming that high feature importance is good.
Better version after prediction. See below.
```
export SINGULARITY_BINDPATH=/francislab
export OMP_NUM_THREADS=16
export IMOKA_MAX_MEM_GB=96
img=/francislab/data2/refs/singularity/iMOKA_extended-1.1.5.img
for k in 11 21 31 ; do
for s in 80a 80b 80c ; do
tail -q -n +2 IDH.${k}.${s}/output_fi.tsv | sort -k2gr | head -100 | awk '{print $1}' | sort | uniq > ${k}.${s}.mers.txt
dir=/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20220121-iMOKA
for f in ${dir}/IDH.${k}/preprocess/*/*json ; do
echo $f
singularity exec ${img} iMOKA_core extract --raw --input ${dir}/${k}.${s}.mers.txt --source ${f} --output ${f}.${s}.raw.mer_counts.txt
singularity exec ${img} iMOKA_core extract --input ${dir}/${k}.${s}.mers.txt --source ${f} --output ${f}.${s}.scaled.mer_counts.txt
done ; done ; done
```
then Merge
```
for k in 11 21 31 ; do
for s in 80a 80b 80c ; do
python3 ./merge.py --int --output ${k}.${s}.raw.merged.csv.gz IDH.${k}/preprocess/*/*.${s}.raw.mer_counts.txt
python3 ./merge.py --output ${k}.${s}.scaled.merged.csv.gz IDH.${k}/preprocess/*/*.${s}.scaled.mer_counts.txt
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
BOX="https://dav.box.com/dav/Francis _Lab_Share/20200720-TCGA-GBMLGG-RNA_bam/20220121-iMOKA"
curl -netrc -X MKCOL "${BOX}/"

for f in metadata.cart.TCGA.GBM-LGG.WGS.bam.2020-07-17.csv TCGA.Glioma.metadata.tsv ; do
echo $f
curl -netrc -T ${f} "${BOX}/"
done

for k in 11 21 31 ; do

for s in 80a 80b 80c ; do
BOX="https://dav.box.com/dav/Francis _Lab_Share/20200720-TCGA-GBMLGG-RNA_bam/20220121-iMOKA/IDH.${k}.${s}"
curl -netrc -X MKCOL "${BOX}/"

curl -netrc -T ${k}.${s}.mers.txt "${BOX}/"
curl -netrc -T ${k}.${s}.raw.merged.csv.gz "${BOX}/"
curl -netrc -T ${k}.${s}.scaled.merged.csv.gz "${BOX}/"

for f in create_matrix.tsv aggregated.json output.json output_fi.tsv ; do
echo $f
curl -netrc -T IDH.${k}.${s}/${f} "${BOX}/"
done ; done ; done
```




