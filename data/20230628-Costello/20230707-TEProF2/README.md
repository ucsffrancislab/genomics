
#	20230628-Costello/20230707-TEProF2



```
/francislab/data1/refs/RseQC/README.md 
```

```
base=/francislab/data1/working/20230628-Costello/20230705-STAR/out
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
base=/francislab/data1/working/20230628-Costello/20230705-STAR/out
dir=${base}/strand_check
for f in ${dir}/*.strand_check.txt ; do
awk -F: '($1=="Fraction of reads explained by \"1+-,1-+,2++,2--\""){if($2<0.1){print "--fr"}else if($2>0.9){print "--rf"}else{print "none"}}' ${f}
done | sort | uniq -c

      6 none
    562 --rf

```



This data looks stranded. Pass the strand or depend on the XS tag?

Looks like it is working fine without passing strand.



```

TEProF2_array_wrapper.bash --threads 4 \
  --out ${PWD}/in \
  --extension .Aligned.sortedByCoord.out.bam \
  ${PWD}/../20230705-STAR/out/*.Aligned.sortedByCoord.out.bam

```



```
TEProF2_aggregation_steps.bash --threads 64 \
  --reference_merged_candidates_gtf /francislab/data1/refs/TEProf2/reference_merged_candidates.gtf \
  --in  ${PWD}/in --out ${PWD}/out
```





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


