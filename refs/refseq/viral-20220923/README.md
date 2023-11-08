
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




