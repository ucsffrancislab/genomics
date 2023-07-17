
#	TEProF2


```
/francislab/data1/refs/RseQC/README.md 
```

```
base=/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230628-STAR_hg38_XS/out
dir=${base}/strand_check
mkdir ${dir}
for bai in ${base}/*Aligned.sortedByCoord.out.bam.bai; do
bam=${bai%%.bai}
echo $bam
f=${dir}/$(basename ${bai} .bam.bai).strand_check.txt
if [ ! -f ${f} ] ; then infer_experiment.py -r /francislab/data1/refs/RseQC/hg38_GENCODE_V42_Basic.bed -i ${bam} > ${f} ; fi
done
```

```
base=/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230628-STAR_hg38_XS/out
dir=${base}/strand_check
for f in ${dir}/*.strand_check.txt ; do
awk -F: '($1=="Fraction of reads explained by \"1+-,1-+,2++,2--\""){if($2<0.1){print "--fr"}else if($2>0.9){print "--rf"}else{print "none"}}' ${f}
done | sort | uniq -c
```


This data is not stranded. Most are roughly 50/50.






```

TEProF2_array_wrapper.bash --threads 4 \
  --out /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230629-TEProF2/in \
  --extension .Aligned.sortedByCoord.out.bam \
  /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230628-STAR_hg38_XS/out/*.Aligned.sortedByCoord.out.bam

```



```
TEProF2_aggregation_steps.bash --threads 64 \
  --reference_merged_candidates_gtf /francislab/data1/refs/TEProf2/reference_merged_candidates.gtf \
  --in  /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230629-TEProF2/in \
  --out /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230629-TEProF2/out
```

```
+ rm -f /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230629-TEProF2/out/candidateCommands.complete
+ parallel -j 32
cat: write error: Cannot allocate memory
cat: write error: Cannot allocate memory
cat: write error: Cannot allocate memory
slurmstepd: error: Detected 26362 oom-kill event(s) in StepId=1475792.batch. Some of your processes may have been killed by the cgroup out-of-memory handler.
```


Edit parallel to only run 1/4 of threads

Refined the process by chromosome so grep file is small and uses less memory. Can run max threads now.









Prepping to view final R data
```R
R

load("out/Step13.RData")
colnames(tpmexpressiontable)[1] = "ids"
write.table(tpmexpressiontable,file='tpmexpressiontable.csv',sep=",",row.names=FALSE,quote=FALSE)
```


```
chmod a-w tpmexpressiontable.csv
```






```
BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in tpmexpressiontable* ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done

```


