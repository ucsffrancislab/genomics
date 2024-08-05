
#	20220804-RaleighLab-RNASeq/20240725-TEProF2_v25


```
/francislab/data1/refs/RseQC/README.md 
```

```
base=/francislab/data1/working/20220804-RaleighLab-RNASeq/20240724-STAR_twopass_basic-hg38_v25/out
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
base=/francislab/data1/working/20220804-RaleighLab-RNASeq/20240724-STAR_twopass_basic-hg38_v25/out
dir=${base}/strand_check
for f in ${dir}/*.strand_check.txt ; do
awk -F: '($1=="Fraction of reads explained by \"1+-,1-+,2++,2--\""){if($2<0.1){print "--fr"}else if($2>0.9){print "--rf"}else{print "none"}}' ${f}
done | sort | uniq -c
```

```
     97 none
    204 --rf
```

Quick check suggests that this data is mostly stranded, but it was aligned with the XS attribute so not passing the strand.









```

TEProF2_array_wrapper.bash --threads 4 \
  --arguments /francislab/data1/refs/TEProf2/rnapipelinerefhg38/TEProF2.arguments.txt \
  --out ${PWD}/in \
  --extension .Aligned.sortedByCoord.out.bam \
  /francislab/data1/working/20220804-RaleighLab-RNASeq/20240724-STAR_twopass_basic-hg38_v25/out/*.Aligned.sortedByCoord.out.bam

```



223 and 151 failed due to memory

```

TEProF2_array_wrapper.bash --array 151,223 --threads 8 \
  --arguments /francislab/data1/refs/TEProf2/rnapipelinerefhg38/TEProF2.arguments.txt \
  --out ${PWD}/in \
  --extension .Aligned.sortedByCoord.out.bam \
  /francislab/data1/working/20220804-RaleighLab-RNASeq/20240724-STAR_twopass_basic-hg38_v25/out/*.Aligned.sortedByCoord.out.bam

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

awk 'BEGIN{FS="\t";OFS=","}(NR==1){print "Transcript,Stanford"}(NR>1){c=0;for(i=2;i<=NF;i++){c+=$i};print $1,c}' presence.tsv > counts.csv
```













##	20240802

```

TEProF2_aggregation_steps.bash --threads 64 \
  --arguments /francislab/data1/refs/TEProf2/rnapipelinerefhg38/TEProF2.arguments.txt \
  --reference_merged_candidates_gtf /francislab/data1/refs/TEProf2/rnapipelinerefhg38/reference_merged_candidates.gtf \
  --in  ${PWD}/in --out ${PWD}/out2

```

+ sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL --job-name=TEProF2_aggregation_steps.bash --time=14-0 --nodes=1 --ntasks=64 --mem=480000M --gres=scratch:1792G --output=/francislab/data1/working/20220804-RaleighLab-RNASeq/20240725-TEProF2_v25/logs/TEProF2_aggregation_steps.bash.20240805081057323917359.out.log /c4/home/gwendt/.local/bin/ucsffrancislab_genomics/TEProF2_aggregation_steps.bash --time 14-0 --arguments /francislab/data1/refs/TEProf2/rnapipelinerefhg38/TEProF2.arguments.txt --in /francislab/data1/working/20220804-RaleighLab-RNASeq/20240725-TEProF2_v25/in --out /francislab/data1/working/20220804-RaleighLab-RNASeq/20240725-TEProF2_v25/out2 --reference_merged_candidates_gtf /francislab/data1/refs/TEProf2/rnapipelinerefhg38/reference_merged_candidates.gtf





I don't get this. Only written to at very end.

[1] "Testing 11 2024-08-02 17:14:51.585071"
chmod: cannot access '/francislab/data1/working/20220804-RaleighLab-RNASeq/20240725-TEProF2_v25/out2/Step11_FINAL.RData': No such file or directory









```
module load r
TEProF2_ACS_Select_and_Pivot.Rscript < out2/allCandidateStatistics.tsv > presence2.tsv

awk 'BEGIN{FS="\t";OFS=","}(NR==1){print "Transcript,Raleigh 301"}(NR>1){c=0;for(i=2;i<=NF;i++){c+=$i};print $1,c}' presence2.tsv > counts2.csv

```





