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









```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210610-hg38-viral-homology"
curl -netrc -X MKCOL "${BOX}/"

for f in *bam*; do
curl -netrc -T $f "${BOX}/"
done
```




```
NC_022701
NC_022846
NC_022847
NC_023955
```


```
./report.bash > report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '2d' report.md > report.csv
```




```
find out/split.vsl -name *.fasta* -exec rm -f {} \;
find out/split.vsl -name *.mask.* -exec rm -f {} \;

date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-1000%10 --job-name="homology" --output="${PWD}/array.${date}-%A_%a.out" --time=900 --nodes=1 --ntasks=8 --mem=60G /francislab/data1/working/20211012-hg38-complete-homology/array_wrapper2.bash

```






##	20211109

Create Torque_teno masked non-homologous reference

cat $( find /francislab/data1/refs/refseq/complete-20210920/complete_genomes -name \*Torque_teno\* | xargs -I% basename % | cut -d_ -f1,2 | awk '{print "out/split.vsl/"$1".masked.split.25.mask.fasta"}' ) > Torque_teno.masked-nonhomologous.fa

Not all exist

bowtie2-build Torque_teno.masked-nonhomologous.fa Torque_teno.masked-nonhomologous



cat $( find /francislab/data1/refs/refseq/complete-20210920/complete_genomes -name \*Torque_teno\* | xargs -I% basename % | cut -d_ -f1,2 | awk '{print "out/masks/"$1".masked.fasta"}' ) > Torque_teno.masked.fa

bowtie2-build Torque_teno.masked.fa Torque_teno.masked

Not all exist!


for a in $( find /francislab/data1/refs/refseq/complete-20210920/complete_genomes -name \*Torque_teno\* | xargs -I% basename % | cut -d_ -f1,2 ); do
if [ -f "out/masks/${a}.masked.fasta" ] ; then
cat out/masks/${a}.masked.fasta
else 
cat out/raw/${a}.fasta
fi
done > Torque_teno.mostly_masked.fa

bowtie2-build Torque_teno.mostly_masked.fa Torque_teno.mostly_masked

for a in $( find /francislab/data1/refs/refseq/complete-20210920/complete_genomes -name \*anello\* | xargs -I% basename % | cut -d_ -f1,2 ); do
if [ -f "out/masks/${a}.masked.fasta" ] ; then
cat out/masks/${a}.masked.fasta
else 
cat out/raw/${a}.fasta
fi
done > anello.mostly_masked.fa

bowtie2-build anello.mostly_masked.fa anello.mostly_masked


