

#	20230426-PanCancerAntigens


https://www.nature.com/articles/s41588-023-01349-3



https://static-content.springer.com/esm/art%3A10.1038%2Fs41588-023-01349-3/MediaObjects/41588_2023_1349_MOESM1_ESM.pdf


https://static-content.springer.com/esm/art%3A10.1038%2Fs41588-023-01349-3/MediaObjects/41588_2023_1349_MOESM3_ESM.xlsx



```
tail -n +3 41588_2023_1349_MOESM3_ESM/S2.csv | awk -F, '{print $1}' > S2_TranscriptID.txt


grep -f S2_TranscriptID.txt 41588_2023_1349_MOESM3_ESM/S10.csv | awk 'BEGIN{FS=",";OFS="_"}($13!="None"){print ">"$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12;print $13}'  | sed 's/ /_/' > S10_S2_ProteinSequences.fa

grep -f S2_TranscriptID.txt 41588_2023_1349_MOESM3_ESM/S10.csv | awk 'BEGIN{FS=",";OFS="_"}($13!="None"){print ">"$1,$2,$7,$9,$10;print $13}'  | sed 's/ /_/' > S10_S2_ProteinSequences.fa


makeblastdb -in S10_S2_ProteinSequences.fa -input_type fasta -dbtype prot -out S10_S2_ProteinSequences -title S10_S2_ProteinSequences -parse_seqids



tail -n +3 41588_2023_1349_MOESM3_ESM/S10.csv | awk 'BEGIN{FS=",";OFS="_"}($13!="None"){print ">"$1,$2,$7,$9,$10;print $13}' | sed 's/ /_/' > S10_All_ProteinSequences.fa


makeblastdb -in S10_All_ProteinSequences.fa -input_type fasta -dbtype prot -out S10_All_ProteinSequences -title S10_All_ProteinSequences -parse_seqids

```









Column Names / Numbers

```

head -2 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | tail -1 | awk -F, '{for(i=1;i<=NF;i++){print i" : "$i}}'

```


1 : Transcript ID
26 : GBM_tumor
38 : LGG_tumor
87 : Brain_gtex
106 : Tumor Total
107 : Normal Total
108 : GTEx Total
109 : GTEx Total without Testis


```

tail -n +3 41588_2023_1349_MOESM3_ESM/S1.csv | awk -F, '((($26>0)||($38>0))&&($87==0)){print $1}' > S1_BrainTumorTranscriptIDs.txt

grep -f S1_BrainTumorTranscriptIDs.txt 41588_2023_1349_MOESM3_ESM/S10.csv | awk 'BEGIN{FS=",";OFS="_"}($13!="None"){print ">"$1,$2,$7,$9,$10;print $13}'  | sed 's/ /_/' > S10_S1Brain_ProteinSequences.fa

makeblastdb -in S10_S1Brain_ProteinSequences.fa -input_type fasta -dbtype prot -out S10_S1Brain_ProteinSequences -title S10_S1Brain_ProteinSequences -parse_seqids
```



```

awk 'BEGIN{OFS=FS=","}(NR==2)||(NR>2 && $108==0){print $1,$26,$38,$87,$106,$107,$108}' 41588_2023_1349_MOESM3_ESM/S1.csv | head
Transcript ID,GBM_tumor,LGG_tumor,Brain_gtex,Tumor Total,Normal Total,GTEx Total
TCONS_00004307,1,0,0,1018,0,0
TCONS_00004314,0,0,0,925,1,0
TCONS_00031384,0,0,0,895,3,0
TCONS_00004305,1,0,0,700,0,0
TCONS_00108523,0,0,0,431,1,0
TCONS_00087188,0,0,0,391,0,0
TCONS_00115232,0,0,0,391,1,0
TCONS_00115235,0,2,0,375,2,0
TCONS_00060183,0,0,0,368,4,0

awk 'BEGIN{OFS=FS=","}(NR>2 && $108==0){print $1}' 41588_2023_1349_MOESM3_ESM/S1.csv | head

awk 'BEGIN{OFS=FS=","}(NR>2 && $108==0){print $1}' 41588_2023_1349_MOESM3_ESM/S1.csv > S1_TranscriptIDs_GTEx0.txt

awk 'BEGIN{OFS=FS=","}(NR>2 && $108<=1){print $1}' 41588_2023_1349_MOESM3_ESM/S1.csv > S1_TranscriptIDs_GTEx1.txt

```





```
awk -F, '(NR>1){print $8}' TABLE_TCGAID.csv | tr -d \" | cut -c 6- | uniq > their_sample_list

ls /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/*R1.fastq.gz | xargs -I% basename % _R1.fastq.gz | cut -d+ -f1 | uniq > our_sample_list

join our_sample_list their_sample_list > shared_sample_list1
comm -12 our_sample_list their_sample_list > shared_sample_list2

wc -l *sample_list*
   726 our_sample_list
   704 shared_sample_list1
   704 shared_sample_list2
 11086 their_sample_list

diff shared_sample_list*
```




