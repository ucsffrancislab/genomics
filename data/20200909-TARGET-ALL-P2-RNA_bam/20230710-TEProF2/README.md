
#	20200909-TARGET-ALL-P2-RNA_bam/20230710-TEProF2



```
/francislab/data1/refs/RseQC/README.md 
```

```
base=/francislab/data1/raw/20200909-TARGET-ALL-P2-RNA_bam/bam
dir=${base}/strand_check
mkdir ${dir}
for bai in ${base}/*.bam.bai; do
bam=${bai%%.bai}
echo $bam
f=${dir}/$(basename ${bai} .bam.bai).strand_check.txt
if [ ! -f ${f} ] ; then infer_experiment.py -r /francislab/data1/refs/RseQC/hg38_GENCODE_V42_Basic.bed -i ${bam} > ${f} ; fi
done
```

```
base=/francislab/data1/raw/20200909-TARGET-ALL-P2-RNA_bam/bam
dir=${base}/strand_check
for f in ${dir}/*.strand_check.txt ; do
awk -F: '($1=="Fraction of reads explained by \"1+-,1-+,2++,2--\""){if($2<0.1){print "--fr"}else if($2>0.9){print "--rf"}else{print "none"}}' ${f}
done | sort | uniq -c

 
      5 --fr
     51 none
    476 --rf

```



This data is predominantly stranded.





```

TEProF2_array_wrapper.bash --threads 4 \
  --out ${PWD}/in \
  --extension .bam \
  /francislab/data1/raw/20200909-TARGET-ALL-P2-RNA_bam/bam/*bam

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




##	20230724















Create a translation table to convert TCONS to Viral

```
awk 'BEGIN{FS=OFS=","}(NR>1){print $(NF-1),$NF}' /francislab/data1/working/20230426-PanCancerAntigens/20230426-explore/select_protein_accessions_IN_S10_All_ProteinSequences.blastp.e0.005.trimandsort.species.csv | sort | uniq > TCONS_species.e0.005.csv

cat tpmexpressiontable.csv | datamash transpose -t, | head -1 > tpmexpressiontable.sorted.csv
cat tpmexpressiontable.csv | datamash transpose -t, | tail -n +2 >> tpmexpressiontable.sorted.csv

join -t, TCONS_species.e0.005.csv \
  <( tail -n +2 tpmexpressiontable.sorted.csv ) \
  > tpmexpressiontable.sorted.species.csv

awk 'BEGIN{FS=OFS=","}{ for(i=3;i<=NF;i++){s[$2][i]+=$i}}END{for(k in s){t=k;for(i=3;i<=NF;i++){t=t","s[k][i]};print t}}' tpmexpressiontable.sorted.species.csv | sort | awk 'BEGIN{FS=OFS=","}{s=0;for(i=2;i<=NF;i++){if($i>0.01)s++};print $1,s}' > tpmexpressiontable.sorted.species.agg.csv


```


```
BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in TCONS_species.e0.005.csv tpmexpressiontable.sorted.csv tpmexpressiontable.sorted.species.csv tpmexpressiontable.sorted.species.agg.csv; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done

```







##	20230726





They used `allCandidateStatistics.tsv` to call a subject for counting, not the RData.

```
tail -n +2 out/allCandidateStatistics.tsv | awk -F- '{print $3}' | sort | uniq -c
1594860 03A
 425296 03B
1807508 04A
9250188 09A
1036659 09B
  26581 40A
```
Assuming TARGET uses TCGA's standard, https://gdc.cancer.gov/resources-tcga-users/tcga-code-tables/sample-type-codes ,
these are all cancer data either primary, recurrent, blood or marrow.



Here, we have multiple samples for a single subject so I'm going to merge.
Average TPM and sum Intron Count.

```
head out/allCandidateStatistics.tsv 
File	Transcript_Name	Transcript Expression (TPM)	Fraction of Total Gene Expression	Intron Read Count
10-PAKSWW-03A-02R	TCONS_00000050	0	0	0
10-PAKSWW-04A-01R	TCONS_00000050	0.115040519989652	1	0
10-PAMXHJ-09A-01R	TCONS_00000050	0.208128410505855	1	0
10-PAMXSP-09A-01R	TCONS_00000050	0.0303605879995034	1	0
10-PANATY-09B-01R	TCONS_00000050	0.162713903272666	0.0969938620656324	0
10-PANCVR-03A-01R	TCONS_00000050	0	0	0
10-PANCVR-04A-02R	TCONS_00000050	0.0917455083758413	0.315797926802337	0
10-PANDBX-09B-01R	TCONS_00000050	0.274180365888374	1	0
10-PANDWE-03A-02R	TCONS_00000050	0.0858284378804346	1	0
```

Some of these subjects have multiple samples. Merge?

Covert this sample tsv to a subject csv.

All the same TARGET study so no need to sort or separate.


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

Skip this step done in TCGA
```
#join -t, --header subject_study.csv subjectsStatistics.csv > subjectsStatistics.study.csv
#
#head -1 subjectsStatistics.study.csv > subjectsStatistics.study.ALL.csv
#tail -n +2 subjectsStatistics.study.csv | sort -t, -k3,3 -k1,1 >> subjectsStatistics.study.ALL.csv
#
#head -1 subjectsStatistics.study.ALL.csv > subjectsStatistics.study.GBM.csv
#head -1 subjectsStatistics.study.ALL.csv > subjectsStatistics.study.LGG.csv
#
#awk -F, '($2=="GBM")' subjectsStatistics.study.ALL.csv >> subjectsStatistics.study.GBM.csv
#awk -F, '($2=="LGG")' subjectsStatistics.study.ALL.csv >> subjectsStatistics.study.LGG.csv
```

Skip this step done in TCGA
```
#for s in ALL GBM LGG ; do
#echo $s
#awk -v s=${s} 'BEGIN{FS=OFS=","}(NR==1){print "Transcript_Name",s;next}{
#if($3==tcons){
#if(($4>1)&&($6>1)){c++}
#}else{
#if(tcons!=""){print tcons,c};c=0;tcons=$3
#}
#}END{print tcons,c}' subjectsStatistics.study.${s}.csv > subjectsStatistics.study.${s}.agg.csv
#done
#
#join --header -t, S1.csv subjectsStatistics.study.ALL.agg.csv > tmp
#join --header -t, tmp subjectsStatistics.study.GBM.agg.csv > tmp2
#join --header -t, tmp2 subjectsStatistics.study.LGG.agg.csv > subjectsStatistics.study.agg.joined.csv
#\rm tmp tmp2
```


```
head subjectsStatistics.csv 
File,Transcript_Name,Transcript Expression (TPM),Fraction of Total Gene Expression,Intron Read Count
10-PAKSWW,TCONS_00000050,0.0575203,1,0
10-PAMXHJ,TCONS_00000050,0.208128,1,0
10-PAMXSP,TCONS_00000050,0.0303606,0.0969938620656324,0
10-PANATY,TCONS_00000050,0.162714,0,0
10-PANCVR,TCONS_00000050,0.0458728,1,0
10-PANDBX,TCONS_00000050,0.27418,1,0
10-PANDWE,TCONS_00000050,0.0858284,1,0
10-PANEUH,TCONS_00000050,0.0121203,0,0
10-PANFNZ,TCONS_00000050,0,0,0
```

no group added, so use 2, 3 and 5, not 3, 4 and 6


```
awk -v s=TARGET 'BEGIN{FS=OFS=","}(NR==1){print "Transcript_Name",s;next}{
if($2==tcons){
if(($3>1)&&($5>1)){c++}
}else{
if(tcons!=""){print tcons,c};c=0;tcons=$2
}
}END{print tcons,c}' subjectsStatistics.csv > subjectsStatistics.agg.csv



head -2 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | tail -n 1 | tr -d "\r" > S1.csv

tail -n +3 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | sort -t, -k1,1 | tr -d "\r" >> S1.csv

join --header -t, S1.csv subjectsStatistics.agg.csv > subjectsStatistics.agg.joined.csv
```


```
BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in subjectsStatistics.agg.joined.csv ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done
```



