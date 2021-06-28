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

samtools merge EBV.bam proteins/{YP_401684.3,YP_401699.3,YP_401715.3,YP_401718.3,YP_401720.3,YP_401631.1,YP_401632.1,YP_401633.1,YP_401634.1,YP_401635.1,YP_401636.1,YP_401637.1,YP_401638.1,YP_401639.1,YP_401640.1,YP_401641.1,YP_401642.1,YP_401644.1,YP_401645.1,YP_401646.1,YP_401647.1,YP_401648.1,YP_401649.1,YP_401650.1,YP_401651.1,YP_401653.1,YP_401654.1,YP_401655.1,YP_401656.1,YP_401657.1,YP_401658.1,YP_401659.1,YP_401662.1,YP_401663.1,YP_401664.1,YP_401665.1,YP_401666.1,YP_401667.1,YP_401668.1,YP_401669.1,YP_401670.1,YP_401671.1,YP_401672.1,YP_401673.1,YP_401674.1,YP_401675.1,YP_401676.1,YP_401677.1,YP_401678.1,YP_401679.1,YP_401680.1,YP_401681.1,YP_401682.1,YP_401683.1,YP_401685.1,YP_401686.1,YP_401687.1,YP_401688.1,YP_401689.1,YP_401690.1,YP_401691.1,YP_401692.1,YP_401693.1,YP_401694.1,YP_401695.1,YP_401696.1,YP_401697.1,YP_401698.1,YP_401700.1,YP_401701.1,YP_401702.1,YP_401703.1,YP_401704.1,YP_401705.1,YP_401706.1,YP_401707.1,YP_401708.1,YP_401709.1,YP_401710.1,YP_401711.1,YP_401712.1,YP_401713.1,YP_401714.1,YP_401716.1,YP_401717.1,YP_401719.1,YP_401721.1,YP_401722.1,YP_401724.1,YP_401725.1,YP_401726.1,YP_401728.1}*bam

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

