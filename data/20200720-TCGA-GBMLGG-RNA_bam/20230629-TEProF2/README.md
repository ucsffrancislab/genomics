
#	TEProF2


```
/francislab/data1/refs/RseQC/README.md 
```

```
base=/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230628-STAR_hg38_XS/out
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
base=/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230628-STAR_hg38_XS/out
dir=${base}/strand_check
for f in ${dir}/*.strand_check.txt ; do
awk -F: '($1=="Fraction of reads explained by \"1+-,1-+,2++,2--\""){if($2<0.1){print "--fr"}else if($2>0.9){print "--rf"}else{print "none"}}' ${f}
done | sort | uniq -c
```


This data is not stranded. Most are roughly 50/50.






```

TEProF2_array_wrapper.bash --threads 4 \
  --out /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230629-TEProF2/in \
  --extension .Aligned.sortedByCoord.out.bam \
  /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230628-STAR_hg38_XS/out/*.Aligned.sortedByCoord.out.bam

```



```
TEProF2_aggregation_steps.bash --threads 64 \
  --reference_merged_candidates_gtf /francislab/data1/refs/TEProf2/reference_merged_candidates.gtf \
  --in  /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230629-TEProF2/in \
  --out /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230629-TEProF2/out
```

```
+ rm -f /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230629-TEProF2/out/candidateCommands.complete
+ parallel -j 32
cat: write error: Cannot allocate memory
cat: write error: Cannot allocate memory
cat: write error: Cannot allocate memory
slurmstepd: error: Detected 26362 oom-kill event(s) in StepId=1475792.batch. Some of your processes may have been killed by the cgroup out-of-memory handler.
```


Edit parallel to only run 1/4 of threads

Refined the process by chromosome so grep file is small and uses less memory. Can run max threads now.









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





##	20230724


Annotate with LGG or GBM


```
cut -f1,2 /francislab/data1/refs/TCGA/TCGA.Glioma.metadata.tsv | sed -e 's/TCGA-//g' -e 's/\t/,/g' > subject_study.csv

head -2 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | tail -n 1 | awk 'BEGIN{FS=OFS=","}{print $1,$26,$38}' | tr -d "\r" > S1.csv
tail -n +3 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | sort -t, -k1,1 | awk 'BEGIN{FS=OFS=","}{print $1,$26,$38}' | tr -d "\r" >> S1.csv

awk 'BEGIN{FS=OFS=","}(NR==1){print;next}($1~/^..-....-01/){split($1,a,"-");$1=a[1]"-"a[2];print}' tpmexpressiontable.csv > tpmexpressiontable.subject.csv

join -t, --header subject_study.csv tpmexpressiontable.subject.csv > tpmexpressiontable.subject.study.ALL.csv

head -1 tpmexpressiontable.subject.study.ALL.csv > tpmexpressiontable.subject.study.GBM.csv
head -1 tpmexpressiontable.subject.study.ALL.csv > tpmexpressiontable.subject.study.LGG.csv

awk -F, '($2=="GBM")' tpmexpressiontable.subject.study.ALL.csv >> tpmexpressiontable.subject.study.GBM.csv
awk -F, '($2=="LGG")' tpmexpressiontable.subject.study.ALL.csv >> tpmexpressiontable.subject.study.LGG.csv


for s in ALL GBM LGG ; do
f=tpmexpressiontable.subject.study.${s}.csv
echo $f
cat ${f} | datamash transpose -t, | awk -v s=${s} 'BEGIN{FS=OFS=","}(NR==1){print "TCONS",s;next}(NR>2){ for(i=2;i<=NF;i++){if($i>10)a[$1]++};print $1,a[$1] }' > ${f%.csv}.agg.csv
done



join --header -t, S1.csv tpmexpressiontable.subject.study.ALL.agg.csv > tmp
join --header -t, tmp tpmexpressiontable.subject.study.GBM.agg.csv > tmp2
join --header -t, tmp2 tpmexpressiontable.subject.study.LGG.agg.csv > tpmexpressiontable.subject.study.joined.csv
\rm tmp tmp2

```




```
BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in tpmexpressiontable.subject.study.joined.csv ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done
```




Create a translation table to convert TCONS to Viral


```
awk 'BEGIN{FS=OFS=","}(NR>1){print $(NF-1),$NF}' /francislab/data1/working/20230426-PanCancerAntigens/20230426-explore/select_protein_accessions_IN_S10_All_ProteinSequences.blastp.e0.005.trimandsort.species.csv | sort | uniq > TCONS_species.e0.005.csv

cat tpmexpressiontable.csv | datamash transpose -t, | head -1 > tpmexpressiontable.sorted.csv
cat tpmexpressiontable.csv | datamash transpose -t, | tail -n +2 >> tpmexpressiontable.sorted.csv

join -t, TCONS_species.e0.005.csv \
  <( tail -n +2 tpmexpressiontable.sorted.csv ) \
  > tpmexpressiontable.sorted.species.csv
```

```
head tpmexpressiontable.sorted.species.csv | cut -c1-100
TCONS_00000820,Human alphaherpesvirus 1,0,0,0,0,0,0,0.000531905731863191,0.000813138243711905,0,0,0,
TCONS_00000820,Human alphaherpesvirus 2,0,0,0,0,0,0,0.000531905731863191,0.000813138243711905,0,0,0,
TCONS_00000820,Human alphaherpesvirus 3,0,0,0,0,0,0,0.000531905731863191,0.000813138243711905,0,0,0,
TCONS_00002594,Human gammaherpesvirus 4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
TCONS_00002595,Human gammaherpesvirus 4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
TCONS_00003184,Human alphaherpesvirus 1,0.704724144973338,0.936696584022382,0,2.00585812436771,0,0,0
TCONS_00003184,Human alphaherpesvirus 2,0.704724144973338,0.936696584022382,0,2.00585812436771,0,0,0
TCONS_00004313,Human gammaherpesvirus 8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
TCONS_00004428,Variola virus,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
TCONS_00004429,Variola virus,0.129904493580813,0.188582338908091,0,0,0,0,0,0,0,0,0,0,0.1147977428202

```

```

awk 'BEGIN{FS=OFS=","}{ for(i=3;i<=NF;i++){s[$2][i]+=$i}}END{for(k in s){t=k;for(i=3;i<=NF;i++){t=t","s[k][i]};print t}}' tpmexpressiontable.sorted.species.csv | sort | awk 'BEGIN{FS=OFS=","}{s=0;for(i=2;i<=NF;i++){if($i>0.01)s++};print $1,s}' > tpmexpressiontable.sorted.species.agg.csv
```

```
BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in tpmexpressiontable.sorted.species.agg.csv; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done
```








##	20230725


They used `allCandidateStatistics.tsv` to call a subject for counting, not the RData.

Here, we have multiple samples for a single subject so I'm going to merge.
Average TPM and sum Intron Count.

```
head out/allCandidateStatistics.tsv 
File	Transcript_Name	Transcript Expression (TPM)	Fraction of Total Gene Expression	Intron Read Count
02-0047-01A-01R-1849-01+1	TCONS_00000050	0.584999815701071	1	0
02-0047-01A-01R-1849-01+2	TCONS_00000050	0.787714079719568	1	0
02-0055-01A-01R-1849-01+1	TCONS_00000050	6.14088165270914	0.846313476598139	0
02-0055-01A-01R-1849-01+2	TCONS_00000050	8.53331347943616	0.867583298061072	0
02-2483-01A-01R-1849-01+1	TCONS_00000050	0.647165119772972	0.0509629814790806	0
02-2483-01A-01R-1849-01+2	TCONS_00000050	0.467683735232652	0.0527361940518989	0
02-2485-01A-01R-1849-01+1	TCONS_00000050	0.0190372772404058	0.00752552517310175	0
02-2485-01A-01R-1849-01+2	TCONS_00000050	0.0290970189897434	0.00832843044112294	0
02-2486-01A-01R-1849-01+1	TCONS_00000050	0	0	0
```


Covert this sample tsv to a subject csv.

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
}END{ print subj,tcons,tpm/c,$4,irc }' out/allCandidateStatistics.tsv | sort -t, -k1,2 >> subjectsStatistics.csv



join -t, --header subject_study.csv subjectsStatistics.csv > subjectsStatistics.study.csv

head -1 subjectsStatistics.study.csv > subjectsStatistics.study.ALL.csv
tail -n +2 subjectsStatistics.study.csv | sort -t, -k3,3 -k1,1 >> subjectsStatistics.study.ALL.csv

head -1 subjectsStatistics.study.ALL.csv > subjectsStatistics.study.GBM.csv
head -1 subjectsStatistics.study.ALL.csv > subjectsStatistics.study.LGG.csv

awk -F, '($2=="GBM")' subjectsStatistics.study.ALL.csv >> subjectsStatistics.study.GBM.csv
awk -F, '($2=="LGG")' subjectsStatistics.study.ALL.csv >> subjectsStatistics.study.LGG.csv



for s in ALL GBM LGG ; do
echo $s
awk -v s=${s} 'BEGIN{FS=OFS=","}(NR==1){print "Transcript_Name",s;next}{
if($3==tcons){
if(($4>=1)&&($6>=1)){c++}
}else{
if(tcons!=""){print tcons,c};c=0;tcons=$3
}
}END{print tcons,c}' subjectsStatistics.study.${s}.csv > subjectsStatistics.study.${s}.agg.csv
done

join --header -t, S1.csv subjectsStatistics.study.ALL.agg.csv > tmp
join --header -t, tmp subjectsStatistics.study.GBM.agg.csv > tmp2
join --header -t, tmp2 subjectsStatistics.study.LGG.agg.csv > subjectsStatistics.study.agg.joined.csv
\rm tmp tmp2
```


```
BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in subjectsStatistics.study.agg.joined.csv ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done
```




##	20230726


Create matrix of 


```
head subjectsStatistics.csv
File,Transcript_Name,Transcript Expression (TPM),Fraction of Total Gene Expression,Intron Read Count
02-0047,TCONS_00000050,0.686357,0.846313476598139,0
02-0047,TCONS_00000056,0,0.123963095389445,0
02-0047,TCONS_00000058,0,0.00483105643202961,0
02-0047,TCONS_00000059,0,0,0
02-0047,TCONS_00000073,0.0295707,1,0
02-0047,TCONS_00000078,0.788036,0.253018003310857,4
02-0047,TCONS_00000080,0.661171,0.546399368004186,4
02-0047,TCONS_00000090,0,0,0
02-0047,TCONS_00000091,0,0,0


head /francislab/data1/working/20230426-PanCancerAntigens/20230426-explore/select_protein_accessions_IN_S10_S2_ProteinSequences.blastp.e0.005.trimandsort.species.TCONS.csv
Transcript ID,Species
TCONS_00000820,Human alphaherpesvirus 1
TCONS_00000820,Human alphaherpesvirus 2
TCONS_00000820,Human alphaherpesvirus 3
TCONS_00002594,Human gammaherpesvirus 4
TCONS_00002595,Human gammaherpesvirus 4
TCONS_00003184,Human alphaherpesvirus 1
TCONS_00003184,Human alphaherpesvirus 2
TCONS_00004313,Human gammaherpesvirus 8
TCONS_00004428,Variola virus
```

```
tail -n +2 /francislab/data1/working/20230426-PanCancerAntigens/20230426-explore/select_protein_accessions_IN_S10_S2_ProteinSequences.blastp.e0.05.trimandsort.species.TCONS.csv | cut -d, -f1 | uniq > viral_TCONS.0.05.txt
```


```
( head -1 subjectsStatistics.csv && tail -n +2 subjectsStatistics.csv | grep -f viral_TCONS.0.05.txt ) | head
File,Transcript_Name,Transcript Expression (TPM),Fraction of Total Gene Expression,Intron Read Count
02-0047,TCONS_00000463,0,0,0
02-0047,TCONS_00000820,0,0,0
02-0047,TCONS_00001232,0,0.0922518735873746,0
02-0047,TCONS_00001235,0.0301408,0,0
02-0047,TCONS_00001290,0.0118123,0,0
02-0047,TCONS_00002594,0,0,0
02-0047,TCONS_00002595,0,0,0
02-0047,TCONS_00003184,0.82071,0,0
02-0047,TCONS_00004143,0,0.521057050988852,0
```




```
( head -1 subjectsStatistics.csv | awk 'BEGIN{FS=OFS=","}{print $2,$1}' && \
  tail -n +2 subjectsStatistics.csv \
  | grep -f viral_TCONS.0.05.txt \
  | awk 'BEGIN{FS=OFS=","}{if(($3>=1)&&($5>=1)){print $2,$1}}' \
  | sort -t, -k1,2 \
) > subjectsStatistics.presence.csv

cat subjectsStatistics.presence.csv | cut -d, -f1 | uniq -c | awk 'BEGIN{OFS=","}{print $2,$1}' > subjectsStatistics.presence.counts.csv


join --header -t, /francislab/data1/working/20230426-PanCancerAntigens/20230426-explore/select_protein_accessions_IN_S10_S2_ProteinSequences.blastp.e0.05.trimandsort.species.TCONS.csv subjectsStatistics.presence.counts.csv > subjectsStatistics.presence.species.counts.csv

```



```
BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in subjectsStatistics.presence.species.counts.csv ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done
```



##	20230727



```
cut -f1,2 /francislab/data1/refs/TCGA/TCGA.Glioma.metadata.tsv | sed -e 's/TCGA-//g' -e 's/\t/,/g' > subject_study.csv

tail -n +2 /francislab/data1/working/20230426-PanCancerAntigens/20230426-explore/select_protein_accessions_IN_S10_S2_ProteinSequences.blastp.e0.05.trimandsort.species.TCONS.csv | cut -d, -f1 | uniq > viral_TCONS.0.05.txt

( head -1 subjectsStatistics.csv | awk 'BEGIN{FS=OFS=","}{print $1,$2}' && \
  tail -n +2 subjectsStatistics.csv \
  | grep -f viral_TCONS.0.05.txt \
  | awk 'BEGIN{FS=OFS=","}{if(($3>=1)&&($5>=1)){print $1,$2}}' \
) > subjectsStatistics.presence.csv

join --header -t, subject_study.csv subjectsStatistics.presence.csv > subjectsStatistics.presence.ALL.csv

for s in GBM LGG ; do
a=subjectsStatistics.presence.ALL.csv
( head -1 ${a} && tail -n +2 ${a} | grep ${s} ) > subjectsStatistics.presence.${s}.csv
done

for s in ALL GBM LGG ; do
a=subjectsStatistics.presence.${s}.csv
( head -1 ${a} | awk -v s=${s} 'BEGIN{FS=OFS=","}{print $3,s}' && tail -n +2 ${a} | cut -d, -f3 | sort | uniq -c | awk 'BEGIN{OFS=","}{print $2,$1}' ) > subjectsStatistics.presence.${s}.counts.csv
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





##	20230828

```
tail -n +2 out/allCandidateStatistics.tsv | cut -f2 | uniq | sort | uniq > our_transcripts



tail -n +2 /francislab/data1/refs/TEProf2/Expression\ of\ Transcripts\ Across\ TCGA\ Samples-\ 2297.csv | cut -d, -f2 | tr -d \" | uniq | sort | uniq > their_transcripts


join our_transcripts their_transcripts > shared_transcripts1
comm -12 our_transcripts their_transcripts > shared_transcripts2
diff shared_transcripts?

wc -l *_transcript*
 26581 our_transcripts
  2297 their_transcripts
  2215 shared_transcripts1
  2215 shared_transcripts2

```


Covert this sample tsv to a subject sample type csv.


```
#head -1 out/allCandidateStatistics.tsv | sed 's/\t/,/g' > sampleTypeStatistics.csv
#echo "File,Transcript_Name,Transcript Expression (TPM),Intron Read Count,Present" > sampleTypeStatistics.csv
echo "File,Transcript Name,our TPM,our Intron Read Count,our Present" > sampleTypeStatistics.csv

awk 'BEGIN{FS="\t";OFS=","}(NR==1){c=1;next}{ 
split($1,a,"-");$1=a[1]"-"a[2]"-"substr(a[3],1,2);
if(($1==subj)&&($2==tcons)){
 c+=1; tpm+=$3; irc+=$5;
}else{
 if(subj!=""){ 
  #print subj,tcons,tpm/c,$4,irc 
  ( ( (tpm/c)>=1 ) && ( irc>=1 ) ) ? p=1 : p=0
  print subj,tcons,tpm/c,irc,p
 }
 c=1; subj=$1; tcons=$2; tpm=$3; irc=$5;
}
}END{ 
 #print subj,tcons,tpm/c,$4,irc 
 ( ( (tpm/c)>=1 ) && ( irc>=1 ) ) ? p=1 : p=0
 print subj,tcons,tpm/c,irc,p
}' out/allCandidateStatistics.tsv | sort -t, -k1,2 >> sampleTypeStatistics.csv

```



```
sed 's/,/:/' sampleTypeStatistics.csv > sampleTypeStatistics.tojoin.csv

wc -l sampleTypeStatistics.tojoin.csv /francislab/data1/refs/TEProf2/TCGA_Expression.select.translated.tojoin.csv
  19138321 sampleTypeStatistics.tojoin.csv
  25464543 /francislab/data1/refs/TEProf2/TCGA_Expression.select.translated.tojoin.csv

join --header -t, sampleTypeStatistics.tojoin.csv /francislab/data1/refs/TEProf2/TCGA_Expression.select.translated.tojoin.csv > sampleTypeStatistics.tojoin.paper.csv

wc -l sampleTypeStatistics.tojoin.paper.csv
   1559361 sampleTypeStatistics.tojoin.paper.csv

```


##	20230829

Posting to Slack ...




##	20230830

```
awk 'BEGIN{FS=OFS=","}(NR>1 && ($26>0 || $38>0) ){print $1,$26,$38}' /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv > publishedS1.csv
```




```
awk 'BEGIN{FS=OFS=","}(NR==1){print "subject",$0;next}{split($1,a,"-");print a[1]"-"a[2],$0}' sampleTypeStatistics.csv > sampleTypeStatistics.subject.csv

join -t, --header subject_study.csv sampleTypeStatistics.subject.csv > sampleTypeStatistics.subject.study.ALL.csv

head -1 sampleTypeStatistics.subject.study.ALL.csv > sampleTypeStatistics.subject.study.GBM.csv
head -1 sampleTypeStatistics.subject.study.ALL.csv > sampleTypeStatistics.subject.study.LGG.csv

awk -F, '($2=="GBM")' sampleTypeStatistics.subject.study.ALL.csv >> sampleTypeStatistics.subject.study.GBM.csv
awk -F, '($2=="LGG")' sampleTypeStatistics.subject.study.ALL.csv >> sampleTypeStatistics.subject.study.LGG.csv

echo "Transcript_Name,LGG" > sampleTypeStatistics.subject.study.LGG.counts.csv
awk 'BEGIN{FS=OFS=","}(NR>1 && $7==1){tc[$4]+=1}END{for(i in tc){print i,tc[i]}}' sampleTypeStatistics.subject.study.LGG.csv | sort -k1,1 >> sampleTypeStatistics.subject.study.LGG.counts.csv &
echo "Transcript_Name,GBM" > sampleTypeStatistics.subject.study.GBM.counts.csv
awk 'BEGIN{FS=OFS=","}(NR>1 && $7==1){tc[$4]+=1}END{for(i in tc){print i,tc[i]}}' sampleTypeStatistics.subject.study.GBM.csv | sort -k1,1 >> sampleTypeStatistics.subject.study.GBM.counts.csv &

```



```
echo "sample" > their_sample_list
awk -F, '(NR>1){print $13}' /francislab/data1/refs/TEProf2/TABLE_TCGAID.csv | tr -d \" | cut -c 6- | uniq >> their_sample_list
join -t, --header their_sample_list sampleTypeStatistics.csv > sampleTypeStatistics.shared.csv

awk 'BEGIN{FS=OFS=","}(NR==1){print "subject",$0;next}{split($1,a,"-");print a[1]"-"a[2],$0}' sampleTypeStatistics.shared.csv > sampleTypeStatistics.shared.subject.csv

join -t, --header subject_study.csv sampleTypeStatistics.shared.subject.csv > sampleTypeStatistics.shared.subject.study.ALL.csv

head -1 sampleTypeStatistics.shared.subject.study.ALL.csv > sampleTypeStatistics.shared.subject.study.GBM.csv
head -1 sampleTypeStatistics.shared.subject.study.ALL.csv > sampleTypeStatistics.shared.subject.study.LGG.csv

awk -F, '($2=="GBM")' sampleTypeStatistics.shared.subject.study.ALL.csv >> sampleTypeStatistics.shared.subject.study.GBM.csv
awk -F, '($2=="LGG")' sampleTypeStatistics.shared.subject.study.ALL.csv >> sampleTypeStatistics.shared.subject.study.LGG.csv

echo "Transcript_Name,LGG" > sampleTypeStatistics.shared.subject.study.LGG.counts.csv
awk 'BEGIN{FS=OFS=","}(NR>1 && $7==1){tc[$4]+=1}END{for(i in tc){print i,tc[i]}}' sampleTypeStatistics.shared.subject.study.LGG.csv | sort -k1,1 >> sampleTypeStatistics.shared.subject.study.LGG.counts.csv &
echo "Transcript_Name,GBM" > sampleTypeStatistics.shared.subject.study.GBM.counts.csv
awk 'BEGIN{FS=OFS=","}(NR>1 && $7==1){tc[$4]+=1}END{for(i in tc){print i,tc[i]}}' sampleTypeStatistics.shared.subject.study.GBM.csv | sort -k1,1 >> sampleTypeStatistics.shared.subject.study.GBM.counts.csv &

```



```

python3 ./merge.py --int --output merged.all_studies.csv /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230629-TEProF2/sampleTypeStatistics.subject.study.GBM.counts.csv /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230629-TEProF2/sampleTypeStatistics.subject.study.LGG.counts.csv /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230629-TEProF2/sampleTypeStatistics.shared.subject.study.GBM.counts.csv /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230629-TEProF2/sampleTypeStatistics.shared.subject.study.LGG.counts.csv /francislab/data1/working/20200909-TARGET-ALL-P2-RNA_bam/20230710-TEProF2/subjectsStatistics.presence.ALL.counts.csv /francislab/data1/working/20220804-RaleighLab-RNASeq/20230512-TEProF2/subjectsStatistics.presence.ALL.counts.csv /francislab/data1/working/20230628-Costello/20230707-TEProF2/subjectsStatistics.presence.ALL.counts.csv
```

Manually edit column names and upload
```
vi merged.all_studies.csv 

box_upload.bash merged.all_studies.csv

```




