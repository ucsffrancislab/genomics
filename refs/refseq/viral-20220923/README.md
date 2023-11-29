
#	


```
faSplit byname viral.protein.faa.gz viral.protein/


zcat viral.*.genomic.fna.gz | sed -e '/^>/s/[ \/,]/_/g' -e '/^>/s/\(^.\{1,250\}\).*/\1/' | gzip > viral.genomic.fna.gz
mkdir viral.genomic
faSplit byname viral.genomic.fna.gz viral.genomic/
```




##	20231107


```
echo "virus,accession,with_version,with_description" > herpes_protein_virus_translation_table.csv
grep "_Human_" viral.protein.names.txt | grep herpes | sed -e 's/^>//' | awk 'BEGIN{FS=OFS="_"}{print $1,$2","$0}' | awk 'BEGIN{FS=".";OFS=","}{print $1,$0}' | awk 'BEGIN{FS="_Human";OFS=","}{print "Human"$NF,$0}' | sort >> herpes_protein_virus_translation_table.csv

cut -d, -f1 herpes_protein_virus_translation_table.csv | uniq> herpes_virus_abbreviation_translation_table.csv 
```





##	20231129



```
echo "virus,accession,with_version,with_description" > virus_translation_table.20231122.csv
sed -e 's/^>//' viral.protein.names.txt | awk 'BEGIN{FS=OFS="_"}{print $1,$2","$0}' | awk 'BEGIN{FS=".";OFS=","}{print $1,$0}' | sort | awk 'BEGIN{FS=OFS=","}{ cmd="sqlite3 /francislab/data1/refs/taxonomy_tree/20231122/taxonomy.sqlite \"select t.tax_name from accession a join taxa t on t.taxid=a.taxid where a.accession== \047"$1"\047\""; cmd | getline r; close(cmd) ; print r,$1,$2,$3; r="" }' >> virus_translation_table.20231122.csv

```

```
echo "virus,accession,with_version,with_description" > virus_translation_table.20200507.csv
sed -e 's/^>//' viral.protein.names.txt | awk 'BEGIN{FS=OFS="_"}{print $1,$2","$0}' | awk 'BEGIN{FS=".";OFS=","}{print $1,$0}' | sort | awk 'BEGIN{FS=OFS=","}{ cmd="sqlite3 /francislab/data1/refs/taxonomy_tree/20200507/taxonomy.sqlite \"select t.tax_name from accession a join taxa t on t.ncbi_taxid=a.taxid_id where a.accession== \047"$1"\047\""; cmd | getline r; close(cmd) ; print r,$1,$2,$3; r="" }' >> virus_translation_table.20200507.csv

```



