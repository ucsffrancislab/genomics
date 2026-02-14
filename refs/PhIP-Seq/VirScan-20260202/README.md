
#	VirScan-20260202

Starting fresh. Should have done this sooner.

Need an actual clean version of the VIR3_clean.csv.gz file.

The provided file is not.

```bash
ln -s /c4/home/gwendt/github/ucsffrancislab/PhIP-Seq/Elledge/VIR3_clean.csv.gz

zcat VIR3_clean.csv.gz | head -1 | tr ',' '\n' | awk '{print NR,$0}'
1                         useless so drop
2  Aclstr50               useless so drop
3  Bclstr50               useless so drop
4  Entry                  useless so drop
5  Gene names             usually a duplicate of protein name but blank 43678 times so drup
6  Gene ontology (GO)     useless so drop
7  Gene ontology IDs      useless so drop
8  Genus                  mostly empty so best to drop
9  Organism               similar to species (n=1573). mostly strains. Drop?
10 Protein names          (n=3991)
11 Sequence
12 Species                similar to organism (n=443)
13 Subcellular location
14 Version (entry)	      reliable? make a difference? useful? drop
15 Version (sequence)     reliable? make a difference? useful? drop
16 end
17 id
18 oligo
19 source                 ( 3 different IEDB, Vir2 and Vir3) useful?
20 start
21 peptide

```


Some ids are duplicated.
Some species names have different versions.
Some protein names have different versions.

Digging
```bash
zcat VIR3_clean.csv.gz | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}{print $12}' | sort | uniq -c
zcat VIR3_clean.csv.gz | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}{print ": " $12" / "$9}' | sort | uniq -c
zcat VIR3_clean.csv.gz | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}(NR>1){print ": " $12" // "$9" // "$5" // "$10}' | sort | uniq -c > species_organism_gene_protein.txt
```


Keep 17-id, 12-species, 10-protein name, 11-sequence, 18-oligo, 21-peptide, 20-start, 16-end


There are only 115753 uniq ids

```bash
cut -d, -f1 v001.csv | uniq | wc -l
115754
```



```bash
zcat VIR3_clean.csv.gz | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}{print $17}' | sort -t, -k1n,1 | uniq > v999.csv &

zcat VIR3_clean.csv.gz | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}{print $17,$12,$10,$11,$18,$21,$20,$16}' | sort -t, -k1n,1 > v001.csv &
zcat VIR3_clean.csv.gz | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}{print $17,$12,$10,$11,$18,$21,$20,$16}' | sort -t, -k1n,1 | uniq > v002.csv &


zcat VIR3_clean.csv.gz | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}{print $17,$12,$10,$11,$18,$21,$20,$16}' | sort -t, -k1n,1 | uniq | cut -d, -f1 | uniq -D | uniq -c > v003.test.csv


zcat VIR3_clean.csv.gz | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}{print $17,$18}' | sort -t, -k1n,1 | uniq > id,oligo.csv &
zcat VIR3_clean.csv.gz | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}{print $17,$21}' | sort -t, -k1n,1 | uniq > id,peptide.csv &
zcat VIR3_clean.csv.gz | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}{print $17,$18,$21}' | sort -t, -k1n,1 | uniq > id,oligo,peptide.csv &
zcat VIR3_clean.csv.gz | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}{print $17,$18,$21,$20,$16}' | sort -t, -k1n,1 | uniq > id,oligo,peptide,start,end.csv &
zcat VIR3_clean.csv.gz | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}{print $17,$18,$21,$20,$16,$11}' | sort -t, -k1n,1 | uniq > id,oligo,peptide,start,end,sequence.csv &


Keep 17-id, 12-species, 10-protein name, 11-sequence, 18-oligo, 21-peptide, 20-start, 16-end
zcat VIR3_clean.csv.gz | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}{print $17,$14,$18,$21,$20,$16}' | sort -t, -k1n,1 -k2n,2 | uniq > id,version,oligo,peptide,start,end.csv &

zcat VIR3_clean.csv.gz | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}{print $17,$14,$12,$10,$18,$21,$20,$16}' | sort -t, -k1n,1 -k2n,2 | uniq > id,version,species,protein,oligo,peptide,start,end.csv &

zcat VIR3_clean.csv.gz | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}{print $17,$14,$12,$10,$18,$21,$20,$16,$11}' | sort -t, -k1n,1 -k2n,2 | uniq > id,version,species,protein,oligo,peptide,start,end,sequence.csv &

zcat VIR3_clean.csv.gz | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}{print $17,$15,$14,$12,$10,$18,$21,$20,$16,$11}' | sort -t, -k1n,1 -k2n,2 -k3n,3 | uniq > id,version,version,species,protein,oligo,peptide,start,end,sequence.csv &





zcat VIR3_clean.csv.gz | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}{print $17,$15,$14,$12,$9,$10,$18,$21,$20,$16}' | sort -t, -k1n,1 -k2n,2 -k3n,3 | uniq | sed '1c\id,entry_version,sequence_version,species,organism,protein,oligo,peptide,start,end' > id,entry_version,sequence_version,species,organism,protein,oligo,peptide,start,end.csv &

zcat VIR3_clean.csv.gz | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}{print $17,$15,$14,$12,$10,$18,$21,$20,$16}' | sort -t, -k1n,1 -k2n,2 -k3n,3 | uniq | sed '1c\id,entry_version,sequence_version,species,protein,oligo,peptide,start,end' > id,entry_version,sequence_version,species,protein,oligo,peptide,start,end.csv &

zcat VIR3_clean.csv.gz | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}{print $17,$15,$14,$12,$10}' | sort -t, -k1n,1 -k2n,2 -k3n,3 | uniq | sed '1c\id,entry_version,sequence_version,species,protein' > id,entry_version,sequence_version,species,protein.csv &

```



THERE ARE STILL COMMAS IN THE DATA SO BEWARE




take the highest sequence version and entry version for each id, then drop the versions and keep the rest.

```python3

import pandas as pd
df = pd.read_csv('id,entry_version,sequence_version,species,organism,protein,oligo,peptide,start,end.csv')
df = (df
    .sort_values(['id', 'entry_version', 'sequence_version'], ascending=[True, False, False])
    .drop_duplicates(subset='id', keep='first')
    .drop(columns=['entry_version', 'sequence_version'])
)
df.to_csv('id,species,organism,protein,oligo,peptide,start,end-clean.csv',index=False)

df = pd.read_csv('id,entry_version,sequence_version,species,protein.csv')
df = (df
    .sort_values(['id', 'entry_version', 'sequence_version'], ascending=[True, False, False])
    .drop_duplicates(subset='id', keep='first')
    .drop(columns=['entry_version', 'sequence_version'])
)
df.to_csv('id,species,protein-clean.csv',index=False)

df = pd.read_csv('id,entry_version,sequence_version,species,protein,oligo,peptide,start,end.csv')
df = (df
    .sort_values(['id', 'entry_version', 'sequence_version'], ascending=[True, False, False])
    .drop_duplicates(subset='id', keep='first')
    .drop(columns=['entry_version', 'sequence_version'])
)
df.to_csv('id,species,protein,oligo,peptide,start,end-clean.csv',index=False)

```

THERE ARE STILL COMMAS IN THE DATA SO BEWARE




Take AI's lead but use it to create a translation table rather than actually change the data.

Then join on the table, remove the original versions of species, organism and protein names to create new normalized file


Read the raw file drom all but species, organism and protein.

Drop duplicates

For all 3 species, create a new version of the column with modifications:
* replace commas with spaces
* remove bracketed and parentesized content.

The manually search for synonyms like ...
* 'Human cytomegalovirus (HHV-5) (Human herpesvirus 5)': 'Human herpesvirus 5',



```bash
awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}(NR>1){print $2,$3,$4}' id,species,organism,protein,oligo,peptide,start,end-clean.csv | uniq | wc -l
10147

awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}(NR>1){print $2,$3,$4}' id,species,organism,protein,oligo,peptide,start,end-clean.csv | sort | uniq | wc -l
7857
awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}(NR>1){print $2}' id,species,organism,protein,oligo,peptide,start,end-clean.csv | sort | uniq | wc -l
443
awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}(NR>1){print $3}' id,species,organism,protein,oligo,peptide,start,end-clean.csv | sort | uniq | wc -l
1558
awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}(NR>1){print $4}' id,species,organism,protein,oligo,peptide,start,end-clean.csv | sort | uniq | wc -l
3991
```


```bash
create_translation_tables.py
```


```bash
wc -l species_translation_table.csv
```




NEED TO TRIM OLIGOS

```bash
awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}(NR>1){print ">"$1;print $5}' id,species,organism,protein,oligo,peptide,start,end-clean.csv > id,species,organism,protein,oligo,peptide,start,end-clean.fna
```






Should trim the indexes of of the oligos.

Leading indexes ...
```bash
zcat VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}{if($18~/^a/){i=2}else{i=1};print substr($18,1,14+i)}' | sort | uniq -c

  70798 aGGAATTCCGCTGCGT (16)
  37805 aTGAATTCGGAGCGGT (16)
  19654  GGAATTCCGCTGCGT (15)
```

Leading and Trailing indexes ...
```bash
zcat VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}{if($18~/^a/){i=2}else{i=1};print substr($18,1,14+i)" "substr($18,length($18)-13-i)}' | sort | uniq -c

  70798 aGGAATTCCGCTGCGT CAGGgaagagctcgaa
  37805 aTGAATTCGGAGCGGT CACTGCACTCGAGACa
  19654  GGAATTCCGCTGCGT CAGGGAAGAGCTCGA
```

```bash

zcat VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}{if($18~/^a/){i=2}else{i=1};print substr($18,1,14+i)" "substr($18,length($18)-13-i); print substr($18,15+i,length($18)-30-i))}' | head
```


Actual sequences ...

a bit concerned about the -30-1. (-28-(2*i)) is better

```bash
zcat VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}{ if($18~/^a/){i=2}else{i=1} print $17,toupper(substr($18,15+i,length($18)-28-(2*i))); }' | sort -t, -k1n,1 -k2,2 | uniq > VirScan/VIR3_clean.id_upper_oligo.uniq.csv
```









##	The Good Stuff

```bash
zcat VIR3_clean.csv.gz | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}{ if($18~/^a/){i=2}else{i=1} print $17,$15,$14,$12,$9,$10,toupper(substr($18,15+i,length($18)-28-(2*i))),$21,$20,$16}' | sort -t, -k1n,1 -k2n,2 -k3n,3 | uniq | sed '1c\id,entry_version,sequence_version,species,organism,protein,oligo,peptide,start,end' > id,entry_version,sequence_version,species,organism,protein,oligo,peptide,start,end.csv &
```


```python3

import pandas as pd
df = pd.read_csv('id,entry_version,sequence_version,species,organism,protein,oligo,peptide,start,end.csv')
df = (df
    .sort_values(['id', 'entry_version', 'sequence_version'], ascending=[True, False, False])
    .drop_duplicates(subset='id', keep='first')
    .drop(columns=['entry_version', 'sequence_version'])
)
df.to_csv('id,species,organism,protein,oligo,peptide,start,end-clean.csv',index=False)
```



blastp the PEPTIDES

```bash
awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}(NR>1){print ">"$1;print $6}' id,species,organism,protein,oligo,peptide,start,end-clean.csv > id,species,organism,protein,oligo,peptide,start,end-clean.faa
```


   'qaccver saccver pident length mismatch gapopen qstart qend sstart send
   evalue bitscore', which is equivalent to the keyword 'std'

Make sure that the memory is appropriate for the reference.

```bash

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
--job-name=blast1 --time=14-0 --nodes=1 --ntasks=8 --mem=60GB \
--output=${PWD}/blastp.viral.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
--wrap="module load blast; blastp -db /francislab/data1/refs/refseq/viral-20260206/viral -query id,species,organism,protein,oligo,peptide,start,end-clean.faa -outfmt '6 std staxids sscinames sskingdoms' -out id,species,organism,protein,oligo,peptide,start,end-clean.blastp.viral.tsv -num_threads 8"

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
--job-name=blast2 --time=14-0 --nodes=1 --ntasks=16 --mem=120GB \
--output=${PWD}/blastp.viral.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
--wrap="module load blast; blastp -db /francislab/data1/refs/blast/refseq_protein -query id,species,organism,protein,oligo,peptide,start,end-clean.faa -outfmt '6 std staxids sscinames sskingdoms' -out id,species,organism,protein,oligo,peptide,start,end-clean.blastp.refseq_protein.tsv -num_threads 16"

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
--job-name=blast3 --time=14-0 --nodes=1 --ntasks=8 --mem=60GB \
--output=${PWD}/blastp.viral.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
--wrap="module load blast; blastp -db /francislab/data1/refs/blast/refseq_select_prot -query id,species,organism,protein,oligo,peptide,start,end-clean.faa -outfmt '6 std staxids sscinames sskingdoms' -out id,species,organism,protein,oligo,peptide,start,end-clean.blastp.refseq_select_prot.tsv -num_threads 8"


sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
--job-name=blast4 --time=14-0 --nodes=1 --ntasks=8 --mem=60GB \
--output=${PWD}/blastp.viral.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
--wrap="module load blast; blastp -db /francislab/data1/refs/refseq/viral-20260206/viral -query id,species,organism,protein,oligo,peptide,start,end-clean.faa -out id,species,organism,protein,oligo,peptide,start,end-clean.blastp.viral.shorte1000ws2.txt -num_threads 8 -task blastp-short -evalue 1000 -word_size 2 -seg no -max_target_seqs 10"

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
--job-name=blast5 --time=14-0 --nodes=1 --ntasks=8 --mem=60GB \
--output=${PWD}/blastp.viral.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
--wrap="module load blast; blastp -db /francislab/data1/refs/refseq/viral-20260206/viral -query id,species,organism,protein,oligo,peptide,start,end-clean.faa -outfmt '6 std staxids sscinames sskingdoms' -out id,species,organism,protein,oligo,peptide,start,end-clean.blastp.viral.shorte1000ws2PAM30.tsv -num_threads 8 -task blastp-short -evalue 1000 -word_size 2 -seg no -max_target_seqs 100 -matrix PAM30"



sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \

#	expecting 115753 which will mean that everything matched something

cut -f1 id,species,organism,protein,oligo,peptide,start,end-clean.blastp.viral.tsv | uniq | wc -l
#	114855. short. Which ones missed and why?

cut -f1 id,species,organism,protein,oligo,peptide,start,end-clean.blastp.refseq_select_prot.tsv | uniq | wc -l
#	looks like this is all bacteria. Its finding matches, but they're all bacteria.

cut -f1 id,species,organism,protein,oligo,peptide,start,end-clean.blastp.refseq_protein.tsv | uniq | wc -l
#	TAKING WAY WAY TOO LONG. 6000 queries in 35 hours. Need to break up


cut -f1 id,species,organism,protein,oligo,peptide,start,end-clean.blastp.viral.tsv | uniq | wc -l
114855

cut -f1 id,species,organism,protein,oligo,peptide,start,end-clean.blastp.viral.shorte1000ws2.tsv | uniq | wc -l
115690

cut -f1 id,species,organism,protein,oligo,peptide,start,end-clean.blastp.viral.shorte1000ws2PAM30.tsv | uniq | wc -l
115690

#	closer


```






---

```bash
wc -l id,species,organism,protein,oligo,peptide,start,end-clean.faa
231506

head -n 115752 id,species,organism,protein,oligo,peptide,start,end-clean.faa > id,species,organism,protein,oligo,peptide,start,end-clean.1of2.faa
tail -n 115754 id,species,organism,protein,oligo,peptide,start,end-clean.faa > id,species,organism,protein,oligo,peptide,start,end-clean.2of2.faa

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
--job-name=blast1 --time=14-0 --nodes=1 --ntasks=32 --mem=240GB \
--output=${PWD}/blastp.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
--wrap="module load blast; blastp -db /francislab/data1/refs/blast/nr -query id,species,organism,protein,oligo,peptide,start,end-clean.1of2.faa -outfmt '6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore staxids sscinames sskingdoms' -out id,species,organism,protein,oligo,peptide,start,end-clean.1of2.blastp.nr.tsv -num_threads 32"

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
--job-name=blast2 --time=14-0 --nodes=1 --ntasks=32 --mem=240GB \
--output=${PWD}/blastp.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
--wrap="module load blast; blastp -db /francislab/data1/refs/blast/nr -query id,species,organism,protein,oligo,peptide,start,end-clean.2of2.faa -outfmt '6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore staxids sscinames sskingdoms' -out id,species,organism,protein,oligo,peptide,start,end-clean.2of2.blastp.nr.tsv -num_threads 32"

```

This will include taxids.

Filter blast results based only on, hmmm, 



This won't include the family and what not.

I think that's why I wrote an app for that.

Blast is missing a lot and including a lot of duplicate alignments. This won't be helpful.

canceling

What about making a ref from RefSeq viral fna?






---

```bash 
zcat VIR3_clean.csv.gz | sed -e 's/Chikungunya virus (CHIKV)/Chikungunya virus/g' \
  -e 's/Eastern equine encephalitis virus (EEEV) (Eastern equine encephalomyelitis virus)/Eastern equine encephalitis virus/g' \
  -e 's/Uukuniemi virus (Uuk)/Uukuniemi virus/g' \
  -e 's/Human torovirus (HuTV)/Human torovirus/g' \
  -e 's/BK polyomavirus (BKPyV)/BK polyomavirus/g' \
  -e 's/Human cytomegalovirus (HHV-5) (Human herpesvirus 5)/Human herpesvirus 5/g' \
  -e 's/New York virus (NYV)/New York virus/g' \
  -e 's/Capsid scaffolding protein (Capsid protein P40) (Protease precursor) (pPR) (Virion structural gene 33 protein) \[Cleaved into: Assemblin (EC 3.4.21.97) (Capsid protein VP24) (Protease); Assembly protein (Capsid protein VP22A)\]/Capsid protein P40/g' \
  -e 's/Tripartite terminase subunit UL15 homolog (DNA-packaging protein 45) (Terminase large subunit) \[Cleaved into: Gene 42 protein\]/Tripartite terminase subunit UL15 homolog/g' \
| awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}{print $17,$12,$10,$11,$18,$21,$20,$16}' | sort -t, -k1n,1 | uniq > v900.csv &
```

```
zcat VIR3_clean.csv.gz | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}{print $14}'

zcat VIR3_clean.csv.gz \

  | tail -n +2 | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}{gsub(/,/,"",$5);gsub(/,/,"",$10);print $17,$12,$10,$5}' | sort -t, -k1,1 | uniq > VIR3_clean.id_species_protein_gene.uniq.csv
sed -i '1iid,species,protein,gene' VIR3_clean.id_species_protein_gene.uniq.csv
sed -i '/89962,O/d' VIR3_clean.id_species_protein_gene.uniq.csv
chmod a-w VIR3_clean.id_species_protein_gene.uniq.csv
```

