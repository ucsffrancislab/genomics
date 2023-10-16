
#	20230426-PanCancerAntigens/20231011-focused_blasting


Refer to 20230426-PanCancerAntigens/20230426-explore


Try breaking up virus (or antigen) into smaller reads and cross blast

~25bp AA

Find areas of >30 percent identity.



```
module load samtools

cat S10_All_ProteinSequences.fa | pepsyn tile -l 25 -p 24 - S10_All_ProteinSequences-tile-25-24.faa

samtools faidx Human_herpes_protein_accessions.faa

makeblastdb -parse_seqids \
  -in Human_herpes_protein_accessions.faa \
  -input_type fasta \
  -dbtype prot \
  -out Human_herpes_protein_accessions \
  -title Human_herpes_protein_accessions


echo -e "qaccver\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore" \
  > S10_All_ProteinSequences_fragments_in_Human_herpes_protein_accessions.blastp.e0.05.tsv
blastp -db Human_herpes_protein_accessions \
  -outfmt 6 -evalue 0.05 \
  -query S10_All_ProteinSequences-tile-25-24.faa \
  >> S10_All_ProteinSequences_fragments_in_Human_herpes_protein_accessions.blastp.e0.05.tsv &

blastp -db Human_herpes_protein_accessions \
  -evalue 0.05 \
  -query S10_All_ProteinSequences-tile-25-24.faa \
  >> S10_All_ProteinSequences_fragments_in_Human_herpes_protein_accessions.blastp.e0.05.txt &


blast2sam.pl S10_All_ProteinSequences_fragments_in_Human_herpes_protein_accessions.blastp.e0.05.txt \
  > S10_All_ProteinSequences_fragments_in_Human_herpes_protein_accessions.blastp.e0.05.sam

samtools view -o tmp -ht Human_herpes_protein_accessions.faa.fai S10_All_ProteinSequences_fragments_in_Human_herpes_protein_accessions.blastp.e0.05.sam

samtools sort -o S10_All_ProteinSequences_fragments_in_Human_herpes_protein_accessions.blastp.e0.05.bam tmp
samtools index S10_All_ProteinSequences_fragments_in_Human_herpes_protein_accessions.blastp.e0.05.bam


cat tmp | awk '{print $3}' | sort | uniq -c

box_upload.bash Human_herpes_protein_accessions.fa* S10_All_ProteinSequences_fragments_in_Human_herpes_protein_accessions.blastp.e0.05.bam*
```




```
cat /francislab/data1/refs/refseq/viral-20220923/viral.protein/*_Human*herpes*.fa | sed  -e '/^>/s/,//g' -e '/^>/s/->//g' > test.faa
grep "^>" test.faa | grep -E -o "Human_.*herpesvirus_.*" | sort | uniq -c
     77 Human_alphaherpesvirus_1
     77 Human_alphaherpesvirus_2
     73 Human_alphaherpesvirus_3
    169 Human_betaherpesvirus_5
     88 Human_betaherpesvirus_6A
    104 Human_betaherpesvirus_6B
     86 Human_betaherpesvirus_7
     94 Human_gammaherpesvirus_4
     86 Human_gammaherpesvirus_8
     80 Human_herpesvirus_4_type_2
```





```
#cat /francislab/data1/refs/refseq/viral-20220923/viral.protein/*_Human*herpes*.fa | sed  -e '/^>/s/,//g' -e '/^>/s/->//g' -e '/^>/s/\(^.\{1,51\}\).*/\1/' > Human_herpes_proteins.faa
#cat /francislab/data1/refs/refseq/viral-20220923/viral.protein/*_Human*herpes*.fa | sed  -e '/^>/s/Human_.*herpesvirus_\(.*\)$/HHV\1/' -e '/^>/s/HHV4_type_2/HHV4t2/' | awk 'BEGIN{FS=OFS="_"}(/^>/){s=$1"_"$2"_"$NF;for(i=3;i<NF;i++){s=s"_"$i}print s}(!/^>/){print}' | sed  -e '/^>/s/,//g' -e '/^>/s/->//g' -e '/^>/s/\(^.\{1,51\}\).*/\1/' > Human_herpes_proteins.faa
cat /francislab/data1/refs/refseq/viral-20220923/viral.protein/*_Human*herpes*.fa | sed  -e '/^>/s/Human_.*herpesvirus_\(.*\)$/HHV\1/' -e '/^>/s/HHV4_type_2/HHV4t2/' | awk 'BEGIN{FS=OFS="_"}(/^>/){s=$1"_"$2"_"$NF;for(i=3;i<NF;i++){s=s"_"$i}print s}(!/^>/){print}' | sed  -e '/^>/s/,//g' -e '/^>/s/->//g' -e '/^>/s/\(^.\{1,51\}\).*/\1/' -e '/^>/s/>\(.*\)$/>\1 \1/g' > Human_herpes_proteins.faa

samtools faidx Human_herpes_proteins.faa

makeblastdb -parse_seqids \
  -in Human_herpes_proteins.faa \
  -input_type fasta \
  -dbtype prot \
  -out Human_herpes_proteins \
  -title Human_herpes_proteins


echo -e "qaccver\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore" \
  > S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.tsv
blastp -db Human_herpes_proteins \
  -outfmt 6 -evalue 0.05 \
  -query S10_All_ProteinSequences-tile-25-24.faa \
  >> S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.tsv &

blastp -db Human_herpes_proteins \
  -evalue 0.05 \
  -query S10_All_ProteinSequences-tile-25-24.faa \
  > S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.txt &






blastp -db Human_herpes_proteins \
  -outfmt 5 -evalue 0.05 \
  -query S10_All_ProteinSequences-tile-25-24.faa \
  > S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.xml &


blast2bam S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.xml \
  Human_herpes_proteins.faa S10_All_ProteinSequences-tile-25-24.faa \
  > S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.sam
samtools sort -o S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.bam \
  S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.sam



#blast2sam.pl S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.txt \
#  > S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.sam
#
#samtools view -o tmp -ht Human_herpes_proteins.faa.fai S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.sam
#
#samtools sort -o S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.bam tmp
#samtools index S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.bam
#
#cat tmp | awk '{print $3}' | sort | uniq -c | sort -k1n,1 | tail

box_upload.bash Human_herpes_proteins.fa* 

box_upload.bash S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.*

```




Can you please filter these based on a % identity- greater than 40%, 60% and 80% then link them back to the TCONS in S1 from the paper so we can see the counts across the cancers?


```
tail -n +2 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | head -1 > S1.csv
tail -n +3 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | sort -t, -k1,1 >> S1.csv

base=S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.tsv
sed 's/\t/,/g' ${base} > ${base%.tsv}.csv
base=S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.csv
awk 'BEGIN{FS=OFS=","}(NR==1){print "TCONS",$0}(NR>1){split($1,a,"_");print a[1]"_"a[2],$0}' ${base} > ${base%.csv}.TCONS.csv
base=S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.TCONS.csv

join -t, --header S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.TCONS.csv S1.csv > tmp


awk -F, '( (NR==1) || ($4>=40) )' ${base} > ${base%.csv}.gt40.csv
awk -F, '( (NR==1) || ($4>=60) )' ${base} > ${base%.csv}.gt60.csv
awk -F, '( (NR==1) || ($4>=80) )' ${base} > ${base%.csv}.gt80.csv


box_upload.bash ${base%.csv}.gt??.csv

```




```
awk '{print $2}' S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.tsv | sort | uniq -c | sort -k1n,1 | tail
    162 YP_001129366.1_HHV8_K6
    165 YP_401633.1_HHV4_tegument_protein_G75
    169 YP_001129438.1_HHV4t2_BNRF1
    183 YP_001129434.1_HHV8_ORF75
    286 YP_081612.1_HHV5_envelope_protein_US28
    605 YP_009137215.1_HHV2_serine-threonine_protein_kinas
    768 YP_009137138.1_HHV1_serine-threonine_protein_kinas
    908 YP_009137146.1_HHV1_virion_protein_US10
   1090 NP_040188.1_HHV3_serine-threonine_protein_kinase_U
   1590 YP_001129351.1_HHV8_ORF4
```




