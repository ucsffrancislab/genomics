#!/usr/bin/env bash

set -e  #       exit if any command fails     # can be problematic when piping through head.
set -u  #       Error on usage of unset variables
set -o pipefail

if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	module load CBI samtools blast
fi


# makeblastdb -in S10_S2_ProteinSequences.fa -input_type fasta -dbtype prot -out S10_S2_ProteinSequences -title S10_S2_ProteinSequences -parse_seqids

TCONS_FASTA=/francislab/data1/raw/20230426-PanCancerAntigens/S10_S2_ProteinSequences.faa
TCONS_FASTA_BASE=$( basename ${TCONS_FASTA} .faa )
#PROTEIN_FASTA=All_Human_proteins.faa
PROTEIN_FASTA=Human_herpes_proteins.faa
#PROTEIN_FASTA=Variola_virus_proteins.faa
PROTEIN_FASTA_BASE=$( basename ${PROTEIN_FASTA} .faa )
EVALUE=0.05


echo "Tiling TCONS protein sequences"

#	scp c4:/francislab/data1/raw/20230426-PanCancerAntigens/S10_S2_ProteinSequences-tile-25-24.faa ./
#cat ${TCONS_FASTA} | pepsyn tile -l 25 -p 24 - ${TCONS_FASTA_BASE}-tile-25-24.faa

echo "head ${TCONS_FASTA_BASE}-tile-25-24.faa"
head ${TCONS_FASTA_BASE}-tile-25-24.faa

samtools faidx ${TCONS_FASTA_BASE}-tile-25-24.faa






echo "Preparing sequence names"
#	Remove characters that makeblastdb angry
#	Shorten to 50 chars
#	Add second iteration which was used by blast2bam or something but is otherwise ignored

#	scp c4:/francislab/data1/working/20230426-PanCancerAntigens/20231011-focused_blasting/All_Human_proteins.faa ./
#cat /francislab/data1/refs/refseq/viral-20220923/viral.protein/*_Human_*.fa | sed  -e "/^>/s/'//g" -e '/^>/s/,//g' -e '/^>/s/->//g' -e '/^>/s/\(^.\{1,51\}\).*/\1/' -e '/^>/s/>\(.*\)$/>\1 \1/g' > All_Human_proteins.faa




echo "head ${PROTEIN_FASTA}"
head ${PROTEIN_FASTA}

samtools faidx ${PROTEIN_FASTA}

makeblastdb -parse_seqids \
  -in ${PROTEIN_FASTA} \
  -input_type fasta \
  -dbtype prot \
  -out ${PROTEIN_FASTA_BASE} \
  -title ${PROTEIN_FASTA_BASE}


echo "Blasting TCONS tiles to ${PROTEIN_FASTA_BASE}"

echo -e "qaccver\tsaccver\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore" \
  > ${TCONS_FASTA_BASE}_fragments_in_${PROTEIN_FASTA_BASE}.blastp.e${EVALUE}.tsv
blastp -db ${PROTEIN_FASTA_BASE} \
  -outfmt 6 -evalue ${EVALUE} \
  -query ${TCONS_FASTA_BASE}-tile-25-24.faa \
  >> ${TCONS_FASTA_BASE}_fragments_in_${PROTEIN_FASTA_BASE}.blastp.e${EVALUE}.tsv

echo "head ${TCONS_FASTA_BASE}_fragments_in_${PROTEIN_FASTA_BASE}.blastp.e${EVALUE}.tsv"
head ${TCONS_FASTA_BASE}_fragments_in_${PROTEIN_FASTA_BASE}.blastp.e${EVALUE}.tsv




#	scp c4:/francislab/data1/working/20230426-PanCancerAntigens/20231011-focused_blasting/Human_herpes_proteins.faa ./
#	All_Human_proteins.faa

#echo "virus,accession,with_version,with_description" > ${PROTEIN_FASTA_BASE}.virus_translation_table.csv
#grep "_Human_" viral.protein.names.txt | sed -e 's/^>//' | awk 'BEGIN{FS=OFS="_"}{print $1,$2","$0}' | awk 'BEGIN{FS=".";OFS=","}{print $1,$0}' | awk 'BEGIN{FS="_Human";OFS=","}{print "Human"$NF,$0}' | sort >> ${PROTEIN_FASTA_BASE}.virus_translation_table.csv
#
#cut -d, -f1 all_human_protein_virus_translation_table.csv | uniq > all_human_virus_abbreviation_translation_table.csv 


#	Herpes viruses
#	grep "_Human_" viral.protein.names.txt | grep herpes | sed -e 's/^>//' | awk 'BEGIN{FS=OFS="_"}{print $1,$2","$0}' | awk 'BEGIN{FS=".";OFS=","}{print $1,$0}' | awk 'BEGIN{FS="_Human";OFS=","}{print "Human"$NF,$0}' | sort >> ${PROTEIN_FASTA_BASE}.virus_translation_table.csv


#	Variola virus
#grep "_Variola_virus$" viral.protein.names.txt | sed -e 's/^>//' | awk 'BEGIN{FS=OFS="_"}{print $1,$2","$0}' | awk 'BEGIN{FS=".";OFS=","}{print "Variola_virus",$1,$0}' | sort >> ${PROTEIN_FASTA_BASE}.virus_translation_table.csv




#echo "accession,withversion,description" > Human_alphaherpesvirus_3.protein_translation_table.csv
#ls -1 /francislab/data1/refs/refseq/viral-20220923/viral.protein/*_Human_alphaherpesvirus_3.fa | cut -d/ -f8 | sed 's/_Human_alphaherpesvirus_3.fa//' | awk 'BEGIN{OFS=","}{split($0,a,".");split($0,b,"_");print a[1],b[1]"_"b[2],$0}' >> Human_alphaherpesvirus_3.protein_translation_table.csv

#join --header -t, all_human_virus_abbreviation_translation_table.csv \
#	all_human_protein_virus_translation_table.csv > tmp1

#head -3 tmp1
#virus,abbreviation,accession,with_version,with_description
#Human_alphaherpesvirus_1,HHV1,YP_009137073,YP_009137073.1,YP_009137073.1_neurovirulence_protein_ICP34.5_Human_alphaherpesvirus_1
#Human_alphaherpesvirus_1,HHV1,YP_009137074,YP_009137074.1,YP_009137074.1_ubiquitin_E3_ligase_ICP0_Human_alphaherpesvirus_1



sed 's/\t/,/g' ${TCONS_FASTA_BASE}_fragments_in_${PROTEIN_FASTA_BASE}.blastp.e${EVALUE}.tsv \
  | awk 'BEGIN{FS=OFS=","}(NR>1){split($1,a,"_");split($2,b,".");print a[1]"_"a[2],b[1],$NF}' > tmp2


echo "head tmp2"
head tmp2
#TCONS_00000560,YP_009505610,25.4
#TCONS_00000560,YP_009505610,25.0
#TCONS_00000560,YP_009505610,25.0
#TCONS_00000667,YP_401658,25.8
#TCONS_00000667,YP_001129455,25.8
#TCONS_00000667,YP_401658,25.8
#TCONS_00000667,YP_001129455,25.8
#TCONS_00000667,YP_401658,25.8
#TCONS_00000667,YP_001129455,25.8
#TCONS_00000667,YP_401658,25.8



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

echo "head tmp3"
head tmp3
#AP_000108,TCONS_00016038,25.0
#AP_000108,TCONS_00060502,25.0
#AP_000108,TCONS_00101289,25.4
#AP_000112,TCONS_00083962,25.0
#AP_000114,TCONS_00013399,26.2
#AP_000115,TCONS_00094751,25.4
#AP_000116,TCONS_00010219,25.0
#AP_000120,TCONS_00043366,26.6
#AP_000121,TCONS_00110433,25.8
#AP_000124,TCONS_00016567,25.0





#tail -n +2 all_human_protein_virus_translation_table.csv | awk 'BEGIN{FS=OFS=","}{print $2,$1}' | sort -t, -k1,2 | uniq > tmp4
tail -n +2 ${PROTEIN_FASTA_BASE}.virus_translation_table.csv | awk 'BEGIN{FS=OFS=","}{print $2,$1}' | sort -t, -k1,2 | uniq > tmp4

echo head tmp4
head tmp4

#	with or without abbreviation

#tail -n +2 tmp1 | awk 'BEGIN{FS=OFS=","}{print $3,$2}' | sort -t, -k1,2 | uniq > tmp4
##head -3 tmp4
##NP_040124,HHV3
##NP_040125,HHV3
##NP_040126,HHV3


echo "virus,protein,TCONS,bitscore" > tmp5
#virus_protein_TCONS_bitscore.csv
join -t, tmp4 tmp3 | awk 'BEGIN{FS=OFS=","}{print $2,$1,$3,$4}' | sort -t, -k1,3 >> tmp5
#virus_protein_TCONS_bitscore.csv

#head -3 virus_protein_TCONS_bitscore.csv
#virus,protein,TCONS,bitscore
#HHV1,YP_009137074,TCONS_00009055,33.9
#HHV1,YP_009137074,TCONS_00030850,31.6


echo head tmp5
head tmp5



#tail -n +2 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | head -1 > S1.csv
#tail -n +3 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | sort -t, -k1,1 >> S1.csv
#
#sed '1s/ /_/g' S1.csv | cut -d, -f1,10- | tr -d "\r" > S1._.csv
#
#echo "Transcript_ID,Study_SampleType,Count" > S1.list.csv
#awk 'BEGIN{FS=OFS=","}(NR==1){for(i=2;i<=NF;i++){k[i]=$i}}(NR>1){ for(i=2;i<=NF;i++){if($i>0){print $1,k[i],$i}}}' S1._.csv >> S1.list.csv






echo "Transcript_ID,virus,protein,bitscore" > tmp13
#TCONS_virus_protein_bitscore.csv
tail -n +2 tmp5 | awk 'BEGIN{FS=OFS=","}{print $3,$1,$2,$4}' | sort -t, -k1,3 >> tmp13
#tail -n +2 virus_protein_TCONS_bitscore.csv | awk 'BEGIN{FS=OFS=","}{print $3,$1,$2,$4}' | sort -t, -k1,3 >> TCONS_virus_protein_bitscore.csv

echo head tmp13
head tmp13

#	Transcript_ID,virus,protein,bitscore
#	TCONS_00000560,Human_rhinovirus_NAT001,YP_009505610,25.4
#	TCONS_00000667,Human_gammaherpesvirus_4,YP_401658,25.8
#	TCONS_00000667,Human_herpesvirus_4_type_2,YP_001129455,25.8
#	TCONS_00000820,Human_alphaherpesvirus_1,YP_009137138,28.5
#	TCONS_00000820,Human_alphaherpesvirus_2,YP_009137215,27.3
#	TCONS_00000820,Human_alphaherpesvirus_3,NP_040188,26.9
#	TCONS_00002008,Human_alphaherpesvirus_3,NP_040188,26.2
#	TCONS_00002575,Human_papillomavirus_type_131,YP_004169279,25.8
#	TCONS_00003195,Human_betaherpesvirus_5,YP_081508,26.2



#join --header -t, TCONS_virus_protein_bitscore.csv S1.list.csv > tmp6
join --header -t, tmp13 S1.list.csv > tmp6

echo head tmp6
head tmp6

#	Transcript_ID,virus,protein,bitscore,Study_SampleType,Count
#	TCONS_00000560,Human_rhinovirus_NAT001,YP_009505610,25.4,BLCA_tumor,21
#	TCONS_00000560,Human_rhinovirus_NAT001,YP_009505610,25.4,BRCA_tumor,4
#	TCONS_00000560,Human_rhinovirus_NAT001,YP_009505610,25.4,CESC_tumor,17
#	TCONS_00000560,Human_rhinovirus_NAT001,YP_009505610,25.4,COAD_tumor,3
#	TCONS_00000560,Human_rhinovirus_NAT001,YP_009505610,25.4,DLBC_tumor,2
#	TCONS_00000560,Human_rhinovirus_NAT001,YP_009505610,25.4,ESCA_tumor,7
#	TCONS_00000560,Human_rhinovirus_NAT001,YP_009505610,25.4,HNSC_tumor,26
#	TCONS_00000560,Human_rhinovirus_NAT001,YP_009505610,25.4,KIRC_tumor,3
#	TCONS_00000560,Human_rhinovirus_NAT001,YP_009505610,25.4,KIRP_tumor,1








awk 'BEGIN{FS=OFS=","}{print $2,$3,$5,$4}' tmp6 > tmp7

echo head tmp7
head tmp7

#head -3 tmp7
#virus,protein,Study_SampleType,bitscore
#HHV5,YP_081561,LUAD_tumor,24.6
#HHV5,YP_081561,STAD_tumor,24.6

#	virus,protein,Study_SampleType,bitscore
#	Human_rhinovirus_NAT001,YP_009505610,BLCA_tumor,25.4
#	Human_rhinovirus_NAT001,YP_009505610,BRCA_tumor,25.4
#	Human_rhinovirus_NAT001,YP_009505610,CESC_tumor,25.4
#	Human_rhinovirus_NAT001,YP_009505610,COAD_tumor,25.4
#	Human_rhinovirus_NAT001,YP_009505610,DLBC_tumor,25.4
#	Human_rhinovirus_NAT001,YP_009505610,ESCA_tumor,25.4
#	Human_rhinovirus_NAT001,YP_009505610,HNSC_tumor,25.4
#	Human_rhinovirus_NAT001,YP_009505610,KIRC_tumor,25.4
#	Human_rhinovirus_NAT001,YP_009505610,KIRP_tumor,25.4





echo "virus,protein,Study_SampleType,bitscore" > tmp8
tail -n +2 tmp7 | sort -t, -k1,3 -k4nr >> tmp8

echo head tmp8
head tmp8

#	virus,protein,Study_SampleType,bitscore
#	Human_T-cell_leukemia_virus_type_I,NP_057860,BLCA_tumor,28.5
#	Human_T-cell_leukemia_virus_type_I,NP_057860,BLCA_tumor,27.7
#	Human_T-cell_leukemia_virus_type_I,NP_057860,BRCA_tumor,28.5
#	Human_T-cell_leukemia_virus_type_I,NP_057860,Brain_gtex,28.5
#	Human_T-cell_leukemia_virus_type_I,NP_057860,Brain_gtex,27.7
#	Human_T-cell_leukemia_virus_type_I,NP_057860,CESC_tumor,27.7
#	Human_T-cell_leukemia_virus_type_I,NP_057860,DLBC_tumor,28.5
#	Human_T-cell_leukemia_virus_type_I,NP_057860,ESCA_tumor,28.5
#	Human_T-cell_leukemia_virus_type_I,NP_057860,ESCA_tumor,27.7



echo "virus,protein,Study_SampleType,bitscore" > tmp9
####tail -n +2 tmp3 | awk 'BEGIN{FS=OFS=","}( k[$1][$2][$3] == "" ){k[$1][$2][$3]=$4;print $1,$2,$3,$4}' >> tmp9
tail -n +2 tmp8 | awk 'BEGIN{FS=OFS=","}( k[$1][$2][$3] == "" ){k[$1][$2][$3]=$4;print $1,$2,$3,$4}' >> tmp9

echo head tmp9
head tmp9


#	virus,protein,Study_SampleType,bitscore
#	Human_T-cell_leukemia_virus_type_I,NP_057860,BLCA_tumor,28.5
#	Human_T-cell_leukemia_virus_type_I,NP_057860,BRCA_tumor,28.5
#	Human_T-cell_leukemia_virus_type_I,NP_057860,Brain_gtex,28.5
#	Human_T-cell_leukemia_virus_type_I,NP_057860,CESC_tumor,27.7
#	Human_T-cell_leukemia_virus_type_I,NP_057860,DLBC_tumor,28.5
#	Human_T-cell_leukemia_virus_type_I,NP_057860,ESCA_tumor,28.5
#	Human_T-cell_leukemia_virus_type_I,NP_057860,GTEx_Total,28.5
#	Human_T-cell_leukemia_virus_type_I,NP_057860,GTEx_Total_without_Testis,28.5
#	Human_T-cell_leukemia_virus_type_I,NP_057860,HNSC_tumor,27.7





awk 'BEGIN{FS=OFS=",";split("ACC_tumor,ACC_normal,BLCA_tumor,BLCA_normal,BRCA_tumor,BRCA_normal,CESC_tumor,CESC_normal,CHOL_tumor,CHOL_normal,COAD_tumor,COAD_normal,DLBC_tumor,DLBC_normal,ESCA_tumor,ESCA_normal,GBM_tumor,GBM_normal,HNSC_tumor,HNSC_normal,KICH_tumor,KICH_normal,KIRC_tumor,KIRC_normal,KIRP_tumor,KIRP_normal,LAML_tumor,LAML_normal,LGG_tumor,LGG_normal,LIHC_tumor,LIHC_normal,LUAD_tumor,LUAD_normal,LUSC_tumor,LUSC_normal,MESO_tumor,MESO_normal,OV_tumor,OV_normal,PAAD_tumor,PAAD_normal,PCPG_tumor,PCPG_normal,PRAD_tumor,PRAD_normal,READ_tumor,READ_normal,SARC_tumor,SARC_normal,SKCM_tumor,SKCM_normal,STAD_tumor,STAD_normal,TGCT_tumor,TGCT_normal,THCA_tumor,THCA_normal,THYM_tumor,THYM_normal,UCEC_tumor,UCEC_normal,UCS_tumor,UCS_normal,UVM_tumor,UVM_normal,Adipose_Tissue_gtex,Ovary_gtex,Vagina_gtex,Breast_gtex,Salivary_Gland_gtex,Adrenal_Gland_gtex,Spleen_gtex,Esophagus_gtex,Prostate_gtex,Testis_gtex,Nerve_gtex,Brain_gtex,Thyroid_gtex,Lung_gtex,Skin_gtex,Blood_gtex,Blood_Vessel_gtex,Pituitary_gtex,Heart_gtex,Colon_gtex,Pancreas_gtex,Stomach_gtex,Muscle_gtex,Small_Intestine_gtex,Uterus_gtex,Kidney_gtex,Liver_gtex,Cervix_Uteri_gtex,Bladder_gtex,Fallopian_Tube_gtex,Tumor_Total,Normal_Total,GTEx_Total,GTEx_Total_without_Testis",cols,",")}
(NR>1){bitscores[$1][$2][$3]=$4}
END{
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
				}
			}
			print s
		}
	}
}' tmp9 > tmp10

echo "head tmp10 | cut -c1-150"
head tmp10 | cut -c1-150

head -1 tmp10 > tmp11
#S1_virus_protein_bitscore.csv
tail -n +2 tmp10 | sort -t, -k1,2 >> tmp11
#S1_virus_protein_bitscore.csv

echo "head tmp11 | cut -c1-150"
head tmp11 | cut -c1-150



cp tmp11 S1_${TCONS_FASTA_BASE}_fragments_in_${PROTEIN_FASTA_BASE}.blastp.e${EVALUE}.csv
./S1_virus_protein_bitscore.heatmap.py S1_${TCONS_FASTA_BASE}_fragments_in_${PROTEIN_FASTA_BASE}.blastp.e${EVALUE}.csv

