
#	20200909-TARGET-ALL-P2-RNA_bam/20230710-TEProF2



```
/francislab/data1/refs/RseQC/README.md 
```

```
base=/francislab/data1/raw/20200909-TARGET-ALL-P2-RNA_bam/bam
dir=${base}/strand_check
mkdir ${dir}
for bai in ${base}/*.bam.bai; do
bam=${bai%%.bai}
echo $bam
f=${dir}/$(basename ${bai} .bam.bai).strand_check.txt
if [ ! -f ${f} ] ; then infer_experiment.py -r /francislab/data1/refs/RseQC/hg38_GENCODE_V42_Basic.bed -i ${bam} > ${f} ; fi
done
```

```
base=/francislab/data1/raw/20200909-TARGET-ALL-P2-RNA_bam/bam
dir=${base}/strand_check
for f in ${dir}/*.strand_check.txt ; do
awk -F: '($1=="Fraction of reads explained by \"1+-,1-+,2++,2--\""){if($2<0.1){print "--fr"}else if($2>0.9){print "--rf"}else{print "none"}}' ${f}
done | sort | uniq -c

 
      5 --fr
     51 none
    476 --rf

```



This data is predominantly stranded.





```

TEProF2_array_wrapper.bash --threads 4 \
  --out ${PWD}/in \
  --extension .bam \
  /francislab/data1/raw/20200909-TARGET-ALL-P2-RNA_bam/bam/*bam

```



```
TEProF2_aggregation_steps.bash --threads 64 \
  --reference_merged_candidates_gtf /francislab/data1/refs/TEProf2/reference_merged_candidates.gtf \
  --in  ${PWD}/in --out ${PWD}/out
```



