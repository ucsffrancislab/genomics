
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


```

zcat VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}{gsub(/,/,";",$10);gsub(/\"/,"",$10);print $17,$10,$12}' | sort -t, -k1n,1 -k2,2 -k3,3 | uniq | sed '1i id,protein,species' > VIR3_clean.circos_framework.uniq.clean.csv

```









