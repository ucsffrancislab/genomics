

S1

```

echo "Transcript ID,Subfam,Chr TE,Start TE,End TE,Location TE,Gene,Splice Target,Strand,ACC_tumor,ACC_normal,BLCA_tumor,BLCA_normal,BRCA_tumor,BRCA_normal,CESC_tumor,CESC_normal,CHOL_tumor,CHOL_normal,COAD_tumor,COAD_normal,DLBC_tumor,DLBC_normal,ESCA_tumor,ESCA_normal,GBM_tumor,GBM_normal,HNSC_tumor,HNSC_normal,KICH_tumor,KICH_normal,KIRC_tumor,KIRC_normal,KIRP_tumor,KIRP_normal,LAML_tumor,LAML_normal,LGG_tumor,LGG_normal,LIHC_tumor,LIHC_normal,LUAD_tumor,LUAD_normal,LUSC_tumor,LUSC_normal,MESO_tumor,MESO_normal,OV_tumor,OV_normal,PAAD_tumor,PAAD_normal,PCPG_tumor,PCPG_normal,PRAD_tumor,PRAD_normal,READ_tumor,READ_normal,SARC_tumor,SARC_normal,SKCM_tumor,SKCM_normal,STAD_tumor,STAD_normal,TGCT_tumor,TGCT_normal,THCA_tumor,THCA_normal,THYM_tumor,THYM_normal,UCEC_tumor,UCEC_normal,UCS_tumor,UCS_normal,UVM_tumor,UVM_normal,Adipose Tissue_gtex,Ovary_gtex,Vagina_gtex,Breast_gtex,Salivary Gland_gtex,Adrenal Gland_gtex,Spleen_gtex,Esophagus_gtex,Prostate_gtex,Testis_gtex,Nerve_gtex,Brain_gtex,Thyroid_gtex,Lung_gtex,Skin_gtex,Blood_gtex,Blood Vessel_gtex,Pituitary_gtex,Heart_gtex,Colon_gtex,Pancreas_gtex,Stomach_gtex,Muscle_gtex,Small Intestine_gtex,Uterus_gtex,Kidney_gtex,Liver_gtex,Cervix Uteri_gtex,Bladder_gtex,Fallopian Tube_gtex,Tumor Total,Normal Total,GTEx Total,GTEx Total without Testis" | awk -F, '{for(i=1;i<=NF;i++){print i " - " $i}}'

```

```
1 - Transcript ID
2 - Subfam
3 - Chr TE
4 - Start TE
5 - End TE
6 - Location TE
7 - Gene
8 - Splice Target
9 - Strand
10 - ACC_tumor
11 - ACC_normal
12 - BLCA_tumor
13 - BLCA_normal
14 - BRCA_tumor
15 - BRCA_normal
16 - CESC_tumor
17 - CESC_normal
18 - CHOL_tumor
19 - CHOL_normal
20 - COAD_tumor
21 - COAD_normal
22 - DLBC_tumor
23 - DLBC_normal
24 - ESCA_tumor
25 - ESCA_normal
26 - GBM_tumor
27 - GBM_normal
28 - HNSC_tumor
29 - HNSC_normal
30 - KICH_tumor
31 - KICH_normal
32 - KIRC_tumor
33 - KIRC_normal
34 - KIRP_tumor
35 - KIRP_normal
36 - LAML_tumor
37 - LAML_normal
38 - LGG_tumor
39 - LGG_normal
40 - LIHC_tumor
41 - LIHC_normal
42 - LUAD_tumor
43 - LUAD_normal
44 - LUSC_tumor
45 - LUSC_normal
46 - MESO_tumor
47 - MESO_normal
48 - OV_tumor
49 - OV_normal
50 - PAAD_tumor
51 - PAAD_normal
52 - PCPG_tumor
53 - PCPG_normal
54 - PRAD_tumor
55 - PRAD_normal
56 - READ_tumor
57 - READ_normal
58 - SARC_tumor
59 - SARC_normal
60 - SKCM_tumor
61 - SKCM_normal
62 - STAD_tumor
63 - STAD_normal
64 - TGCT_tumor
65 - TGCT_normal
66 - THCA_tumor
67 - THCA_normal
68 - THYM_tumor
69 - THYM_normal
70 - UCEC_tumor
71 - UCEC_normal
72 - UCS_tumor
73 - UCS_normal
74 - UVM_tumor
75 - UVM_normal
76 - Adipose Tissue_gtex
77 - Ovary_gtex
78 - Vagina_gtex
79 - Breast_gtex
80 - Salivary Gland_gtex
81 - Adrenal Gland_gtex
82 - Spleen_gtex
83 - Esophagus_gtex
84 - Prostate_gtex
85 - Testis_gtex
86 - Nerve_gtex
87 - Brain_gtex
88 - Thyroid_gtex
89 - Lung_gtex
90 - Skin_gtex
91 - Blood_gtex
92 - Blood Vessel_gtex
93 - Pituitary_gtex
94 - Heart_gtex
95 - Colon_gtex
96 - Pancreas_gtex
97 - Stomach_gtex
98 - Muscle_gtex
99 - Small Intestine_gtex
100 - Uterus_gtex
101 - Kidney_gtex
102 - Liver_gtex
103 - Cervix Uteri_gtex
104 - Bladder_gtex
105 - Fallopian Tube_gtex
106 - Tumor Total
107 - Normal Total
108 - GTEx Total
109 - GTEx Total without Testis
```


```
echo "Transcript ID,Subfam,Chr TE,Start TE,End TE,Location TE,Gene,Splice Target,Strand,Index of Start Codon,Frame,Frame Type,Protein Sequence,Original Protein Sequence,Strategy,,," | awk -F, '{for(i=1;i<=NF;i++){print i " - " $i}}'
1 - Transcript ID
2 - Subfam
3 - Chr TE
4 - Start TE
5 - End TE
6 - Location TE
7 - Gene
8 - Splice Target
9 - Strand
10 - Index of Start Codon
11 - Frame
12 - Frame Type
13 - Protein Sequence
14 - Original Protein Sequence
15 - Strategy
16 - 
17 - 
18 - 
```

```
tail -n +3 41588_2023_1349_MOESM3_ESM/S10.csv | sort -k1,1 -k10n,10 | awk 'BEGIN{FS=OFS=","}($13!="None"){print ">"$1"-"$10;print $13}' | grep -c "^>"
2834

tail -n +3 41588_2023_1349_MOESM3_ESM/S10.csv | sort -k1,1 -k10n,10 | awk 'BEGIN{FS=OFS=","}($13!="None"){print ">"$1"-"$10;print $13}' > S10.faa

makeblastdb -in S10.faa -input_type fasta -dbtype prot -out S10 -title S10 -parse_seqids
```

```

awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")"}($8=="\"\""){print}' AllergenOnline.csv
"Secale cereale","Rye","Sec c 38.0101","Aero Plant","Secale Sec c 38.01","IgE plus basophil+ or SPT+","26","","75198875","7"

```


```

mkdir AllergenOnline
for acc in $( awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")"}{print $8}' AllergenOnline.csv | tr -d \" | tail -n +2 ) ; do
echo $acc
efetch -db protein -format fasta -id $acc > AllergenOnline/${acc}.faa
done


# | sed  -e '/^>/s/[],()\/[]//g' -e '/^>/s/->//g' -e '/^>/s/ /_/g' -e 's/'\''//g' -e '/^>/s/\(^.\{1,51\}\).*/\1/' -e '/^>/s/>\(.*\)$/>\1 \1/g'

cat AllergenOnline/*.faa | sed -e '/^>/s/[], ():;,=\/[]/_/g' -e '/^>/s/__/_/g' -e '/^>/s/\(^.\{1,51\}\).*/\1/' > AllergenOnline.faa
makeblastdb -in AllergenOnline.faa -input_type fasta -dbtype prot -out AllergenOnline -title AllergenOnline -parse_seqids

```


```

head -2 41588_2023_1349_MOESM3_ESM/S10.csv | tail -n 1 > 41588_2023_1349_MOESM3_ESM/S10.sorted.csv
tail -n +3 41588_2023_1349_MOESM3_ESM/S10.csv | sort -d -k1,1 >> 41588_2023_1349_MOESM3_ESM/S10.sorted.csv

echo TranscriptID > GBM_tumor_gte_10_TranscriptID.txt
tail -n +3 41588_2023_1349_MOESM3_ESM/S1.csv | awk -F, '($26>=10){print $1}' | sort >> GBM_tumor_gte_10_TranscriptID.txt

join --header -t, GBM_tumor_gte_10_TranscriptID.txt 41588_2023_1349_MOESM3_ESM/S10.sorted.csv | awk -F, '(NR>1 && $13!="None"){print ">"$1"-"$10;print $13}' > S10_GBM_tumor_gte_10.faa

makeblastdb -in S10_GBM_tumor_gte_10.faa -input_type fasta -dbtype prot -out S10_GBM_tumor_gte_10 -title S10_GBM_tumor_gte_10 -parse_seqids

```


```

tail -n +2 AllergenOnline.csv | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")"}($8!="\"\"" && $4~/(Aero|airway)/){print "cat AllergenOnline/"$8".faa"}' | tr -d \" | sh | sed -e '/^>/s/[], ():;,=\/[]/_/g' -e '/^>/s/__/_/g' -e '/^>/s/\(^.\{1,51\}\).*/\1/' > AllergenOnlineAir.faa
makeblastdb -in AllergenOnlineAir.faa -input_type fasta -dbtype prot -out AllergenOnlineAir -title AllergenOnlineAir -parse_seqids

```


```

for e in 0.05 0.005 0.0005 ; do
for a in AllergenOnline AllergenOnlineAir ; do
for s in S10 S10_GBM_tumor_gte_10 ; do

echo -e "qaccver\tsaccver\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore" \
  > ${a}_IN_${s}.blastp.e${e}.tsv
blastp -db ${s} -outfmt 6 \
  -query ${a}.faa -evalue ${e} >> ${a}_IN_${s}.blastp.e${e}.tsv &

echo -e "qaccver\tsaccver\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore" \
  > ${s}_IN_${a}.blastp.e${e}.tsv
blastp -db ${a} -outfmt 6 \
  -query ${s}.faa -evalue ${e} >> ${s}_IN_${a}.blastp.e${e}.tsv &

done ; done ; done

```





##	20240523




```
echo TranscriptID > GBM_tumor_gte_1_TranscriptID.txt
tail -n +3 41588_2023_1349_MOESM3_ESM/S1.csv | awk -F, '($26>=1){print $1}' | sort >> GBM_tumor_gte_1_TranscriptID.txt

join --header -t, GBM_tumor_gte_1_TranscriptID.txt 41588_2023_1349_MOESM3_ESM/S10.sorted.csv | awk -F, '(NR>1 && $13!="None"){print ">"$1"-"$10;print $13}' > S10_GBM_tumor_gte_1.faa

makeblastdb -in S10_GBM_tumor_gte_1.faa -input_type fasta -dbtype prot -out S10_GBM_tumor_gte_1 -title S10_GBM_tumor_gte_1 -parse_seqids

```



```

for e in 10 0.5 0.05 0.005 0.0005 ; do
for a in AllergenOnline AllergenOnlineAir ; do
for s in S10 S10_GBM_tumor_gte_10 S10_GBM_tumor_gte_1 ; do

echo -e "qaccver\tsaccver\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore" \
  > ${a}_IN_${s}.blastp.e${e}.tsv
blastp -db ${s} -outfmt 6 \
  -query ${a}.faa -evalue ${e} >> ${a}_IN_${s}.blastp.e${e}.tsv &

echo -e "qaccver\tsaccver\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore" \
  > ${s}_IN_${a}.blastp.e${e}.tsv
blastp -db ${a} -outfmt 6 \
  -query ${s}.faa -evalue ${e} >> ${s}_IN_${a}.blastp.e${e}.tsv &

done ; done ; done

```




##	20240528



One thing I could use a hand with is making a heat map based in you allergens/TCONS you already made. (edited) 

Its just for the grant and just needs to look pretty

based on the blast results?

yep- I’m not sure which one to use though. Maybe the 0.05 in GBM?
I also wonder if we should run the food set also?

you want a heat map of bitscores?
What food set?
i see
Was I correct calling "Aero" the respiratory?
and "airway"

Yes- but I noticed that some area really really high. I think you ran the whole protein not the tile?
That is OK for this… we just need to scale it or something

It would be good to be able to have “Respiratory” and “Food” sections on the heat map.
I think animal and plant is good

Yes, I used the full length Allergen and TCONS transcripts

Perfectly fine for this, we could just cap the bit score at 40 or something for plotting









```

tail -n +2 AllergenOnline.csv | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")"}($8!="\"\"" && $4~/(Food)/){print "cat AllergenOnline/"$8".faa"}' | tr -d \" | sh | sed -e '/^>/s/[], ():;,=\/[]/_/g' -e '/^>/s/__/_/g' -e '/^>/s/\(^.\{1,51\}\).*/\1/' > AllergenOnlineFood.faa
makeblastdb -in AllergenOnlineFood.faa -input_type fasta -dbtype prot -out AllergenOnlineFood -title AllergenOnlineFood -parse_seqids

```


```

for e in 10 0.5 0.05 0.005 0.0005 ; do
for a in AllergenOnlineFood ; do
for s in S10 S10_GBM_tumor_gte_10 S10_GBM_tumor_gte_1 ; do

echo -e "qaccver\tsaccver\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore" \
  > ${a}_IN_${s}.blastp.e${e}.tsv
blastp -db ${s} -outfmt 6 \
  -query ${a}.faa -evalue ${e} >> ${a}_IN_${s}.blastp.e${e}.tsv &

echo -e "qaccver\tsaccver\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore" \
  > ${s}_IN_${a}.blastp.e${e}.tsv
blastp -db ${a} -outfmt 6 \
  -query ${s}.faa -evalue ${e} >> ${s}_IN_${a}.blastp.e${e}.tsv &

done ; done ; done

```







```

./blast_bitscore_heatmap.Rmd S10_GBM_tumor_gte_1_IN_AllergenOnlineAir.blastp.e0.5.tsv 
./blast_bitscore_heatmap.Rmd S10_GBM_tumor_gte_1_IN_AllergenOnlineFood.blastp.e0.5.tsv 
./blast_bitscore_heatmap.Rmd AllergenOnlineAir_IN_S10_GBM_tumor_gte_1.blastp.e0.5.tsv
./blast_bitscore_heatmap.Rmd AllergenOnlineFood_IN_S10_GBM_tumor_gte_1.blastp.e0.5.tsv

./blast_bitscore_heatmap.Rmd S10_GBM_tumor_gte_1_IN_AllergenOnlineAir.blastp.e0.05.tsv 
./blast_bitscore_heatmap.Rmd S10_GBM_tumor_gte_1_IN_AllergenOnlineFood.blastp.e0.05.tsv 
./blast_bitscore_heatmap.Rmd AllergenOnlineAir_IN_S10_GBM_tumor_gte_1.blastp.e0.05.tsv
./blast_bitscore_heatmap.Rmd AllergenOnlineFood_IN_S10_GBM_tumor_gte_1.blastp.e0.05.tsv




```



```
open S10_GBM_tumor_gte_1_IN_*blastp.e0.5.heatmap.html *_IN_S10_GBM_tumor_gte_1.blastp.e0.5.heatmap.html
```








##	Deving a shiny app to allow for some playing with the heatmap

```

R -e "library(shiny);runApp(launch.browser = TRUE)"

```
