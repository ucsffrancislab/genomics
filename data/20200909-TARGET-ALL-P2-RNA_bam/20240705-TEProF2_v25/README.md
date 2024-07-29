
#	20200909-TARGET-ALL-P2-RNA_bam/20240705-TEProF2_v25


```
/francislab/data1/refs/RseQC/README.md 
```

```
base=/francislab/data1/working/20200909-TARGET-ALL-P2-RNA_bam/20240619-STAR_twopass_basic-hg38_v25/out
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
base=/francislab/data1/working/20200909-TARGET-ALL-P2-RNA_bam/20240619-STAR_twopass_basic-hg38_v25/out
dir=${base}/strand_check
for f in ${dir}/*.strand_check.txt ; do
awk -F: '($1=="Fraction of reads explained by \"1+-,1-+,2++,2--\""){if($2<0.1){print "--fr"}else if($2>0.9){print "--rf"}else{print "none"}}' ${f}
done | sort | uniq -c
```

```
      5 --fr
     43 none
    484 --rf
```

Quick check suggests that this data is mostly stranded, but it was aligned with the XS attribute so not passing the strand.









```

TEProF2_array_wrapper.bash --threads 4 \
  --arguments /francislab/data1/refs/TEProf2/rnapipelinerefhg38/TEProF2.arguments.txt \
  --out ${PWD}/in \
  --extension .Aligned.sortedByCoord.out.bam \
  /francislab/data1/working/20200909-TARGET-ALL-P2-RNA_bam/20240619-STAR_twopass_basic-hg38_v25/out/*.Aligned.sortedByCoord.out.bam

```



```

TEProF2_aggregation_steps.bash --threads 64 \
  --arguments /francislab/data1/refs/TEProf2/rnapipelinerefhg38/TEProF2.arguments.txt \
  --reference_merged_candidates_gtf /francislab/data1/refs/TEProf2/reference_merged_candidates.gtf \
  --in  ${PWD}/in --out ${PWD}/out

```










```
module load r
TEProF2_ACS_Select_and_Pivot.Rscript < out/allCandidateStatistics.tsv > presence.tsv
```


```
awk 'BEGIN{FS="\t";OFS=","}(NR==1){print "Transcript,TARGET 532"}(NR>1){c=0;for(i=2;i<=NF;i++){c+=$i};print $1,c}' presence.tsv > counts.csv


```





