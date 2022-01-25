

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


Create a couple 80% subsets of source.IDH.tsv
```
m=$( cat source.IDH.Mutant.tsv | wc -l )
mc=$( echo "0.8 * ${m}" | bc -l 2> /dev/null)
shuf --head-count ${mc} source.IDH.Mutant.tsv > source.IDH.80a.tsv
shuf --head-count ${mc} source.IDH.Mutant.tsv > source.IDH.80b.tsv
shuf --head-count ${mc} source.IDH.Mutant.tsv > source.IDH.80c.tsv

m=$( cat source.IDH.WT.tsv | wc -l )
mc=$( echo "0.8 * ${m}" | bc -l 2> /dev/null)
shuf --head-count ${mc} source.IDH.WT.tsv >> source.IDH.80a.tsv
shuf --head-count ${mc} source.IDH.WT.tsv >> source.IDH.80b.tsv
shuf --head-count ${mc} source.IDH.WT.tsv >> source.IDH.80c.tsv
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








Prepare create_matrix.tsv for each dir
```
for k in 11 21 31 ; do
for s in 80a 80b 80c ; do
dir1=${PWD}/IDH.${k}
dir2=${PWD}/IDH.${k}.${s}
sed "s'${dir1}'${dir2}'" ${dir1}/create_matrix.tsv > ${dir2}/create_matrix.tsv
done ; done
```














```
date=$( date "+%Y%m%d%H%M%S" )

for k in 11 ; do
for s in a b c ; do
sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL --job-name=R${k}${s} --time=20160 --nodes=1 --ntasks=64 --mem=499G --gres=scratch:1500G \
 --output=${PWD}/IDH.${k}.80${s}/iMOKA_scratch.${date}.txt \
 ${PWD}/iMOKA_scratch.bash --dir ${PWD}/IDH.${k}.80${s} --source-file ${PWD}/source.IDH.80${s}.tsv -k ${k} --step create
done ; done

```


