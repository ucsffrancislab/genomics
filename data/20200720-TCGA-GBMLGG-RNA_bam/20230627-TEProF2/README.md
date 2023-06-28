
#	TEProF2


```
/francislab/data1/refs/RseQC/README.md 
```

```
base=/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200805-STAR_hg38/out
dir=${base}/strand_check
mkdir ${dir}
for bai in ${base}/*Aligned.sortedByCoord.out.bam.bai; do
bam=${bai%%.bai}
echo $bam
f=${dir}/$(basename ${bai} .bam.bai).strand_check.txt
if [ ! -f ${f} ] ; then infer_experiment.py -r /francislab/data1/refs/RseQC/hg38_GENCODE_V42_Basic.bed -i ${bam} > ${f}
fi
done
```

```
base=/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200805-STAR_hg38/out
dir=${base}/strand_check
for f in ${dir}/*.strand_check.txt ; do
awk -F: '($1=="Fraction of reads explained by \"1+-,1-+,2++,2--\""){if($2<0.1){print "--fr"}else if($2>0.9){print "--rf"}else{print "none"}}' ${f}
done | sort | uniq -c
```


This data is not stranded. Most are roughly 50/50.








```

TEProF2_array_wrapper.bash --threads 4 \
  --out /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230627-TEProF2/in \
  --extension .STAR.hg38.Aligned.sortedByCoord.out.bam \
  /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200805-STAR_hg38/out/*.STAR.hg38.Aligned.sortedByCoord.out.bam

```





