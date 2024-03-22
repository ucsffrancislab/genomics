
#	20230413-VZV


https://www.dropbox.com/sh/qvo1t75sgsq7fi8/AABPlKrMoiJnWciIHeRzV3LMa/VIR3_clean.csv.gz?dl=0

https://www.dropbox.com/sh/qvo1t75sgsq7fi8/AAAY-LQEQDrxV6wWF6OJDHPWa?dl=0



Find and extract Varicella zoster virus - Human alphaherpesvirus 3 genome
Find and extract VZV proteins

https://www.ncbi.nlm.nih.gov/nuccore/NC_001348.1

```
mkdir genome
ln -s /francislab/data1/refs/refseq/viral-20220923/viral.genomic/NC_001348.1_Human_herpesvirus_3__complete_genome.fa genome/
module load bwa
bwa index genome/NC_001348.1_Human_herpesvirus_3__complete_genome.fa
module load bowtie2
bowtie2-build genome/NC_001348.1_Human_herpesvirus_3__complete_genome.fa genome/NC_001348.1_Human_herpesvirus_3__complete_genome

mkdir proteins
for f in /francislab/data1/refs/refseq/viral-20220923/viral.protein/*_Human_alphaherpesvirus_3.fa ; do
ln -s $f proteins/
done
cat proteins/*_Human_alphaherpesvirus_3.fa > Human_alphaherpesvirus_3_proteins.fa
```





Phipseq VZV proteins

```
for i in $(seq 0 9) ; do 
echo $i
./phipseq.bash 56 28 Human_alphaherpesvirus_3_proteins.fa > phipseq.log
mkdir phipseq-${i}
mv phipseq.log orf_tiles* oligos-* cterm_tiles* protein_tiles-56-28.fasta phipseq-${i}
done

```


Align results
```
mkdir share
for i in $(seq 0 9) ; do 
echo $i

tblastx -db genome/NC_001348.1_Human_herpesvirus_3__complete_genome.fa -query phipseq-${i}/oligos-ref-56-28.fasta -out phipseq-${i}/oligos-ref-56-28.default.tblastx
cp Human_alphaherpesvirus_3.sam_header phipseq-${i}/oligos-ref-56-28.default.sam
#blast2sam.pl phipseq-${i}/oligos-ref-56-28.default.tblastx | awk 'BEGIN{FS=OFS="\t"}{split($6,a,/[MIHSD]/,b);s="";for(i in b){if(b[i]=="H"){s=s""a[i]}else{s=s""3*a[i]};s=s""b[i]}print $1,$2,$3,$4,$5,s,$7,$8,$9,$10,$11,$12}' >> phipseq-${i}/oligos-ref-56-28.default.sam
blast2sam.pl phipseq-${i}/oligos-ref-56-28.default.tblastx > phipseq-${i}/oligos-ref-56-28.default.before.sam
awk 'BEGIN{FS=OFS="\t"}{split($6,a,/[MIHSD]/,b);s="";for(i in b){s=s""3*a[i];s=s""b[i]}print $1,$2,$3,$4,$5,s,$7,$8,$9,$10,$11,$12}' phipseq-${i}/oligos-ref-56-28.default.before.sam >> phipseq-${i}/oligos-ref-56-28.default.sam
samtools sort -o share/phipseq-${i}-oligos-ref-56-28.default.bam phipseq-${i}/oligos-ref-56-28.default.sam
samtools index share/phipseq-${i}-oligos-ref-56-28.default.bam

tblastx -max_target_seqs 1 -max_hsps 1 -db genome/NC_001348.1_Human_herpesvirus_3__complete_genome.fa -query phipseq-${i}/oligos-ref-56-28.fasta -out phipseq-${i}/oligos-ref-56-28.tblastx
cp Human_alphaherpesvirus_3.sam_header phipseq-${i}/oligos-ref-56-28.sam
#blast2sam.pl phipseq-${i}/oligos-ref-56-28.tblastx | awk 'BEGIN{FS=OFS="\t"}{split($6,a,/[MIHSD]/,b);s="";for(i in b){if(b[i]=="H"){s=s""a[i]}else{s=s""3*a[i]};s=s""b[i]}print $1,$2,$3,$4,$5,s,$7,$8,$9,$10,$11,$12}' >> phipseq-${i}/oligos-ref-56-28.sam
blast2sam.pl phipseq-${i}/oligos-ref-56-28.tblastx > phipseq-${i}/oligos-ref-56-28.before.sam
awk 'BEGIN{FS=OFS="\t"}{split($6,a,/[MIHSD]/,b);s="";for(i in b){s=s""3*a[i];s=s""b[i]}print $1,$2,$3,$4,$5,s,$7,$8,$9,$10,$11,$12}' phipseq-${i}/oligos-ref-56-28.before.sam >> phipseq-${i}/oligos-ref-56-28.sam
samtools sort -o share/phipseq-${i}-oligos-ref-56-28.bam phipseq-${i}/oligos-ref-56-28.sam
samtools index share/phipseq-${i}-oligos-ref-56-28.bam

done
```










Create VZV blast reference

```
makeblastdb -in genome/NC_001348.1_Human_herpesvirus_3__complete_genome.fa -input_type fasta -dbtype nucl -title VZV -parse_seqids
```


Align VZV proteins with tblastn or whatever to VZV genome
```

tblastn -max_target_seqs 1 -max_hsps 1 -db genome/NC_001348.1_Human_herpesvirus_3__complete_genome.fa -query Human_alphaherpesvirus_3_proteins.fa -out Human_alphaherpesvirus_3_proteins.tblastn
cp Human_alphaherpesvirus_3.sam_header Human_alphaherpesvirus_3_proteins.sam
#blast2sam.pl Human_alphaherpesvirus_3_proteins.tblastn | awk 'BEGIN{FS=OFS="\t"}{split($6,a,/[MIHSD]/,b);s="";for(i in b){if(b[i]=="H"){s=s""a[i]}else{s=s""3*a[i]};s=s""b[i]}print $1,$2,$3,$4,$5,s,$7,$8,$9,$10,$11,$12}' >> Human_alphaherpesvirus_3_proteins.sam
blast2sam.pl Human_alphaherpesvirus_3_proteins.tblastn > Human_alphaherpesvirus_3_proteins.before.sam
awk 'BEGIN{FS=OFS="\t"}{split($6,a,/[MIHSD]/,b);s="";for(i in b){s=s""3*a[i];s=s""b[i]}print $1,$2,$3,$4,$5,s,$7,$8,$9,$10,$11,$12}' Human_alphaherpesvirus_3_proteins.before.sam >> Human_alphaherpesvirus_3_proteins.sam
samtools sort -o share/Human_alphaherpesvirus_3_proteins.bam Human_alphaherpesvirus_3_proteins.sam
samtools index share/Human_alphaherpesvirus_3_proteins.bam

tblastn -db genome/NC_001348.1_Human_herpesvirus_3__complete_genome.fa -query Human_alphaherpesvirus_3_proteins.fa -out Human_alphaherpesvirus_3_proteins.default.tblastn
cp Human_alphaherpesvirus_3.sam_header Human_alphaherpesvirus_3_proteins.default.sam
#blast2sam.pl Human_alphaherpesvirus_3_proteins.default.tblastn | awk 'BEGIN{FS=OFS="\t"}{split($6,a,/[MIHSD]/,b);s="";for(i in b){if(b[i]=="H"){s=s""a[i]}else{s=s""3*a[i]};s=s""b[i]}print $1,$2,$3,$4,$5,s,$7,$8,$9,$10,$11,$12}' >> Human_alphaherpesvirus_3_proteins.default.sam
blast2sam.pl Human_alphaherpesvirus_3_proteins.default.tblastn > Human_alphaherpesvirus_3_proteins.default.before.sam
awk 'BEGIN{FS=OFS="\t"}{split($6,a,/[MIHSD]/,b);s="";for(i in b){s=s""3*a[i];s=s""b[i]}print $1,$2,$3,$4,$5,s,$7,$8,$9,$10,$11,$12}' Human_alphaherpesvirus_3_proteins.default.before.sam >> Human_alphaherpesvirus_3_proteins.default.sam
samtools sort -o share/Human_alphaherpesvirus_3_proteins.default.bam Human_alphaherpesvirus_3_proteins.default.sam
samtools index share/Human_alphaherpesvirus_3_proteins.default.bam

```








```

zgrep Varicella VIR3_clean.csv.gz | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")"}{print ">"$1"-"$10;print $21}' | sed -e '/^>/s/[ \/,\(\)]/_/g' -e '/^>/s/\(^.\{1,250\}\).*/\1/' > VIR3_Varicella.fa

tblastn -max_target_seqs 1 -max_hsps 1 -db genome/NC_001348.1_Human_herpesvirus_3__complete_genome.fa -query VIR3_Varicella.fa -out VIR3_Varicella.tblastn

Warning: [tblastn] Query_505 25945-Tegument_.. : Could not calculate ungapped Karlin-Altschul parameters due to an invalid query sequence or its translation. Please verify the query sequence(s) and/or filtering options 
Warning: [tblastn] Query_1468 51765-Putative.. : Could not calculate ungapped Karlin-Altschul parameters due to an invalid query sequence or its translation. Please verify the query sequence(s) and/or filtering options 
Warning: [tblastn] Query_1491 56367-Tegument.. : Could not calculate ungapped Karlin-Altschul parameters due to an invalid query sequence or its translation. Please verify the query sequence(s) and/or filtering options 
Warning: [tblastn] Query_1609 61461-Tegument_protein: Could not calculate ungapped Karlin-Altschul parameters due to an invalid query sequence or its translation. Please verify the query sequence(s) and/or filtering options 
Warning: [tblastn] Query_1610 61462-Tegument_protein: Could not calculate ungapped Karlin-Altschul parameters due to an invalid query sequence or its translation. Please verify the query sequence(s) and/or filtering options 
Warning: [tblastn] Query_1611 61463-Tegument_protein: Could not calculate ungapped Karlin-Altschul parameters due to an invalid query sequence or its translation. Please verify the query sequence(s) and/or filtering options 
Warning: [tblastn] Query_1612 61464-Tegument_protein: Could not calculate ungapped Karlin-Altschul parameters due to an invalid query sequence or its translation. Please verify the query sequence(s) and/or filtering options 
Warning: [tblastn] Query_1613 61465-Tegument_protein: Could not calculate ungapped Karlin-Altschul parameters due to an invalid query sequence or its translation. Please verify the query sequence(s) and/or filtering options 


cp Human_alphaherpesvirus_3.sam_header VIR3_Varicella.sam
#blast2sam.pl VIR3_Varicella.tblastn | awk 'BEGIN{FS=OFS="\t"}{split($6,a,/[MIHSD]/,b);s="";for(i in b){if(b[i]=="H"){s=s""a[i]}else{s=s""3*a[i]};s=s""b[i]}print $1,$2,$3,$4,$5,s,$7,$8,$9,$10,$11,$12}' >> VIR3_Varicella.sam
blast2sam.pl VIR3_Varicella.tblastn > VIR3_Varicella.before.sam
awk 'BEGIN{FS=OFS="\t"}{split($6,a,/[MIHSD]/,b);s="";for(i in b){s=s""3*a[i];s=s""b[i]}print $1,$2,$3,$4,$5,s,$7,$8,$9,$10,$11,$12}' VIR3_Varicella.before.sam >> VIR3_Varicella.sam
samtools sort -o share/VIR3_Varicella.bam VIR3_Varicella.sam
samtools index share/VIR3_Varicella.bam


tblastn -db genome/NC_001348.1_Human_herpesvirus_3__complete_genome.fa -query VIR3_Varicella.fa -out VIR3_Varicella.default.tblastn
cp Human_alphaherpesvirus_3.sam_header VIR3_Varicella.default.sam
#blast2sam.pl VIR3_Varicella.default.tblastn | awk 'BEGIN{FS=OFS="\t"}{split($6,a,/[MIHSD]/,b);s="";for(i in b){if(b[i]=="H"){s=s""a[i]}else{s=s""3*a[i]};s=s""b[i]}print $1,$2,$3,$4,$5,s,$7,$8,$9,$10,$11,$12}' >> VIR3_Varicella.default.sam
blast2sam.pl VIR3_Varicella.default.tblastn > VIR3_Varicella.default.before.sam
awk 'BEGIN{FS=OFS="\t"}{split($6,a,/[MIHSD]/,b);s="";for(i in b){s=s""3*a[i];s=s""b[i]}print $1,$2,$3,$4,$5,s,$7,$8,$9,$10,$11,$12}' VIR3_Varicella.default.before.sam >> VIR3_Varicella.default.sam
samtools sort -o share/VIR3_Varicella.default.bam VIR3_Varicella.default.sam
samtools index share/VIR3_Varicella.default.bam
```









```
wget https://ftp.ncbi.nih.gov/refseq/release/viral/viral.1.protein.gpff.gz
wget https://ftp.ncbi.nih.gov/refseq/release/viral/viral.1.genomic.gbff.gz

region=$( zgrep -n "^LOCUS" viral.1.genomic.gbff.gz | grep -A1 "NC_001348" | awk -F: '{print $1}' | paste )

start=$( echo $region | cut -d" " -f1 )
#17536996

stop=$( echo $region | cut -d" " -f2 )
#17541847

zcat viral.1.genomic.gbff.gz | tail -n +${start} | head -n $[stop-start] > NC_001348.genomic.gbff



grep "^     CDS" NC_001348.genomic.gbff | awk '{gsub(/complement|join|[\(\)]/,"",$2);split($2,a,",");for(i in a){split(a[i],b,".");print "NC_001348.1_Human_herpesvirus_3__complete_genome\t"b[1]"\t"b[3]}}' > share/NC_001348.1_Human_herpesvirus_3__complete_genome.CDS.bed

grep "^     gene" NC_001348.genomic.gbff | awk '{gsub(/complement|join|[\(\)]/,"",$2);split($2,a,",");for(i in a){split(a[i],b,".");print "NC_001348.1_Human_herpesvirus_3__complete_genome\t"b[1]"\t"b[3]}}' > share/NC_001348.1_Human_herpesvirus_3__complete_genome.gene.bed


```





```
sed  -e '/^>/s/\(^.\{1,51\}\).*/\1/' Human_alphaherpesvirus_3_proteins.fa > Human_alphaherpesvirus_3_proteins.trim.fa

makeblastdb -in Human_alphaherpesvirus_3_proteins.trim.fa -input_type fasta -dbtype prot -title VZV_Proteins -parse_seqids

blastp -max_target_seqs 1 -max_hsps 1 -db Human_alphaherpesvirus_3_proteins.trim.fa -query VIR3_Varicella.fa -out VIR3_Varicella.Human_alphaherpesvirus_3_proteins.blastp
cp Human_alphaherpesvirus_3_proteins.trim.sam_header VIR3_Varicella.Human_alphaherpesvirus_3_proteins.sam
blast2sam.pl VIR3_Varicella.Human_alphaherpesvirus_3_proteins.blastp >> VIR3_Varicella.Human_alphaherpesvirus_3_proteins.sam
samtools sort -o share/VIR3_Varicella.Human_alphaherpesvirus_3_proteins.bam VIR3_Varicella.Human_alphaherpesvirus_3_proteins.sam
samtools index share/VIR3_Varicella.Human_alphaherpesvirus_3_proteins.bam


for i in $(seq 0 9) ; do 
echo $i
blastx -max_target_seqs 1 -max_hsps 1 -db Human_alphaherpesvirus_3_proteins.trim.fa -query phipseq-${i}/oligos-ref-56-28.fasta -out phipseq-${i}/oligos-ref-56-28.Human_alphaherpesvirus_3_proteins.blastx
cp Human_alphaherpesvirus_3_proteins.trim.sam_header phipseq-${i}/oligos-ref-56-28.Human_alphaherpesvirus_3_proteins.sam
blast2sam.pl phipseq-${i}/oligos-ref-56-28.Human_alphaherpesvirus_3_proteins.blastx >> phipseq-${i}/oligos-ref-56-28.Human_alphaherpesvirus_3_proteins.sam
samtools sort -o share/phipseq-${i}-oligos-ref-56-28.Human_alphaherpesvirus_3_proteins.bam phipseq-${i}/oligos-ref-56-28.Human_alphaherpesvirus_3_proteins.sam
samtools index share/phipseq-${i}-oligos-ref-56-28.Human_alphaherpesvirus_3_proteins.bam
done
```





```
for f in share/*; do

BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
BOX="${BOX_BASE}/${PROJECT}"
for f in Human_alphaherpesvirus_3_proteins.trim.fa share/VIR3_Varicella.Human_alphaherpesvirus_3_proteins.bam{,.bai} share/phipseq-?-oligos-ref-56-28.Human_alphaherpesvirus_3_proteins.bam{,.bai}; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done
```

##	20230926





```
cat /francislab/data1/refs/refseq/viral-20220923/viral.protein/*_Human_betaherpesvirus_5.fa > Human_betaherpesvirus_5_proteins.fa

sed  -e '/^>/s/\(^.\{1,51\}\).*/\1/' Human_betaherpesvirus_5_proteins.fa > Human_betaherpesvirus_5_proteins.trim.fa

makeblastdb -in Human_betaherpesvirus_5_proteins.trim.fa -input_type fasta -dbtype prot -title CMV_Proteins -out Human_betaherpesvirus_5_proteins -parse_seqids

```







##	20240321



/francislab/data1/raw/20230426-PanCancerAntigens/S10_S2_ProteinSequences.fa


blastp -query /francislab/data1/working/20230413-VZV/Human_alphaherpesvirus_3_proteins.fa
-db /francislab/data1/refs/sources/gencodegenes.org/release_43/SPARC


I’m wondering if any of the TE modified antigens look similar to SPARC? I guess that is a circular way of looking at what we already looked at, but do you see what I’m getting at?



```
blastp -query /francislab/data1/working/20230413-VZV/Human_alphaherpesvirus_3_proteins.fa \
-db /francislab/data1/refs/sources/gencodegenes.org/release_43/SPARC

blastp -query /francislab/data1/refs/sources/gencodegenes.org/release_43/SPARC.fa \
-db /francislab/data1/raw/20230426-PanCancerAntigens/S10_S2_ProteinSequences
```


SPARC_VZV_peptides.faa
```
>SPARC_peptide
HPVELLARDFEKNYN
>VZV_peptide
SPELLARDPYGPAVDIWSAGIVLFEMATGQ
```

```
blastp -query SPARC_VZV_peptides.faa \
-db /francislab/data1/raw/20230426-PanCancerAntigens/S10_S2_ProteinSequences \
-outfmt 6 -out SPARC_VZV_peptides_in_TCONS_sequences.tsv
```
















