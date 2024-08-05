
#	20240610-Stanford/20240717-TEProF2-hg38_v25


```
TEProF2_array_wrapper.bash --threads 8   --arguments /francislab/data1/refs/TEProf2/rnapipelinerefhg38/TEProF2.arguments.txt   --out /wittelab/data5/lkachuri/myeloma/4-TEProF2_v25_Clint/   --extension Aligned.sortedByCoord.out.bam  /wittelab/data5/lkachuri/myeloma/3-STAR_v25_Clint/*Aligned.sortedByCoord.out.bam
```

```
TEProF2_aggregation_steps.bash --threads 32   --arguments /francislab/data1/refs/TEProf2/rnapipelinerefhg38/TEProF2.arguments.txt   --reference_merged_candidates_gtf /francislab/data1/refs/TEProf2/reference_merged_candidates.gtf   --in /wittelab/data5/lkachuri/myeloma/4-TEProF2_v25_Clint/ --out /wittelab/data5/lkachuri/myeloma/5-TEProF2_v25_Clint/
```




```
module load r
TEProF2_ACS_Select_and_Pivot.Rscript < out/allCandidateStatistics.tsv > presence.tsv
```


```
awk 'BEGIN{FS="\t";OFS=","}(NR==1){print "Transcript,Stanford"}(NR>1){c=0;for(i=2;i<=NF;i++){c+=$i};print $1,c}' presence.tsv > counts.csv


join --header -t, -a1 -a2 -e0 /francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/S1.sorted.csv counts.csv > tmp
```



```
awk -F, '{print NF}' tmp | sort | uniq -c
   1152 109
  25665 110
    917 2
```

2 means the Stanford only
109 means the reference only
110 means both

(same counts as 5 samples test)







```
awk 'BEGIN{FS=OFS=","}(NF==110){print}(NF==2){$110=$2;$2="";print}(NF==109){$110=0;print}' tmp > S1.Stanford.csv

join --header -t, /francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/S2.TranscriptIDs.txt S1.Stanford.csv > S1.Stanford.S2.csv
```








##	20240802

```
TEProF2_aggregation_steps.bash --threads 64 \
  --arguments /francislab/data1/refs/TEProf2/rnapipelinerefhg38/TEProF2.arguments.txt \
  --reference_merged_candidates_gtf /francislab/data1/refs/TEProf2/rnapipelinerefhg38/reference_merged_candidates.gtf \
  --in  ${PWD}/in --out ${PWD}/out2
```




```
module load r
TEProF2_ACS_Select_and_Pivot.Rscript < out2/allCandidateStatistics.tsv > presence2.tsv

awk 'BEGIN{FS="\t";OFS=","}(NR==1){print "Transcript,Stanford 42"}(NR>1){c=0;for(i=2;i<=NF;i++){c+=$i};print $1,c}' presence2.tsv > counts2.csv

```





