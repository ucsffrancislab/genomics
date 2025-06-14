
#	PhIP-Seq/NeoAntigen


2025_0124_cross_analysis_summary_ha_mf_ag.tsv is a table of HLA types and peptides.
Peptides are in the tsv multiple times for multiple HLA types.
Extract a unique list of peptides and convert to fasta file.
Then prep phip seq tiles


```
tail -n +2 2025_0124_cross_analysis_summary_ha_mf_ag.tsv | cut -f2 | sort | uniq | head

cat sequences.txt  | assemble_peptides.py 2> /dev/null  | assemble_peptides.py 2> /dev/null | assemble_peptides.py 2> /dev/null | assemble_peptides.py 2> /dev/null | assemble_peptides.py 2> /dev/null | assemble_peptides.py 2> /dev/null | wc -l
#	172

cat sequences.txt  | assemble_peptides.py 2> /dev/null  | assemble_peptides.py 2> /dev/null | assemble_peptides.py 2> /dev/null | assemble_peptides.py 2> /dev/null | assemble_peptides.py 2> /dev/null | assemble_peptides.py 2> /dev/null > assembled_peptides.txt

wc -l assembled_peptides.txt
#172 assembled_peptides.txt

awk '{print ">"NR;print $0}' assembled_peptides.txt > assembled_peptides.faa

tail -n +2 2025_0124_cross_analysis_summary_ha_mf_ag.tsv | cut -f2 | sort | uniq > peptides.txt

./align_peptides.py -s peptides.txt -r assembled_peptides.txt > aligned_peptides.sam

samtools sort -o aligned_peptides.bam aligned_peptides.sam

samtools index aligned_peptides.bam
```

Moved all into assemble/



##	20250401


Prep libraries for multiple lengths

Here is a count of each peptide length.
```
awk '{print length($0)}' assemble/peptides.txt | sort -n | uniq -c
    762 8
    823 9
    631 10
    484 11
```

Separate into files by length.
```
tail -n +2 2025_0124_cross_analysis_summary_ha_mf_ag.tsv | cut -f2 | sort | uniq | awk '{ print ">"$0 >> "peptides."length($0)".faa"; print $0 >> "peptides."length($0)".faa"}'
```

Run phip_seq_create_tiles at that length.  There will be no overlap as they are simply too short.
```
for i in 8 9 10 11; do
 phip_seq_create_tiles.bash -t ${i} -o 0 -i peptides.${i}.faa
done
```

It generates a number of files, but the number of reads for each length is ...
```
grep -c "^>" oligos-ref-{?,??}-0.fasta
oligos-ref-8-0.fasta:1524
oligos-ref-9-0.fasta:1643
oligos-ref-10-0.fasta:1261
oligos-ref-11-0.fasta:968
```
Note that this is twice the number of peptides because it creates a separate sequence for every tile replacing the last amino acid with the stop codon. Not certain what purpose this has or how it impacts things.

```
grep -A1 ">AAAAPASR" {orf,cterm}_tiles-8-0.fasta
orf_tiles-8-0.fasta:>AAAAPASR|0-8
orf_tiles-8-0.fasta-AAAAPASR
--
cterm_tiles-8-0.fasta:>AAAAPASR|CTERM|STOP
cterm_tiles-8-0.fasta-AAAPASR*
```

```
grep -A 1 AAAAPASR oligos-ref-8-0.fasta
>AAAAPASR|0-8
GCTGCCGCTGCGCCGGCGTCTCGC
--
>AAAAPASR|CTERM|STOP
GCGGCCGCACCGGCTTCTCGTTAG
```

Additionally, another file is created that includes 16 bp appended to each end.
```
grep -A 1 AAAAPASR oligos-8-0.fasta
>AAAAPASR|0-8
AGGAATTCCGCTGCGTGCTGCCGCTGCGCCGGCGTCTCGCGCCTGGAGACGCCATC
--
>AAAAPASR|CTERM|STOP
AGGAATTCCGCTGCGTGCGGCCGCACCGGCTTCTCGTTAGGCCTGGAGACGCCATC
```

Moved all to 20250401/


##	20250403



```
tail -n +2 2025_0124_cross_analysis_summary_ha_mf_ag.tsv | cut -f2 | sort | uniq | awk '{ print ">"$0; print $0}' > peptides.faa
```

Run phip_seq_create_tiles at length 12.  There will be no overlap as they are simply too short.
```
phip_seq_create_tiles.bash -t 12 -o 0 -i peptides.faa
```

It generates a number of files, but the number of reads for each length is ...
```
grep -c "^>" oligos-ref-12-0.fasta
oligos-ref-12-0.fasta:2700
```








##	20250428

From Fundamental immune–oncogenicity trade-offs define driver mutation fitness
https://doi.org/10.1038/s41586-022-04696-z

Add these mutations to this collection.

How long? Include original? Center around mutation?

This'll require some manual labor.

41586_2022_4696_MOESM1_ESM


```
./extract_sequences_and_mutate.bash > gene_hotspot_mutations.faa
```



##	20250429


New list of neoantigens from: https://genomebiology.biomedcentral.com/articles/10.1186/s13059-023-03005-9#Sec18

Comprehensive analysis of neoantigens derived from structural variation across whole genomes from 2528 tumors - Genome Biology

neopeptides_shi.csv - too many



13059_2023_3005_MOESM1_ESM-S5.csv


```
tail -n +2 2025_0124_cross_analysis_summary_ha_mf_ag.tsv | cut -f2 | sort | uniq > tmp
tail -n +2 13059_2023_3005_MOESM1_ESM-S5.csv | cut -d, -f3 | sort | uniq >> tmp
sort tmp | uniq -d

tail -n +2 13059_2023_3005_MOESM1_ESM-S5.csv | cut -d, -f3 | sort | uniq | awk '{ print ">"$0; print $0}' > 13059_2023_3005_MOESM1_ESM-S5.faa
```



From REdiscoverTE?
```
tail -n +2 2025_0124_cross_analysis_summary_ha_mf_ag.tsv | cut -f2 | sort | uniq > tmp
tail -n +2 41467_2019_13035_moesm9_esm.csv | head -40 | cut -d, -f1 | sort | uniq >> tmp
sort tmp | uniq -d

tail -n +2 41467_2019_13035_moesm9_esm.csv | head -40 | cut -d, -f1 | sort | uniq | awk '{ print ">"$0; print $0}' > 41467_2019_13035_moesm9_esm.faa
```







##	20250507



```
tail -n +2 2025_0124_cross_analysis_summary_ha_mf_ag.tsv | cut -f2 | sort | uniq | awk '{ print ">Darwin-"$0; print $0}' > peptides.faa

./extract_sequences_and_mutate.bash >> peptides.faa

tail -n +2 13059_2023_3005_MOESM1_ESM-S5.csv | cut -d, -f3 | sort | uniq | awk '{ print ">NeoEpitope-"$0; print $0}' >> peptides.faa

tail -n +2 41467_2019_13035_moesm9_esm.csv | head -40 | cut -d, -f1 | sort | uniq | awk '{ print ">REdiscoverTE-"$0; print $0}' >> peptides.faa


phip_seq_create_tiles.bash -t 12 -o 0 -i peptides.faa
```



```
wc -l peptides.faa oligos-12-0.fasta
  5906 peptides.faa
  5886 oligos-12-0.fasta
 11792 total
```


```
sdiff -sd <( grep "^>" peptides.faa ) <( grep "^>" oligos-12-0.fasta | cut -d\| -f1 )
>IDH1:127-137:Original					      <
>KRAS:7-17:Original					      <
>KRAS:7-17:Original					      <
>NRAS:56-66:Original					      <
>NRAS:56-66:Mutation:Q61R				      <
>NRAS:56-66:Original					      <
>PTEN:125-135:Original					      <
>SMAD4:356-366:Original					      <
>TP53:243-253:Original					      <
>TP53:268-278:Original					      <
```
Most of these are due to the same hotspot having multiple mutations so the original is duplicated and then removed.



Note that NRAS and HRAS are very similar and these 2 Originals and Q61R mutations are identical

```
>HRAS:56-66:Original
LDTAGQEEYSA
>HRAS:56-66:Mutation:Q61R
LDTAGREEYSA

>NRAS:56-66:Original
LDTAGQEEYSA
>NRAS:56-66:Mutation:Q61R
LDTAGREEYSA

>NRAS:56-66:Original
LDTAGQEEYSA
>NRAS:56-66:Mutation:Q61K
LDTAGKEEYSA
```

So those 6 are reduced to just 3


The metadata table needs to show ...
```
HRAS:56-66:Original = NRAS:56-66:Original
HRAS:56-66:Mutation:Q61R = NRAS:56-66:Mutation:Q61R
```



##	20250519




There are some duplicate sequences which are filtered out so as to not create 2, however both should be given "credit" when aligned. Gonna need to figure that out later.

#awk -F, '(NR>1 && $13 != "None"){if(!seen[$13]){seen[$13]++;print ">"$1"-"$10"-"$15;print $13}}' s10_glioma_TCONS_subset.csv >> peptides.faa
#./extract_sequences_and_mutate.bash | paste - - | sort | uniq | awk '{if(!seen[$2]){seen[$2]++;print $1;print $2}}' >> peptides.faa



```
\rm *proteins.faa orf* cterm* protein_tiles* oligos* tmp*csv

cat << EOF


EOF


tail -n +2 2025_0124_cross_analysis_summary_ha_mf_ag.tsv | cut -f2 | sort | uniq | awk '{ print ">Darwin-"$0; print $0}' > proteins.faa

./extract_sequences_and_mutate.bash >> proteins.faa

tail -n +2 13059_2023_3005_MOESM1_ESM-S5.csv | cut -d, -f3 | sort | uniq | awk '{print ">NeoEpitope-"$0; print $0}' >> proteins.faa

tail -n +2 41467_2019_13035_moesm9_esm.csv | head -40 | cut -d, -f1 | sort | uniq | awk '{print ">REdiscoverTE-"$0; print $0}' >> proteins.faa

./BRCA_LAML_GBM_LGG_TCONS.bash >> proteins.faa

cat proteins.faa | paste - - | sort | awk '{print $1;print $2}' > sorted_proteins.faa

cat sorted_proteins.faa | paste - - | uniq | awk '{if(!seen[$2]){seen[$2]++;print $1;print $2}}' > unique_proteins.faa

grep -c "^>" proteins.faa unique_proteins.faa

#phip_seq_create_tiles.bash -t 56 -o 28 -i unique_proteins.faa
#phip_seq_create_tiles.bash -t 38 -o 19 -i unique_proteins.faa
phip_seq_create_tiles.bash -t 28 -o 14 -i unique_proteins.faa

grep -vs "^>" oligos-??-??.fasta > oligos.sequences.txt
wc -l oligos.sequences.txt


grep -vs "^[>0]" *.fasta.clstr


box_upload.bash *proteins.faa orf* cterm* protein_tiles* oligos*
```










##	20250527



There are some duplicate sequences which are filtered out so as to not create 2, however both should be given "credit" when aligned. Gonna need to figure that out later.




https://pubmed.ncbi.nlm.nih.gov/38815010/

We identified, from the literature, two nonsomatically mutated immunogenic pep- tides derived from HER2 that have been extensively characterized (20, 32, 33, 42–45). GP2 is a nine–amino acid immunogenic pep- tide derived from the transmembrane domain of HER2 (aa 654 to 662; IISAVVGIL), whereas E75 is a nine–amino acid peptide derived from the extracellular domain (aa 366 to 379; KIFGSLAFL).

Manually add those 2.




https://www.nature.com/articles/s41586-020-1969-6

Pan-cancer analysis of whole genomes

Supplementary Table 1. Sample, demographic and basic mutation data for the 2,583 white-listed donors in the PCAWG data-set

s41586-020-1969-6-SuppTable1.csv


New list of neoantigens from: https://genomebiology.biomedcentral.com/articles/10.1186/s13059-023-03005-9

Comprehensive analysis of neoantigens derived from structural variation across whole genomes from 2528 tumors - Genome Biology

neopeptides_shi.csv



Column K (histology abbrv) - all CNS-*, ICGC_DONOR - select just those samples
Or just CNS-GBM



```
awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}{print $3,$11}' s41586-020-1969-6-SuppTable1.csv | wc -l
2584

awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}($11~/^CNS-/){print $3,$11}' s41586-020-1969-6-SuppTable1.csv | wc -l
287

awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}($11~/^Breast-/){print $3}' s41586-020-1969-6-SuppTable1.csv | sort > s41586-020-1969-6-Breast.txt
awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}($11~/^Breast-AdenoCA/){print $3}' s41586-020-1969-6-SuppTable1.csv | sort > s41586-020-1969-6-Breast-AdenoCA.txt
awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}($11~/^Breast-DCIS/){print $3}' s41586-020-1969-6-SuppTable1.csv | sort > s41586-020-1969-6-Breast-DCIS.txt
awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}($11~/^Breast-LobularCA/){print $3}' s41586-020-1969-6-SuppTable1.csv | sort > s41586-020-1969-6-Breast-LobularCA.txt


awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}($11~/^CNS-/){print $3}' s41586-020-1969-6-SuppTable1.csv | sort > s41586-020-1969-6-CNS.txt
awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}($11=="CNS-GBM"){print $3}' s41586-020-1969-6-SuppTable1.csv | sort > s41586-020-1969-6-CNS-GBM.txt

awk -F, '(NR==FNR){ids[$1]++}(NR!=FNR){if(ids[$1])print $2}' s41586-020-1969-6-CNS-GBM.txt neopeptides_shi.csv | sort | uniq | wc -l
1236

awk -F, '(NR==FNR){ids[$1]++}(NR!=FNR){if(ids[$1])print $2}' s41586-020-1969-6-CNS.txt neopeptides_shi.csv | sort | uniq | wc -l
1639
```



```
\rm *proteins.faa orf* cterm* protein_tiles* oligos* tmp*csv

cat << EOF > proteins.faa
>Manual-HER2:654-662
IISAVVGIL
>Manual-HER2:366-379
KIFGSLAFL
EOF

awk -F, '(NR==FNR){ids[$1]++}(NR!=FNR){if(ids[$1])print $2}' s41586-020-1969-6-CNS-GBM.txt neopeptides_shi.csv | sort | uniq | awk '{print ">NeoPeptidesShi-"$0;print $0}' >> proteins.faa
tail -n +2 2025_0124_cross_analysis_summary_ha_mf_ag.tsv | cut -f2 | sort | uniq | awk '{ print ">Darwin-"$0; print $0}' >> proteins.faa
./extract_sequences_and_mutate.bash >> proteins.faa
tail -n +2 13059_2023_3005_MOESM1_ESM-S5.csv | cut -d, -f3 | sort | uniq | awk '{print ">NeoEpitope-"$0; print $0}' >> proteins.faa
tail -n +2 41467_2019_13035_moesm9_esm.csv | head -40 | cut -d, -f1 | sort | uniq | awk '{print ">REdiscoverTE-"$0; print $0}' >> proteins.faa
./BRCA_LAML_GBM_LGG_TCONS.bash >> proteins.faa
cat proteins.faa | paste - - | sort | awk '{print $1;print $2}' > sorted_proteins.faa
cat sorted_proteins.faa | paste - - | uniq | awk '{if(!seen[$2]){seen[$2]++;print $1;print $2}}' > unique_proteins.faa

grep -c "^>" proteins.faa unique_proteins.faa

phip_seq_create_tiles.bash -t 56 -o 28 -i unique_proteins.faa
#phip_seq_create_tiles.bash -t 38 -o 19 -i unique_proteins.faa
#phip_seq_create_tiles.bash -t 28 -o 14 -i unique_proteins.faa

grep -vs "^>" oligos-??-??.fasta > oligos.sequences.txt
wc -l oligos.sequences.txt

#	56 6089 CNS - 5691 - GBM
#	38 6833 CNS - 6431 - GBM
#	28 7657 CNS - 7259 - GBM

grep -vs "^[>0]" *.fasta.clstr


box_upload.bash *proteins.faa orf* cterm* protein_tiles* oligos*
```









##	20250528



-Tile across the gene EGFR, there may be multiple splice variants, let’s try to get them all if possible (just to fill up library)

ok, I think thsi is the AA sequence: LEEKKGNYVVTDH
It results from an in-frame deletion of exons 2–7 in the EGFR gene, which corresponds to a deletion of amino acids 6–273 in the extracellular domain of the wild-type EGFR protein.
lets also add this IDH1 neoepitope: PIIIGHHAYGDQYH


```
./create.bash

box_upload.bash *proteins.faa orf* cterm* protein_tiles* oligos* SelectTumorOnlyTranscriptIds.txt
```








##	20250605


Gonna need to create a cvs

Tile Id - 
Source or Family - VirScan, Darwin, TCONS, REdiscoverTE, FRa, NeoEpitope, NeoPeptideShi, ...
Group - 
Species - Human, HHV3, HHV5, ...
Public Epitope Flag - True or False only for VirScan source
Full Protein Given - 
Tiled Protein - 
Oligo - 


sorted_proteins.faa -> unique_proteins.faa -> protein_tiles-28-14.fasta -> oligos-ref-28-14.fasta

==> unique_proteins.faa <==
>CMV_11190
ARLDARLERELQKKLPAGGRLPVYRLGDEVPRRLESRFGRTVHALSRPFNGTTETC

==> protein_tiles-28-14.fasta <==
>CMV_11190|0-28
ARLDARLERELQKKLPAGGRLPVYRLGD

==> oligos-ref-28-14.fasta <==
>CMV_11190|0-28
GCCCGTCTTGATGCGCGCTTAGAACGTGAATTACAGAAGAAGCTGCCGGCGGGGGGCCGCCTGCCGGTTTATCGTCTGGGCGAT


cat oligos-ref-28-14.fasta | paste - - | awk 'BEGIN{OFS=","}{gsub("^>","",$1);print $1,$2}' | sort -t, -k1,1 | sed '1iname,oligo' > oligos-ref-28-14.csv
cat protein_tiles-28-14.fasta | paste - - | awk 'BEGIN{OFS=","}{gsub("^>","",$1);split($1,a,"|");print $1,a[1],$2}' | sort -t, -k1,1 | sed '1iname,group,peptide' > protein_tiles-28-14.csv
join --header -t, protein_tiles-28-14.csv oligos-ref-28-14.csv > protein_tiles-oligos-28-14.csv

cat unique_proteins.faa | paste - - | awk 'BEGIN{OFS=","}{gsub("^>","",$1);print $1,$2}' | sort -t, -k1,1 | sed '1igroup,protein' > unique_proteins.csv
cat sorted_proteins.faa | paste - - | awk 'BEGIN{OFS=","}{gsub("^>","",$1);print $1,$2}' | sort -t, -k1,1 | sed '1igroup,protein' > sorted_proteins.csv
#join --header -t, -a 1 -o auto sorted_proteins.csv unique_proteins.csv | more

#join --header -t, unique_proteins.csv protein_tiles-oligos-28-14.csv | wc -l

join -t, -1 1 -2 2 <( tail -n +2 unique_proteins.csv ) <( tail -n +2 protein_tiles-oligos-28-14.csv | sort -t, -k2,2 ) | sed '1iprotein_name,protein,tile_name,peptide,oligo' > protein_protein_tiles-oligos-28-14.csv

wc -l protein_tiles-28-14.csv oligos-ref-28-14.csv protein_tiles-oligos-28-14.csv protein_protein_tiles-oligos-28-14.csv



>HotSpot_APC:2303-2311:Mutation:S2307L|CTERM|STOP|C-PADDED-18
>VZV_YP_068407.1_capsid_scaffold_protein_Human_alphaherpesvirus_3|0-28
>VZV_YP_053044.1_membrane_protein_UL56_Human_alphaherpesvirus_3|CTERM|STOP
>HotSpot_EGFR:854-862:Original|CTERM|STOP|C-PADDED-18
>EGFR_HotSpot:1046-1054:Mutation:I1050V|CTERM|STOP|C-PADDED-18


try to find any sequences with to much similarity. not sure that there's anything to do about it.
makeblastdb -in oligos-ref-28-14.fasta -dbtype nucl -title oligos -out oligos
blastn -db oligos -query oligos-ref-28-14.fasta -outfmt 6 | more




How to denote duplicate proteins? 
Some are identical names and sequence and can be ignored.
Others need noted somehow.

```
for dup in $( cat proteins.faa | paste - - | sort | uniq | awk '{print $2}' | sort | uniq -d ) ; do echo "----"; cat proteins.faa | paste - - | sort | uniq | awk '{print $1;print $2}' | grep -B1 --no-group-separator "^${dup}$" ; done
```



Could just do this in the CSV and then regenerate any fasta files needed from the csv

Some corrections already. 

Drop _Human_alphaherpesvirus_3 from VZV sequence names. Unnecessary. (not sure that this is needed either)

```
sed -i -e "/^>RefSeqVZV_/s/_Human_alphaherpesvirus_3//" *protein*a oligos*a cterm_tiles-28-14.fasta orf_tiles-28-14.fasta 
```


Add the species to the public epitope name. Something like ... (not sure that this is really needed)
```
for regex in $( grep "Human herpes" /francislab/data1/refs/PhIP-Seq/VirScan/public_epitope_annotations.join_sorted.csv | awk -F, '{gsub(/ /,"-",$2);print "s/\\>VirScanPublicEpitope_"$1"\\$/\\>VirScanPublicEpitope_"$2"_"$1"/";print "s/\\>VirScanPublicEpitope_"$1"\\|/\\>VirScanPublicEpitope_"$2"_"$1"\\|/" }' ); do
echo sed -i $regex *protein*a oligos*a cterm_tiles-28-14.fasta orf_tiles-28-14.fasta
done | bash
```







##	20250609

build_csv.bash


11997


```
module load blast
awk -F, '(NR>1){print ">"$1;print $7}' neoantigen_dataset.csv > neoantigen.fna
makeblastdb -in neoantigen.fna -dbtype nucl -title neoantigens -out neoantigens
blastn -task megablast -db neoantigens -query neoantigen.fna -outfmt 6 -out neoantigen_neoantigens.megablast.tsv
blastn -task blastn -db neoantigens -query neoantigen.fna -outfmt 6 -out neoantigen_neoantigens.blastn.tsv
```

Not all align for some reason.



```
module load bowtie2
bowtie2-build neoantigens neoantigen.fna
bowtie2 -f -x ${PWD}/neoantigens -U neoantigen.fna 2>/dev/null | awk '($1!~/^@/ && $5<42)' 

7710	0	7710	1	36	84M	*	0	0	CCGCCGCCGCCGTTACCGGGTGCAGGTATCCCGCCGCCGCCGCCGCTTCCGGGTGCGGGTATCCCGCCGCCGCCGCCGCTGCCG	IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII	AS:i:0	XS:i:-32	XN:i:0	XM:i:0	XO:i:0	XG:i:0	NM:i:0	MD:Z:84	YT:Z:UU
7714	0	7714	1	38	84M	*	0	0	CCGCCGCCGTTGCCGGGTGCAGGTATCCCGCCGCCGCCGCCGCTTCCGGGTGCCGGCATCCCGCCGCCGCCGCCGCTGCCGGGG	IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII	AS:i:0	XS:i:-44	XN:i:0	XM:i:0	XO:i:0	XG:i:0	NM:i:0	MD:Z:84	YT:Z:UU

bowtie2 -a -f -x ${PWD}/neoantigens -U neoantigen.fna 2>/dev/null | awk '($1!~/^@/ && $2>0)' 
7710	256	7714	1	255	1M3I80M	*	0	0	CCGCCGCCGCCGTTACCGGGTGCAGGTATCCCGCCGCCGCCGCCGCTTCCGGGTGCGGGTATCCCGCCGCCGCCGCCGCTGCCG	IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII	AS:i:-32	XS:i:-3XN:i:0	XM:i:3	XO:i:1	XG:i:3	NM:i:6	MD:Z:11G41C2C24	YT:Z:UU
7714	256	7710	4	255	77M3I4M	*	0	0	CCGCCGCCGTTGCCGGGTGCAGGTATCCCGCCGCCGCCGCCGCTTCCGGGTGCCGGCATCCCGCCGCCGCCGCCGCTGCCGGGG	IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII	AS:i:-44	XS:i:-4XN:i:0	XM:i:5	XO:i:1	XG:i:3	NM:i:8	MD:Z:11A41G2T21C0C1	YT:Z:UU
```

So 7710 is similar to 7714




```
module load blast
awk -F, '(NR>1){print ">"$1;print $7}' neoantigen_dataset.csv > neoantigen.fna
cut -d, -f1,6 neoantigen_dataset.csv | cut -d\* -f1 | awk -F, '(NR>1){print ">"$1;print $2}' > neoantigen.faa
makeblastdb -in neoantigen.faa -dbtype prot -title neoantigens -out neoantigens

blastp -db neoantigens -query neoantigen.faa -outfmt 6 -out neoantigen_neoantigens.blastp.tsv

```



