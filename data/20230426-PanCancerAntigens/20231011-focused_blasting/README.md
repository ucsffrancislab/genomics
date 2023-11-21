
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


echo -e "qaccver\tsaccver\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore" \
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


echo -e "qaccver\tsaccver\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore" \
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

awk -F, '( (NR==1) || ($4>=40) )' tmp > ${base%.csv}.gt40.csv
awk -F, '( (NR==1) || ($4>=60) )' tmp > ${base%.csv}.gt60.csv
awk -F, '( (NR==1) || ($4>=80) )' tmp > ${base%.csv}.gt80.csv


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





##	20231018


AA molecular weight calculator


For those same TCONS- lets also link them with the TCGA data from S1 and see which ones were in glioma
I just quickly did the prediction for those 5 TCONS that we first nominated and they mostly come in at 53-92kDa


read select TCONS tile list

if in select tcons list
compute molecular weight
print tcons, tcons tile, AA, molecular weight

```
awk '($2=="NP_040188.1_HHV3_serine-threonine_protein_kinase_U"){split($1,a,"|");print a[1]}' S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.tsv | uniq | sort | uniq > S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.NP_040188.tsv
```


```
my_file = open("S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.NP_040188.tsv", "r") 
data = my_file.read() 
tcons = data.split("\n") 

from Bio.SeqUtils.ProtParam import ProteinAnalysis
from Bio.SeqIO.FastaIO import SimpleFastaParser

import csv
with open('output.csv', 'w', newline='') as csvfile:
  writer = csv.writer(csvfile, delimiter=',',
    dialect='unix',
    quotechar='|', quoting=csv.QUOTE_MINIMAL)
  writer.writerow(["TCONS", "TCONS_FULL", "AA", "MW" ])
  with open("S10_All_ProteinSequences.fa") as handle:
    for values in SimpleFastaParser(handle):
      if( values[0] in tcons ):
        tc=values[0].split("_")
        X = ProteinAnalysis(values[1])
        writer.writerow([tc[0] + "_" + tc[1], values[0], values[1], "%0.2f" % X.molecular_weight() ])
  
```

```

join -t, --header output.csv S1.csv > S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.NP_040188_with_MW.csv
box_upload.bash S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.NP_040188_with_MW.csv

```









##	20231019 

Hey hey, when you have a minute, could you please do the same tiled AA blastp for small pox (variola)?


Try breaking up virus (or antigen) into smaller reads and cross blast

~25bp AA

Find areas of >30 percent identity.



Done already above, but just in case
```
cat S10_All_ProteinSequences.fa | pepsyn tile -l 25 -p 24 - S10_All_ProteinSequences-tile-25-24.faa
```



```
cat /francislab/data1/refs/refseq/viral-20220923/viral.protein/*_Variola_virus.fa | sed  -e '/^>/s/[(),]//g' -e '/^>/s/->//g' -e '/^>/s/\(^.\{1,51\}\).*/\1/' -e '/^>/s/>\(.*\)$/>\1 \1/g' > Variola_virus_proteins.faa

module load samtools
samtools faidx Variola_virus_proteins.faa

module load blast
makeblastdb -parse_seqids \
  -in Variola_virus_proteins.faa \
  -input_type fasta \
  -dbtype prot \
  -out Variola_virus_proteins \
  -title Variola_virus_proteins


echo -e "qaccver\tsaccver\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore" \
  > S10_All_ProteinSequences_fragments_in_Variola_virus_proteins.blastp.e0.05.tsv
blastp -db Variola_virus_proteins \
  -outfmt 6 -evalue 0.05 \
  -query S10_All_ProteinSequences-tile-25-24.faa \
  >> S10_All_ProteinSequences_fragments_in_Variola_virus_proteins.blastp.e0.05.tsv &

blastp -db Variola_virus_proteins \
  -evalue 0.05 \
  -query S10_All_ProteinSequences-tile-25-24.faa \
  > S10_All_ProteinSequences_fragments_in_Variola_virus_proteins.blastp.e0.05.txt &

blastp -db Variola_virus_proteins \
  -outfmt 5 -evalue 0.05 \
  -query S10_All_ProteinSequences-tile-25-24.faa \
  > S10_All_ProteinSequences_fragments_in_Variola_virus_proteins.blastp.e0.05.xml &

```

WAIT

```
blast2bam S10_All_ProteinSequences_fragments_in_Variola_virus_proteins.blastp.e0.05.xml \
  Variola_virus_proteins.faa S10_All_ProteinSequences-tile-25-24.faa \
  > S10_All_ProteinSequences_fragments_in_Variola_virus_proteins.blastp.e0.05.sam

samtools sort -o S10_All_ProteinSequences_fragments_in_Variola_virus_proteins.blastp.e0.05.bam \
  S10_All_ProteinSequences_fragments_in_Variola_virus_proteins.blastp.e0.05.sam
samtools index S10_All_ProteinSequences_fragments_in_Variola_virus_proteins.blastp.e0.05.bam


#blast2sam.pl S10_All_ProteinSequences_fragments_in_Variola_virus_proteins.blastp.e0.05.txt \
#  > S10_All_ProteinSequences_fragments_in_Variola_virus_proteins.blastp.e0.05.sam
#
#samtools view -o tmp -ht Variola_virus_proteins.faa.fai S10_All_ProteinSequences_fragments_in_Variola_virus_proteins.blastp.e0.05.sam
#
#samtools sort -o S10_All_ProteinSequences_fragments_in_Variola_virus_proteins.blastp.e0.05.bam tmp
#samtools index S10_All_ProteinSequences_fragments_in_Variola_virus_proteins.blastp.e0.05.bam
#
#cat tmp | awk '{print $3}' | sort | uniq -c | sort -k1n,1 | tail

box_upload.bash Variola_virus_proteins.fa* 

box_upload.bash S10_All_ProteinSequences_fragments_in_Variola_virus_proteins.blastp.e0.05.*

```




Can you please filter these based on a % identity- greater than 40%, 60% and 80% then link them back to the TCONS in S1 from the paper so we can see the counts across the cancers?


DONE ABOVE ALREADY
```
tail -n +2 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | head -1 > S1.csv
tail -n +3 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | sort -t, -k1,1 >> S1.csv
```


```
base=S10_All_ProteinSequences_fragments_in_Variola_virus_proteins.blastp.e0.05.tsv
sed 's/\t/,/g' ${base} > ${base%.tsv}.csv
base=S10_All_ProteinSequences_fragments_in_Variola_virus_proteins.blastp.e0.05.csv
awk 'BEGIN{FS=OFS=","}(NR==1){print "TCONS",$0}(NR>1){split($1,a,"_");print a[1]"_"a[2],$0}' ${base} > ${base%.csv}.TCONS.csv
base=S10_All_ProteinSequences_fragments_in_Variola_virus_proteins.blastp.e0.05.TCONS.csv

join -t, --header S10_All_ProteinSequences_fragments_in_Variola_virus_proteins.blastp.e0.05.TCONS.csv S1.csv > tmp

awk -F, '( (NR==1) || ($4>=40) )' tmp > ${base%.csv}.gt40.csv
awk -F, '( (NR==1) || ($4>=60) )' tmp > ${base%.csv}.gt60.csv
awk -F, '( (NR==1) || ($4>=80) )' tmp > ${base%.csv}.gt80.csv


box_upload.bash ${base%.csv}.gt??.csv

```




```
awk '{print $2}' S10_All_ProteinSequences_fragments_in_Variola_virus_proteins.blastp.e0.05.tsv | sort | uniq -c | sort -k1n,1 | tail


    356 NP_042172.1_hypothetical_protein_VARVgp128_Variola
    365 NP_042102.1_hypothetical_protein_VARVgp058_Variola
    365 NP_042225.1_hypothetical_protein_VARVgp181_Variola
    376 NP_042094.1_DNA_polymerase_Variola_virus
    429 NP_042127.1_hypothetical_protein_VARVgp083_Variola
    434 NP_042233.1_hypothetical_protein_VARVgp189_Variola
    494 NP_042151.1_hypothetical_protein_VARVgp107_Variola
    736 NP_042238.1_hypothetical_protein_VARVgp194_Variola
   1602 NP_042219.1_EEV_membrane_glycoprotein_Variola_viru
   2785 NP_042056.1_secreted_complement-binding_protein_Va

```




##	20231025



```
for v in Variola_virus Human_herpes ; do
base=S10_All_ProteinSequences_fragments_in_${v}_proteins.blastp.e0.05.TCONS.csv

join -t, --header S10_All_ProteinSequences_fragments_in_${v}_proteins.blastp.e0.05.TCONS.csv S1.csv > tmp

awk -F, '( (NR==1) || ($13>=25) )' tmp > ${base%.csv}.bitscoregt25.csv
awk -F, '( (NR==1) || ($13>=30) )' tmp > ${base%.csv}.bitscoregt30.csv
awk -F, '( (NR==1) || ($13>=35) )' tmp > ${base%.csv}.bitscoregt35.csv
awk -F, '( (NR==1) || ($13>=40) )' tmp > ${base%.csv}.bitscoregt40.csv

box_upload.bash ${base%.csv}.bitscoregt??.csv
done

```







##	20231026


Trying to filter the blast output xml file so that can create a bam file with just those alignments.


```
module load samtools
for v in Human_herpes_proteins Variola_virus_proteins ; do
for min in 30 35 40 ; do
 xml=S10_All_ProteinSequences_fragments_in_${v}.blastp.e0.05.bitscoregt${min}.xml
 xsltproc --param minimum-bit-score ${min} -o ${xml} blastxmlfilteronbitscore.xsl \
  S10_All_ProteinSequences_fragments_in_${v}.blastp.e0.05.xml
 sed -i 's/<Iteration_hits\/>/<Iteration_hits><\/Iteration_hits><Iteration_message>No hits found<\/Iteration_message>/g' ${xml}
 blast2bam ${xml} ${v}.faa S10_All_ProteinSequences-tile-25-24.faa > ${xml%.xml}.sam
 samtools view -h -F4 ${xml%.xml}.sam | samtools sort -o ${xml%.xml}.bam -
 samtools index ${xml%.xml}.bam
 box_upload.bash ${xml%.xml}.bam ${xml%.xml}.bam.bai
done
done

```


##	20231027


```
cat /francislab/data1/refs/refseq/viral-20220923/viral.protein/*_Human_alphaherpesvirus_3.fa | sed  -e '/^>/s/Human_alphaherpesvirus_3$/HHV3/' | awk 'BEGIN{FS=OFS="_"}(/^>/){s=$1"_"$2"_"$NF;for(i=3;i<NF;i++){s=s"_"$i}print s}(!/^>/){print}' | sed  -e '/^>/s/,//g' -e '/^>/s/->//g' -e '/^>/s/\(^.\{1,51\}\).*/\1/' -e '/^>/s/>\(.*\)$/>\1 \1/g' > Human_alphaherpesvirus_3_proteins.faa

module load samtools
samtools faidx Human_alphaherpesvirus_3_proteins.faa
```



```
cat /francislab/data1/refs/refseq/viral-20220923/viral.genomic/NC_001348.1_Human_herpesvirus_3__complete_genome.fa | sed  -e '/^>/s/>\(.*\)$/>\1 \1/g' > Human_herpesvirus_3_genome.fna

samtools faidx Human_herpesvirus_3_genome.fna

makeblastdb -parse_seqids \
  -in Human_herpesvirus_3_genome.fna \
  -input_type fasta \
  -dbtype nucl \
  -out Human_herpesvirus_3_genome \
  -title Human_herpesvirus_3_genome

```

Find locations of the viral proteins in the genome with tblastn.

Whole or as Tiles???


```

xml=Human_alphaherpesvirus_3_proteins_in_Human_herpesvirus_3_genome.xml
tblastn -db Human_herpesvirus_3_genome \
  -evalue 0.05 \
  -query Human_alphaherpesvirus_3_proteins.faa \
  > ${xml%.xml}.txt
tblastn -db Human_herpesvirus_3_genome \
  -outfmt 6 -evalue 0.05 \
  -query Human_alphaherpesvirus_3_proteins.faa \
  > ${xml%.xml}.tsv
tblastn -db Human_herpesvirus_3_genome \
  -outfmt 5 -evalue 0.05 \
  -query Human_alphaherpesvirus_3_proteins.faa \
  > ${xml}
blast2bam ${xml} /francislab/data1/refs/refseq/viral-20220923/viral.genomic/NC_001348.1_Human_herpesvirus_3__complete_genome.fa Human_alphaherpesvirus_3_proteins.faa > ${xml%.xml}.sam
samtools view -h -F4 ${xml%.xml}.sam | samtools sort -o ${xml%.xml}.bam -
samtools index ${xml%.xml}.bam

box_upload.bash Human_herpesvirus_3_genome.fna* ${xml%.xml}.bam*

```

Create a gtf or gff from resulting regions.


```
samtools view Human_alphaherpesvirus_3_proteins_in_Human_herpesvirus_3_genome.bam | awk 'BEGIN{FS=OFS="\t"}{
patsplit($6,a,/[[:digit:]]+/)
cigarsum=0
for(i=1;i<=length(a);i++){cigarsum+=a[i]}
split($3,c,"_")
print c[1]"_"c[2],"viral","protein",$4,$4+cigarsum,".","+",".","protein_id \""$1"\""
}' > Human_alphaherpesvirus_3_proteins_in_Human_herpesvirus_3_genome.gtf

```


Run featureCounts on subjects viral alignment to these regions.


```
sbatch --job-name="featureCounts" --nodes=1 --ntasks=64 --mem=495G --time=14-0 --export=NONE --wrap="~/.local/bin/featureCounts.bash -T 64 -a /francislab/data1/working/20230426-PanCancerAntigens/20231011-focused_blasting/Human_alphaherpesvirus_3_proteins_in_Human_herpesvirus_3_genome.gtf -t protein -g protein_id -o ${PWD}/featureCounts.HHV3_proteins.csv ${PWD}/out/*.GRCh38.primary_assembly.genome.plus.viral-20210916-RMHM.bam"
```



Note that "NC_001348.1	121075	121125" was masked for Human Homology and is within NP_040184 and NP_040193 transcriptional regulator ICP4
Both appear identical







##	20231027b - xml to csv

```

xsltproc blastxmltocsv.xsl S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.xml

```


##	20231030



```
samtools faidx Human_herpes_proteins.faa NP_040188.1_HHV3_serine-threonine_protein_kinase_U:188-237
>NP_040188.1_HHV3_serine-threonine_protein_kinase_U:188-237
RSVLRALQYLHNNSIIHRDIKSENIFINHPGDVCVGDFGAACFPVDINAN

samtools faidx Human_herpes_proteins.faa NP_040188.1_HHV3_serine-threonine_protein_kinase_U:250-279
>NP_040188.1_HHV3_serine-threonine_protein_kinase_U:250-279
SPELLARDPYGPAVDIWSAGIVLFEMATGQ

```



```
module load blast
module load samtools
zcat /francislab/data1/refs/refseq/mRNA_Prot/human.*.protein.faa.gz | sed  -e '/^>/s/ \[Homo sapiens\]//g' -e '/^>/s/[],()\/[]//g' -e '/^>/s/->//g' -e '/^>/s/ /_/g' -e 's/'\''//g' -e '/^>/s/\(^.\{1,51\}\).*/\1/' -e '/^>/s/>\(.*\)$/>\1 \1/g' > mRNA_Prot.faa
makeblastdb -parse_seqids -input_type fasta -dbtype prot -out mRNA_Prot -title mRNA_Prot -in mRNA_Prot.faa
samtools faidx mRNA_Prot.faa


blastp -db mRNA_Prot \
  -outfmt 6 -evalue 0.05 \
  -query Human_herpes_proteins.faa \
  > Human_herpes_proteins_in_mRNA_Prot.blastp.e0.05.tsv &

blastp -db mRNA_Prot \
  -outfmt 5 -evalue 0.05 \
  -query Human_herpes_proteins.faa \
  > Human_herpes_proteins_in_mRNA_Prot.blastp.e0.05.xml &


xml=Human_herpes_proteins_in_mRNA_Prot.blastp.e0.05.xml
blast2bam ${xml} mRNA_Prot.faa Human_herpes_proteins.faa > ${xml%.xml}.sam
samtools view -h -F4 ${xml%.xml}.sam | samtools sort -o ${xml%.xml}.bam -
samtools index ${xml%.xml}.bam
box_upload.bash ${xml%.xml}.bam ${xml%.xml}.bam.bai

module load samtools
for min in 50 75 100 150 200 ; do
 xml=Human_herpes_proteins_in_mRNA_Prot.blastp.e0.05.bitscoregt${min}.xml
 xsltproc --param minimum-bit-score ${min} -o ${xml} blastxmlfilteronbitscore.xsl \
  Human_herpes_proteins_in_mRNA_Prot.blastp.e0.05.xml
 sed -i 's/<Iteration_hits\/>/<Iteration_hits>\n      <\/Iteration_hits>/g' ${xml}
 blast2bam ${xml} mRNA_Prot.faa Human_herpes_proteins.faa > ${xml%.xml}.sam
 samtools view -h -F4 ${xml%.xml}.sam | samtools sort -o ${xml%.xml}.bam -
 samtools index ${xml%.xml}.bam
 box_upload.bash ${xml%.xml}.bam ${xml%.xml}.bam.bai
done

```








can lower the e-value. lets try 0.005 to make the list smaller

Oh oh- Lets just do the one AA sequence :
SPELLARDPYGPAVDIWSAGIVLFEMATGQ



```

blastp -db mRNA_Prot \
  -outfmt 5 -evalue 0.005 \
  -query Human_herpes_proteins.faa \
  > Human_herpes_proteins_in_mRNA_Prot.blastp.e0.005.xml &


xml=Human_herpes_proteins_in_mRNA_Prot.blastp.e0.005.xml
blast2bam ${xml} mRNA_Prot.faa Human_herpes_proteins.faa > ${xml%.xml}.sam
samtools view -h -F4 ${xml%.xml}.sam | samtools sort -o ${xml%.xml}.bam -
samtools index ${xml%.xml}.bam
box_upload.bash ${xml%.xml}.bam ${xml%.xml}.bam.bai

module load samtools
for min in 50 75 100 150 200 ; do
 xml=Human_herpes_proteins_in_mRNA_Prot.blastp.e0.005.bitscoregt${min}.xml
 xsltproc --param minimum-bit-score ${min} -o ${xml} blastxmlfilteronbitscore.xsl \
  Human_herpes_proteins_in_mRNA_Prot.blastp.e0.005.xml
 sed -i 's/<Iteration_hits\/>/<Iteration_hits>\n      <\/Iteration_hits>/g' ${xml}
 blast2bam ${xml} mRNA_Prot.faa Human_herpes_proteins.faa > ${xml%.xml}.sam
 samtools view -h -F4 ${xml%.xml}.sam | samtools sort -o ${xml%.xml}.bam -
 samtools index ${xml%.xml}.bam
 box_upload.bash ${xml%.xml}.bam ${xml%.xml}.bam.bai
done

```


```

echo -e ">sequence\nSPELLARDPYGPAVDIWSAGIVLFEMATGQ" > sequence.faa


blastp -db mRNA_Prot \
  -outfmt 6 -evalue 0.005 \
  -query sequence.faa \
  > sequence_in_mRNA_Prot.blastp.e0.005.tsv

blastp -db mRNA_Prot \
  -outfmt 5 -evalue 0.005 \
  -query sequence.faa \
  > sequence_in_mRNA_Prot.blastp.e0.005.xml

xml=sequence_in_mRNA_Prot.blastp.e0.005.xml
blast2bam ${xml} mRNA_Prot.faa Human_herpes_proteins.faa > ${xml%.xml}.sam
samtools view -h -F4 ${xml%.xml}.sam | samtools sort -o ${xml%.xml}.bam -
samtools index ${xml%.xml}.bam

```




##	20231031


```
echo "accession,withversion,description" > Human_alphaherpesvirus_3.protein_translation_table.csv
ls -1 /francislab/data1/refs/refseq/viral-20220923/viral.protein/*_Human_alphaherpesvirus_3.fa | cut -d/ -f8 | sed 's/_Human_alphaherpesvirus_3.fa//' | awk 'BEGIN{OFS=","}{split($0,a,".");split($0,b,"_");print a[1],b[1]"_"b[2],$0}' >> Human_alphaherpesvirus_3.protein_translation_table.csv


```




##	20231101



```

echo -e "qaccver\tsaccver\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore" \
  > S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.5.tsv
blastp -db Human_herpes_proteins \
  -outfmt 6 -evalue 0.5 \
  -query S10_All_ProteinSequences-tile-25-24.faa \
  >> S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.5.tsv &

```




```
awk '($2=="NP_040188.1_HHV3_serine-threonine_protein_kinase_U"){split($1,a,"|");print a[1]}' S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.5.tsv | uniq | sort | uniq > S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.5.NP_040188.tsv
```


```
module load WitteLab python3/3.9.1
python3


my_file = open("S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.5.NP_040188.tsv", "r") 
data = my_file.read() 
tcons = data.split("\n") 

from Bio.SeqUtils.ProtParam import ProteinAnalysis
from Bio.SeqIO.FastaIO import SimpleFastaParser

import csv
with open('output.csv', 'w', newline='') as csvfile:
  writer = csv.writer(csvfile, delimiter=',',
    dialect='unix',
    quotechar='|', quoting=csv.QUOTE_MINIMAL)
  writer.writerow(["TCONS", "TCONS_FULL", "AA", "MW" ])
  with open("S10_All_ProteinSequences.fa") as handle:
    for values in SimpleFastaParser(handle):
      if( values[0] in tcons ):
        tc=values[0].split("_")
        X = ProteinAnalysis(values[1])
        writer.writerow([tc[0] + "_" + tc[1], values[0], values[1], "%0.2f" % X.molecular_weight() ])
  
```

```

join -t, --header output.csv S1.csv > S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.5.NP_040188_with_MW.csv
box_upload.bash S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.5.NP_040188_with_MW.csv

```




##	20231107


```
head -3 S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.5.tsv
qaccver	saccver	pident	length	mismatch	gapopen	qstart	qend	sstart	send	evalue	bitscore
TCONS_00000246_HERVFH21-int_TAS1R1_+_104|131-156	YP_073755.1_HHV7_tegument_protein_UL35	47.368	19	10	0	6	24	570	588	0.48	21.2
TCONS_00000246_HERVFH21-int_TAS1R1_+_104|132-157	YP_073755.1_HHV7_tegument_protein_UL35	42.857	21	12	0	5	25	570	590	0.41	21.6

head -3 /francislab/data1/refs/refseq/viral-20220923/herpes_protein_virus_translation_table.csv
virus,accession,with_version,with_description
Human_alphaherpesvirus_1,YP_009137073,YP_009137073.1,YP_009137073.1_neurovirulence_protein_ICP34.5_Human_alphaherpesvirus_1
Human_alphaherpesvirus_1,YP_009137074,YP_009137074.1,YP_009137074.1_ubiquitin_E3_ligase_ICP0_Human_alphaherpesvirus_1

head -3 /francislab/data1/refs/refseq/viral-20220923/herpes_virus_abbreviation_translation_table.csv
virus,abbreviation
Human_alphaherpesvirus_1,HHV1
Human_alphaherpesvirus_2,HHV2
```


```
join --header -t, /francislab/data1/refs/refseq/viral-20220923/herpes_virus_abbreviation_translation_table.csv \
  /francislab/data1/refs/refseq/viral-20220923/herpes_protein_virus_translation_table.csv > tmp1

head -3 tmp1
virus,abbreviation,accession,with_version,with_description
Human_alphaherpesvirus_1,HHV1,YP_009137073,YP_009137073.1,YP_009137073.1_neurovirulence_protein_ICP34.5_Human_alphaherpesvirus_1
Human_alphaherpesvirus_1,HHV1,YP_009137074,YP_009137074.1,YP_009137074.1_ubiquitin_E3_ligase_ICP0_Human_alphaherpesvirus_1
```


```
sed 's/\t/,/g' S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.tsv \
  | awk 'BEGIN{FS=OFS=","}(NR>1){split($1,a,"_");split($2,b,".");print a[1]"_"a[2],b[1],$NF}' > tmp2

head -3 tmp2
TCONS_00000246,YP_081561,24.6
TCONS_00000246,YP_081561,24.6
TCONS_00000246,YP_081561,24.6

sort -t, -k1,2 -k3nr tmp2 | uniq | head
TCONS_00000246,NP_050190,23.9
TCONS_00000246,YP_081561,24.6
TCONS_00000667,YP_001129455,25.8
TCONS_00000667,YP_001129455,24.3
TCONS_00000667,YP_401658,25.8
TCONS_00000667,YP_401658,24.3
TCONS_00000802,YP_009137100,24.3
TCONS_00000820,NP_040188,26.9
TCONS_00000820,NP_040188,26.6
TCONS_00000820,NP_040188,26.2

sort -t, -k1,2 -k3nr tmp2 | uniq | awk 'BEGIN{FS=OFS=","}( k[$1][$2] == "" ){k[$1][$2]=$3;print $2,$1,$3}' | head
NP_050190,TCONS_00000246,23.9
YP_081561,TCONS_00000246,24.6
YP_001129455,TCONS_00000667,25.8
YP_401658,TCONS_00000667,25.8
YP_009137100,TCONS_00000802,24.3
NP_040188,TCONS_00000820,26.9
YP_009137138,TCONS_00000820,28.5
YP_009137215,TCONS_00000820,27.3
YP_081510,TCONS_00000820,23.9
YP_001129393,TCONS_00001232,24.3
```


```
sort -t, -k1,2 -k3nr tmp2 | uniq | awk 'BEGIN{FS=OFS=","}( k[$1][$2] == "" ){k[$1][$2]=$3;print $2,$1,$3}' | sort -t, -k1,2 > tmp3

head -3 tmp3
NP_040125,TCONS_00071958,25.8
NP_040125,TCONS_00115919,24.3
NP_040127,TCONS_00037379,25.4

tail -n +2 tmp1 | awk 'BEGIN{FS=OFS=","}{print $3,$2}' | sort -t, -k1,2 | uniq > tmp4
head -3 tmp4
NP_040124,HHV3
NP_040125,HHV3
NP_040126,HHV3


echo "virus,protein,TCONS,bitscore" > virus_protein_TCONS_bitscore.csv
join -t, tmp4 tmp3 | awk 'BEGIN{FS=OFS=","}{print $2,$1,$3,$4}' | sort -t, -k1,3 >> virus_protein_TCONS_bitscore.csv

head -3 virus_protein_TCONS_bitscore.csv
virus,protein,TCONS,bitscore
HHV1,YP_009137074,TCONS_00009055,33.9
HHV1,YP_009137074,TCONS_00030850,31.6

box_upload.bash virus_protein_TCONS_bitscore.csv
```



##	20231108

```
module load WitteLab python3/3.9.1
python3


from Bio.SeqUtils.ProtParam import ProteinAnalysis
from Bio.SeqIO.FastaIO import SimpleFastaParser

import csv
with open('S10_All_ProteinSequences.MW.csv', 'w', newline='') as csvfile:
  writer = csv.writer(csvfile, delimiter=',',
    dialect='unix',
    quotechar='|', quoting=csv.QUOTE_MINIMAL)
  writer.writerow(["TCONS", "TCONS_FULL", "AA", "MW" ])
  with open("S10_All_ProteinSequences.fa") as handle:
    for values in SimpleFastaParser(handle):
      tc=values[0].split("_")
      X = ProteinAnalysis(values[1])
      writer.writerow([tc[0] + "_" + tc[1], values[0], values[1], "%0.2f" % X.molecular_weight() ])
  
```



```
module load WitteLab python3/3.9.1
python3


from Bio.SeqUtils.ProtParam import ProteinAnalysis
from Bio.SeqIO.FastaIO import SimpleFastaParser

import csv
with open('Human_herpes_proteins.MW.csv', 'w', newline='') as csvfile:
  writer = csv.writer(csvfile, delimiter=',',
    dialect='unix',
    quotechar='|', quoting=csv.QUOTE_MINIMAL)
  writer.writerow(["TCONS", "TCONS_FULL", "AA", "MW" ])
  with open("Human_herpes_proteins.faa") as handle:
    for values in SimpleFastaParser(handle):
      tc=values[0].split("_")
      X = ProteinAnalysis(values[1])
      writer.writerow([tc[0] + "_" + tc[1], values[0], values[1], "%0.2f" % X.molecular_weight() ])
  
```



```
module load blast

echo -e "qaccver\tsaccver\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore" \
  > S10_All_ProteinSequences_fragments_in_Variola_virus_proteins.blastp.e0.5.tsv
blastp -db Variola_virus_proteins \
  -outfmt 6 -evalue 0.5 \
  -query S10_All_ProteinSequences-tile-25-24.faa \
  >> S10_All_ProteinSequences_fragments_in_Variola_virus_proteins.blastp.e0.5.tsv &

```
