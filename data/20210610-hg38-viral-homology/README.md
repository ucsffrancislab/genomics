# Human / non-Human homology analysis


On a number of occasions, reads have aligned to viral or other non-human genomes suggesting their presence in the sample.
Unfortunately, these were false positives due to simple repeats.
Sadly, RepeatMasker doesn't always mask these regions.

My intention here is to take a number of viral references, break them into many overlapping 100bp reads and align them to the hg38 reference.

I will then run RepeatMasker on the viral references and repeat the previous exercise.



RepeatMasker version 4.1.1
Search Engine: NCBI/RMBLAST [ 2.10.0+ ]

Using Master RepeatMasker Database: /c4/home/gwendt/.local/RepeatMasker-4.1.1/Libraries/RepeatMaskerLib.h5
  Title    : Dfam
  Version  : 3.2
  Date     : 2020-07-02
  Families : 273,693

Species/Taxa Search:
  Homo sapiens [NCBI Taxonomy ID: 9606]
  Lineage: root;cellular organisms;Eukaryota;Opisthokonta;Metazoa;
           Eumetazoa;Bilateria;Deuterostomia;Chordata;
           Craniata <chordates>;Vertebrata <vertebrates>;
           Gnathostomata <vertebrates>;Teleostomi;Euteleostomi;
           Sarcopterygii;Dipnotetrapodomorpha;Tetrapoda;Amniota;
           Mammalia;Theria <mammals>;Eutheria;Boreoeutheria;
           Euarchontoglires;Primates;Haplorrhini;Simiiformes
  1337 families in ancestor taxa; 8 lineage-specific families








Any viral regions that align to human will be marked for masking with a bed file.

Possibly with ...

maskOutFa - Produce a masked .fa file given an unmasked .fa and
a RepeatMasker .out file, or a .bed file to mask on.
usage:
   maskOutFa in.fa maskFile out.fa.masked
where in.fa and out.fa.masked can be the same file, and
maskFile can end in .out (for RepeatMasker) or .bed.
MaskFile parameter can also be the word 'hard' in which case 
lower case letters are converted to N's.
options:
   -soft - puts masked parts in lower case other in upper.
   -softAdd - lower cases masked bits, leaves others unchanged
   -clip - clip out of bounds mask records rather than dying.
   -maskFormat=fmt - "out" or "bed" for when input does not have required extension.


esearch -db nucleotide -query "NC_030850.1" | efetch -format fasta > NC_030850.1.fasta








All future viral references will be created from these multi-masked sequences.



I've done this before, but can find no reference to it.
See
/c4/home/gwendt/github/ucsffrancislab/genomics/refs/fasta/viruses/






https://www.sciencedirect.com/science/article/pii/S1074761318301213



Create notebook with plots of 
* masked regions
* homologous regions
* masked homologous regions

How to gauge? Base count? Number of N's in reference?
Length? Percentage masked?


Align EV samples to raw Burk reference.
Align EV samples to raw, non-homologouos Burk reference.
Align EV samples to masked Burk reference.
Align EV samples to masked, non-homologouos Burk reference.

EV Burkholderia alignments CP019668.1

Sadly, the homologous regions are not the same as those aligning.






Matrix


Accession,Description,length,( N counts for masked and all splits )




./report.bash > report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '2d' report.md > report.csv






---


Protein comparisons of VZV and EBV to hg38

PROTEIN VERSION for 
VZV - HHV-3 - NC_001348
EBV - HHV-4 - NC_007605


/francislab/data1/working/20210610-hg38-viral-homology/20210601-HERV-peptides/


Extract protein sequences from RefSeq viral proteins.
Chop into overlapping 14bp sequences. Any bigger becomes hard to manage.
Reverse translate to all possible nucleotide sequences.
Align each to hg38 to find any homogeneity.


```
eval samtools merge VZV.bam proteins/{$(zgrep "Human alphaherpesvirus 3" /francislab/data1/refs/refseq/viral/viral.protein.faa.gz | sed 's/>//' | cut -f1 -d' ' | paste -s -d',')}*bam
samtools index VZV.bam
samtools_depths_to_ranges.bash VZV.bam > VZV.ranges.txt

GTF=/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf

while read chr a start b stop c length d ; do
if [ $length -ge 100 ] ; then
echo "${chr}:${start}-${stop} (${length})"
awk -v c=$chr -v p=$start -v OFS="\t" '( ( $1 == c ) && ( $4 <= p ) && ( p <= $5 ) ){print "",$1,$4,$5,$10;exit}' $GTF | sed 's/[";]//g'
samtools view VZV.bam ${chr}:${start}-${stop} | awk '{print $1}' | awk -F"_" '{print $1"_"$2"."$3}' | sort -u | awk '{print "\t"$1}'
fi
done < <( tail -n +3 VZV.ranges.txt ) > VZV.notable_ranges_and_genes.txt


eval samtools merge EBV.bam proteins/{$(zgrep "Human gammaherpesvirus 4" /francislab/data1/refs/refseq/viral/viral.protein.faa.gz | sed 's/>//' | cut -f1 -d' ' | paste -s -d',')}*bam
samtools index EBV.bam
samtools_depths_to_ranges.bash EBV.bam > EBV.ranges.txt

GTF=/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf

while read chr a start b stop c length d ; do
if [ $length -ge 100 ] ; then
echo "${chr}:${start}-${stop} (${length})"
awk -v c=$chr -v p=$start -v OFS="\t" '( ( $1 == c ) && ( $4 <= p ) && ( p <= $5 ) ){print "",$1,$4,$5,$10;exit}' $GTF | sed 's/[";]//g'
samtools view EBV.bam ${chr}:${start}-${stop} | awk '{print $1}' | awk -F"_" '{print $1"_"$2"."$3}' | sort -u | awk '{print "\t"$1}'
fi
done < <( tail -n +3 EBV.ranges.txt ) > EBV.notable_ranges_and_genes.txt






samtools view VZV.bam | awk '{print $1}' | awk -F"_" '{print $1"_"$2"."$3}' | sort | uniq -c > VZV.aligned_accessions.txt
samtools view EBV.bam | awk '{print $1}' | awk -F"_" '{print $1"_"$2"."$3}' | sort | uniq -c > EBV.aligned_accessions.txt

sort -n VZV.aligned_accessions.txt | tail
sort -n EBV.aligned_accessions.txt | tail
```





```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210610-hg38-viral-homology"
curl -netrc -X MKCOL "${BOX}/"

for f in *bam*; do
curl -netrc -T $f "${BOX}/"
done
```




```
eval samtools merge VZV.e2e.bam proteins/{$(zgrep "Human alphaherpesvirus 3" /francislab/data1/refs/refseq/viral/viral.protein.faa.gz | sed 's/>//' | cut -f1 -d' ' | paste -s -d',')}*.e2e.bam
samtools index VZV.e2e.bam


GTF=/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf
while read count chr pos ; do
echo $count $chr $pos
awk -v c=$chr -v p=$pos -v OFS="\t" '( ( $1 == c ) && ( ( ( $4 <= p ) && ( p <= $5 ) ) || ( ( $4 <= p+1000 ) && ( p+1000 <= $5 ) ) ) ){print "",$1,$4,$5,$10;exit}' $GTF | sed 's/[";]//g'
done < <( samtools view VZV.e2e.bam | awk 'BEGIN{FS=OFS="\t"}{split($1,a,"_");print a[1]"_"a[2]"_"a[3]"_"a[4],$3,int($4/1000)*1000}' | sort -k2,2 -k3n -k1,1 | uniq | awk '{print $2,$3}'| uniq -c ) > VZV.e2e.1000.groupings.txt &

while read count chr pos ; do
echo $count $chr $pos
awk -v c=$chr -v p=$pos -v OFS="\t" '( ( $1 == c ) && ( ( ( $4 <= p ) && ( p <= $5 ) ) || ( ( $4 <= p+10000 ) && ( p+10000 <= $5 ) ) ) ){print "",$1,$4,$5,$10;exit}' $GTF | sed 's/[";]//g'
done < <( samtools view VZV.e2e.bam | awk 'BEGIN{FS=OFS="\t"}{split($1,a,"_");print a[1]"_"a[2]"_"a[3]"_"a[4],$3,int($4/10000)*10000}' | sort -k2,2 -k3n -k1,1 | uniq | awk '{print $2,$3}'| uniq -c ) > VZV.e2e.10000.groupings.txt &





eval samtools merge EBV.e2e.bam proteins/{$(zgrep "Human gammaherpesvirus 4" /francislab/data1/refs/refseq/viral/viral.protein.faa.gz | sed 's/>//' | cut -f1 -d' ' | paste -s -d',')}*.e2e.bam
samtools index EBV.e2e.bam

GTF=/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf

while read count chr pos ; do
echo $count $chr $pos
awk -v c=$chr -v p=$pos -v OFS="\t" '( ( $1 == c ) && ( ( ( $4 <= p ) && ( p <= $5 ) ) || ( ( $4 <= p+1000 ) && ( p+1000 <= $5 ) ) ) ){print "",$1,$4,$5,$10;exit}' $GTF | sed 's/[";]//g'
done < <( samtools view EBV.e2e.bam | awk 'BEGIN{FS=OFS="\t"}{split($1,a,"_");print a[1]"_"a[2]"_"a[3]"_"a[4],$3,int($4/1000)*1000}' | sort -k2,2 -k3n -k1,1  | uniq | awk '{print $2,$3}'| uniq -c ) > EBV.e2e.1000.groupings.txt &

while read count chr pos ; do
echo $count $chr $pos
awk -v c=$chr -v p=$pos -v OFS="\t" '( ( $1 == c ) && ( ( ( $4 <= p ) && ( p <= $5 ) ) || ( ( $4 <= p+10000 ) && ( p+10000 <= $5 ) ) ) ){print "",$1,$4,$5,$10;exit}' $GTF | sed 's/[";]//g'
done < <( samtools view EBV.e2e.bam | awk 'BEGIN{FS=OFS="\t"}{split($1,a,"_");print a[1]"_"a[2]"_"a[3]"_"a[4],$3,int($4/10000)*10000}' | sort -k2,2 -k3n -k1,1  | uniq | awk '{print $2,$3}'| uniq -c ) > EBV.e2e.10000.groupings.txt &

```






```
awk '(/\tchr/){if(x==1)print;x=0}(/^[[:digit:]]/){if($1>2){print;x=1}else{x=0}}' VZV.e2e.1000.groupings.txt
awk '(/\tchr/){if(x==1)print;x=0}(/^[[:digit:]]/){if($1>3){print;x=1}else{x=0}}' VZV.e2e.10000.groupings.txt

awk '(/\tchr/){if(x==1)print;x=0}(/^[[:digit:]]/){if($1>29){print;x=1}else{x=0}}' EBV.e2e.1000.groupings.txt
awk '(/\tchr/){if(x==1)print;x=0}(/^[[:digit:]]/){if($1>35){print;x=1}else{x=0}}' EBV.e2e.10000.groupings.txt
```


20210709

Just interested in the counts per gene so extracting just that, summing up the counts as they can cross the 1000 or 10000 bp bins.

```
awk '(/\tchr/){if(x==1)printf("\t%s",$NF);x=0}(/^[[:digit:]]/){printf("\n%s",$1);x=1}END{printf("\n")}' EBV.e2e.10000.groupings.txt | awk '{c[$2]+=$1}END{for(k in c){print c[k]"\t"k}}' | sort -rn | head -500 > EBV.e2e.10000.groupings.top500genes.txt
awk '(/\tchr/){if(x==1)printf("\t%s",$NF);x=0}(/^[[:digit:]]/){printf("\n%s",$1);x=1}END{printf("\n")}' EBV.e2e.1000.groupings.txt | awk '{c[$2]+=$1}END{for(k in c){print c[k]"\t"k}}' | sort -rn | head -500 > EBV.e2e.1000.groupings.top500genes.txt

awk '(/\tchr/){if(x==1)printf("\t%s",$NF);x=0}(/^[[:digit:]]/){printf("\n%s",$1);x=1}END{printf("\n")}' VZV.e2e.10000.groupings.txt | awk '{c[$2]+=$1}END{for(k in c){print c[k]"\t"k}}' | sort -rn | head -500 > VZV.e2e.10000.groupings.top500genes.txt
awk '(/\tchr/){if(x==1)printf("\t%s",$NF);x=0}(/^[[:digit:]]/){printf("\n%s",$1);x=1}END{printf("\n")}' VZV.e2e.1000.groupings.txt | awk '{c[$2]+=$1}END{for(k in c){print c[k]"\t"k}}' | sort -rn | head -500 > VZV.e2e.1000.groupings.top500genes.txt



BOX="https://dav.box.com/dav/Francis _Lab_Share/20210610-hg38-viral-homology"

for f in *top500genes.txt; do
curl -netrc -T $f "${BOX}/"
done
```


