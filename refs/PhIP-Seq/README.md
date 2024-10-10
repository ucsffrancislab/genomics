
#	refs/PhIP-Seq


```
ln -s /c4/home/gwendt/github/ucsffrancislab/PhIP-Seq/Elledge/VIR3_clean.csv.gz
ln -s /c4/home/gwendt/github/ucsffrancislab/PhIP-Seq/Elledge/vir3.fasta

zcat VIR3_clean.csv.gz | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")"}(NR>1){o=substr($18,17,168);print $17","o}' | uniq | sort -t, -k1n,1 | uniq | awk -F, '{print ">"$1;print $2}' | gzip > VIR3_clean.uniq.fna.gz
bowtie-build VIR3_clean.uniq.fna.gz VIR3_clean
bowtie2-build VIR3_clean.uniq.fna.gz VIR3_clean
```


HAP_LExP_Peptide_Oligo_Metadata_for_Distribution.csv.gz was downloaded from box. I think Stephen uploaded it. Not sure where it came from.

```
#zcat HAP_LExP_Peptide_Oligo_Metadata_for_Distribution.csv.gz | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}(NR>1 && $4=="HAPLib.2"){o=substr($8,18,168);print ">"$2;print o}' | tr -d \" | gzip > HAP.fna.gz

zcat HAP_LExP_Peptide_Oligo_Metadata_for_Distribution.csv.gz | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}(NR>1 && $4=="\"HAPLib.1\""){o=substr($8,18,168);print ">"$2;print o}' | gzip > HAPLib.1.fna.gz

module load bowtie
bowtie-build HAPLib.1.fna.gz HAPLib.1
chmod 440 HAP*ebwt

module load bowtie2
bowtie2-build HAPLib.1.fna.gz HAPLib.1
chmod 440 HAP*bt2

zcat HAP_LExP_Peptide_Oligo_Metadata_for_Distribution.csv.gz | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}(NR>1 && $4=="\"HAPLib.2\""){o=substr($8,18,168);print ">"$2;print o}' | gzip > HAPLib.2.fna.gz

module load bowtie
bowtie-build HAPLib.2.fna.gz HAPLib.2
chmod 440 HAP*ebwt

module load bowtie2
bowtie2-build HAPLib.2.fna.gz HAPLib.2
chmod 440 HAP*bt2

zcat HAP_LExP_Peptide_Oligo_Metadata_for_Distribution.csv.gz | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}(NR>1 && $4=="\"LExPELib.1\""){o=substr($8,18,168);print ">"$2;print o}' | gzip > LExPELib.1.fna.gz

module load bowtie
bowtie-build LExPELib.1.fna.gz LExPELib.1
chmod 440 LEx*ebwt

module load bowtie2
bowtie2-build LExPELib.1.fna.gz LExPELib.1
chmod 440 LEx*bt2

zcat HAP_LExP_Peptide_Oligo_Metadata_for_Distribution.csv.gz | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}(NR>1 && $4=="\"LExPELib.2\""){o=substr($8,18,168);print ">"$2;print o}' | gzip > LExPELib.2.fna.gz

module load bowtie
bowtie-build LExPELib.2.fna.gz LExPELib.2
chmod 440 LEx*ebwt

module load bowtie2
bowtie2-build LExPELib.2.fna.gz LExPELib.2
chmod 440 LEx*bt2
```


```
"","id","peptide","sub_library","Original_Entry_Sequence","Original_Entry","Original_Entry_Name","oligo_200","Variant","mutations",
"WT_peptide","UniProtKB_Entry","Reviewed","Entry Name","Protein names","Gene Names","Organism","Length","Chain","Organism (ID)",
"Taxonomic lineage","Taxonomic lineage (Ids)","UniProt_Sequence","UniProt_Seq_Identical"

```
```
zcat HAP_LExP_Peptide_Oligo_Metadata_for_Distribution.csv.gz | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}{print $2,$17}' | tr -d \" | sed -e 's/(.*)//g' -e 's/\s*$//' > HAP_id_virus.csv




zcat HAP_LExP_Peptide_Oligo_Metadata_for_Distribution.csv.gz | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}{gsub(/,/,"",$15);print $2,$15,$17}' | tr -d \" | sed -r -e 's/\([^(]*\)//g' -e 's/\s*,\s*/,/g' -e 's/\s+/ /g' -e 's/\s*$//' > HAP_id_protein_virus.csv

zcat HAP_LExP_Peptide_Oligo_Metadata_for_Distribution.csv.gz | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}{gsub(/,/,"",$15);print $2,$15,$17,$3,$24}' | tr -d \" | sed -r -e 's/\([^(]*\)//g' -e 's/\s*,\s*/,/g' -e 's/\s+/ /g' -e 's/\s*$//' > HAP_id_protein_virus_seqs_unique.csv


```



##	20240314


RAPSearch2 DOES NOT LIKE gzipped files.


```
zcat VIR3_clean.csv.gz | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")"}(NR>1){print $17","$21}' | uniq | sort -t, -k1n,1 | uniq | awk -F, '{print ">"$1;print $2}' > VIR3_clean.uniq.faa


~/github/zhaoyanswill/RAPSearch2/RAPSearch2.24_64bits/bin/prerapsearch -d VIR3_clean.uniq.faa -n VIR3_clean.uniq.RapSearch2.db


~/github/zhaoyanswill/RAPSearch2/RAPSearch2.24_64bits/bin/rapsearch -q 4440037.3.dna.fa -d nogCOGdomN95_db -o 4440037.3.dna-vs-nogCOGdomN95 -z 4
```



##	20240506


```
zcat VIR3_clean.fna.gz | cut -c1-70 | paste - - | sort | uniq | awk '{print $1;print $2}' | gzip > VIR3_clean.1-70.fna.gz
zcat VIR3_clean.fna.gz | cut -c1-75 | paste - - | sort | uniq | awk '{print $1;print $2}' | gzip > VIR3_clean.1-75.fna.gz
zcat VIR3_clean.fna.gz | cut -c1-80 | paste - - | sort | uniq | awk '{print $1;print $2}' | gzip > VIR3_clean.1-80.fna.gz
zcat VIR3_clean.fna.gz | cut -c1-84 | paste - - | sort | uniq | awk '{print $1;print $2}' | gzip > VIR3_clean.1-84.fna.gz
zcat VIR3_clean.fna.gz | cut -c1-85 | paste - - | sort | uniq | awk '{print $1;print $2}' | gzip > VIR3_clean.1-85.fna.gz
zcat VIR3_clean.fna.gz | cut -c1-90 | paste - - | sort | uniq | awk '{print $1;print $2}' | gzip > VIR3_clean.1-90.fna.gz
zcat VIR3_clean.fna.gz | cut -c1-95 | paste - - | sort | uniq | awk '{print $1;print $2}' | gzip > VIR3_clean.1-95.fna.gz
zcat VIR3_clean.fna.gz | cut -c1-100 | paste - - | sort | uniq | awk '{print $1;print $2}' | gzip > VIR3_clean.1-100.fna.gz
zcat VIR3_clean.fna.gz | cut -c1-110 | paste - - | sort | uniq | awk '{print $1;print $2}' | gzip > VIR3_clean.1-110.fna.gz
zcat VIR3_clean.fna.gz | cut -c1-120 | paste - - | sort | uniq | awk '{print $1;print $2}' | gzip > VIR3_clean.1-120.fna.gz
zcat VIR3_clean.fna.gz | cut -c1-130 | paste - - | sort | uniq | awk '{print $1;print $2}' | gzip > VIR3_clean.1-130.fna.gz
zcat VIR3_clean.fna.gz | cut -c1-140 | paste - - | sort | uniq | awk '{print $1;print $2}' | gzip > VIR3_clean.1-140.fna.gz
zcat VIR3_clean.fna.gz | cut -c1-150 | paste - - | sort | uniq | awk '{print $1;print $2}' | gzip > VIR3_clean.1-150.fna.gz
zcat VIR3_clean.fna.gz | cut -c1-160 | paste - - | sort | uniq | awk '{print $1;print $2}' | gzip > VIR3_clean.1-160.fna.gz

module load bowtie2
bowtie2-build VIR3_clean.1-75.fna.gz VIR3_clean.1-75
bowtie2-build VIR3_clean.1-84.fna.gz VIR3_clean.1-84

bowtie2-build VIR3_clean.1-70.fna.gz VIR3_clean.1-70
bowtie2-build VIR3_clean.1-80.fna.gz VIR3_clean.1-80
bowtie2-build VIR3_clean.1-90.fna.gz VIR3_clean.1-90
bowtie2-build VIR3_clean.1-100.fna.gz VIR3_clean.1-100
bowtie2-build VIR3_clean.1-110.fna.gz VIR3_clean.1-110
bowtie2-build VIR3_clean.1-120.fna.gz VIR3_clean.1-120
bowtie2-build VIR3_clean.1-130.fna.gz VIR3_clean.1-130
bowtie2-build VIR3_clean.1-140.fna.gz VIR3_clean.1-140
bowtie2-build VIR3_clean.1-150.fna.gz VIR3_clean.1-150
bowtie2-build VIR3_clean.1-160.fna.gz VIR3_clean.1-160
```





##	20240513



Hey Jake - when you have a minute, could you please compare the VZV (and I guess the human herpesviruses), to the peptide sequences in the LEX library? I’m thinking the same way (20AA tiles) we did this before. Id like to know if VZV has homology to any of those AA sequences and the herpesviurses will be a good comparison. Thanks!

Somehow, field 19 of this CSV seems like its hard to parse even though double double quotes is apparently appropriate.

```
"CHAIN 1..175; /note=""E1B protein, small T-antigen""; /id=""PRO_0000221710"""
```
parses to
```
"CHAIN 1..176; /note=""E1B protein
```



```

zcat HAP_LExP_Peptide_Oligo_Metadata_for_Distribution.csv.gz | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}(NR>1 && $4=="\"LExPELib.1\""){a=substr($17,2,length($17)-2);gsub(/[ \(\)]/,"_",a);b=substr($3,2,length($3)-2);print ">"$2"_"a;print b}' | gzip > LExPELib.1.tiles.faa.gz

zcat HAP_LExP_Peptide_Oligo_Metadata_for_Distribution.csv.gz | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}(NR>1 && $4=="\"LExPELib.2\""){a=substr($17,2,length($17)-2);gsub(/[ \(\)]/,"_",a);b=substr($3,2,length($3)-2);print ">"$2"_"a;print b}' | gzip > LExPELib.2.tiles.faa.gz

```

SPELLARDPYGPAVDIWSAGIVLFEMATGQ

```

zcat LExPELib.1.tiles.faa.gz | sed -e '/^>/s/[ \/,]/_/g' -e '/^>/s/\(^.\{1,50\}\).*/\1/' | makeblastdb -dbtype prot -input_type fasta -title LExPELib.1.tiles -parse_seqids -out LExPELib.1.tiles

zcat LExPELib.2.tiles.faa.gz | sed -e '/^>/s/[ \/,]/_/g' -e '/^>/s/\(^.\{1,50\}\).*/\1/' | makeblastdb -dbtype prot -input_type fasta -title LExPELib.2.tiles -parse_seqids -out LExPELib.2.tiles

```
Why?

I'm blastin the tiles to Herpes Virus DB.



```

zcat LExPELib.1.tiles.faa.gz | blastp -db /francislab/data1/refs/refseq/viral-20220923/HerpesProteins -outfmt 6 -out LExPELib.1.tiles.in.HerpesProteins.tsv

zcat LExPELib.2.tiles.faa.gz | blastp -db /francislab/data1/refs/refseq/viral-20220923/HerpesProteins -outfmt 6 -out LExPELib.2.tiles.in.HerpesProteins.tsv

```







##	20240516

I tried several different FPAT regexes without success. I think that best way to deal with these double quotes inside a double quoted dataset is to change them to something else prior to parsing, do whatever, then change back.

```
cat test.csv | sed 's/""/\x0\x0/g'  | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]*\")"}{for(i=1;i<=NF;i++){print i":"$i}}' | sed 's/\x0/"/g'
```





##	20240613

There should be just 115753 uniqued on just ids.

```
zgrep -c "^>" VIR3_clean.uniq.fna.gz 
115753

```


```

zcat VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}{print $17,$10,$12}' | sort -t, -k3,3 -k2,2 -k1,1 > VIR3_clean.circos_framework.csv

```



```

zcat VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}{print $17,$10,$12}' | sort -t, -k3,3 -k2,2 -k1,1 | uniq > VIR3_clean.circos_framework.uniq.csv

```

This will still result in many "duplicates" as some sequence ids have different protein names.

```
grep "^87073," VIR3_clean.circos_framework.uniq.csv 

87073,"Polyprotein, ",Encephalomyocarditis virus
87073,Genome polyprotein [Cleaved into: Protein VP0 (VP4-VP2); Protein VP4 (P1A) (Rho) (Virion protein 4); Protein VP2 (Beta) (P1B) (Virion protein 2); Protein VP3 (Gamma) (P1C) (Virion protein 3); Protein VP1 (Alpha) (P1D) (Virion protein 1)] (Fragment),Encephalomyocarditis virus
87073,Genome polyprotein [Cleaved into: Protein VP0 (VP4-VP2); Protein VP4 (P1A) (Rho) (Virion protein 4); Protein VP2 (Beta) (P1B) (Virion protein 2); Protein VP3 (Gamma) (P1C) (Virion protein 3); Protein VP1 (Alpha) (P1D) (Virion protein 1); Protein 2A (P2A) (G); Protein 2B (I) (P2B); Protein 2C (C) (P2C) (EC 3.6.1.15); Protein 3A (P3A); Protein 3B (P3B) (H) (VPg); Picornain 3C (EC 3.4.22.28) (Protease 3C) (P3C) (p22); RNA-directed RNA polymerase 3D-POL (E) (P3D-POL) (EC 2.7.7.48)],Encephalomyocarditis virus
```


```
wc -l VIR3_clean.circos_framework.*
  128257 VIR3_clean.circos_framework.csv
  117936 VIR3_clean.circos_framework.uniq.csv
  246193 total
```

Over 2,000 duplicates will still be there. Deal with it.




Just can't have commas when using "join" as it is very elementary.
It also MUST be sorted by id to match the sort on the tile counts used in the dataset.








##	20240807


```
zcat VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}{print $17,$12}' | sort -t, -k1n,1 -k3,3 | uniq | sed '1i id,species' > VIR3_clean.uniq.csv
```


Noticed that 1 id 89962 goes by 2 different names but may be the same amino acid





import difflib
peptide=              "ZZZZSEQUENCEZZZZZZZZZZZZZZZZZ"
already_found_peptide="AAAAAAAAAAAAAAAAASEQUENCEAAAA"
matcher = difflib.SequenceMatcher(None, peptide,already_found_peptide)
match = matcher.find_longest_match(0, len(peptide), 0, len(already_found_peptide))         
match.size
8




##	20240909


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

    columns = ['id', 'Species', 'Organism', 'Entry', 'peptide']

```
#zcat VIR3_clean.csv.gz | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}{print $17,$12,$9,$4,$21}' \

echo "id,Species,peptide" > VIR3_clean.virus_score.csv
zcat VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}{print $17,$12,$21}' \
  | sed -e 's/Chikungunya virus (CHIKV)/Chikungunya virus/g' \
  -e 's/Eastern equine encephalitis virus (EEEV) (Eastern equine encephalomyelitis virus)/Eastern equine encephalitis virus/g' \
  -e 's/Uukuniemi virus (Uuk)/Uukuniemi virus/g' \
  -e 's/Human torovirus (HuTV)/Human torovirus/g' \
  -e 's/BK polyomavirus (BKPyV)/BK polyomavirus/g' \
  -e 's/Human cytomegalovirus (HHV-5) (Human herpesvirus 5)/Human herpesvirus 5/g' \
  -e 's/New York virus (NYV)/New York virus/g' \
  | sort -t, -k1n,1 | uniq >> VIR3_clean.virus_score.csv



```




##	20240917


```

tail -n +2 public_epitope_annotations.sorted.csv | awk 'BEGIN{FS=OFS=","}{print $1,$5,$3}' | sort -t, -k1n,1 > public_epitope_annotations.clean.csv
sed -i '1iid,species,public_epitope' public_epitope_annotations.clean.csv
chmod 400 public_epitope_annotations.clean.csv

#	too many duplicate records with differing proteins
#84182,Influenza A virus,Non-structural protein 1 (NS1) (NS1A),Vir2,197,TLQRFAWGSSNENGGPPLTPKQKRKMARTARSKVRRDKMAD
#84182,Influenza A virus,Nonstructural protein 1,Vir2,197,TLQRFAWGSSNENGGPPLTPKQKRKMARTARSKVRRDKMAD

#echo "id,Species,protein,source,start,peptide" > VIR3_clean.select.csv
#zcat VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}{gsub(/,/," ",$10);print $17,$12,$10,$19,$20,$21}' \
#  | sed -e 's/Chikungunya virus (CHIKV)/Chikungunya virus/g' \
#  -e 's/Eastern equine encephalitis virus (EEEV) (Eastern equine encephalomyelitis virus)/Eastern equine encephalitis virus/g' \
#  -e 's/Uukuniemi virus (Uuk)/Uukuniemi virus/g' \
#  -e 's/Human torovirus (HuTV)/Human torovirus/g' \
#  -e 's/BK polyomavirus (BKPyV)/BK polyomavirus/g' \
#  -e 's/Human cytomegalovirus (HHV-5) (Human herpesvirus 5)/Human herpesvirus 5/g' \
#  -e 's/New York virus (NYV)/New York virus/g' \
#  | sort -t, -k1n,1 | uniq >> VIR3_clean.select.csv


# a few duplicates with differing start positions
#echo "id,Species,source,start,peptide" > VIR3_clean.select.csv
#zcat VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}{print $17,$12,$19,$20,$21}' \
#  | sed -e 's/Chikungunya virus (CHIKV)/Chikungunya virus/g' \
#  -e 's/Eastern equine encephalitis virus (EEEV) (Eastern equine encephalomyelitis virus)/Eastern equine encephalitis virus/g' \
#  -e 's/Uukuniemi virus (Uuk)/Uukuniemi virus/g' \
#  -e 's/Human torovirus (HuTV)/Human torovirus/g' \
#  -e 's/BK polyomavirus (BKPyV)/BK polyomavirus/g' \
#  -e 's/Human cytomegalovirus (HHV-5) (Human herpesvirus 5)/Human herpesvirus 5/g' \
#  -e 's/New York virus (NYV)/New York virus/g' \
#  | sort -t, -k1n,1 | uniq >> VIR3_clean.select.csv


echo "id,Species,protein,source,start,peptide" > VIR3_clean.select.csv
zcat VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}{gsub(/,/," ",$10);print $17,$12,$10,$19,$20,$21}' \
  | sed -e 's/Chikungunya virus (CHIKV)/Chikungunya virus/g' \
  -e 's/Eastern equine encephalitis virus (EEEV) (Eastern equine encephalomyelitis virus)/Eastern equine encephalitis virus/g' \
  -e 's/Uukuniemi virus (Uuk)/Uukuniemi virus/g' \
  -e 's/Human torovirus (HuTV)/Human torovirus/g' \
  -e 's/BK polyomavirus (BKPyV)/BK polyomavirus/g' \
  -e 's/Human cytomegalovirus (HHV-5) (Human herpesvirus 5)/Human herpesvirus 5/g' \
  -e 's/New York virus (NYV)/New York virus/g' \
  | sort -t, -k1n,1 | uniq | awk -F, '(!seen[$1]){print;seen[$1]++}' >> VIR3_clean.select.csv


```





##	20241008

Create a cleaner reference

All peptides (many repeated)
```
zcat VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}{print $21}' | wc -l
128257
```

Unique, (include 1 copy of each repeat)
```
zcat VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}{print $21}' | sort | uniq | wc -l
111638
```

Only those not repeated
```
zcat VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}{print $21}' | sort | uniq -u | wc -l
104567
```

1 copy of each repeat
```
zcat VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}{print $21}' | sort | uniq -d | wc -l
7071
```

All copies of all repeats
```
zcat VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}{print $21}' | sort | uniq -D | wc -l
23690
```



Actual duplicates
```
zcat VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}{print $21}' | sort | uniq -d > VIR3_clean.duplicates.txt
sed -i '1iduplicated_peptide' VIR3_clean.duplicates.txt
```


Unique peptides with id
```
zcat VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}{print $21,$17}' | sort -t, -k1,1 -k2n,2 | uniq  | wc -l

zcat VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}{print $21,$17}' | sort -t, -k1,1 -k2n,2 | uniq  > VIR3_clean.peptides_with_ids.csv
sed -i '1ipeptide,id' VIR3_clean.peptides_with_ids.csv
```

```
zcat VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}{gsub(/,/," ",$10);print $21,$17,$12,$10}' \
  | sed -e 's/Chikungunya virus (CHIKV)/Chikungunya virus/g' \
  -e 's/Eastern equine encephalitis virus (EEEV) (Eastern equine encephalomyelitis virus)/Eastern equine encephalitis virus/g' \
  -e 's/Uukuniemi virus (Uuk)/Uukuniemi virus/g' \
  -e 's/Human torovirus (HuTV)/Human torovirus/g' \
  -e 's/BK polyomavirus (BKPyV)/BK polyomavirus/g' \
  -e 's/Human cytomegalovirus (HHV-5) (Human herpesvirus 5)/Human herpesvirus 5/g' \
  -e 's/New York virus (NYV)/New York virus/g' \
  | sort -t, -k1,1 -k2n,2 > tmp
  
sed -i '1ipeptide,id,Species,protein,source,start' tmp

```

```
join --header -t, VIR3_clean.duplicates.txt tmp > VIR3_clean.duplicates.tmp

```


Duplicated peptides with different ids

```

join --header -t, VIR3_clean.duplicates.txt VIR3_clean.peptides_with_ids.csv | tail -n +2 | cut -d, -f1 | uniq -c | sort -nr | head
     12 MQLFHLCLIISCSCPTVQASKLCLGWLWGMDIDPYKEFGASVELLSFLPSDFFPSI
     10 MGGWSSKPRQGMGTNLSVPNPLGFFPDHQLDPAFGANSNNPDWDFNPNKDHWPEAN
      8 MGQNLSTSNPLGFFPDHQLDPAFRANTANPDWDFNPNKDTWPDANKVGAGAFGLGF
      8 MGGWSSKPRKGMGTNLSVPNPLGFFPDHQLDPAFKANSENPDWDLNPHKDNWPDAN
      8 MASYPCHQHASAFDQAARSRGHSNRRTALRPRRQQEATEVRLEQKMPTLLRVYIDG
      8 LRPRRQQEATEVRLEQKMPTLLRVYIDGPHGMGKTTTTQLLVALGSRDDIVYVPEP
      7 SHPIILGFRKIPMGVGLSPFLLAQFTSAICSVVRRAFPHCLAFSYMDDVVLGAKSV
      7 PHGMGKTTTTQLLVALGSRDDIVYVPEPMTYWQVLGASETIANIYTTQHRLDQGEI
      7 ARFYPNLTKYLPLDKGIKPYYPEHAVNHYFKTRHYLHTLWKAGILYKRETTRSASF
      6 TTPPHSPTTPPPEPPSKSSPDSLAPSTLRSLRKRRLSSPQGPSTLNPICQSPPVSP

grep MQLFHLCLIISCSCPTVQASKLCLGWLWGMDIDPYKEFGASVELLSFLPSDFFPSI VIR3_clean.duplicates.tmp 
MQLFHLCLIISCSCPTVQASKLCLGWLWGMDIDPYKEFGASVELLSFLPSDFFPSI,10645,Hepatitis B virus,Precore/core protein (Fragment)
MQLFHLCLIISCSCPTVQASKLCLGWLWGMDIDPYKEFGASVELLSFLPSDFFPSI,10647,Hepatitis B virus,Precore/core protein (Fragment)
MQLFHLCLIISCSCPTVQASKLCLGWLWGMDIDPYKEFGASVELLSFLPSDFFPSI,10649,Hepatitis B virus,Precore/core protein (Fragment)
MQLFHLCLIISCSCPTVQASKLCLGWLWGMDIDPYKEFGASVELLSFLPSDFFPSI,10662,Hepatitis B virus,Precore/core protein (Fragment)
MQLFHLCLIISCSCPTVQASKLCLGWLWGMDIDPYKEFGASVELLSFLPSDFFPSI,10666,Hepatitis B virus,Precore/core protein (Fragment)
MQLFHLCLIISCSCPTVQASKLCLGWLWGMDIDPYKEFGASVELLSFLPSDFFPSI,11653,Hepatitis B virus,Precore/core protein (Fragment)
MQLFHLCLIISCSCPTVQASKLCLGWLWGMDIDPYKEFGASVELLSFLPSDFFPSI,3604,Hepatitis B virus,Precore/core protein
MQLFHLCLIISCSCPTVQASKLCLGWLWGMDIDPYKEFGASVELLSFLPSDFFPSI,5060,Hepatitis B virus,Precore/core protein
MQLFHLCLIISCSCPTVQASKLCLGWLWGMDIDPYKEFGASVELLSFLPSDFFPSI,67528,Hepatitis B virus,Precore/core protein
MQLFHLCLIISCSCPTVQASKLCLGWLWGMDIDPYKEFGASVELLSFLPSDFFPSI,6987,Hepatitis B virus,Truncated precore/core protein
MQLFHLCLIISCSCPTVQASKLCLGWLWGMDIDPYKEFGASVELLSFLPSDFFPSI,71218,Hepatitis B virus,HBeAg/HBcAg
MQLFHLCLIISCSCPTVQASKLCLGWLWGMDIDPYKEFGASVELLSFLPSDFFPSI,74459,Hepatitis B virus,Truncated precore/core protein

```



```
join --header -t, VIR3_clean.duplicates.txt VIR3_clean.peptides_with_ids.csv | tail -n +2 | cut -d, -f1 | uniq -c | sort -nr | head

join --header -t, VIR3_clean.duplicates.txt VIR3_clean.peptides_with_ids.csv | tail -n +2 | cut -d, -f1 | uniq -c | sort -k1nr,1 | awk '($1>1){print $2}' | sort > tmp

join --header -t, tmp VIR3_clean.duplicates.tmp | head


```






OLIGO ANALYSIS

```

zcat VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}{print $18}' | sort | uniq -u | wc -l
111834

zcat VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}{print $18}' | sort | uniq -d | wc -l
3919

zcat VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}{print $18}' | sort | uniq -D | wc -l
16423

zcat VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}{print $17,$18,$21}' | sort | uniq -D | wc -l
16423


zcat VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}{print $18}' | sort | uniq -d > VIR3_clean.duplicated_oligos.txt
sed -i '1ioligo' VIR3_clean.duplicated_oligos.txt

zcat VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}{print $18,$17}' | sort -t, -k1,1 -k2n,2 | uniq > VIR3_clean.oligos_with_ids.csv
sed -i '1ioligo,id' VIR3_clean.oligos_with_ids.csv

join --header -t, VIR3_clean.duplicated_oligos.txt VIR3_clean.oligos_with_ids.csv

join --header -t, VIR3_clean.duplicated_oligos.txt VIR3_clean.oligos_with_ids.csv | tail -n +2 | cut -d, -f1 | uniq -c | awk '$1>1'

#	NOTHING! Meaning the duplicated oligos have a duplicated id as well.

zcat VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}{print $17}' | sort | uniq -d > VIR3_clean.duplicated_ids.txt
sed -i '1iids' VIR3_clean.duplicated_ids.txt

zcat VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}{print $17,$18}' | sort -t, -k1,1 -k2,2 | uniq > VIR3_clean.ids_with_oligos.csv
sed -i '1iid,oligo' VIR3_clean.ids_with_oligos.csv

join --header -t, VIR3_clean.duplicated_ids.txt VIR3_clean.ids_with_oligos.csv | tail -n +2 | cut -d, -f1 | uniq -c | awk '$1>1'

#	again nothin saying the duplicated ids have the same duplicated oligo
```







##	Creating alternate reference

ehh

```
zcat VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}{print $17,$18,$21,$12}' \
  | sed -e 's/Chikungunya virus (CHIKV)/Chikungunya virus/g' \
  -e 's/Eastern equine encephalitis virus (EEEV) (Eastern equine encephalomyelitis virus)/Eastern equine encephalitis virus/g' \
  -e 's/Uukuniemi virus (Uuk)/Uukuniemi virus/g' \
  -e 's/Human torovirus (HuTV)/Human torovirus/g' \
  -e 's/BK polyomavirus (BKPyV)/BK polyomavirus/g' \
  -e 's/Human cytomegalovirus (HHV-5) (Human herpesvirus 5)/Human herpesvirus 5/g' \
  -e 's/New York virus (NYV)/New York virus/g' \
  | sort -t, -k1,1 | uniq > VIR3_clean.join_sorted.csv
sed -i '1iid,oligo,peptide,species' VIR3_clean.join_sorted.csv

```



cat test_ids* | tr -d "^^" | sort -n | sed 's/^/^/' > demo_test_ids






##	Add column to virus score matrix


```
awk 'BEGIN{FS=OFS=","}(NR==FNR){seen[$1]++}
(NR>FNR){if(FNR==1){$4="public" }else{ (seen[$1]>0)?$4="True":$4="False" } print
}' public_epitope_annotations.join_sorted.csv VIR3_clean.virus_score.join_sorted.csv
> VIR3_clean.virus_score.join_sorted.with_public.csv 
```







##	20241009


```
mkdir human_herpes
awk -F, '($2~/^Human herpes/){print ">"$1" "$2"\n"$3 > "human_herpes/"$1".faa"}' VIR3_clean.virus_score.csv

```


```
alphafold_array_wrapper.bash *.faa
```


The TM-score range is 0 to 1, with higher values indicating a more accurate match between two protein structures: 

1: A perfect match between the two structures 

0.5 or higher: The predicted model and the native structure have the same fold topology 

0.17 or lower: No structural similarity between the predicted model and the native structure 

Below 0.5: The predicted structure is likely wrong 

TM-align is a protein structure alignment algorithm that reports two TM-scores, one normalized by the length of the first structure and the other by the length of the second structure.


```

sbatch --export=NONE --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="usalign" --output="${PWD}/$( date "+%Y%m%d%H%M%S%N" ).out" --time=2880 --nodes=1 --ntasks-per-node=4 --ntasks=4 --mem=30G /francislab/data1/refs/PhIP-Seq/usalign.bash

sbatch --export=NONE --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="usalign_aggregate" --output="${PWD}/$( date "+%Y%m%d%H%M%S%N" ).out" --time=2880 --nodes=1 --ntasks-per-node=4 --ntasks=4 --mem=30G /francislab/data1/refs/PhIP-Seq/usalign_aggregate.bash

```



