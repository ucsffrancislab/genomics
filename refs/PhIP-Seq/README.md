
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


```

      1 source
   8606 IEDB
 108603 Vir2
  11048 Vir3

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




##	20241001


```

./novel_peptides.py public_epitope_annotations.join_sorted.csv


box_upload.bash public_epitope_annotations.join_sorted.csv.shared_epitopes.csv

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







##	20241011




```

for f in *.usalign.log ; do
d=${f%-*}
e=${f#*-}
mkdir -p ${d}
echo mv ${f} ${d}/${e}
mv ${f} ${d}/${e}
done > 20241011.first_move.log &

```

```

204_4-332_3.usalign.log
204_4
332_3.usalign.log


204_4/332_3.usalign.log

```

```
for f in *_?/*_?.usalign.log ; do
d=$(dirname ${f})
bd=${d}
d1=${d%_?}
e=${f##*/}
d2=${e%_*}
mkdir -p ${d1}/${d2}
echo mv ${f} ${d1}/${d2}/${bd}-${e}
mv ${f} ${d1}/${d2}/${bd}-${e}
done > 20241012.second_move.log &

```


```

1227/4351/1227_0-4351_0.usalign.log

```


##	20241012

While, 2 threads is find, 15GB is not enough.

Trying 3 threads

```

alphafold_array_wrapper.bash --threads 4 human_herpes/??.faa human_herpes/???.faa human_herpes/????.faa

```


Some fail with ...

```
[gwendt@c4-dev3 /francislab/data1/refs/PhIP-Seq]$ tail logs/alphafold_array_wrapper.bash.20241012081547537386005-155380_288.out.log
    feature_dict = data_pipeline.process(
  File "/app/alphafold/alphafold/data/pipeline.py", line 223, in process
    templates_result = self.template_featurizer.get_templates(
  File "/app/alphafold/alphafold/data/templates.py", line 894, in get_templates
    result = _process_single_hit(
  File "/app/alphafold/alphafold/data/templates.py", line 738, in _process_single_hit
    cif_string = _read_file(cif_path)
  File "/app/alphafold/alphafold/data/templates.py", line 682, in _read_file
    with open(path, 'r') as f:
FileNotFoundError: [Errno 2] No such file or directory: '/francislab/data1/refs/alphafold/databases/pdb_mmcif/mmcif_files/5cvx.cif'
```


Some people claim that this is due the the max template date being too new.

Others clain that the pdb_mmcif needs updated?

Gonna let them all run.



5CVX
Structure of DNA-binding protein HU from micoplasma Spiroplasma melliferum
DOI: 10.2210/pdb5CVX/pdb
Deposited: 2015-07-27 Released: 2015-08-19
Deposition Author(s): Boyko, K.M., Gorbacheva, M.A., Rakitina, T.V., Korgenevsky, D.A., Kamashev, D.E., Vanyushkina, A.A., Lipkin, A.V., Popov, V.O.
Entry 5CVX was removed from the distribution of released PDB entries (status Obsolete) on 2016-06-22.
It has been replaced (superseded) by 5L8Z.


Confused.



aws s3 ls --no-sign-request s3://pdbsnapshots/20240101/pub/pdb/

Another resolution is to get a snapshot of the mmcifs and the seqres database from something like https://registry.opendata.aws/pdb-3d-structural-biology-data/ - note that the seqres database has to be older than or the same age as the mmcif download. (see README)





Hi thanks for raising this. Have you updated the pdb_seqres file more recently than the PDB mmcif files? This error is likely to happen when they are out of sync. In the future we can add a more informative error message.


5CVX is in the obsolete.dat file. Shouldn't be looking for it?


```

grep FileNotFoundError logs/alphafold_array_wrapper.bash.*.out.log

logs/alphafold_array_wrapper.bash.20241012100943398198461-155803_1406.out.log:FileNotFoundError: [Errno 2] No such file or directory: '/francislab/data1/refs/alphafold/databases/pdb_mmcif/mmcif_files/6sng.cif'
logs/alphafold_array_wrapper.bash.20241012100943398198461-155803_1422.out.log:FileNotFoundError: [Errno 2] No such file or directory: '/francislab/data1/refs/alphafold/databases/pdb_mmcif/mmcif_files/6sng.cif'
logs/alphafold_array_wrapper.bash.20241012100943398198461-155803_288.out.log:FileNotFoundError: [Errno 2] No such file or directory: '/francislab/data1/refs/alphafold/databases/pdb_mmcif/mmcif_files/5cvx.cif'

```





##	20241014



```
mkdir testDB.links
cd testDB.links
for f in ../human_herpes/*/ranked_?.pdb; do
ext=${f#*/ranked_}
b=$( basename $( dirname $f ) )
ln -s $f ${b}_${ext}
done

~/.local/foldseek/bin/foldseek createdb testDB.links/ testDB
~/.local/foldseek/bin/foldseek createindex testDB tmp

~/.local/foldseek/bin/foldseek easy-search ../alphafold/SPELLARDPYGPAVDIWSAGIVLFEMATGQ-prehensile_ranked_0.pdb testDB aln.m8 tmpFolder

~/.local/foldseek/bin/foldseek easy-search human_herpes/100/ranked_0.pdb testDB aln.m8 tmpFolder


```


##	20241016


```

alphafold_array_wrapper.bash --threads 4 human_herpes/1????.faa

```




##	20241021

The aggregation takes a while so to avoid redoing, gonna try to populate a database.

```
/francislab/data1/refs/PhIP-Seq/human_herpes/10000/ranked_0.pdb:A	/francislab/data1/refs/PhIP-Seq/human_herpes/10000/ranked_0.pdb:1.0000	1.0000	0.00	1.000	1.000	1.000	56	56	56

```


```
#	chain is always A
#chain=b[2];

sqlite3 human_herpes_usalign.sqlite_db 'CREATE TABLE usalign ( structure1 TEXT NOT NULL, structure2 TEXT NOT NULL, ave_TM_score REAL NOT NULL); CREATE UNIQUE INDEX IF NOT EXISTS pairings ON usalign(structure1, structure2);'

head human_herpes_usalign.tsv | awk 'BEGIN{FS=OFS="\t"}{
split($1,a,"/");
tile1=a[length(a)-1];
split(a[length(a)],b,":");
split(a[length(a)],c,".");
split(c[1],d,"_");
rank1=d[2];
split($2,a,"/");
tile2=a[length(a)-1];
split(a[length(a)],b,":");
split(a[length(a)],c,".");
split(c[1],d,"_");
rank2=d[2];
print(tile1"-"rank1,tile2"-"rank2,($3+$4)/2)
}' | sqlite3 human_herpes_usalign.sqlite_db -separator $'\t' ".import /dev/stdin usalign"

```





```

sqlite3 -cmd ".output stdout" human_herpes_usalign.sqlite_db "SELECT ave_TM_score FROM usalign WHERE structure1 = '10000-0' AND structure2 = '10001-2'";

sqlite3 -cmd ".output stdout" human_herpes_usalign.sqlite_db "SELECT ave_TM_score FROM usalign WHERE structure1 = '10000-0' AND structure2 = '10001-9'";

```





##	20241023


```
ll human_herpes/??.faa human_herpes/???.faa human_herpes/????.faa | wc -l
1630

ll human_herpes/??/ranked_0.pdb human_herpes/???/ranked_0.pdb human_herpes/????/ranked_0.pdb | wc -l
1627


alphafold_array_wrapper.bash --threads 4 human_herpes/??.faa human_herpes/???.faa human_herpes/????.faa

alphafold_array_wrapper.bash --threads 4 human_herpes/1????.faa

alphafold_array_wrapper.bash --threads 4 human_herpes/2????.faa


```



Problem tiles:
* 3413 (_288.)
* 9445 (_1406.)
* 9461 (_1422.)
* 15071 (_843.)





##	20241030


```
awk -F, '($2~/^Human herpes/){print ">"$1" "$2"\n"$3 >> "human_herpes.faa"}' VIR3_clean.virus_score.csv

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 \
--job-name=HerpesMHC --time=14-0 --nodes=1 --ntasks=4 --mem=30GB \
--output=${PWD}/HerpesMHC.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
/francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/MHC.bash -f /francislab/data1/refs/PhIP-Seq/human_herpes.faa


awk -F, '($2~/^Human herpes/){print $1}' VIR3_clean.virus_score.csv | sort | sed '1iTile' > human_herpes.tile_numbers.txt
```


##	20241101


Somehow use AGS41970_HLA.tsv as a reference to compare




```

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 \
--job-name=AGSHerpesMHC --time=14-0 --nodes=1 --ntasks=4 --mem=30GB \
--output=${PWD}/HerpesMHC.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
/francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/MHC.bash -f /francislab/data1/refs/PhIP-Seq/human_herpes.faa

```




##	20241105

```
./netMHCpan_analysis.py -i MHC/human_herpes.netMHCpan.AGS.txt

join --header -a1 -t, human_herpes.tile_numbers.txt MHC/human_herpes.netMHCpan.AGS.csv > tmp.csv

python3 -c "import pandas as pd; pd.read_csv('tmp.csv',sep=',').to_csv('MHC/human_herpes.netMHCpan.AGS.alltiles.csv',index=False)"

join --header -a1 -t, human_herpes.tile_numbers.txt /francislab/data1/working/20240925-Illumina-PhIP/20240925c-PhIP/merged_hits.csv > tmp.csv

python3 -c "import pandas as pd; pd.read_csv('tmp.csv',sep=',').to_csv('PhIPseq_merged_hits.alltiles.csv',index=False)"

join --header -t, MHC/human_herpes.netMHCpan.AGS.alltiles.csv PhIPseq_merged_hits.alltiles.csv > PhIPseq_merged_hits.herpes.NetMHC.alltiles.csv
```




```

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 \
--job-name=HerpesMHCAGS --time=14-0 --nodes=1 --ntasks=4 --mem=30GB \
--output=${PWD}/HerpesMHCAGS.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
~/.local/bin/netMHCpan.bash -f /francislab/data1/refs/PhIP-Seq/human_herpes.faa --start_allele HLA-A3001

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 \
--job-name=HerpesMHCIIAGS --time=14-0 --nodes=1 --ntasks=4 --mem=30GB \
--output=${PWD}/HerpesMHCIIAGS.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
~/.local/bin/netMHCIIpan.bash -f /francislab/data1/refs/PhIP-Seq/human_herpes.faa

```





##	20241119

```
grep "^++ dirname" $( grep -L "^Runtime" logs/alphafold_array_wrapper.bash.20241024071903713622467-171567_*.out.log )
logs/alphafold_array_wrapper.bash.20241024071903713622467-171567_1563.out.log:++ dirname /francislab/data2/refs/PhIP-Seq/human_herpes/26002.faa
logs/alphafold_array_wrapper.bash.20241024071903713622467-171567_1564.out.log:++ dirname /francislab/data2/refs/PhIP-Seq/human_herpes/26003.faa
logs/alphafold_array_wrapper.bash.20241024071903713622467-171567_1565.out.log:++ dirname /francislab/data2/refs/PhIP-Seq/human_herpes/26004.faa
logs/alphafold_array_wrapper.bash.20241024071903713622467-171567_1566.out.log:++ dirname /francislab/data2/refs/PhIP-Seq/human_herpes/26005.faa
logs/alphafold_array_wrapper.bash.20241024071903713622467-171567_1567.out.log:++ dirname /francislab/data2/refs/PhIP-Seq/human_herpes/26006.faa
logs/alphafold_array_wrapper.bash.20241024071903713622467-171567_1568.out.log:++ dirname /francislab/data2/refs/PhIP-Seq/human_herpes/26007.faa
logs/alphafold_array_wrapper.bash.20241024071903713622467-171567_1569.out.log:++ dirname /francislab/data2/refs/PhIP-Seq/human_herpes/26008.faa
logs/alphafold_array_wrapper.bash.20241024071903713622467-171567_1647.out.log:++ dirname /francislab/data2/refs/PhIP-Seq/human_herpes/26086.faa
logs/alphafold_array_wrapper.bash.20241024071903713622467-171567_1882.out.log:++ dirname /francislab/data2/refs/PhIP-Seq/human_herpes/26321.faa
logs/alphafold_array_wrapper.bash.20241024071903713622467-171567_2178.out.log:++ dirname /francislab/data2/refs/PhIP-Seq/human_herpes/26617.faa

```


```
alphafold_array_wrapper.bash --threads 4 --array 1563-1569,1647,1882,2178 human_herpes/2????.faa
```



```
grep "^++ dirname" $( grep -L "^Runtime" logs/alphafold_array_wrapper.bash.20241119143814025440901-240864_*.out.log )
logs/alphafold_array_wrapper.bash.20241119143814025440901-240864_1647.out.log:++ dirname /francislab/data2/refs/PhIP-Seq/human_herpes/26086.faa
logs/alphafold_array_wrapper.bash.20241119143814025440901-240864_1882.out.log:++ dirname /francislab/data2/refs/PhIP-Seq/human_herpes/26321.faa
logs/alphafold_array_wrapper.bash.20241119143814025440901-240864_2178.out.log:++ dirname /francislab/data2/refs/PhIP-Seq/human_herpes/26617.faa
```


```
alphafold_array_wrapper.bash --threads 4 human_herpes/3????.faa
```







  21         DRB1_0101      LRVTFHRVKPTLVGH    4   FHRVKPTLV     1.000        0 52_Human_herpes      0.918567     0.41        NA   <= SB
  22         DRB1_0101      RVTFHRVKPTLVGHV    3   FHRVKPTLV     1.000        0 52_Human_herpes      0.929287     0.35        NA   <= SB
  23         DRB1_0101      VTFHRVKPTLVGHVG    2   FHRVKPTLV     1.000        0 52_Human_herpes      0.652326     1.61        NA   <= WB




##	20241125


```
zgrep "^>" /francislab/data1/refs/PhIP-Seq/VIR3_clean.uniq.fna.gz | tr -d "^\>" | sort > /francislab/data1/refs/PhIP-Seq/VIR3_clean.uniq.sequences.join_sorted
sed -i '1iid' /francislab/data1/refs/PhIP-Seq/VIR3_clean.uniq.sequences.join_sorted

```


##	20241126

netMHCIIpan requires sequences be gte 9 

Any sequence shorter will cause the whole thing to fail.

There is 1 in human_herpes.faa
```
< >96177 Human herpesvirus 1
< MKTNPL
```

```
awk -F, '($2~/^Human herpes/ && length($3)>=9 ){print ">"$1" "$2"\n"$3 >> "human_herpes.gte9.faa"}' VIR3_clean.virus_score.csv
```




##	20241127

17 - id,
18 - oligo,

can't remember what i was doing here!!!!


select only VIR3? Nope. only 11,000!
```
1 source
8606 IEDB
108603 Vir2
11048 Vir3
```

```
12 - Species,
13 - Subcellular location,
14 - Version (entry),
15 - Version (sequence),
16 - end,
17 - id,
18 - oligo,
19 - source,
```


```
zcat VIR3_clean.csv.gz | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}($17==89962){print $17,$12,$19}' 
89962,Chikungunya virus,Vir2
89962,O'nyong-nyong virus,Vir2
89962,O'nyong-nyong virus,Vir2
```



```
zcat VIR3_clean.csv.gz | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}{print $17,$12,$19}' | sort | uniq | wc -l
115755
```

```
zcat VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}{print $17,$12,$19}' | sort | uniq | sort -t, -k1,1 > VIR3_clean.id_species_source.uniq.csv
sed -i '1iid,species,source' VIR3_clean.id_species_source.uniq.csv
sed -i '/89962,O/d' VIR3_clean.id_species_source.uniq.csv
chmod a-w VIR3_clean.id_species_source.uniq.csv

zcat VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}{print $17,$12}' | sort | uniq | sort -t, -k1,1 > VIR3_clean.id_species.uniq.csv
sed -i '1iid,species' VIR3_clean.id_species.uniq.csv
sed -i '/89962,O/d' VIR3_clean.id_species.uniq.csv
chmod a-w VIR3_clean.id_species.uniq.csv
```


##	20241210



```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 \
--job-name=HerpesMHCIIAGS --time=14-0 --nodes=1 --ntasks=4 --mem=30GB \
--output=${PWD}/HerpesMHCIIAGS.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
~/.local/bin/netMHCIIpan.bash -f /francislab/data1/refs/PhIP-Seq/human_herpes.gte9.faa --start_allele HLA-DPA10103-DPB11701

```

##	20241219


```
awk 'BEGIN{OFS=","}{print $2,$11}' /francislab/data1/refs/PhIP-Seq/MHC/human_herpes.netMHCpan.AGS.txt | datamash -t, -s crosstab 1,2 | sed 's"N/A""g' > /francislab/data1/refs/PhIP-Seq/MHC/human_herpes.netMHCpan.AGS.pivot.csv

awk -F, '(NR==1){l=$1;for(i=2;i<=NF;i++){split($i,a,"_");l=l","a[1]}print l}(NR>1){for(i=2;i<=NF;i++){s[i]+=$i}}END{l="sum";for(i=2;i<=NF;i++){l=l","s[i]}print l}' /francislab/data1/refs/PhIP-Seq/MHC/human_herpes.netMHCpan.AGS.pivot.csv | datamash transpose -t, > tmp.csv
head -1 tmp.csv > /francislab/data1/refs/PhIP-Seq/MHC/human_herpes.netMHCpan.AGS.pivot.counts.csv
tail -n +2 tmp.csv | sort -t, -k1,1 > /francislab/data1/refs/PhIP-Seq/MHC/human_herpes.netMHCpan.AGS.pivot.counts.csv
\rm tmp.csv

awk -F, '(NR==1){print}(NR>1){for(i=2;i<=NF;i++){if($i>0)s[i]+=1}}END{l="sum";for(i=2;i<=NF;i++){l=l","s[i]}print l}' /francislab/data1/refs/PhIP-Seq/MHC/human_herpes.netMHCpan.AGS.pivot.csv | datamash transpose -t, | sort -t, -k2nr,2 | head

awk -F, '(NR==1){print}(NR>1){for(i=2;i<=NF;i++){if($i>0)s[i]+=1}}END{l="sum";for(i=2;i<=NF;i++){l=l","s[i]}print l}' /francislab/data1/refs/PhIP-Seq/MHC/human_herpes.netMHCpan.AGS.pivot.csv | datamash transpose -t, | sort -t, -k2nr,2 | tail

```

Don't know why I didn't finish this before

```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 \
--job-name=HerpesMHCAGS --time=14-0 --nodes=1 --ntasks=4 --mem=30GB \
--output=${PWD}/HerpesMHCAGS.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
~/.local/bin/netMHCpan.bash -f /francislab/data1/refs/PhIP-Seq/human_herpes.faa --start_allele HLA-C0726

```






```
awk 'BEGIN{OFS=","}{print $2,$8}' /francislab/data1/refs/PhIP-Seq/MHC/human_herpes.gte9.netMHCIIpan.AGS.txt | datamash -t, -s crosstab 1,2 | sed 's"N/A""g' > /francislab/data1/refs/PhIP-Seq/MHC/human_herpes.gte9.netMHCIIpan.AGS.pivot.csv

awk -F, '(NR==1){l=$1;for(i=2;i<=NF;i++){split($i,a,"_");l=l","a[1]}print l}(NR>1){for(i=2;i<=NF;i++){s[i]+=$i}}END{l="sum";for(i=2;i<=NF;i++){l=l","s[i]}print l}' /francislab/data1/refs/PhIP-Seq/MHC/human_herpes.gte9.netMHCIIpan.AGS.pivot.csv | datamash transpose -t, > tmp.csv
head -1 tmp.csv > /francislab/data1/refs/PhIP-Seq/MHC/human_herpes.gte9.netMHCIIpan.AGS.pivot.counts.csv
tail -n +2 tmp.csv | sort -t, -k1,1 > /francislab/data1/refs/PhIP-Seq/MHC/human_herpes.gte9.netMHCIIpan.AGS.pivot.counts.csv
\rm tmp.csv

awk -F, '(NR==1){print}(NR>1){for(i=2;i<=NF;i++){if($i>0)s[i]+=1}}END{l="sum";for(i=2;i<=NF;i++){l=l","s[i]}print l}' /francislab/data1/refs/PhIP-Seq/MHC/human_herpes.gte9.netMHCIIpan.AGS.pivot.csv | datamash transpose -t, | sort -t, -k2nr,2 | head

awk -F, '(NR==1){print}(NR>1){for(i=2;i<=NF;i++){if($i>0)s[i]+=1}}END{l="sum";for(i=2;i<=NF;i++){l=l","s[i]}print l}' /francislab/data1/refs/PhIP-Seq/MHC/human_herpes.gte9.netMHCIIpan.AGS.pivot.csv | datamash transpose -t, | sort -t, -k2nr,2 | tail

```




##	20241227


```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 \
--job-name=HerpesMHCIIAGS --time=14-0 --nodes=1 --ntasks=4 --mem=30GB \
--output=${PWD}/HerpesMHCIIAGS.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
~/.local/bin/netMHCIIpan.bash -f /francislab/data1/refs/PhIP-Seq/human_herpes.gte9.faa --start_allele HLA-DPA10104-DPB14001

```




##	20250113


```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 \
--job-name=HerpesMHCIIAGS --time=14-0 --nodes=1 --ntasks=4 --mem=30GB \
--output=${PWD}/HerpesMHCIIAGS.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
~/.local/bin/netMHCIIpan.bash -f /francislab/data1/refs/PhIP-Seq/human_herpes.gte9.faa --start_allele HLA-DPA10201-DPB14801

```


##	20250116


```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 \
--job-name=HerpesMHCIIAGS --time=14-0 --nodes=1 --ntasks=4 --mem=30GB \
--output=${PWD}/HerpesMHCIIAGS.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
~/.local/bin/netMHCIIpan.bash -f /francislab/data1/refs/PhIP-Seq/human_herpes.gte9.faa --start_allele HLA-DPA10202-DPB10601

```



