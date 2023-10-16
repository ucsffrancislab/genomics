
#	20230628-Costello/20231006-TEProF2


```
/francislab/data1/refs/RseQC/README.md 
```

```
base=/francislab/data1/working/20230628-Costello/20231005-STAR/out
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
base=/francislab/data1/working/20230628-Costello/20231005-STAR/out
dir=${base}/strand_check
for f in ${dir}/*.strand_check.txt ; do
awk -F: '($1=="Fraction of reads explained by \"1+-,1-+,2++,2--\""){if($2<0.1){print "--fr"}else if($2>0.9){print "--rf"}else{print "none"}}' ${f}
done | sort | uniq -c


      9 none
    559 --rf

```


Quick check suggests that this data is all stranded, but it was aligned with the XS attribute so not passing the strand.


```

TEProF2_array_wrapper.bash --threads 4 \
  --out ${PWD}/in \
  --extension .Aligned.sortedByCoord.out.bam \
  ${PWD}/../20231005-STAR/out/*.Aligned.sortedByCoord.out.bam

```


```
TEProF2_aggregation_steps.bash --threads 64 \
  --reference_merged_candidates_gtf /francislab/data1/refs/TEProf2/reference_merged_candidates.gtf \
  --in  ${PWD}/in --out ${PWD}/out
```









##	20231016



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



