
#	refs/refseq/viral-20231129


```
zcat viral.?.protein.faa.gz | grep "^>" | sed -e 's/[],()\/[]//g' -e "s/'//g" -e 's/->//g' -e 's/ /_/g' > viral.protein.names.txt

#-e 's/\(^.\{1,51\}\).*/\1/' 



echo "virus,accession,with_version,with_description" > virus_translation_table.20231122.csv
sed -e 's/^>//' viral.protein.names.txt | awk 'BEGIN{FS=OFS="_"}{print $1,$2","$0}' | awk 'BEGIN{FS=".";OFS=","}{print $1,$0}' | sort | awk 'BEGIN{FS=OFS=","}{ cmd="sqlite3 /francislab/data1/refs/taxonomy_tree/20231122/taxonomy.sqlite \"select t.tax_name from accession a join taxa t on t.taxid=a.taxid where a.accession== \047"$1"\047\""; cmd | getline r; close(cmd) ; print r,$1,$2,$3; r="" }' >> virus_translation_table.20231122.csv &

```

```
echo "order,family,virus,accession,with_version,with_description" > virus_taxonomy_tree_translation_table.20231122.csv
sed -e 's/^>//' viral.protein.names.txt | awk 'BEGIN{FS=OFS="_"}{print $1,$2","$0}' | awk 'BEGIN{FS=".";OFS=","}{print $1,$0}' | sort | awk 'BEGIN{FS=OFS=","}{ cmd="sqlite3 /francislab/data1/refs/taxonomy_tree/20231122/taxonomy.sqlite \"select t.tax_name, t.parent_taxid from accession a join taxa t on t.taxid=a.taxid where a.accession== \047"$1"\047\""; cmd | getline results; close(cmd) ; split(results,a,"|"); virus_name=a[1]; parent_taxid=a[2]; do{ cmd="sqlite3 /francislab/data1/refs/taxonomy_tree/20231122/taxonomy.sqlite \"select lineage_level, tax_name, parent_taxid from taxa where taxid="parent_taxid"\""; cmd | getline results; close(cmd) ; split(results,a,"|"); parent_taxid=a[3];
if(a[1]=="family"){family_name=a[2]}
if(a[1]=="order"){order_name=a[2]}
if(a[1]=="class"){class_name=a[2]}
if(a[1]=="phylum"){phylum_name=a[2]}
if(a[2]=="root"){
if(family_name==""){if(class_name==""){family_name="Unknown Family"}else{family_name=class_name}}
if(order_name==""){if(phylum_name==""){order_name="Unknown Order"}else{order_name=phylum_name}}
}
} while( ( order_name == "" ) || ( family_name == "" ) )
print order_name,family_name,virus_name,$1,$2,$3; order_name=family_name=virus_name=class_name=phylum_name="" }' >> virus_taxonomy_tree_translation_table.20231122.csv &

```


```
sqlite3 /francislab/data1/refs/taxonomy_tree/20231122/taxonomy.sqlite "select a.accession, t1.taxid, t1.tax_name, t1.lineage_level, t2.taxid, t2.tax_name, t2.lineage_level, t3.taxid, t3.tax_name, t3.lineage_level, t4.taxid, t4.tax_name, t4.lineage_level, t5.taxid, t5.tax_name, t5.lineage_level, t6.taxid, t6.tax_name, t6.lineage_level from accession a join taxa t1 on t1.taxid = a.taxid join taxa t2 on t2.taxid = t1.parent_taxid join taxa t3 on t3.taxid = t2.parent_taxid join taxa t4 on t4.taxid = t3.parent_taxid join taxa t5 on t5.taxid = t4.parent_taxid join taxa t6 on t6.taxid = t5.parent_taxid where a.accession = 'NP_037662'"

sqlite3 /francislab/data1/refs/taxonomy_tree/20231122/taxonomy.sqlite "select a.accession, t1.taxid, t1.tax_name, t1.lineage_level, t2.taxid, t2.tax_name, t2.lineage_level, t3.taxid, t3.tax_name, t3.lineage_level, t4.taxid, t4.tax_name, t4.lineage_level, t5.taxid, t5.tax_name, t5.lineage_level, t6.taxid, t6.tax_name, t6.lineage_level, t7.taxid, t7.tax_name, t7.lineage_level, t8.taxid, t8.tax_name, t8.lineage_level, t9.taxid, t9.tax_name, t9.lineage_level from accession a join taxa t1 on t1.taxid = a.taxid join taxa t2 on t2.taxid = t1.parent_taxid join taxa t3 on t3.taxid = t2.parent_taxid join taxa t4 on t4.taxid = t3.parent_taxid join taxa t5 on t5.taxid = t4.parent_taxid join taxa t6 on t6.taxid = t5.parent_taxid join taxa t7 on t7.taxid = t6.parent_taxid join taxa t8 on t8.taxid = t7.parent_taxid join taxa t9 on t9.taxid = t8.parent_taxid where a.accession = 'NP_037580'"
```



```

sqlite3 /francislab/data1/refs/taxonomy_tree/20231122/taxonomy.sqlite "select a.accession, t1.taxid, t1.tax_name, t1.lineage_level, t2.taxid, t2.tax_name, t2.lineage_level, t3.taxid, t3.tax_name, t3.lineage_level, t4.taxid, t4.tax_name, t4.lineage_level, t5.taxid, t5.tax_name, t5.lineage_level, t6.taxid, t6.tax_name, t6.lineage_level, t7.taxid, t7.tax_name, t7.lineage_level, t8.taxid, t8.tax_name, t8.lineage_level, t9.taxid, t9.tax_name, t9.lineage_level from accession a join taxa t1 on t1.taxid = a.taxid join taxa t2 on t2.taxid = t1.parent_taxid join taxa t3 on t3.taxid = t2.parent_taxid join taxa t4 on t4.taxid = t3.parent_taxid join taxa t5 on t5.taxid = t4.parent_taxid join taxa t6 on t6.taxid = t5.parent_taxid join taxa t7 on t7.taxid = t6.parent_taxid join taxa t8 on t8.taxid = t7.parent_taxid join taxa t9 on t9.taxid = t8.parent_taxid where a.accession = 'NP_037662'"

NP_037662|2681618|Escherichia phage HK022|no rank|10742|Shamshuipovirus HK022|species|2843034|Shamshuipovirus|genus|2842527|Hendrixvirinae|subfamily|2731619|Caudoviricetes|class|2731618|Uroviricota|phylum|2731360|Heunggongvirae|kingdom|2731341|Duplodnaviria|clade|10239|Viruses|superkingdom

sqlite3 /francislab/data1/refs/taxonomy_tree/20231122/taxonomy.sqlite "select a.accession, t1.taxid, t1.tax_name, t1.lineage_level, t2.taxid, t2.tax_name, t2.lineage_level, t3.taxid, t3.tax_name, t3.lineage_level, t4.taxid, t4.tax_name, t4.lineage_level, t5.taxid, t5.tax_name, t5.lineage_level, t6.taxid, t6.tax_name, t6.lineage_level, t7.taxid, t7.tax_name, t7.lineage_level, t8.taxid, t8.tax_name, t8.lineage_level, t9.taxid, t9.tax_name, t9.lineage_level from accession a join taxa t1 on t1.taxid = a.taxid join taxa t2 on t2.taxid = t1.parent_taxid join taxa t3 on t3.taxid = t2.parent_taxid join taxa t4 on t4.taxid = t3.parent_taxid join taxa t5 on t5.taxid = t4.parent_taxid join taxa t6 on t6.taxid = t5.parent_taxid join taxa t7 on t7.taxid = t6.parent_taxid join taxa t8 on t8.taxid = t7.parent_taxid join taxa t9 on t9.taxid = t8.parent_taxid where a.accession = 'NP_040188'"

NP_040188|10335|Human alphaherpesvirus 3|no rank|3050294|Varicellovirus humanalpha3|species|10319|Varicellovirus|genus|10293|Alphaherpesvirinae|subfamily|3044472|Orthoherpesviridae|family|548681|Herpesvirales|order|2731363|Herviviricetes|class|2731361|Peploviricota|phylum|2731360|Heunggongvirae|kingdom

sqlite3 /francislab/data1/refs/taxonomy_tree/20231122/taxonomy.sqlite "select a.accession, t1.taxid, t1.tax_name, t1.lineage_level, t2.taxid, t2.tax_name, t2.lineage_level, t3.taxid, t3.tax_name, t3.lineage_level, t4.taxid, t4.tax_name, t4.lineage_level, t5.taxid, t5.tax_name, t5.lineage_level, t6.taxid, t6.tax_name, t6.lineage_level, t7.taxid, t7.tax_name, t7.lineage_level, t8.taxid, t8.tax_name, t8.lineage_level, t9.taxid, t9.tax_name, t9.lineage_level from accession a join taxa t1 on t1.taxid = a.taxid join taxa t2 on t2.taxid = t1.parent_taxid join taxa t3 on t3.taxid = t2.parent_taxid join taxa t4 on t4.taxid = t3.parent_taxid join taxa t5 on t5.taxid = t4.parent_taxid join taxa t6 on t6.taxid = t5.parent_taxid join taxa t7 on t7.taxid = t6.parent_taxid join taxa t8 on t8.taxid = t7.parent_taxid join taxa t9 on t9.taxid = t8.parent_taxid where a.accession = 'NP_037580'"

NP_037580|111470|Diaporthe ambigua RNA virus 1|species|35278|unclassified ssRNA positive-strand viruses|clade|439490|unclassified ssRNA viruses|no rank|2585030|unclassified Riboviria|no rank|2559587|Riboviria|clade|10239|Viruses|superkingdom|1|root|no rank|1|root|no rank|1|root|no rank


sqlite3 /francislab/data1/refs/taxonomy_tree/20231122/taxonomy.sqlite "select a.accession, t1.taxid, t1.tax_name, t1.lineage_level, t2.taxid, t2.tax_name, t2.lineage_level, t3.taxid, t3.tax_name, t3.lineage_level, t4.taxid, t4.tax_name, t4.lineage_level, t5.taxid, t5.tax_name, t5.lineage_level, t6.taxid, t6.tax_name, t6.lineage_level, t7.taxid, t7.tax_name, t7.lineage_level, t8.taxid, t8.tax_name, t8.lineage_level, t9.taxid, t9.tax_name, t9.lineage_level from accession a join taxa t1 on t1.taxid = a.taxid join taxa t2 on t2.taxid = t1.parent_taxid join taxa t3 on t3.taxid = t2.parent_taxid join taxa t4 on t4.taxid = t3.parent_taxid join taxa t5 on t5.taxid = t4.parent_taxid join taxa t6 on t6.taxid = t5.parent_taxid join taxa t7 on t7.taxid = t6.parent_taxid join taxa t8 on t8.taxid = t7.parent_taxid join taxa t9 on t9.taxid = t8.parent_taxid where a.accession = 'YP_003934917'"

YP_003934917|907191|Raspberry latent virus|species|2788865|unclassified Reovirales|no rank|2732541|Reovirales|order|2732459|Resentoviricetes|class|2732405|Duplornaviricota|phylum|2732396|Orthornavirae|kingdom|2559587|Riboviria|clade|10239|Viruses|superkingdom|1|root|no rank


sqlite3 /francislab/data1/refs/taxonomy_tree/20231122/taxonomy.sqlite "select a.accession, t1.taxid, t1.tax_name, t1.lineage_level, t2.taxid, t2.tax_name, t2.lineage_level, t3.taxid, t3.tax_name, t3.lineage_level, t4.taxid, t4.tax_name, t4.lineage_level, t5.taxid, t5.tax_name, t5.lineage_level, t6.taxid, t6.tax_name, t6.lineage_level, t7.taxid, t7.tax_name, t7.lineage_level, t8.taxid, t8.tax_name, t8.lineage_level, t9.taxid, t9.tax_name, t9.lineage_level from accession a join taxa t1 on t1.taxid = a.taxid join taxa t2 on t2.taxid = t1.parent_taxid join taxa t3 on t3.taxid = t2.parent_taxid join taxa t4 on t4.taxid = t3.parent_taxid join taxa t5 on t5.taxid = t4.parent_taxid join taxa t6 on t6.taxid = t5.parent_taxid join taxa t7 on t7.taxid = t6.parent_taxid join taxa t8 on t8.taxid = t7.parent_taxid join taxa t9 on t9.taxid = t8.parent_taxid where a.accession = 'YP_009664708'"

YP_009664708|226584|Iguanid herpesvirus 2|species|860343|unclassified Herpesvirales|no rank|548681|Herpesvirales|order|2731363|Herviviricetes|class|2731361|Peploviricota|phylum|2731360|Heunggongvirae|kingdom|2731341|Duplodnaviria|clade|10239|Viruses|superkingdom|1|root|no rank

```


Not sure where this comes from. sqlite? quote in data?
```
????


Error: no such column: Geplafuvirales
Error: no such column: Geplafuvirales
Error: no such column: Geplafuvirales
Error: no such column: Geplafuvirales
Error: no such column: Cirlivirales
Error: no such column: Cirlivirales
Error: no such column: Cirlivirales
Error: no such column: Cirlivirales
Error: no such column: Geplafuvirales
Error: no such column: root
Error: no such column: root
Error: no such column: root

```






```
nohup sed -e 's/^>//' viral.protein.names.txt | awk 'BEGIN{FS=OFS="_"}{print $1,$2","$0}' | awk 'BEGIN{FS=".";OFS=","}{print $1,$0}' | sort | awk 'BEGIN{FS=OFS=","}{ cmd="sqlite3 /francislab/data1/refs/taxonomy_tree/20231122/taxonomy.sqlite \"select t.tax_name, t.parent_taxid from accession a join taxa t on t.taxid=a.taxid where a.accession== \047"$1"\047\""; 
print cmd; cmd | getline results; close(cmd) ; print results; split(results,a,"|"); virus_name=a[1]; parent_taxid=a[2]; do{ cmd="sqlite3 /francislab/data1/refs/taxonomy_tree/20231122/taxonomy.sqlite \"select lineage_level, tax_name, parent_taxid from taxa where taxid="parent_taxid"\""; print cmd; cmd | getline results; close(cmd) ; print results; split(results,a,"|"); parent_taxid=a[3];
if(a[1]=="family"){family_name=a[2]}
if(a[1]=="order"){order_name=a[2]}
if(a[1]=="class"){class_name=a[2]}
if(a[1]=="phylum"){phylum_name=a[2]}
if(a[2]=="root"){
if(family_name==""){if(class_name==""){family_name="Unknown Family"}else{family_name=class_name}}
if(order_name==""){if(phylum_name==""){order_name="Unknown Order"}else{order_name=phylum_name}}
}
} while( ( order_name == "" ) || ( family_name == "" ) )
print order_name,family_name,virus_name,$1,$2,$3; order_name=family_name=virus_name=class_name=phylum_name="" }' >> testing &

```











```
zcat viral.?.protein.faa.gz | sed -e '/^>/s/[];,()\/[]//g' -e "/^>/s/'//g" -e '/^>/s/->//g' -e '/^>/s/ /_/g' | gzip > viral.protein.faa.gz
chmod 400 viral.protein.faa.gz
zgrep "^>" viral.protein.faa.gz | sed 's/^>//' > viral.protein.names.txt
chmod 400 viral.protein.names.txt
mkdir viral.protein/
faSplit byname viral.protein.faa.gz viral.protein/
```


```
module load samtools

cat viral.protein/*_Human*herpes*.fa | sed  -e '/^>/s/Human_.*herpesvirus_\(.*\)$/HHV\1/' -e '/^>/s/HHV4_type_2/HHV4t2/' | awk 'BEGIN{FS=OFS="_"}(/^>/){s=$1"_"$2"_"$NF;for(i=3;i<NF;i++){s=s"_"$i}print s}(!/^>/){print}' | sed  -e '/^>/s/\(^.\{1,51\}\).*/\1/' -e '/^>/s/>\(.*\)$/>\1 \1/g' > Human_herpes_proteins.faa
samtools faidx Human_herpes_proteins.faa
chmod 400 Human_herpes_proteins.faa*

cat viral.protein/*_Variola_virus.fa | sed  -e '/^>/s/\(^.\{1,51\}\).*/\1/' -e '/^>/s/>\(.*\)$/>\1 \1/g' > Variola_virus_proteins.faa
samtools faidx Variola_virus_proteins.faa
chmod 400 Variola_virus_proteins.faa*

cat viral.protein/*_Human_*.fa | sed  -e '/^>/s/\(^.\{1,51\}\).*/\1/' -e '/^>/s/>\(.*\)$/>\1 \1/g' > All_Human_proteins.faa
samtools faidx All_Human_proteins.faa
chmod 400 All_Human_proteins.faa*

zcat viral.protein.faa.gz | sed -e '/^>/s/\(^.\{1,51\}\).*/\1/' -e '/^>/s/>\(.*\)$/>\1 \1/g' > All_proteins.faa
samtools faidx All_proteins.faa
chmod 400 All_proteins.faa*

```







##	20231208

```
echo "phylum,class,order,family,subfamily,genus,virus,accession,with_version,with_description" > virus_taxonomy_tree_translation_table.20231129.20231122.csv
nohup sed -e 's/^>//' viral.protein.names.txt | awk 'BEGIN{FS=OFS="_"}{print $1,$2","$0}' | awk 'BEGIN{FS=".";OFS=","}{print $1,$0}' | sort | awk 'BEGIN{FS=OFS=","}{ cmd="sqlite3 /francislab/data1/refs/taxonomy_tree/20231122/taxonomy.sqlite \"select t.tax_name, t.parent_taxid from accession a join taxa t on t.taxid=a.taxid where a.accession== \047"$1"\047\""; 
cmd | getline results; close(cmd) ; split(results,a,"|"); virus_name=a[1]; parent_taxid=a[2]; 
do{ cmd="sqlite3 /francislab/data1/refs/taxonomy_tree/20231122/taxonomy.sqlite \"select lineage_level, tax_name, parent_taxid from taxa where taxid="parent_taxid"\""; 
cmd | getline results; close(cmd); split(results,a,"|"); parent_taxid=a[3];
if(a[1]=="genus"){genus_name=a[2]}
if(a[1]=="subfamily"){subfamily_name=a[2]}
if(a[1]=="family"){family_name=a[2]}
if(a[1]=="order"){order_name=a[2]}
if(a[1]=="class"){class_name=a[2]}
if(a[1]=="phylum"){phylum_name=a[2]}
if(a[2]=="root"){ 
if(genus_name==""){genus_name="Unknown Genus"} 
if(subfamily_name==""){subfamily_name="Unknown SubFamily"} 
if(family_name==""){family_name="Unknown Family"} 
if(order_name==""){order_name="Unknown Order"} 
if(class_name==""){class_name="Unknown Class"} 
if(phylum_name==""){phylum_name="Unknown Phylum"} 
} } while( ( phylum_name == "" ) || ( class_name == "" ) || ( order_name == "" ) || ( family_name == "" ) || ( subfamily_name == "" ) || ( genus_name == "" ) )
print phylum_name,class_name,order_name,family_name,subfamily_name,genus_name,virus_name,$1,$2,$3; 
phylum_name=class_name=order_name=family_name=subfamily_name=genus_name=virus_name="" }' >> virus_taxonomy_tree_translation_table.20231129.20231122.csv &

```


if(a[1]=="order"){order_name=a[2]}
if(a[1]=="class"){class_name=a[2]}
if(a[1]=="phylum"){phylum_name=a[2]}
if(family_name==""){if(class_name==""){family_name="Unknown Family"}else{family_name=class_name}}
if(order_name==""){if(phylum_name==""){order_name="Unknown Order"}else{order_name=phylum_name}}
} while( ( order_name == "" ) || ( family_name == "" ) )
print order_name,family_name,virus_name,$1,$2,$3; order_name=family_name=virus_name=class_name=phylum_name="" }' >> testing &



##	20231209


```
nohup build_virus_taxonomy_tree_translation_table.bash &
```


Still got these. No idea why.

```
cat /francislab/data1/refs/refseq/viral-20231129/nohup.out 
Error: no such column: root
Error: no such column: root
Error: no such column: root
Error: no such column: root
Error: no such column: root
Error: no such column: root
Error: no such column: root
Error: no such column: root
```


This may got to stderr and not stdout so not helping
```
grep "Error: no such column" virus_taxonomy_tree_translation_table.20231129.20231122.test.csv 
```



