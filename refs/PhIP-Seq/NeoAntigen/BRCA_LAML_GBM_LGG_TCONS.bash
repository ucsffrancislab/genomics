#!/usr/bin/env bash

#	First, Can you please double check me that these are only in the tumor and not GTEX/normal, and cover the correct TCONS.

#	I think this also replaces s10_glioma_TCONS_subset.csv


#	BRCA_LAML_GBM_LGG_TCONS.csv


#	cut -d, -f1 BRCA_LAML_GBM_LGG_TCONS.csv > tmp1.csv

#	/francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv

#	head -2 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | tail -n 1 | tr "," "\n" | awk '{print NR,$0}'
#	1 Transcript ID
#	2 Subfam
#	3 Chr TE
#	4 Start TE
#	5 End TE
#	6 Location TE
#	7 Gene
#	8 Splice Target
#	9 Strand
#	10 ACC_tumor
#	11 ACC_normal
#	12 BLCA_tumor
#	13 BLCA_normal
#	14 BRCA_tumor
#	15 BRCA_normal
#	16 CESC_tumor
#	17 CESC_normal
#	18 CHOL_tumor
#	19 CHOL_normal
#	20 COAD_tumor
#	21 COAD_normal
#	22 DLBC_tumor
#	23 DLBC_normal
#	24 ESCA_tumor
#	25 ESCA_normal
#	26 GBM_tumor
#	27 GBM_normal
#	28 HNSC_tumor
#	29 HNSC_normal
#	30 KICH_tumor
#	31 KICH_normal
#	32 KIRC_tumor
#	33 KIRC_normal
#	34 KIRP_tumor
#	35 KIRP_normal
#	36 LAML_tumor
#	37 LAML_normal
#	38 LGG_tumor
#	39 LGG_normal
#	40 LIHC_tumor
#	41 LIHC_normal
#	42 LUAD_tumor
#	43 LUAD_normal
#	44 LUSC_tumor
#	45 LUSC_normal
#	46 MESO_tumor
#	47 MESO_normal
#	48 OV_tumor
#	49 OV_normal
#	50 PAAD_tumor
#	51 PAAD_normal
#	52 PCPG_tumor
#	53 PCPG_normal
#	54 PRAD_tumor
#	55 PRAD_normal
#	56 READ_tumor
#	57 READ_normal
#	58 SARC_tumor
#	59 SARC_normal
#	60 SKCM_tumor
#	61 SKCM_normal
#	62 STAD_tumor
#	63 STAD_normal
#	64 TGCT_tumor
#	65 TGCT_normal
#	66 THCA_tumor
#	67 THCA_normal
#	68 THYM_tumor
#	69 THYM_normal
#	70 UCEC_tumor
#	71 UCEC_normal
#	72 UCS_tumor
#	73 UCS_normal
#	74 UVM_tumor
#	75 UVM_normal
#	76 Adipose Tissue_gtex
#	77 Ovary_gtex
#	78 Vagina_gtex
#	79 Breast_gtex
#	80 Salivary Gland_gtex
#	81 Adrenal Gland_gtex
#	82 Spleen_gtex
#	83 Esophagus_gtex
#	84 Prostate_gtex
#	85 Testis_gtex
#	86 Nerve_gtex
#	87 Brain_gtex
#	88 Thyroid_gtex
#	89 Lung_gtex
#	90 Skin_gtex
#	91 Blood_gtex
#	92 Blood Vessel_gtex
#	93 Pituitary_gtex
#	94 Heart_gtex
#	95 Colon_gtex
#	96 Pancreas_gtex
#	97 Stomach_gtex
#	98 Muscle_gtex
#	99 Small Intestine_gtex
#	100 Uterus_gtex
#	101 Kidney_gtex
#	102 Liver_gtex
#	103 Cervix Uteri_gtex
#	104 Bladder_gtex
#	105 Fallopian Tube_gtex
#	106 Tumor Total
#	107 Normal Total
#	108 GTEx Total
#	109 GTEx Total without Testis


#tail -n +2 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | awk -F, '(( $107+$109==0 ) && ( ($14>0) || ($26>0) || ($36>0) || ($38>0) ) ){print $1}' > tmp1.csv
#	- 8713

#tail -n +2 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | awk -F, '(( $107+$108==0 ) && ( ($14>0) || ($26>0) || ($36>0) || ($38>0) ) ){print $1}' > tmp1.csv
#	- 6898

#tail -n +2 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | awk -F, '(( $107+$109==0 ) && ( ($14>1) || ($26>1) || ($36>1) || ($38>1) ) ){print $1}' > tmp1.csv
#	- 5742

#tail -n +2 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | awk -F, '(( $107+$108==0 ) && ( ($14>1) || ($26>1) || ($36>1) || ($38>1) ) ){print $1}' > tmp1.csv
#	6325

#tail -n +2 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | awk -F, '(( $107+$109==0 ) && ( ($14>1) || ($26>0) || ($36>1) || ($38>0) ) ){print $1}' > tmp1.csv
#	- 6582

#tail -n +2 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | awk -F, '(( $107+$109==0 ) && ( ($14>1) || ($26>0) || ($38>0) ) ){print $1}' > tmp1.csv
#	- 6123

#tail -n +2 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | awk -F, '(( $107+$108==0 ) && ( ($14>0) || ($26>0) || ($38>0) ) ){print $1}' > tmp1.csv
#	- 6474



#	No Normal, No GTEx without Testis, 2+ for BRCA or LAML or 1+ for GBM or LGG
#tail -n +2 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | awk -F, '(( $107+$109==0 ) && ( ($14>1) || ($26>0) || ($36>1) || ($38>0) ) ){print $1}' > tmp1.csv
#	8236

#	No Normal, No GTEx, 2+ for BRCA or LAML or 1+ for GBM or LGG
#tail -n +2 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | awk -F, '(( $107+$108==0 ) && ( ($14>1) || ($26>0) || ($36>1) || ($38>0) ) ){print $1}' > tmp1.csv
#	7053


#	No Normal, No GTEx, 2+ for BRCA or 1+ for GBM or LGG
#tail -n +2 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | awk -F, '(( $107+$108==0 ) && ( ($14>1) || ($26>0) || ($38>0) ) ){print $1}' > tmp1.csv
#	6660

#	No Normal, No GTEx, 3+ for BRCA or 1+ for GBM or LGG
#tail -n +2 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | awk -F, '(( $107+$108==0 ) && ( ($14>2) || ($26>0) || ($38>0) ) ){print $1}' > tmp1.csv
#	6208



#	No Normal, No GTEx, 4+ for BRCA or 1+ for GBM or LGG
#tail -n +2 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | awk -F, '(( $107+$108==0 ) && ( ($14>3) || ($26>0) || ($38>0) ) ){print $1}' > tmp1.csv
#	5894


#	No Normal, No GTEx, 1+ for BRCA or 1+ for GBM or LGG
#tail -n +2 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | awk -F, '(( $107+$108==0 ) && ( ($14>0) || ($26>0) || ($38>0) ) ){print $1}' > tmp1.csv
#	8128







#	No Normal, No GTEx, 1+ for GBM or LGG
#tail -n +2 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | awk -F, '(( $107+$108==0 ) && ( ($26>0) || ($38>0) ) ){print $1}' > tmp1.csv
#	4253 - 56nt
#	4897 - 38nt
#	5610 - 28nt


#	No Normal, No GTEx without Testis, 1+ for GBM or LGG
tail -n +2 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | awk -F, '(( $107+$109==0 ) && ( ($26>0) || ($38>0) ) ){print $1}' > tmp1.csv
#	4454 - 56nt
#	5198 - 38nt
#	6022 - 28nt   <--- so close






#	No Normal, No GTEx without Testis, 1+ for BRCA or LAML or 1+ for GBM or LGG
#tail -n +2 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | awk -F, '(( $107+$109==0 ) && ( ($14>0) || ($26>0) || ($36>0) || ($38>0) ) ){print $1}' > tmp1.csv
#	18126 - 28nt

#	No Normal, No GTEx, 1+ for BRCA, LAML, GBM or LGG
#tail -n +2 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | awk -F, '(( $107+$108==0 ) && ( ($14>0) || ($26>0) || ($36>0) || ($38>0) ) ){print $1}' > tmp1.csv
#	14423 - 28nt

#	No Normal, No GTEx, 1+ for BRCA, GBM or LGG
#tail -n +2 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | awk -F, '(( $107+$108==0 ) && ( ($14>0) || ($26>0) || ($38>0) ) ){print $1}' > tmp1.csv
#	13546 - 28nt


#	No Normal, No GTEx, 2+ for BRCA or 1+ for GBM or LGG
#tail -n +2 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | awk -F, '(( $107+$108==0 ) && ( ($14>1) || ($26>0) || ($38>0) ) ){print $1}' > tmp1.csv
#	10537 - 28nt



head -1 tmp1.csv > SelectTumorOnlyTranscriptIds.txt
tail -n +2 tmp1.csv | sort >> SelectTumorOnlyTranscriptIds.txt
#wc -l SelectTumorOnlyTranscriptIds.txt

#	1 Transcript ID
#	14 BRCA_tumor    <--
#	15 BRCA_normal
#	26 GBM_tumor     <--
#	27 GBM_normal
#	36 LAML_tumor    <--
#	37 LAML_normal
#	38 LGG_tumor     <--
#	39 LGG_normal


#	head /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S10.csv
#	Transcript ID,Subfam,Chr TE,Start TE,End TE,Location TE,Gene,Splice Target,Strand,Index of Start Codon,Frame,Frame Type,Protein Sequence,Original Protein Sequence,Strategy,,,

tail -n +2 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S10.csv | tail -n 1 > tmp1.csv
tail -n +3 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S10.csv | sort -t, -k1,1 >> tmp1.csv


join --header -t, SelectTumorOnlyTranscriptIds.txt tmp1.csv > tmp2.csv

#wc -l tmp2.csv


#awk -F, '(NR>1 && $13 != "None"){if(!seen[$13]){seen[$13]++;print ">"$1"-"$10"-"$15;print $13}}' tmp2.csv

awk -F, '(NR>1 && $13 != "None"){print ">"$1"-"$10"-"$15;print $13}' tmp2.csv

#	head -2 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S10.csv | tail -n 1 | tr ',' '\n' | awk '{print NR,$1}'
#
#	1 Transcript <-- TCONS_
#	2 Subfam
#	3 Chr
#	4 Start
#	5 End
#	6 Location
#	7 Gene
#	8 Splice
#	9 Strand
#	10 Index <-- numeric
#	11 Frame
#	12 Frame
#	13 Protein <--
#	14 Original
#	15 Strategy <-- cpc2, kozak
#	16
#	17
#	18




