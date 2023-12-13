
#	Creating a viral protein / bit score version of S1.




##	Some source commands

```
tail -n +2 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | head -1 > S1.csv
tail -n +3 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | sort -t, -k1,1 >> S1.csv

tail -n +2 41588_2023_1349_MOESM3_ESM/S1.csv | cut -d, -f1,10-75 | head -1 | sed -e 's/_tumor/_Tumor/g' -e 's/_normal/_Normal/g' > S1.sorted.csv
tail -n +3 41588_2023_1349_MOESM3_ESM/S1.csv | cut -d, -f1,10-75 | sort -t, -k1,1 >> S1.sorted.csv
```

```
echo "virus,accession,with_version,with_description" > herpes_protein_virus_translation_table.csv
grep "_Human_" viral.protein.names.txt | grep herpes | sed -e 's/^>//' | awk 'BEGIN{FS=OFS="_"}{print $1,$2","$0}' | awk 'BEGIN{FS=".";OFS=","}{print $1,$0}' | awk 'BEGIN{FS="_Human";OFS=","}{print "Human"$NF,$0}' | sort >> herpes_protein_virus_translation_table.csv

cut -d, -f1 herpes_protein_virus_translation_table.csv | uniq> herpes_virus_abbreviation_translation_table.csv 
```

```
echo "accession,withversion,description" > Human_alphaherpesvirus_3.protein_translation_table.csv
ls -1 /francislab/data1/refs/refseq/viral-20220923/viral.protein/*_Human_alphaherpesvirus_3.fa | cut -d/ -f8 | sed 's/_Human_alphaherpesvirus_3.fa//' | awk 'BEGIN{OFS=","}{split($0,a,".");split($0,b,"_");print a[1],b[1]"_"b[2],$0}' >> Human_alphaherpesvirus_3.protein_translation_table.csv


join --header -t, /francislab/data1/refs/refseq/viral-20220923/herpes_virus_abbreviation_translation_table.csv \
  /francislab/data1/refs/refseq/viral-20220923/herpes_protein_virus_translation_table.csv > tmp1


head -3 tmp1
virus,abbreviation,accession,with_version,with_description
Human_alphaherpesvirus_1,HHV1,YP_009137073,YP_009137073.1,YP_009137073.1_neurovirulence_protein_ICP34.5_Human_alphaherpesvirus_1
Human_alphaherpesvirus_1,HHV1,YP_009137074,YP_009137074.1,YP_009137074.1_ubiquitin_E3_ligase_ICP0_Human_alphaherpesvirus_1
```

```
sed 's/\t/,/g' S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.tsv \
  | awk 'BEGIN{FS=OFS=","}(NR>1){split($1,a,"_");split($2,b,".");print a[1]"_"a[2],b[1],$NF}' > tmp2

head -3 tmp2
TCONS_00000246,YP_081561,24.6
TCONS_00000246,YP_081561,24.6
TCONS_00000246,YP_081561,24.6

sort -t, -k1,2 -k3nr tmp2 | uniq | head
TCONS_00000246,NP_050190,23.9
TCONS_00000246,YP_081561,24.6
TCONS_00000667,YP_001129455,25.8
TCONS_00000667,YP_001129455,24.3
TCONS_00000667,YP_401658,25.8
TCONS_00000667,YP_401658,24.3
TCONS_00000802,YP_009137100,24.3
TCONS_00000820,NP_040188,26.9
TCONS_00000820,NP_040188,26.6
TCONS_00000820,NP_040188,26.2

sort -t, -k1,2 -k3nr tmp2 | uniq | awk 'BEGIN{FS=OFS=","}( k[$1][$2] == "" ){k[$1][$2]=$3;print $2,$1,$3}' | head
NP_050190,TCONS_00000246,23.9
YP_081561,TCONS_00000246,24.6
YP_001129455,TCONS_00000667,25.8
YP_401658,TCONS_00000667,25.8
YP_009137100,TCONS_00000802,24.3
NP_040188,TCONS_00000820,26.9
YP_009137138,TCONS_00000820,28.5
YP_009137215,TCONS_00000820,27.3
YP_081510,TCONS_00000820,23.9
YP_001129393,TCONS_00001232,24.3
```


```
sort -t, -k1,2 -k3nr tmp2 | uniq | awk 'BEGIN{FS=OFS=","}( k[$1][$2] == "" ){k[$1][$2]=$3;print $2,$1,$3}' | sort -t, -k1,2 > tmp3

head -3 tmp3
NP_040125,TCONS_00071958,25.8
NP_040125,TCONS_00115919,24.3
NP_040127,TCONS_00037379,25.4

tail -n +2 tmp1 | awk 'BEGIN{FS=OFS=","}{print $3,$2}' | sort -t, -k1,2 | uniq > tmp4
head -3 tmp4
NP_040124,HHV3
NP_040125,HHV3
NP_040126,HHV3


echo "virus,protein,TCONS,bitscore" > virus_protein_TCONS_bitscore.csv
join -t, tmp4 tmp3 | awk 'BEGIN{FS=OFS=","}{print $2,$1,$3,$4}' | sort -t, -k1,3 >> virus_protein_TCONS_bitscore.csv

head -3 virus_protein_TCONS_bitscore.csv
virus,protein,TCONS,bitscore
HHV1,YP_009137074,TCONS_00009055,33.9
HHV1,YP_009137074,TCONS_00030850,31.6

box_upload.bash virus_protein_TCONS_bitscore.csv
```










##	Theory

convert

```
             t, A, B, C, D
TCONS_00000246, 0, 0, 1, 5
TCONS_00028179, 0, 5, 0, 3
TCONS_00028180, 5, 1, 2, 0
```

via

```
   v,         p,          TCONS, bitscore
HHV5, YP_081561, TCONS_00000246, 45
HHV5, YP_081561, TCONS_00028179, 35
HHV5, YP_081561, TCONS_00028180, 25
```

to

```
   v,         p,   A,  B,  C,  D
HHV5, YP_081561,  25, 35, 45, 45
```




##	Get some references


Getting some reference files. Not sure if I need them all.

```
scp c4:/francislab/data1/refs/refseq/viral-20220923/herpes_protein_virus_translation_table.csv ./
scp c4:/francislab/data1/refs/refseq/viral-20220923/herpes_virus_abbreviation_translation_table.csv ./
scp c4:/francislab/data1/refs/refseq/viral-20220923/viral.protein.names.txt ./

scp c4:/francislab/data1/refs/TEProf2/S1.sorted* ./
scp c4:/francislab/data1/refs/TEProf2/TCONS_viral_protein_translation_table.* ./
scp c4:/francislab/data1/refs/TEProf2/TCGA_Expression.select.translated.present.sample_aggregated_by_study.csv ./
scp c4:/francislab/data1/refs/TEProf2/TCGA_Expression.select.translated.present.csv ./

scp c4:/francislab/data1/refs/refseq/viral-20220923/virus_translation_table*csv ./


scp c4:/francislab/data1/working/20230426-PanCancerAntigens/20231011-focused_blasting/virus_protein_TCONS_bitscore.csv ./
scp c4:/francislab/data1/working/20230426-PanCancerAntigens/20231011-focused_blasting/S10_All_ProteinSequences_fragments_in_*proteins.blast*5.tsv ./
scp c4:/francislab/data1/working/20230426-PanCancerAntigens/20231011-focused_blasting/S1.csv ./

scp c4:/francislab/data1/refs/refseq/viral-20220923/viral.protein/NP_040188.1_serine-threonine_protein_kinase_US3_Human_alphaherpesvirus_3.fa ./


scp c4:/francislab/data1/refs/refseq/viral-20231129/virus_taxonomy_tree_translation_table.20231122.csv ./

```



##	Start with S1 so get all studies



head S1.csv 
Transcript ID,Subfam,Chr TE,Start TE,End TE,Location TE,Gene,Splice Target,Strand,ACC_tumor,ACC_normal,BLCA_tumor,BLCA_normal,BRCA_tumor,BRCA_normal,CESC_tumor,CESC_normal,CHOL_tumor,CHOL_normal,COAD_tumor,COAD_normal,DLBC_tumor,DLBC_normal,ESCA_tumor,ESCA_normal,GBM_tumor,GBM_normal,HNSC_tumor,HNSC_normal,KICH_tumor,KICH_normal,KIRC_tumor,KIRC_normal,KIRP_tumor,KIRP_normal,LAML_tumor,LAML_normal,LGG_tumor,LGG_normal,LIHC_tumor,LIHC_normal,LUAD_tumor,LUAD_normal,LUSC_tumor,LUSC_normal,MESO_tumor,MESO_normal,OV_tumor,OV_normal,PAAD_tumor,PAAD_normal,PCPG_tumor,PCPG_normal,PRAD_tumor,PRAD_normal,READ_tumor,READ_normal,SARC_tumor,SARC_normal,SKCM_tumor,SKCM_normal,STAD_tumor,STAD_normal,TGCT_tumor,TGCT_normal,THCA_tumor,THCA_normal,THYM_tumor,THYM_normal,UCEC_tumor,UCEC_normal,UCS_tumor,UCS_normal,UVM_tumor,UVM_normal,Adipose Tissue_gtex,Ovary_gtex,Vagina_gtex,Breast_gtex,Salivary Gland_gtex,Adrenal Gland_gtex,Spleen_gtex,Esophagus_gtex,Prostate_gtex,Testis_gtex,Nerve_gtex,Brain_gtex,Thyroid_gtex,Lung_gtex,Skin_gtex,Blood_gtex,Blood Vessel_gtex,Pituitary_gtex,Heart_gtex,Colon_gtex,Pancreas_gtex,Stomach_gtex,Muscle_gtex,Small Intestine_gtex,Uterus_gtex,Kidney_gtex,Liver_gtex,Cervix Uteri_gtex,Bladder_gtex,Fallopian Tube_gtex,Tumor Total,Normal Total,GTEx Total,GTEx Total without Testis
TCONS_00000050,AluY,chr1,928111,928412,intron_2,SAMD11,exon_3,+,2,0,8,0,36,0,7,0,1,0,2,0,0,0,4,0,0,0,2,0,0,5,12,0,16,1,4,0,21,0,1,0,4,0,5,0,10,0,42,0,6,0,17,0,20,1,0,0,21,0,2,0,8,1,14,0,18,1,0,0,45,4,9,0,0,0,5,8,4,7,0,6,31,32,32,49,15,2,24,19,15,0,54,85,34,14,2,8,1,14,13,12,6,0,1,1,337,13,494,445
TCONS_00000056,L2a,chr1,968519,968877,intron_2,PLEKHN1,exon_3,+,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

```
sed '1s/ /_/g' S1.csv | cut -d, -f1,10- | tr -d "\r" > S1._.csv

echo "Transcript_ID,Study_SampleType,Count" > S1.list.csv
awk 'BEGIN{FS=OFS=","}(NR==1){for(i=2;i<=NF;i++){k[i]=$i}}(NR>1){ for(i=2;i<=NF;i++){if($i>0){print $1,k[i],$i}}}' S1._.csv >> S1.list.csv


echo "Transcript_ID,virus,protein,bitscore" > TCONS_virus_protein_bitscore.csv
tail -n +2 virus_protein_TCONS_bitscore.csv | awk 'BEGIN{FS=OFS=","}{print $3,$1,$2,$4}' | sort -t, -k1,3 >> TCONS_virus_protein_bitscore.csv



join --header -t, TCONS_virus_protein_bitscore.csv S1.list.csv > tmp1

head -3 tmp1
Transcript_ID,virus,protein,bitscore,Study_SampleType,Count
TCONS_00000246,HHV5,YP_081561,24.6,LUAD_tumor,5
TCONS_00000246,HHV5,YP_081561,24.6,STAD_tumor,1


awk 'BEGIN{FS=OFS=","}{print $2,$3,$5,$4}' tmp1 > tmp2

head -3 tmp2
virus,protein,Study_SampleType,bitscore
HHV5,YP_081561,LUAD_tumor,24.6
HHV5,YP_081561,STAD_tumor,24.6

echo "virus,protein,Study_SampleType,bitscore" > tmp3
tail -n +2 tmp2 | sort -t, -k1,3 -k4nr >> tmp3

head tmp3
virus,protein,Study_SampleType,bitscore
HHV1,YP_009137074,ACC_tumor,30.4
HHV1,YP_009137074,BLCA_tumor,38.1
HHV1,YP_009137074,BLCA_tumor,27.3
HHV1,YP_009137074,BLCA_tumor,24.6
HHV1,YP_009137074,BRCA_tumor,38.1
HHV1,YP_009137074,BRCA_tumor,31.6
HHV1,YP_009137074,BRCA_tumor,24.6
HHV1,YP_009137074,BRCA_tumor,24.3
HHV1,YP_009137074,CESC_tumor,31.6


echo "virus,protein,Study_SampleType,bitscore" > tmp4
tail -n +2 tmp3 | awk 'BEGIN{FS=OFS=","}( k[$1][$2][$3] == "" ){k[$1][$2][$3]=$4;print $1,$2,$3,$4}' >> tmp4

head tmp4
virus,protein,Study_SampleType,bitscore
HHV1,YP_009137074,ACC_tumor,30.4
HHV1,YP_009137074,BLCA_tumor,38.1
HHV1,YP_009137074,BRCA_tumor,38.1
HHV1,YP_009137074,CESC_tumor,31.6
HHV1,YP_009137074,CHOL_tumor,27.3
HHV1,YP_009137074,COAD_tumor,31.6
HHV1,YP_009137074,ESCA_tumor,27.3
HHV1,YP_009137074,GBM_tumor,24.3
HHV1,YP_009137074,GTEx_Total,33.9



awk 'BEGIN{FS=OFS=",";split("ACC_tumor,ACC_normal,BLCA_tumor,BLCA_normal,BRCA_tumor,BRCA_normal,CESC_tumor,CESC_normal,CHOL_tumor,CHOL_normal,COAD_tumor,COAD_normal,DLBC_tumor,DLBC_normal,ESCA_tumor,ESCA_normal,GBM_tumor,GBM_normal,HNSC_tumor,HNSC_normal,KICH_tumor,KICH_normal,KIRC_tumor,KIRC_normal,KIRP_tumor,KIRP_normal,LAML_tumor,LAML_normal,LGG_tumor,LGG_normal,LIHC_tumor,LIHC_normal,LUAD_tumor,LUAD_normal,LUSC_tumor,LUSC_normal,MESO_tumor,MESO_normal,OV_tumor,OV_normal,PAAD_tumor,PAAD_normal,PCPG_tumor,PCPG_normal,PRAD_tumor,PRAD_normal,READ_tumor,READ_normal,SARC_tumor,SARC_normal,SKCM_tumor,SKCM_normal,STAD_tumor,STAD_normal,TGCT_tumor,TGCT_normal,THCA_tumor,THCA_normal,THYM_tumor,THYM_normal,UCEC_tumor,UCEC_normal,UCS_tumor,UCS_normal,UVM_tumor,UVM_normal,Adipose_Tissue_gtex,Ovary_gtex,Vagina_gtex,Breast_gtex,Salivary_Gland_gtex,Adrenal_Gland_gtex,Spleen_gtex,Esophagus_gtex,Prostate_gtex,Testis_gtex,Nerve_gtex,Brain_gtex,Thyroid_gtex,Lung_gtex,Skin_gtex,Blood_gtex,Blood_Vessel_gtex,Pituitary_gtex,Heart_gtex,Colon_gtex,Pancreas_gtex,Stomach_gtex,Muscle_gtex,Small_Intestine_gtex,Uterus_gtex,Kidney_gtex,Liver_gtex,Cervix_Uteri_gtex,Bladder_gtex,Fallopian_Tube_gtex,Tumor_Total,Normal_Total,GTEx_Total,GTEx_Total_without_Testis",cols,",")}(NR>1){bitscores[$1][$2][$3]=$4}END{
s="virus,protein"
for(c in cols){
s=s","cols[c]
}print s

for(v in bitscores){
for(p in bitscores[v]){
s=v","p
for(c in cols){
if( bitscores[v][p][cols[c]]>0 ){
s=s","bitscores[v][p][cols[c]]
}else{
s=s","0
}}
print s
}}

}' tmp4 > tmp5

head -1 tmp5 > S1_virus_protein_bitscore.csv
tail -n +2 tmp5 | sort -t, -k1,2 >> S1_virus_protein_bitscore.csv

```






##	20231120

```
./S1_virus_protein_bitscore.heatmap.py 
```




##	20231121

Can we also take a crack at all ‘human’ viruses? I know it will be messy


```
cat /francislab/data1/refs/refseq/viral-20220923/viral.protein/*_Human_*.fa | sed  -e "/^>/s/'//g" -e '/^>/s/,//g' -e '/^>/s/->//g' -e '/^>/s/\(^.\{1,51\}\).*/\1/' -e '/^>/s/>\(.*\)$/>\1 \1/g' > All_Human_proteins.faa

module load samtools
samtools faidx All_Human_proteins.faa

module load blast
makeblastdb -parse_seqids \
  -in All_Human_proteins.faa \
  -input_type fasta \
  -dbtype prot \
  -out All_Human_proteins \
  -title All_Human_proteins

echo -e "qaccver\tsaccver\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore" \
  > S10_All_ProteinSequences_fragments_in_All_Human_proteins.blastp.e0.05.tsv
blastp -db All_Human_proteins \
  -outfmt 6 -evalue 0.05 \
  -query S10_All_ProteinSequences-tile-25-24.faa \
  >> S10_All_ProteinSequences_fragments_in_All_Human_proteins.blastp.e0.05.tsv






echo "virus,accession,with_version,with_description" > all_human_protein_virus_translation_table.csv
grep -i "_Human_" viral.protein.names.txt | sed -e 's/^>//' | awk 'BEGIN{FS=OFS="_"}{print $1,$2","$0}' | awk 'BEGIN{FS=".";OFS=","}{print $1,$0}' | awk 'BEGIN{FS="_Human";OFS=","}{print "Human"$NF,$0}' | sort >> all_human_protein_virus_translation_table.csv

cut -d, -f1 all_human_protein_virus_translation_table.csv | uniq > all_human_virus_abbreviation_translation_table.csv 
```






##	20231128

ALL viral proteins, not just human

 Can we get the entire viral protein database blased against the tumor specific TCONS?
I know it will be huge, but we are going to get there anyway!!


```
scp c4:/francislab/data1/refs/refseq/viral-20220923/*.protein.faa.gz ./

ed -e '/^>/s/[ \/,]/_/g'

zcat /francislab/data1/refs/refseq/mRNA_Prot/human.*.protein.faa.gz | sed  -e '/^>/s/ \[Homo sapiens\]//g' 

zcat viral.?.protein.faa.gz | sed -e '/^>/s/[],()\/[]//g' -e "/^>/s/'//g" -e '/^>/s/->//g' -e '/^>/s/ /_/g' -e '/^>/s/\(^.\{1,51\}\).*/\1/' -e '/^>/s/>\(.*\)$/>\1 \1/g' > All_proteins.faa
```


##	20231129


```
scp c4:/francislab/data1/refs/refseq/viral-20220923/virus_translation_table*csv ./

head -1 virus_translation_table.20200507.csv > virus_translation_table.csv
tail -n +2 virus_translation_table.202*.csv | sort -u | grep -vs "^," | grep -vs "^$" | grep -vs "^==" >> virus_translation_table.csv

```


```
[gwendt@c4-dev3 /francislab/data1/refs/refseq/viral-20220923]$ grep YP_009100985 virus_translation_table.202*
virus_translation_table.20200507.csv:Listeria phage WIL-1,YP_009100985,YP_009100985.1,YP_009100985.1_recombination_exonuclease_Listeria_phage_WIL-1
virus_translation_table.20231122.csv:,YP_009100985,YP_009100985.1,YP_009100985.1_recombination_exonuclease_Listeria_phage_WIL-1
[gwendt@c4-dev3 /francislab/data1/refs/refseq/viral-20220923]$ grep YP_009153153 virus_translation_table.202*
virus_translation_table.20200507.csv:Klebsiella phage K64-1,YP_009153153,YP_009153153.1,YP_009153153.1_hypothetical_protein_ACQ27_gp13_Klebsiella_phage_K64-1
virus_translation_table.20231122.csv:,YP_009153153,YP_009153153.1,YP_009153153.1_hypothetical_protein_ACQ27_gp13_Klebsiella_phage_K64-1
[gwendt@c4-dev3 /francislab/data1/refs/refseq/viral-20220923]$ grep YP_010065083 virus_translation_table.202*
virus_translation_table.20200507.csv:,YP_010065083,YP_010065083.1,YP_010065083.1_hypothetical_protein_KMB90_gp46_Vibrio_virus_2019VC1
virus_translation_table.20231122.csv:,YP_010065083,YP_010065083.1,YP_010065083.1_hypothetical_protein_KMB90_gp46_Vibrio_virus_2019VC1
[gwendt@c4-dev3 /francislab/data1/refs/refseq/viral-20220923]$ grep YP_010298128 virus_translation_table.202*
virus_translation_table.20200507.csv:,YP_010298128,YP_010298128.1,YP_010298128.1_AAA_family_ATPase_Serratia_phage_KpZh_1
virus_translation_table.20231122.csv:,YP_010298128,YP_010298128.1,YP_010298128.1_AAA_family_ATPase_Serratia_phage_KpZh_1
[gwendt@c4-dev3 /francislab/data1/refs/refseq/viral-20220923]$ grep YP_010298522 virus_translation_table.202*
virus_translation_table.20200507.csv:,YP_010298522,YP_010298522.1,YP_010298522.1_AAA_family_ATPase_Serratia_phage_KpYy_2_45
virus_translation_table.20231122.csv:,YP_010298522,YP_010298522.1,YP_010298522.1_AAA_family_ATPase_Serratia_phage_KpYy_2_45
```




```

scp c4:/francislab/data1/refs/refseq/viral-20231129/viral.1.protein.faa.gz ./

zcat viral.?.protein.faa.gz | sed -e '/^>/s/[],()\/[]//g' -e "/^>/s/'//g" -e '/^>/s/->//g' -e '/^>/s/ /_/g' -e '/^>/s/\(^.\{1,51\}\).*/\1/' -e '/^>/s/>\(.*\)$/>\1 \1/g' > All_proteins.faa


```

##	20231207


```
scp c4:/francislab/data1/refs/refseq/viral-20231129/viral.protein.faa.gz ./
scp c4:/francislab/data1/refs/refseq/viral-20231129/viral.1.protein.faa.gz ./
scp c4:/francislab/data1/refs/refseq/viral-20231129/viral.protein.names.txt ./
scp c4:/francislab/data1/refs/refseq/viral-20231129/virus_taxonomy_tree_translation_table.20231122b.csv ./
scp c4:/francislab/data1/refs/refseq/viral-20231129/virus_taxonomy_tree_translation_table.20231122.csv ./
scp c4:/francislab/data1/refs/refseq/viral-20231129/virus_translation_table.20231122.csv ./
scp c4:/francislab/data1/refs/refseq/viral-20231129/*_proteins.faa* ./

scp c4:/francislab/data1/refs/refseq/viral-20231129/virus_taxonomy_tree_translation_table.20231129.20231122.csv ./

```



