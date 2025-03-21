
#	TEProF2


/francislab/data1/refs/sources/gencodegenes.org/

/francislab/data1/refs/sources/genome.ucsc.edu/




```

TEProF2_array_wrapper.bash --threads 4 --strand --rf \
  --in /francislab/data1/raw/20220804-RaleighLab-RNASeq/trimmed \
  --out /francislab/data1/working/20220804-RaleighLab-RNASeq/20230512-TEProF2/in \
  --extension .Aligned.sortedByCoord.out.bam

```



```

#TEProF2_TCGA33_guided_aggregation_steps.bash --threads 64 --strand --rf \
#  --in  /francislab/data1/working/20220804-RaleighLab-RNASeq/20230512-TEProF2/in \
#  --out /francislab/data1/working/20220804-RaleighLab-RNASeq/20230512-TEProF2/out

```



Rerunning AGAIN due to my filename parsing change

```

/bin/rm -f ctab_i.txt candidateCommands.txt candidateCommands.complete table_i_all ctablist.txt stringtieExpressionFracCommands.txt stringtieExpressionFracCommands.complete ctab_frac_tot_files.txt ctab_tpm_files.txt table_frac_tot table_tpm table_frac_tot_cand table_tpm_cand "All TE-derived Alternative Isoforms Statistics.csv" allCandidateStatistics.tsv merged_transcripts_all.refBed Step11_FINAL.RData translationPart?.2023*.out.log CPC2.2023*.out.log

```



```

TEProF2_aggregation_steps.bash --threads 64 --strand --rf \
  --reference_merged_candidates_gtf /francislab/data1/refs/TEProf2/reference_merged_candidates.gtf \
  --in  /francislab/data1/working/20220804-RaleighLab-RNASeq/20230512-TEProF2/in \
  --out /francislab/data1/working/20220804-RaleighLab-RNASeq/20230512-TEProF2/out

```







```

BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in out/{Step10.RData,Step11_FINAL.RData,Step12.RData,Step13.RData,candidates_cpcout.fa,candidates_proteinseq.fa} ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done

```






/francislab/data1/working/20230426-PanCancerAntigens/20230426-explore/Human_alphaherpesvirus_3_proteins_IN_S10_S1Brain_ProteinSequences.blastp.e0.05.txt

/francislab/data1/raw/20230426-PanCancerAntigens/S1_BrainTumorTranscriptIDs.txt


```
cat <<EOF > VZV_NP_040188_TranscriptIDs_at_beginning.txt
^TCONS_00011565
^TCONS_00092541
^TCONS_00036289
^TCONS_00000820
^TCONS_00105490
^TCONS_00012449
EOF


```




2- Within each subject- How many transcripts are shared vs unique? i.e. how much homogeneity and heterogeneity is the win in a subject?




```

BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}/TCGA33_guided"
for f in out/{Step10.RData,Step11_FINAL.RData,Step12.RData,Step13.RData,candidates_cpcout.fa,candidates_proteinseq.fa,tpmexpressiontable.csv,tpmexpressiontable.t.csv,tpmexpressiontable.t.GTEx*.csv,tpmexpressiontable.t.GTEx*.all_subjects.csv,tpmexpressiontable.t.GTEx*.subject_count.csv,tpmexpressiontable.t.GTEx*.t.csv,tpmexpressiontable.t.GTEx*.t.transcript_count.csv,tpmexpressiontable.t.NP_040188.csv} ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done

```






----

Try this again
```
\rm -f out/tpmexpressiontable*


sed -e 's/^/\^/' /francislab/data1/raw/20230426-PanCancerAntigens/S1_TranscriptIDs_GTEx0.txt > S1_TranscriptIDs_GTEx0_at_beginning.txt

sed -e 's/^/\^/' /francislab/data1/raw/20230426-PanCancerAntigens/S1_TranscriptIDs_GTEx1.txt > S1_TranscriptIDs_GTEx1_at_beginning.txt

( echo "ids,subfam,locationTE,gene" && ( awk 'BEGIN{FS=OFS=","}(NR>2){print $1,$2,$6,$7}' /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | sort ) ) > ids_subfam_locationTE_gene.csv

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

python3

import pandas as pd

df=pd.read_csv("tpmexpressiontable.csv",index_col='ids')

samples=pd.read_csv("ids_DNA_methylation_group.csv",index_col='ids')

df=pd.concat([df,samples],axis=1).set_index(['methylation_group'], append=True).T

transcripts=pd.read_csv("ids_subfam_locationTE_gene.csv",index_col='ids')

df=pd.concat([df,transcripts],axis=1)
df.index.name='transcriptId'
df.set_index(['subfam','locationTE','gene'],append=True,inplace=True)

df.columns=pd.MultiIndex.from_tuples(df.columns)

df.fillna('', inplace=True)

df=df.reset_index().T.reset_index().T

df.to_csv('tpmexpressiontable.annotated.csv',sep=",",index=False,header=False)

```


I don't care for the output format of multindexed csvs, so reset index and using as basic columns.



```
( head -2 tpmexpressiontable.annotated.csv && grep -f VZV_NP_040188_TranscriptIDs_at_beginning.txt tpmexpressiontable.annotated.csv ) > tpmexpressiontable.annotated.NP_040188.csv



for gtex in GTEx0 GTEx1 ; do

( head -2 tpmexpressiontable.annotated.csv && grep -f S1_TranscriptIDs_${gtex}_at_beginning.txt tpmexpressiontable.annotated.csv ) > tpmexpressiontable.annotated.${gtex}.csv

awk 'BEGIN{FS=OFS=","}(NR<=2){print}(NR>2){z=0;for(i=5;i<=NF;i++){if($i==0){z=1;break}}if(z==0){print}}' tpmexpressiontable.annotated.${gtex}.csv > tpmexpressiontable.annotated.${gtex}.all_subjects.csv

awk 'BEGIN{FS=OFS=","}(NR<=2){print}(NR>2){c=0;for(i=5;i<=NF;i++){if($i>0){c+=1}}if((c/(NF-4))>=0.90){print}}' tpmexpressiontable.annotated.${gtex}.csv > tpmexpressiontable.annotated.${gtex}.0.90_subjects.csv
awk 'BEGIN{FS=OFS=","}(NR<=2){print}(NR>2){c=0;for(i=5;i<=NF;i++){if($i>0){c+=1}}if((c/(NF-4))>=0.95){print}}' tpmexpressiontable.annotated.${gtex}.csv > tpmexpressiontable.annotated.${gtex}.0.95_subjects.csv
awk 'BEGIN{FS=OFS=","}(NR<=2){print}(NR>2){c=0;for(i=5;i<=NF;i++){if($i>0){c+=1}}if((c/(NF-4))>=0.99){print}}' tpmexpressiontable.annotated.${gtex}.csv > tpmexpressiontable.annotated.${gtex}.0.99_subjects.csv
awk 'BEGIN{FS=OFS=","}(NR<=2){print}(NR>2){c=0;for(i=5;i<=NF;i++){if($i>0){c+=1}}if((c/(NF-4))>=1.00){print}}' tpmexpressiontable.annotated.${gtex}.csv > tpmexpressiontable.annotated.${gtex}.1.00_subjects.csv

awk 'BEGIN{FS=OFS=","}(NR==2){print "transcriptId,subfam,locationTE,gene,count,totalcount"}(NR>2){count=0;for(i=5;i<=NF;i++){if($i>0){count+=1}}print $1,$2,$3,$4,count,NF-1}' tpmexpressiontable.annotated.${gtex}.csv > tpmexpressiontable.annotated.${gtex}.subject_count.csv

cat tpmexpressiontable.annotated.${gtex}.csv | datamash transpose -t, > tpmexpressiontable.annotated.${gtex}.t.csv

awk 'BEGIN{FS=OFS=","}(NR==4){print "id,methylation,count,totalcount"}(NR>4){count=0;for(i=3;i<=NF;i++){if($i>0){count+=1}}print $1,$2,count,NF-1}' tpmexpressiontable.annotated.${gtex}.t.csv > tpmexpressiontable.annotated.${gtex}.t.transcript_count.csv

done




for gtex in GTEx0 GTEx1 ; do
for subtype in Immune-enriched Hypermitotic Merlin-intact ; do

cat tpmexpressiontable.annotated.${gtex}.csv | datamash transpose -t, | grep -E "^transcriptId|^subfam|^locationTE|^gene|${subtype}" | datamash transpose -t, > tpmexpressiontable.annotated.${gtex}.${subtype}.csv

awk 'BEGIN{FS=OFS=","}(NR<=2){print}(NR>2){z=0;for(i=5;i<=NF;i++){if($i==0){z=1;break}}if(z==0){print}}' tpmexpressiontable.annotated.${gtex}.${subtype}.csv > tpmexpressiontable.annotated.${gtex}.${subtype}.all_subjects.csv
awk 'BEGIN{FS=OFS=","}(NR<=2){print}(NR>2){c=0;for(i=5;i<=NF;i++){if($i>0){c+=1}}if((c/(NF-4))>=0.90){print}}' tpmexpressiontable.annotated.${gtex}.${subtype}.csv > tpmexpressiontable.annotated.${gtex}.${subtype}.0.90_subjects.csv
awk 'BEGIN{FS=OFS=","}(NR<=2){print}(NR>2){c=0;for(i=5;i<=NF;i++){if($i>0){c+=1}}if((c/(NF-4))>=0.95){print}}' tpmexpressiontable.annotated.${gtex}.${subtype}.csv > tpmexpressiontable.annotated.${gtex}.${subtype}.0.95_subjects.csv
awk 'BEGIN{FS=OFS=","}(NR<=2){print}(NR>2){c=0;for(i=5;i<=NF;i++){if($i>0){c+=1}}if((c/(NF-4))>=0.99){print}}' tpmexpressiontable.annotated.${gtex}.${subtype}.csv > tpmexpressiontable.annotated.${gtex}.${subtype}.0.99_subjects.csv
awk 'BEGIN{FS=OFS=","}(NR<=2){print}(NR>2){c=0;for(i=5;i<=NF;i++){if($i>0){c+=1}}if((c/(NF-4))>=1.00){print}}' tpmexpressiontable.annotated.${gtex}.${subtype}.csv > tpmexpressiontable.annotated.${gtex}.${subtype}.1.00_subjects.csv

awk 'BEGIN{FS=OFS=","}(NR==2){print "transcriptId,subfam,locationTE,gene,count,totalcount"}(NR>2){count=0;for(i=5;i<=NF;i++){if($i>0){count+=1}}print $1,$2,$3,$4,count,NF-1}' tpmexpressiontable.annotated.${gtex}.${subtype}.csv > tpmexpressiontable.annotated.${gtex}.${subtype}.subject_count.csv

cat tpmexpressiontable.annotated.${gtex}.${subtype}.csv | datamash transpose -t, > tpmexpressiontable.annotated.${gtex}.${subtype}.t.csv

awk 'BEGIN{FS=OFS=","}(NR==4){print "id,methylation,count,totalcount"}(NR>4){count=0;for(i=3;i<=NF;i++){if($i>0){count+=1}}print $1,$2,count,NF-1}' tpmexpressiontable.annotated.${gtex}.${subtype}.t.csv > tpmexpressiontable.annotated.${gtex}.${subtype}.t.transcript_count.csv

done
done


chmod a-w tpmexpressiontable*.csv

```



```
BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}/TCGA33_guided"

for f in tpmexpressiontable* ; do

for f in tpmexpressiontable*{Immune-enriched,Hypermitotic,Merlin-intact}* ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done

```






##	20230711


Create a translation table to convert TCONS to Viral

```
awk 'BEGIN{FS=OFS=","}(NR>1){print $(NF-1),$NF}' /francislab/data1/working/20230426-PanCancerAntigens/20230426-explore/select_protein_accessions_IN_S10_All_ProteinSequences.blastp.e0.005.trimandsort.species.csv | sort | uniq > TCONS_species.e0.005.csv

head -2 tpmexpressiontable.annotated.csv > tpmexpressiontable.annotated.sorted.csv
tail -n +3 tpmexpressiontable.annotated.csv | sort >> tpmexpressiontable.annotated.sorted.csv

for subtype in Immune-enriched Hypermitotic Merlin-intact ; do
echo $subtype
cat tpmexpressiontable.annotated.sorted.csv | datamash transpose -t, | grep -E "^transcriptId|^subfam|^locationTE|^gene|${subtype}" | datamash transpose -t, > tpmexpressiontable.annotated.${subtype}.csv
done


for subtype in .sorted .Immune-enriched .Hypermitotic .Merlin-intact ; do
echo $subtype
join -t, TCONS_species.e0.005.csv \
  <( tail -n +3 tpmexpressiontable.annotated${subtype}.csv ) \
  > tpmexpressiontable.annotated${subtype}.species.csv
awk 'BEGIN{FS=OFS=","}{s=0;for(i=6;i<=NF;i++){if($i>0.01)s++};print $2,s}' \
  tpmexpressiontable.annotated${subtype}.species.csv \
  | sort > tpmexpressiontable.annotated${subtype}.species.sums.csv
awk 'BEGIN{FS=OFS=","}{s[$1]+=$2}END{for(k in s){print k,s[k]}}' \
  tpmexpressiontable.annotated${subtype}.species.sums.csv \
  | sort > tpmexpressiontable.annotated${subtype}.species.sums.sums.csv
done

```


```
BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}/TCGA33_guided"

for f in tpmexpressiontable*species.csv tpmexpressiontable*species.sums.sums.csv ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done

```



##	20230712


```
for subtype in .sorted .Immune-enriched .Hypermitotic .Merlin-intact ; do
echo $subtype
awk 'BEGIN{FS=OFS=","}{ for(i=6;i<=NF;i++){s[$2][i]+=$i}}END{for(k in s){t=k;for(i=6;i<=NF;i++){t=t","s[k][i]};print t}}' tpmexpressiontable.annotated${subtype}.species.csv | sort | awk 'BEGIN{FS=OFS=","}{s=0;for(i=2;i<=NF;i++){if($i>0.01)s++};print $1,s}' > tpmexpressiontable.annotated${subtype}.species.agg.csv
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
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done
```




