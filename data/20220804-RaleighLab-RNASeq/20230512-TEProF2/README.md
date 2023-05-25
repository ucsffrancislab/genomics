
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





Prepping to view final R data
```
R

load("out/Step13.RData")
row.names(tpmexpressiontable)=tpmexpressiontable[['TranscriptID']]
df = subset(tpmexpressiontable, select = -c(TranscriptID) )
write.csv(df,file='out/tpmexpressiontable.csv', quote=FALSE)
write.csv(t(df),file='out/tpmexpressiontable.t.csv', quote=FALSE)

```


```
chmod -w out/tpmexpressiontable*

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

( head -1 out/tpmexpressiontable.t.csv && grep -f VZV_NP_040188_TranscriptIDs_at_beginning.txt out/tpmexpressiontable.t.csv ) > out/tpmexpressiontable.t.NP_040188.csv



sed -e 's/^/\^/' /francislab/data1/raw/20230426-PanCancerAntigens/S1_TranscriptIDs_GTEx0.txt > S1_TranscriptIDs_GTEx0_at_beginning.txt

( head -1 out/tpmexpressiontable.t.csv && grep -f S1_TranscriptIDs_GTEx0_at_beginning.txt out/tpmexpressiontable.t.csv ) > out/tpmexpressiontable.t.GTEx0.csv

awk 'BEGIN{FS=OFS=","}(NR==1){print}(NR>1){z=0;for(i=2;i<=NF;i++){if($i==0){z=1;break}}if(z==0){print}}' out/tpmexpressiontable.t.GTEx0.csv > out/tpmexpressiontable.t.GTEx0.all_subjects.csv

awk 'BEGIN{FS=OFS=","}(NR==1){print $1,"count","totalcount"}(NR>1){count=0;for(i=2;i<=NF;i++){if($i>0){count+=1}}print $1,count,NF-1}' out/tpmexpressiontable.t.GTEx0.csv > out/tpmexpressiontable.t.GTEx0.subject_count.csv


cat out/tpmexpressiontable.t.GTEx0.csv | datamash transpose -t, > out/tpmexpressiontable.t.GTEx0.t.csv

awk 'BEGIN{FS=OFS=","}(NR==1){print $1,"count","totalcount"}(NR>1){count=0;for(i=2;i<=NF;i++){if($i>0){count+=1}}print $1,count,NF-1}' out/tpmexpressiontable.t.GTEx0.t.csv > out/tpmexpressiontable.t.GTEx0.t.transcript_count.csv



sed -e 's/^/\^/' /francislab/data1/raw/20230426-PanCancerAntigens/S1_TranscriptIDs_GTEx1.txt > S1_TranscriptIDs_GTEx1_at_beginning.txt

( head -1 out/tpmexpressiontable.t.csv && grep -f S1_TranscriptIDs_GTEx1_at_beginning.txt out/tpmexpressiontable.t.csv ) > out/tpmexpressiontable.t.GTEx1.csv

awk 'BEGIN{FS=OFS=","}(NR==1){print}(NR>1){z=0;for(i=2;i<=NF;i++){if($i==0){z=1;break}}if(z==0){print}}' out/tpmexpressiontable.t.GTEx1.csv > out/tpmexpressiontable.t.GTEx1.all_subjects.csv

awk 'BEGIN{FS=OFS=","}(NR==1){print $1,"count","totalcount"}(NR>1){count=0;for(i=2;i<=NF;i++){if($i>0){count+=1}}print $1,count,NF-1}' out/tpmexpressiontable.t.GTEx1.csv > out/tpmexpressiontable.t.GTEx1.subject_count.csv


cat out/tpmexpressiontable.t.GTEx1.csv | datamash transpose -t, > out/tpmexpressiontable.t.GTEx1.t.csv

awk 'BEGIN{FS=OFS=","}(NR==1){print $1,"count","totalcount"}(NR>1){count=0;for(i=2;i<=NF;i++){if($i>0){count+=1}}print $1,count,NF-1}' out/tpmexpressiontable.t.GTEx1.t.csv > out/tpmexpressiontable.t.GTEx1.t.transcript_count.csv


```





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


```
BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}/TCGA33_guided"

for f in out/{tpmexpressiontable.t.GTEx*.csv,tpmexpressiontable.t.GTEx*.all_subjects.csv,tpmexpressiontable.t.GTEx*.subject_count.csv,tpmexpressiontable.t.GTEx*.t.csv,tpmexpressiontable.t.GTEx*.t.transcript_count.csv,tpmexpressiontable.t.NP_040188.csv} ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done

```

