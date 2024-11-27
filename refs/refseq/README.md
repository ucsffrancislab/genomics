
https://ftp.ncbi.nih.gov/refseq/H_sapiens/
https://ftp.ncbi.nih.gov/refseq/H_sapiens/annotation/GRCh38_latest/refseq_identifiers/
https://ftp.ncbi.nih.gov/refseq/H_sapiens/mRNA_Prot/
https://ftp.ncbi.nih.gov/refseq/H_sapiens/RefSeqGene/
rsync -avz --progress --include=README --include="*fna.gz" --include="*gtf.gz" --exclude="*" rsync://ftp.ncbi.nih.gov/refseq/H_sapiens/mRNA_Prot/ mRNA_Prot/
rsync -avz --progress --include=README.txt --include="*fna.gz" --include="*gtf.gz" --exclude="*" rsync://ftp.ncbi.nih.gov/refseq/H_sapiens/RefSeqGene/ RefSeqGene/
ls -1 $PWD/refseq/mRNA_Prot/human.*.rna.fna.gz | paste -sd ,
ls -1 $PWD/refseq/RefSeqGene/refseqgene.*.genomic.fna.gz | paste -sd ,


rsync -avz --progress --include=README.txt --include="*f?a.gz" --exclude="*" rsync://ftp.ncbi.nih.gov/refseq/release/viral/ viral/


rsync -avz --progress --exclude archive/ rsync://ftp.ncbi.nih.gov/refseq/release/release-catalog/ release-catalog/


rsync -avz --progress --include=README.txt --include="*f?a.gz" --exclude="*" rsync://ftp.ncbi.nih.gov/refseq/release/bacteria/ /francislab/data1/refs/refseq/bacteria/

rsync -avz --progress --include=README.txt --include="*fna.gz" --include="gene_RefSeqGene" --exclude="*" rsync://ftp.ncbi.nih.gov/refseq/H_sapiens/RefSeqGene/ RefSeqGene-20210505/





rsync -avz --progress --include=README.txt --include="*fna.gz" --exclude="*" rsync://ftp.ncbi.nih.gov/refseq/H_sapiens/mRNA_Prot/ mRNA_Prot-20210506/
zcat human.?.rna.fna.gz | gzip > human.rna.fna.gz
zcat human.rna.fna.gz | grep "^>" | tr -d "^>" | awk '{split($0,a,"(");split(a[length(a)],b,")");print $1,b[1]}' > human.rna.table
awk  '( $2 == "NAALADL2" ){print $1}' human.rna.table > NAALADL2.transcripts
awk  '( $2 == "AHDC1" ){print $1}' human.rna.table > AHDC1.transcripts

vi human.rna.table
>NM_001281971.2 Homo sapiens killer cell immunoglobulin like receptor, two Ig domains and short cytoplasmic tail 4 (KIR2DS4), transcript variant 2 (KIR2DS4*003 allele), mRNA
>NM_001322168.1 Homo sapiens killer cell immunoglobulin like receptor, three Ig domains and long cytoplasmic tail 1 (KIR3DL1), transcript variant 2 (alternate allele), mRNA
>NM_013289.3 Homo sapiens killer cell immunoglobulin like receptor, three Ig domains and long cytoplasmic tail 1 (KIR3DL1), transcript variant 1 (reference allele), mRNA







rsync -avz --progress rsync://ftp.ncbi.nih.gov/refseq/H_sapiens/mRNA_Prot/ mRNA_Prot-20210528/


rsync -avz --progress rsync://ftp.ncbi.nih.gov/refseq/release/viral/ viral-20210623/
zcat viral.?.protein.faa.gz | gzip > viral.protein.faa.gz
faSplit byname viral.protein.faa.gz split/

VZV=1384
EBV=


rsync -avz --progress --include=README.txt --include="*fna.gz" --exclude="*" rsync://ftp.ncbi.nih.gov/refseq/release/bacteria/ /francislab/data1/refs/refseq/bacteria-20210916/
cd /francislab/data1/refs/refseq/bacteria-20210916/
cat bacteria.*fna.gz > bacteria.genomic.fna.gz
zcat bacteria.genomic.fna.gz | sed -e '/^>/s/ /_/g' -e '/^>/s/\//_/g' -e '/^>/s/\(^.\{1,250\}\).*/\1/' | gzip  > bacteria.genomic.cleaned.fna.gz
mkdir split
faSplit byname bacteria.genomic.cleaned.fna.gz split/
cd split
for f in *fa ; do echo $f; sed -i -e '1s/_/ /g' -e '1s/^>\(\S\{2\}\) />\1_/' $f ; done
find . -name \*fa -ls -exec gzip {} \;
chmod -w *fa.gz


rsync -avz --progress --include=README.txt --include="*fna.gz" --exclude="*" rsync://ftp.ncbi.nih.gov/refseq/release/viral/ /francislab/data1/refs/refseq/viral-20210916/
cd /francislab/data1/refs/refseq/viral-20210916/
cat viral.*fna.gz > viral.genomic.fna.gz
zcat viral.genomic.fna.gz | sed -e '/^>/s/ /_/g' -e '/^>/s/\//_/g' -e '/^>/s/\(^.\{1,250\}\).*/\1/' | gzip  > viral.genomic.cleaned.fna.gz
mkdir split
faSplit byname viral.genomic.cleaned.fna.gz split/
cd split
for f in *fa ; do echo $f; sed -i -e '1s/_/ /g' -e '1s/^>\(\S\{2\}\) />\1_/' $f ; done
find . -name \*fa -ls -exec gzip {} \;
chmod -w *fa.gz


rsync -avz --progress --include=README.txt --include="*.genomic.fna.gz" --exclude="*" rsync://ftp.ncbi.nih.gov/refseq/release/fungi/ /francislab/data1/refs/refseq/fungi-20210920/
cd /francislab/data1/refs/refseq/fungi-20210920/
cat fungi.*fna.gz > fungi.genomic.fna.gz
zcat fungi.genomic.fna.gz | sed -e '/^>/s/ /_/g' -e '/^>/s/\//_/g' -e '/^>/s/\(^.\{1,250\}\).*/\1/' | gzip  > fungi.genomic.cleaned.fna.gz
mkdir split
faSplit byname fungi.genomic.cleaned.fna.gz split/
cd split
for f in *fa ; do echo $f; sed -i -e '1s/_/ /g' -e '1s/^>\(\S\{2\}\) />\1_/' $f ; done
find . -name \*fa -ls -exec gzip {} \;
chmod -w *fa.gz



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



https://ftp.ncbi.nih.gov/refseq/release/invertebrate/
https://ftp.ncbi.nih.gov/refseq/release/archaea/
https://ftp.ncbi.nih.gov/refseq/release/plant/
https://ftp.ncbi.nih.gov/refseq/release/vertebrate_mammalian/
https://ftp.ncbi.nih.gov/refseq/release/vertebrate_other/

https://ftp.ncbi.nih.gov/refseq/release/complete/



#	No more futsing around with partials. Using the complete reference.

rsync -avz --progress --include=README.txt --include="*.genomic.fna.gz" --exclude="*" rsync://ftp.ncbi.nih.gov/refseq/release/complete/ /francislab/data1/refs/refseq/complete-20210920/
cd /francislab/data1/refs/refseq/complete-20210920/

# prep for faSplit so that output files include full name, not just accession number.
gunzip *.genomic.fna.gz
for f in complete.*.?.genomic.fna ; do echo $f ; sed -i -e '/^>/s/ /_/g' -e '/^>/s/\//_/g' -e '/^>/s/\(^.\{1,250\}\).*/\1/' $f ; done
chmod -w *.genomic.fna

mkdir split
for f in complete.?.?.genomic.fna ; do echo $f ; faSplit byname ${f} split/ ; done
for f in complete.??.?.genomic.fna ; do echo $f ; faSplit byname ${f} split/ ; done
cd split

#	I'm only interested in the complete genome references
mkdir complete
mv *complete_genome.fa complete/

for f in *fa ; do echo $f; sed -i -e '1s/_/ /g' -e '1s/^>\(\S\{2\}\) />\1_/' $f ; done
find . -name \*fa -ls -exec gzip {} \;
chmod -w *fa.gz


gunzip -v complete.?.*.genomic.fna.gz
gunzip -v complete.??.*.genomic.fna.gz
gunzip -v complete.???.*.genomic.fna.gz
gunzip -v complete.????.*.genomic.fna.gz

for i in $( seq 3108 3937 ) ; do echo $i ; for f in complete.${i}.*.genomic.fna ; do echo $f ; if [ -e ${f} ] ; then sed -i -e '/^>/s/ /_/g' -e '/^>/s/\//_/g' -e '/^>/s/\(^.\{1,250\}\).*/\1/' $f ; fi ; done ; done >> correcting &






I/O bottleneck so use more CPU's than necessary to minimize number of jobs running. Better way?


date=$( date "+%Y%m%d%H%M%S" )

for i in $( seq 1101 1200 ) ; do echo $i ; for f in complete.${i}.*.genomic.fna ; do echo $f ; if [ -e ${f} ] ; then sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=$f --time=240 --nodes=1 --ntasks=8 --mem=15G --output=${PWD}/${f}.${date}.txt --wrap="faSplit byname ${PWD}/${f} ${PWD}/split/" ; fi ; done ; done

for i in 1078 1095 1105 1109 1117 1118 ; do echo $i ; for f in complete.${i}.*.genomic.fna ; do echo $f ; if [ -e ${f} ] ; then sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=$f --time=300 --nodes=1 --ntasks=8 --mem=15G --output=${PWD}/${f}.${date}.txt --wrap="faSplit byname ${PWD}/${f} ${PWD}/split/" ; fi ; done ; done


This would have been a great opportunity to learn about array jobs


sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=201-220%10 --job-name="%a.faSplit.complete.genomic" --output="${PWD}/complete.genomic.${date}-%A_%a.out" --time=300 --nodes=1 --ntasks=2 --mem=7G /francislab/data1/refs/refseq/faSplit_array_wrapper.bash --page 2





date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=221-1000%10 --job-name="faSplit.complete.genomic" --output="${PWD}/complete.genomic.${date}.%A_%a.out" --time=300 --nodes=1 --ntasks=2 --mem=7G /francislab/data1/refs/refseq/faSplit_array_wrapper.bash --page 2

date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-1000%5 --job-name="faSplit.complete.genomic" --output="${PWD}/complete.genomic.${date}-%A_%a.out" --time=300 --nodes=1 --ntasks=2 --mem=7G /francislab/data1/refs/refseq/faSplit_array_wrapper.bash --page 3


faSplit byname complete.1297.1.genomic.fna split/
for f in $( cat complete.1297.1.genomic.fna.sequences.txt ); do if [ ! -s "split/${f}.fa" ]; then echo "Missing or empty : $f" >> ${l}.missings.txt; fi; done


NOTE THAT SUBMITTED ARRAY JOBS THAT FAIL DON'T SEND INDIVIDUAL EMAILS!

Rerun these
-rw-r----- 1 gwendt francislab 244 Oct  3 00:22 complete.genomic.20210929070303-262981_433.out
-rw-r----- 1 gwendt francislab 244 Oct  3 00:12 complete.genomic.20210929070303-262981_431.out
-rw-r----- 1 gwendt francislab 244 Oct  2 20:59 complete.genomic.20210929070303-262981_416.out
-rw-r----- 1 gwendt francislab 244 Oct  2 15:22 complete.genomic.20210929070303-262981_391.out
-rw-r----- 1 gwendt francislab 244 Oct  2 14:05 complete.genomic.20210929070303-262981_389.out
-rw-r----- 1 gwendt francislab 244 Oct  2 08:05 complete.genomic.20210929070303-262981_336.out
-rw-r----- 1 gwendt francislab 244 Oct  2 03:04 complete.genomic.20210929070303-262981_322.out
-rw-r----- 1 gwendt francislab 244 Oct  2 02:24 complete.genomic.20210929070303-262981_314.out
-rw-r----- 1 gwendt francislab 244 Oct  1 22:00 complete.genomic.20210929070303-262981_308.out
-rw-r----- 1 gwendt francislab 244 Oct  1 22:00 complete.genomic.20210929070303-262981_307.out
-rw-r----- 1 gwendt francislab 245 Oct  3 21:54 complete.genomic.20210929070303-262981_557.out
-rw-r----- 1 gwendt francislab 245 Oct  3 09:50 complete.genomic.20210929070303-262981_481.out
-rw-r----- 1 gwendt francislab 245 Oct  3 07:45 complete.genomic.20210929070303-262981_464.out
-rw-r----- 1 gwendt francislab 245 Oct  3 04:50 complete.genomic.20210929070303-262981_451.out
-rw-r----- 1 gwendt francislab 245 Oct  1 08:30 complete.genomic.20210929070303-262981_284.out
-rw-r----- 1 gwendt francislab 245 Sep 30 21:58 complete.genomic.20210929070303-262981_253.out
-rw-r----- 1 gwendt francislab 245 Sep 25 08:31 complete.genomic.20210924163633.260211_297.out

date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=821-1000%5 --job-name="faSplit.complete.genomic" --output="${PWD}/complete.genomic.${date}-%A_%a.out" --time=300 --nodes=1 --ntasks=2 --mem=7G /francislab/data1/refs/refseq/faSplit_array_wrapper.bash --page 3


date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-1000%5 --job-name="faSplit.complete.genomic" --output="${PWD}/complete.genomic.${date}-%A_%a.out" --time=300 --nodes=1 --ntasks=2 --mem=7G /francislab/data1/refs/refseq/faSplit_array_wrapper.bash --page 4

date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-896%5 --job-name="faSplit.complete.genomic" --output="${PWD}/complete.genomic.${date}-%A_%a.out" --time=300 --nodes=1 --ntasks=2 --mem=7G /francislab/data1/refs/refseq/faSplit_array_wrapper.bash --page 5




This got really muddy by breaking it all up. Not sure if everything that was supposed to happen actually happened.
Checks

for f in complete.*.*.genomic.fna ; do echo $f; grep "^>" $f | sed -e 's/^>//' > ${f}.sequences.txt ; cat ${f}.sequences.txt | wc -l > ${f}.sequences.wc-l.txt ; done

for f in complete.1000.*.genomic.fna ; do echo $f; grep "^>" $f | sed -e 's/^>//' > ${f}.sequences.txt ; cat ${f}.sequences.txt | wc -l > ${f}.sequences.wc-l.txt ; done

ls split/ | wc -l


NEED TO QUOTE THESE FILENAMES as many include []'s and such.

for l in complete.*.*.genomic.fna.sequences.txt ; do echo ${l}; for f in $( cat ${l} ) ; do if [ ! -s "split/${f}.fa" ] ;then echo "Missing or empty : $f" >> ${l}.missings.txt ; fi ; done ; done



nohup ./missings_check.bash >> missings.out.txt &

nohup ../faSplit_reruns.bash >> faSplit_reruns.out.txt &


mkdir complete_genomes
while read path ; do
echo $path
cp $path complete_genomes/
done < complete_genomes.txt


rsync -avz --progress --include=README.txt --include="*faa.gz" --exclude="*" rsync://ftp.ncbi.nih.gov/refseq/release/protozoa/ protozoa-20221001/

rsync -avz --progress --include=README.txt --include="*fna.gz" --exclude="*" rsync://ftp.ncbi.nih.gov/refseq/release/archaea/ archaea-20230714/






archaea
bacteria
complete
fungi
invertebrate
mitochondrion
plant
plasmid
plastid
protozoa
vertebrate_mammalian
vertebrate_other
viral




rsync -avz --progress --include=README.txt --include="*f?a.gz" --exclude="*" rsync://ftp.ncbi.nih.gov/refseq/release/viral/ viral-20230801/



##	20231030


When parsing out square brackets with sed, the closing bracket needs to come first in the list. `[][]` not `[[]]`

```
zcat /francislab/data1/refs/refseq/mRNA_Prot/human.*.protein.faa.gz | sed  -e '/^>/s/ \[Homo sapiens\]//g' -e '/^>/s/[],()\/[]//g' -e '/^>/s/->//g' -e '/^>/s/ /_/g' -e 's/'\''//g' -e '/^>/s/\(^.\{1,51\}\).*/\1/' -e '/^>/s/>\(.*\)$/>\1 \1/g' > mRNA_Prot.faa
makeblastdb -parse_seqids -input_type fasta -dbtype prot -out mRNA_Prot -title mRNA_Prot -in mRNA_Prot.faa
samtools faidx mRNA_Prot.faa
```


##	20231229




zcat /francislab/data1/refs/refseq/bacteria-20210916/bacteria.genomic.fna.gz | grep -is "^>" | sed -e '/^>/s/[],:\(\)\/'' []/_/g' -r -e '/^>/s/_{2,}/_/g' > bacteria.genomic.txt &


```
grep -c "^>NC_" bacteria.genomic.txt 
6550
wc -l bacteria.genomic.txt 
24423009 bacteria.genomic.txt

grep -vs "^>NC_" bacteria.genomic.txt | grep -vs "^>NZ_" | grep -vs "^>NG_" | grep -vs "^>NR_" | grep -vs "^>NT_"
```

Clean up names and split fasta by name. Only want the NC_*. Delete the rest once extracted.
```
#zcat bacteria.*.*.genomic.fna.gz | sed -e '/^>/s/[],:\(\)\/'' []/_/g' -r -e '/^>/s/_{2,}/_/g' -e '/^>/s/\(^.\{1,250\}\).*/\1/' | gzip  > bacteria.genomic.cleaned.fna.gz
nohup zcat /francislab/data1/refs/refseq/bacteria-20210916/bacteria.*.*.genomic.fna.gz | sed -e '/^>/s/[],:\(\)\/'' []/_/g' -r -e '/^>/s/_{2,}/_/g' | gzip > /francislab/data1/refs/refseq/bacteria-20210916/bacteria.genomic.cleaned2.fna.gz &
```
Take forever and a day
```
nohup faSplit byname bacteria.genomic.cleaned2.fna.gz individual/ &
```

```
mkdir individual_NC_only
mv individual/NC_* individual_NC_only/
/bin/rm -rf individual/
cat individual_NC_only/*fa | gzip > NC_bacteria.fna.gz

module load bowtie2
bowtie2-build NC_bacteria.fna.gz NC_bacteria
```


```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name=Clean \
  --output="${PWD}/cleaning.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=14000 --nodes=1 --ntasks=8 --mem=60G /francislab/data1/refs/refseq/clean.bash

mkdir /francislab/data1/refs/refseq/bacteria-20210916/individual/
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name=Split \
  --output="${PWD}/faSplit.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=14000 --nodes=1 --ntasks=8 --mem=60G \
  --wrap="faSplit byname /francislab/data1/refs/refseq/bacteria-20210916/bacteria.genomic.cleaned5.fna.gz /francislab/data1/refs/refseq/bacteria-20210916/individual/"

```

Cleaning took over 2 days. And Splitting took 4 so far




##	20241126


```

rsync -avz --progress --include=README.txt --include="*f?a.gz" --exclude="*" rsync://ftp.ncbi.nih.gov/refseq/release/viral/ viral-20241126/


```
