#!/usr/bin/env bash

module load samtools blast


# makeblastdb -in S10_S2_ProteinSequences.fa -input_type fasta -dbtype prot -out S10_S2_ProteinSequences -title S10_S2_ProteinSequences -parse_seqids

TCONS_FASTA=/francislab/data1/raw/20230426-PanCancerAntigens/S10_S2_ProteinSequences.fa
EVALUE=0.05


echo "Tiling TCONS protein sequences"

#	scp c4:/francislab/data1/raw/20230426-PanCancerAntigens/S10_S2_ProteinSequences-tile-25-24.faa
#cat ${TCONS_FASTA} | pepsyn tile -l 25 -p 24 - $( basename ${TCONS_FASTA} .fa )-tile-25-24.faa

samtools faidx $( basename ${TCONS_FASTA} .fa )-tile-25-24.faa






echo "Preparing sequence names"
#	Remove characters that makeblastdb angry
#	Shorten to 50 chars
#	Add second iteration which was used by blast2bam or something but is otherwise ignored

#	scp c4:/francislab/data1/working/20230426-PanCancerAntigens/20231011-focused_blasting/All_Human_proteins.faa ./
#cat /francislab/data1/refs/refseq/viral-20220923/viral.protein/*_Human_*.fa | sed  -e "/^>/s/'//g" -e '/^>/s/,//g' -e '/^>/s/->//g' -e '/^>/s/\(^.\{1,51\}\).*/\1/' -e '/^>/s/>\(.*\)$/>\1 \1/g' > All_Human_proteins.faa

samtools faidx All_Human_proteins.faa

makeblastdb -parse_seqids \
  -in All_Human_proteins.faa \
  -input_type fasta \
  -dbtype prot \
  -out All_Human_proteins \
  -title All_Human_proteins


echo "Blasting TCONS tiles to All_Human_proteins"

echo -e "qaccver\tsaccver\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore" \
  > $( basename ${TCONS_FASTA} .fa )_fragments_in_All_Human_proteins.blastp.e${EVALUE}.tsv
blastp -db All_Human_proteins \
  -outfmt 6 -evalue ${EVALUE} \
  -query $( basename ${TCONS_FASTA} .fa )-tile-25-24.faa \
  >> $( basename ${TCONS_FASTA} .fa )_fragments_in_All_Human_proteins.blastp.e${EVALUE}.tsv








echo "virus,accession,with_version,with_description" > all_human_protein_virus_translation_table.csv
grep "_Human_" viral.protein.names.txt | sed -e 's/^>//' | awk 'BEGIN{FS=OFS="_"}{print $1,$2","$0}' | awk 'BEGIN{FS=".";OFS=","}{print $1,$0}' | awk 'BEGIN{FS="_Human";OFS=","}{print "Human"$NF,$0}' | sort >> all_human_protein_virus_translation_table.csv

cut -d, -f1 all_human_protein_virus_translation_table.csv | uniq > all_human_virus_abbreviation_translation_table.csv 



#echo "accession,withversion,description" > Human_alphaherpesvirus_3.protein_translation_table.csv
#ls -1 /francislab/data1/refs/refseq/viral-20220923/viral.protein/*_Human_alphaherpesvirus_3.fa | cut -d/ -f8 | sed 's/_Human_alphaherpesvirus_3.fa//' | awk 'BEGIN{OFS=","}{split($0,a,".");split($0,b,"_");print a[1],b[1]"_"b[2],$0}' >> Human_alphaherpesvirus_3.protein_translation_table.csv



join --header -t, all_human_virus_abbreviation_translation_table.csv \
	all_human_protein_virus_translation_table.csv > tmp1


#head -3 tmp1
#virus,abbreviation,accession,with_version,with_description
#Human_alphaherpesvirus_1,HHV1,YP_009137073,YP_009137073.1,YP_009137073.1_neurovirulence_protein_ICP34.5_Human_alphaherpesvirus_1
#Human_alphaherpesvirus_1,HHV1,YP_009137074,YP_009137074.1,YP_009137074.1_ubiquitin_E3_ligase_ICP0_Human_alphaherpesvirus_1



sed 's/\t/,/g' $( basename ${TCONS_FASTA} .fa )_fragments_in_All_Human_proteins.blastp.e0.05.tsv \
  | awk 'BEGIN{FS=OFS=","}(NR>1){split($1,a,"_");split($2,b,".");print a[1]"_"a[2],b[1],$NF}' > tmp2

#head -3 tmp2
#TCONS_00000246,YP_081561,24.6
#TCONS_00000246,YP_081561,24.6
#TCONS_00000246,YP_081561,24.6
#
#sort -t, -k1,2 -k3nr tmp2 | uniq | head
#TCONS_00000246,NP_050190,23.9
#TCONS_00000246,YP_081561,24.6
#TCONS_00000667,YP_001129455,25.8
#TCONS_00000667,YP_001129455,24.3
#TCONS_00000667,YP_401658,25.8
#TCONS_00000667,YP_401658,24.3
#TCONS_00000802,YP_009137100,24.3
#TCONS_00000820,NP_040188,26.9
#TCONS_00000820,NP_040188,26.6
#TCONS_00000820,NP_040188,26.2
#
#sort -t, -k1,2 -k3nr tmp2 | uniq | awk 'BEGIN{FS=OFS=","}( k[$1][$2] == "" ){k[$1][$2]=$3;print $2,$1,$3}' | head
#NP_050190,TCONS_00000246,23.9
#YP_081561,TCONS_00000246,24.6
#YP_001129455,TCONS_00000667,25.8
#YP_401658,TCONS_00000667,25.8
#YP_009137100,TCONS_00000802,24.3
#NP_040188,TCONS_00000820,26.9
#YP_009137138,TCONS_00000820,28.5
#YP_009137215,TCONS_00000820,27.3
#YP_081510,TCONS_00000820,23.9
#YP_001129393,TCONS_00001232,24.3




sort -t, -k1,2 -k3nr tmp2 | uniq | awk 'BEGIN{FS=OFS=","}( k[$1][$2] == "" ){k[$1][$2]=$3;print $2,$1,$3}' | sort -t, -k1,2 > tmp3

#head -3 tmp3
#NP_040125,TCONS_00071958,25.8
#NP_040125,TCONS_00115919,24.3
#NP_040127,TCONS_00037379,25.4

tail -n +2 tmp1 | awk 'BEGIN{FS=OFS=","}{print $3,$2}' | sort -t, -k1,2 | uniq > tmp4
#head -3 tmp4
#NP_040124,HHV3
#NP_040125,HHV3
#NP_040126,HHV3


echo "virus,protein,TCONS,bitscore" > tmp5
#virus_protein_TCONS_bitscore.csv
join -t, tmp4 tmp3 | awk 'BEGIN{FS=OFS=","}{print $2,$1,$3,$4}' | sort -t, -k1,3 >> tmp5
#virus_protein_TCONS_bitscore.csv

#head -3 virus_protein_TCONS_bitscore.csv
#virus,protein,TCONS,bitscore
#HHV1,YP_009137074,TCONS_00009055,33.9
#HHV1,YP_009137074,TCONS_00030850,31.6










sed '1s/ /_/g' S1.csv | cut -d, -f1,10- | tr -d "\r" > tmp11

echo "Transcript_ID,Study_SampleType,Count" > tmp12
awk 'BEGIN{FS=OFS=","}(NR==1){for(i=2;i<=NF;i++){k[i]=$i}}(NR>1){ for(i=2;i<=NF;i++){if($i>0){print $1,k[i],$i}}}' tmp11 >> tmp12




echo "Transcript_ID,virus,protein,bitscore" > tmp13
#TCONS_virus_protein_bitscore.csv
tail -n +2 virus_protein_TCONS_bitscore.csv | awk 'BEGIN{FS=OFS=","}{print $3,$1,$2,$4}' | sort -t, -k1,3 >> tmp13
#TCONS_virus_protein_bitscore.csv



#join --header -t, TCONS_virus_protein_bitscore.csv tmp12 > tmp6
join --header -t, tmp13 tmp12 > tmp6

#head -3 tmp6
#Transcript_ID,virus,protein,bitscore,Study_SampleType,Count
#TCONS_00000246,HHV5,YP_081561,24.6,LUAD_tumor,5
#TCONS_00000246,HHV5,YP_081561,24.6,STAD_tumor,1


awk 'BEGIN{FS=OFS=","}{print $2,$3,$5,$4}' tmp6 > tmp7

#head -3 tmp7
#virus,protein,Study_SampleType,bitscore
#HHV5,YP_081561,LUAD_tumor,24.6
#HHV5,YP_081561,STAD_tumor,24.6

echo "virus,protein,Study_SampleType,bitscore" > tmp8
tail -n +2 tmp7 | sort -t, -k1,3 -k4nr >> tmp8

#head tmp8
#virus,protein,Study_SampleType,bitscore
#HHV1,YP_009137074,ACC_tumor,30.4
#HHV1,YP_009137074,BLCA_tumor,38.1
#HHV1,YP_009137074,BLCA_tumor,27.3
#HHV1,YP_009137074,BLCA_tumor,24.6
#HHV1,YP_009137074,BRCA_tumor,38.1
#HHV1,YP_009137074,BRCA_tumor,31.6
#HHV1,YP_009137074,BRCA_tumor,24.6
#HHV1,YP_009137074,BRCA_tumor,24.3
#HHV1,YP_009137074,CESC_tumor,31.6


echo "virus,protein,Study_SampleType,bitscore" > tmp9
tail -n +2 tmp3 | awk 'BEGIN{FS=OFS=","}( k[$1][$2][$3] == "" ){k[$1][$2][$3]=$4;print $1,$2,$3,$4}' >> tmp9

#head tmp9
#virus,protein,Study_SampleType,bitscore
#HHV1,YP_009137074,ACC_tumor,30.4
#HHV1,YP_009137074,BLCA_tumor,38.1
#HHV1,YP_009137074,BRCA_tumor,38.1
#HHV1,YP_009137074,CESC_tumor,31.6
#HHV1,YP_009137074,CHOL_tumor,27.3
#HHV1,YP_009137074,COAD_tumor,31.6
#HHV1,YP_009137074,ESCA_tumor,27.3
#HHV1,YP_009137074,GBM_tumor,24.3
#HHV1,YP_009137074,GTEx_Total,33.9



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

}' tmp9 > tmp10

head -1 tmp10 > tmp11
#S1_virus_protein_bitscore.csv
tail -n +2 tmp10 | sort -t, -k1,2 >> tmp11
#S1_virus_protein_bitscore.csv


