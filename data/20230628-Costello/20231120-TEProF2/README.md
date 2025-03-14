
#	20230628-Costello/20231120-TEProF2


```
/francislab/data1/refs/RseQC/README.md 
```

```
ssh d3

base=/francislab/data1/working/20230628-Costello/20231016-STAR_two_pass/out
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
base=/francislab/data1/working/20230628-Costello/20231016-STAR_two_pass/out
dir=${base}/strand_check
for f in ${dir}/*.strand_check.txt ; do
awk -F: '($1=="Fraction of reads explained by \"1+-,1-+,2++,2--\""){if($2<0.1){print "--fr"}else if($2>0.9){print "--rf"}else{print "none"}}' ${f}
done | sort | uniq -c

     17 none
    551 --rf

```


Quick check suggests that this data is all stranded, but it was aligned with the XS attribute so not passing the strand.






One last try with the provided ARGUMENTS as opposed to mine.



```

TEProF2_array_wrapper.bash --threads 4 \
  --arguments /francislab/data1/refs/TEProf2/rnapipelinerefhg38/TEProF2.arguments.txt \
  --out ${PWD}/in \
  --extension .Aligned.sortedByCoord.out.bam \
  ${PWD}/../20231016-STAR_two_pass/out/*.Aligned.sortedByCoord.out.bam

```


```
TEProF2_aggregation_steps.bash --threads 64 \
  --arguments /francislab/data1/refs/TEProf2/rnapipelinerefhg38/TEProF2.arguments.txt \
  --reference_merged_candidates_gtf /francislab/data1/refs/TEProf2/reference_merged_candidates.gtf \
  --in  ${PWD}/in --out ${PWD}/out
```




```
tail -n +2 /francislab/data1/working/20230426-PanCancerAntigens/20230426-explore/select_protein_accessions_IN_S10_S2_ProteinSequences.blastp.e0.05.trimandsort.species.TCONS.csv | cut -d, -f1 | uniq > viral_TCONS.0.05.txt
```



```
sed 's/\t/,/g' out/allCandidateStatistics.tsv > allCandidateStatistics.csv

( head -1 allCandidateStatistics.csv | awk 'BEGIN{FS=OFS=","}{print $1,$2}' && \
  tail -n +2 allCandidateStatistics.csv \
  | grep -f viral_TCONS.0.05.txt \
  | awk 'BEGIN{FS=OFS=","}{if(($3>=1)&&($5>=1)){print $1,$2}}' \
) > allCandidateStatistics.presence.ALL.csv

for s in ALL ; do
a=allCandidateStatistics.presence.${s}.csv
( head -1 ${a} | awk -v s=${s} 'BEGIN{FS=OFS=","}{print $2,s}' && tail -n +2 ${a} | cut -d, -f2 | sort | uniq -c | awk 'BEGIN{OFS=","}{print $2,$1}' ) > allCandidateStatistics.presence.${s}.counts.csv
join --header -t, /francislab/data1/working/20230426-PanCancerAntigens/20230426-explore/select_protein_accessions_IN_S10_S2_ProteinSequences.blastp.e0.05.trimandsort.species.TCONS.csv allCandidateStatistics.presence.${s}.counts.csv > allCandidateStatistics.presence.${s}.species.counts.csv
done

box_upload.bash allCandidateStatistics*.csv
```





```
tail -n +2 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S2.csv | head -1 | awk -F, '{print $1}' > S2_TranscriptID.txt
tail -n +3 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S2.csv | awk -F, '{print $1}' | sort >> S2_TranscriptID.txt



```





```

python3 ./merge.py --int --output merged.all_studies.csv /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230629-TEProF2/sampleTypeStatistics.subject.study.GBM.counts.csv /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230629-TEProF2/sampleTypeStatistics.subject.study.LGG.counts.csv /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230629-TEProF2/sampleTypeStatistics.shared.subject.study.GBM.counts.csv /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230629-TEProF2/sampleTypeStatistics.shared.subject.study.LGG.counts.csv /francislab/data1/working/20200909-TARGET-ALL-P2-RNA_bam/20230710-TEProF2/subjectsStatistics.presence.ALL.counts.csv /francislab/data1/working/20220804-RaleighLab-RNASeq/20230512-TEProF2/subjectsStatistics.presence.ALL.counts.csv /francislab/data1/working/20230628-Costello/20230707-TEProF2/allCandidateStatistics.presence.ALL.counts.csv /francislab/data1/working/20230628-Costello/20231120-TEProF2/allCandidateStatistics.presence.ALL.counts.csv


join --header -t, S2_TranscriptID.txt merged.all_studies.csv > merged.all_studies.S2.csv

```
