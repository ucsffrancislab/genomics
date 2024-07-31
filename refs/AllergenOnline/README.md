
#	AllergenOnline

http://www.allergenonline.org/






```
"Species","Common","IUIS Allergen","Type","Group","Allergenicity","Length","Accession","GI#","1st Version"

echo "accession,species,type" > AllergenGroups.csv
awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}(NR>1 && $8!="\"\""){split($8,a,".");print a[1],$1,$4}' AllergenOnline.csv | tr -d \" | sort -t, -k1,1 >> AllergenGroups.csv

```





```

mkdir fastas
for acc in $( awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")"}{print $8}' AllergenOnline.csv | tr -d \" | tail -n +2 ) ; do
echo $acc
efetch -db protein -format fasta -id $acc > fastas/${acc}.faa
done

```

Some of these fasta files have complex sequence names.

I'm gonna copy them to raw/ and then modify to just be the fasta name.

```
cp -r fastas raw_fastas
chmod -w raw_fastas/*

for f in fastas/*faa ; do
echo $f
base=$( basename $f .faa )
sed -i "1s/^.*$/>${base}/" $f
done

cat fastas/*faa > AllergenOnline.faa

```















---


```
# | sed  -e '/^>/s/[],()\/[]//g' -e '/^>/s/->//g' -e '/^>/s/ /_/g' -e 's/'\''//g' -e '/^>/s/\(^.\{1,51\}\).*/\1/' -e '/^>/s/>\(.*\)$/>\1 \1/g'

cat AllergenOnline/*.faa | sed -e '/^>/s/[], ():;,=\/[]/_/g' -e '/^>/s/__/_/g' -e '/^>/s/\(^.\{1,51\}\).*/\1/' > AllergenOnline.faa
makeblastdb -in AllergenOnline.faa -input_type fasta -dbtype prot -out AllergenOnline -title AllergenOnline -parse_seqids

```
