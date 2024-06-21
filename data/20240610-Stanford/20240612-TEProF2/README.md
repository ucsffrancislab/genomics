
#	20240610-Stanford/20240611-TEProF2



```
/francislab/data1/refs/RseQC/README.md 
```

```
module load WitteLab python3/3.9.1
base=${PWD}/../20240611-STAR_twopass_basic-hg38_v43/out
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
base=${PWD}/../20240611-STAR_twopass_basic-hg38_v43/out
dir=${base}/strand_check
for f in ${dir}/*.strand_check.txt ; do
awk -F: '($1=="Fraction of reads explained by \"1+-,1-+,2++,2--\""){if($2<0.1){print "--fr"}else if($2>0.9){print "--rf"}else{print "none"}}' ${f}
done | sort | uniq -c
```


```
    5 none
```

This data is not stranded. Most are roughly 50/50.






```

TEProF2_array_wrapper.bash --threads 4 \
  --arguments /francislab/data1/refs/TEProf2/rnapipelinerefhg38/TEProF2.arguments.txt \
  --out ${PWD}/in \
  --extension .Aligned.sortedByCoord.out.bam \
  ${PWD}/../20240611-STAR_twopass_basic-hg38_v43/out/*.Aligned.sortedByCoord.out.bam

```



```
TEProF2_aggregation_steps.bash --threads 64 \
  --arguments /francislab/data1/refs/TEProf2/rnapipelinerefhg38/TEProF2.arguments.txt \
  --reference_merged_candidates_gtf /francislab/data1/refs/TEProf2/reference_merged_candidates.gtf \
  --in  ${PWD}/in \
  --out ${PWD}/out
```



allCandidateStatistics.tsv appears to be the "final" data, so the latter steps may not be necessary.



```
head out/allCandidateStatistics.tsv 

File	Transcript_Name	Transcript Expression (TPM)	Fraction of Total Gene Expression	Intron Read Count
SRR3163500	TCONS_00000050	0.0269972980611288	1	0
SRR3163503	TCONS_00000050	0	0	0
SRR3163510	TCONS_00000050	0.276845132896947	1	0
SRR3163511	TCONS_00000050	0	0	0
SRR3163516	TCONS_00000050	4.28646182016811	1	0
SRR3163500	TCONS_00000056	0.758470292685066	0.189844119304379	0
SRR3163503	TCONS_00000056	1.16140601972494	0.230703659270909	0
SRR3163510	TCONS_00000056	1.09776946702687	0.216242970373199	0
SRR3163511	TCONS_00000056	2.65967395243595	0.277697354966442	0

```


It is "found" if ......... I think TPM and Intron Read Count are both > 1. Checking.

allCandidateStatistics.tsv: file with gene expression, fraction expression, transcript expression, and intron junction read information across all the samples for all the candidates.

"to identify whether a candidate was present in a sample (1) the transcript expression was at least 1 TPM and (2) there was at least one read covering the closest unique splice junction to the splice target."

Assuming that (1) is the third column

Assuming that (2) is the last column



```

TEProF2_ACS_Select_and_Pivot.Rscript < out/allCandidateStatistics.tsv > presence.tsv

```



```

awk -F"\t" '(NR==1)||(NR>1 && $2+$3+$4+$5+$6>0)' presence.tsv

awk 'BEGIN{FS="\t";OFS=","}(NR==1){print "Transcript,Stanford"}(NR>1){print $1,$2+$3+$4+$5+$6}' presence.tsv > counts.csv

join --header -t, -a1 -a2 -e0 /francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/S1.sorted.csv counts.csv > tmp

```

Still not sure how to force join to include missing records

```

awk -F, '{print NF}' tmp | sort | uniq -c
   1152 109
  25665 110
    917 2

```

2 means the Stanford only
109 means the reference only
110 means both


```

awk 'BEGIN{FS=OFS=","}(NF==110){print}(NF==2){$110=$2;$2="";print}(NF==109){$110=0;print}' tmp > S1.Stanford.csv

join --header -t, /francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/S2.TranscriptIDs.txt S1.Stanford.csv > S1.Stanford.S2.csv

```







