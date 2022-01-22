

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
f=$( ls /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out/${s}-01* 2> /dev/null | paste -sd";" )
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
awk -F"\t" '( $2 == "Mutant" )' source.IDH.tsv > source.IDH.Mutant.tsv
awk -F"\t" '( $2 == "WT" )' source.IDH.tsv > source.IDH.WT.tsv
```

```
wc -l source.IDH.*
   123 source.IDH.all.tsv
    73 source.IDH.Mutant.tsv
   122 source.IDH.tsv
    49 source.IDH.WT.tsv
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


```
for k in 11 21 31 ; do
for s in 80a 80b 80c ; do
mkdir -p IDH.${k}.${s}
ln -s ../IDH.${k}/preprocess IDH.${k}.${s}
done ; done
```

































```
date=$( date "+%Y%m%d%H%M%S" )
mkdir ${PWD}/11.IDH
sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL --job-name=11.IDH --time=20160 --nodes=1 --ntasks=64 --mem=499G --gres=scratch:1500G --output=${PWD}/11.IDH/iMOKA_scratch.${date}.txt ${PWD}/iMOKA_scratch.bash --dir ${PWD}/11.IDH --source-file ${PWD}/source.IDH.tsv






./iMOKA_scratch.bash --step create --field IDH --k 31 --subset 80a
./iMOKA_scratch.bash --step create --field IDH --k 31 --subset 80b

./iMOKA_scratch.bash --step create --field IDH --k 21 --subset 80a

./iMOKA_scratch.bash --step create --field IDH --k 11 --subset 80a

```


