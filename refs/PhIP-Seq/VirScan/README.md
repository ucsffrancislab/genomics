
#	refs/PhIP-Seq/VirScan



```
1,
2 - Aclstr50,
3 - Bclstr50,
4 - Entry,
5 - Gene names,
6 - Gene ontology (GO),
7 - Gene ontology IDs,
8 - Genus,
9 - Organism,
10 - Protein names,
11 - Sequence,
12 - Species,
13 - Subcellular location,
14 - Version (entry),
15 - Version (sequence),
16 - end,
17 - id,
18 - oligo,
19 - source,
20 - start,
21 - peptide
```


```bash
zcat VIR3_clean.csv.gz | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}( NR==1 || $12 ~ /^Influenza/ ){ print $17,$12,$10,toupper($21); }' | sort -t, -k1n,1 -k2,2 -k3,3 | uniq > VIR3_clean.id_fluspecies_protein_upper_peptide.uniq.csv

```
