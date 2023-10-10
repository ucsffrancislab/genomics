
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






##	20230728


```
head -1 out/allCandidateStatistics.tsv | sed 's/\t/,/g' > subjectsStatistics.csv

awk 'BEGIN{FS="\t";OFS=","}(NR==1){c=1;next}{ split($1,a,"-");$1=a[1]"-"a[2];
if(($1==subj)&&($2==tcons)){
c+=1
tpm+=$3
irc+=$5
}else{
if(subj!=""){ print subj,tcons,tpm/c,$4,irc }
c=1
subj=$1
tcons=$2
tpm=$3
irc=$5
}
}END{ print subj,tcons,tpm/c,$4,irc }' out/allCandidateStatistics.tsv >> subjectsStatistics.csv

#}END{ print subj,tcons,tpm/c,$4,irc }' out/allCandidateStatistics.tsv | sort -t, -k1,2 >> subjectsStatistics.csv
```





```
tail -n +2 /francislab/data1/working/20230426-PanCancerAntigens/20230426-explore/select_protein_accessions_IN_S10_S2_ProteinSequences.blastp.e0.05.trimandsort.species.TCONS.csv | cut -d, -f1 | uniq > viral_TCONS.0.05.txt

( head -1 subjectsStatistics.csv | awk 'BEGIN{FS=OFS=","}{print $1,$2}' && \
  tail -n +2 subjectsStatistics.csv \
  | grep -f viral_TCONS.0.05.txt \
  | awk 'BEGIN{FS=OFS=","}{if(($3>=1)&&($5>=1)){print $1,$2}}' \
) > subjectsStatistics.presence.ALL.csv

#) > subjectsStatistics.presence.csv
#join --header -t, subject_study.csv subjectsStatistics.presence.csv > subjectsStatistics.presence.ALL.csv

#for s in GBM LGG ; do
#a=subjectsStatistics.presence.ALL.csv
#( head -1 ${a} && tail -n +2 ${a} | grep ${s} ) > subjectsStatistics.presence.${s}.csv
#done

#for s in ALL GBM LGG ; do
#a=subjectsStatistics.presence.${s}.csv
#( head -1 ${a} | awk -v s=${s} 'BEGIN{FS=OFS=","}{print $3,s}' && tail -n +2 ${a} | cut -d, -f3 | sort | uniq -c | awk 'BEGIN{OFS=","}{print $2,$1}' ) > subjectsStatistics.presence.${s}.counts.csv
#( head -1 ${a} | awk -v s=${s} 'BEGIN{FS=OFS=","}{print $3,s}' && tail -n +2 ${a} | cut -d, -f3 | sort | uniq -c | awk 'BEGIN{OFS=","}{print $2,$1}' ) > subjectsStatistics.presence.${s}.counts.csv
for s in ALL ; do
a=subjectsStatistics.presence.${s}.csv
( head -1 ${a} | awk -v s=${s} 'BEGIN{FS=OFS=","}{print $2,s}' && tail -n +2 ${a} | cut -d, -f2 | sort | uniq -c | awk 'BEGIN{OFS=","}{print $2,$1}' ) > subjectsStatistics.presence.${s}.counts.csv
join --header -t, /francislab/data1/working/20230426-PanCancerAntigens/20230426-explore/select_protein_accessions_IN_S10_S2_ProteinSequences.blastp.e0.05.trimandsort.species.TCONS.csv subjectsStatistics.presence.${s}.counts.csv > subjectsStatistics.presence.${s}.species.counts.csv
done
```



```
BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in subjectsStatistics.presence.???.species.counts.csv ; do
for f in out/allCandidateStatistics.tsv ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done
```


##	20231010


The above used a TCGA subject / sample name parsing which mucked up some data.



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



