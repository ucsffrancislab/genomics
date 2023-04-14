
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
blast2sam.pl phipseq-${i}/oligos-ref-56-28.default.tblastx >> phipseq-${i}/oligos-ref-56-28.default.sam
samtools sort -o share/phipseq-${i}-oligos-ref-56-28.default.bam phipseq-${i}/oligos-ref-56-28.default.sam
samtools index share/phipseq-${i}-oligos-ref-56-28.default.bam

tblastx -max_hsps 1 -db genome/NC_001348.1_Human_herpesvirus_3__complete_genome.fa -query phipseq-${i}/oligos-ref-56-28.fasta -out phipseq-${i}/oligos-ref-56-28.tblastx
cp Human_alphaherpesvirus_3.sam_header phipseq-${i}/oligos-ref-56-28.sam
blast2sam.pl phipseq-${i}/oligos-ref-56-28.tblastx >> phipseq-${i}/oligos-ref-56-28.sam
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
tblastn -max_hsps 1 -db genome/NC_001348.1_Human_herpesvirus_3__complete_genome.fa -query Human_alphaherpesvirus_3_proteins.fa -out Human_alphaherpesvirus_3_proteins.tblastn
cp Human_alphaherpesvirus_3.sam_header Human_alphaherpesvirus_3_proteins.sam
blast2sam.pl Human_alphaherpesvirus_3_proteins.tblastn >> Human_alphaherpesvirus_3_proteins.sam
samtools sort -o share/Human_alphaherpesvirus_3_proteins.bam Human_alphaherpesvirus_3_proteins.sam
samtools index share/Human_alphaherpesvirus_3_proteins.bam
```








```

zgrep Varicella VIR3_clean.csv.gz | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")"}{print ">"$1"-"$10;print $21}' | sed -e '/^>/s/[ \/,\(\)]/_/g' -e '/^>/s/\(^.\{1,250\}\).*/\1/' > VIR3_Varicella.fa

tblastn -max_hsps 1 -db genome/NC_001348.1_Human_herpesvirus_3__complete_genome.fa -query VIR3_Varicella.fa -out VIR3_Varicella.tblastn

Warning: [tblastn] Query_505 25945-Tegument_.. : Could not calculate ungapped Karlin-Altschul parameters due to an invalid query sequence or its translation. Please verify the query sequence(s) and/or filtering options 
Warning: [tblastn] Query_1468 51765-Putative.. : Could not calculate ungapped Karlin-Altschul parameters due to an invalid query sequence or its translation. Please verify the query sequence(s) and/or filtering options 
Warning: [tblastn] Query_1491 56367-Tegument.. : Could not calculate ungapped Karlin-Altschul parameters due to an invalid query sequence or its translation. Please verify the query sequence(s) and/or filtering options 
Warning: [tblastn] Query_1609 61461-Tegument_protein: Could not calculate ungapped Karlin-Altschul parameters due to an invalid query sequence or its translation. Please verify the query sequence(s) and/or filtering options 
Warning: [tblastn] Query_1610 61462-Tegument_protein: Could not calculate ungapped Karlin-Altschul parameters due to an invalid query sequence or its translation. Please verify the query sequence(s) and/or filtering options 
Warning: [tblastn] Query_1611 61463-Tegument_protein: Could not calculate ungapped Karlin-Altschul parameters due to an invalid query sequence or its translation. Please verify the query sequence(s) and/or filtering options 
Warning: [tblastn] Query_1612 61464-Tegument_protein: Could not calculate ungapped Karlin-Altschul parameters due to an invalid query sequence or its translation. Please verify the query sequence(s) and/or filtering options 
Warning: [tblastn] Query_1613 61465-Tegument_protein: Could not calculate ungapped Karlin-Altschul parameters due to an invalid query sequence or its translation. Please verify the query sequence(s) and/or filtering options 


cp Human_alphaherpesvirus_3.sam_header VIR3_Varicella.sam
blast2sam.pl VIR3_Varicella.tblastn >> VIR3_Varicella.sam
samtools sort -o share/VIR3_Varicella.bam VIR3_Varicella.sam
samtools index share/VIR3_Varicella.bam


tblastn -db genome/NC_001348.1_Human_herpesvirus_3__complete_genome.fa -query VIR3_Varicella.fa -out VIR3_Varicella_default.tblastn
cp Human_alphaherpesvirus_3.sam_header VIR3_Varicella_default.sam
blast2sam.pl VIR3_Varicella_default.tblastn >> VIR3_Varicella_default.sam
samtools sort -o share/VIR3_Varicella_default.bam VIR3_Varicella_default.sam
samtools index share/VIR3_Varicella_default.bam
```













```
BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
BOX="${BOX_BASE}/${PROJECT}"
for f in share/*; do
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done
```


