
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
10 Protein names
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





zcat VIR3_clean.csv.gz | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}{print $17,$15,$14,$12,$10,$18,$21,$20,$16}' | sort -t, -k1n,1 -k2n,2 -k3n,3 | uniq | sed '1c\id,entry_version,sequence_version,species,protein,oligo,peptide,start,end' > id,entry_version,sequence_version,species,protein,oligo,peptide,start,end.csv &

```



THERE ARE STILL COMMAS IN THE DATA SO BEWARE




take the highest sequence version and entry version for each id, then drop the versions and keep the rest.

```python3

import pandas as pd
df = pd.read_csv('id,entry_version,sequence_version,species,protein,oligo,peptide,start,end.csv')
df = (df
    .sort_values(['id', 'entry_version', 'sequence_version'], ascending=[True, False, False])
    .drop_duplicates(subset='id', keep='first')
    .drop(columns=['entry_version', 'sequence_version'])
)
df.to_csv('id,species,protein,oligo,peptide,start,end-clean.csv',index=False)

```














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

---

zcat VIR3_clean.csv.gz | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}{print $14}'

zcat VIR3_clean.csv.gz \

  | tail -n +2 | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}{gsub(/,/,"",$5);gsub(/,/,"",$10);print $17,$12,$10,$5}' | sort -t, -k1,1 | uniq > VIR3_clean.id_species_protein_gene.uniq.csv
sed -i '1iid,species,protein,gene' VIR3_clean.id_species_protein_gene.uniq.csv
sed -i '/89962,O/d' VIR3_clean.id_species_protein_gene.uniq.csv
chmod a-w VIR3_clean.id_species_protein_gene.uniq.csv
```

