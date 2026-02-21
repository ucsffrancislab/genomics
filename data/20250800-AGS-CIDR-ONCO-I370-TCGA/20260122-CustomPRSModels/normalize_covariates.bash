#!/usr/bin/env bash

set -e  # Exit on error
set -u  # Exit on undefined variable

dataset=$1
infile=$2


echo "IID,dataset,source,age,sex,case,rad,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8"



if [ "${dataset}" == "cidr" ] ; then
	echo "Processing ${dataset}"
	awk 'BEGIN {FS=OFS="\t"} 
		(NR==1){ for (i=1; i<=NF; i++) { col_map[$i] = i } }
		(NR>1){
			age = ($(col_map["age_first_surg"]) != "" ? $(col_map["age_first_surg"]) : $(col_map["age_ucsf_surg"]))
			sex=""
			if( $(col_map["sex"]) == "1" ){
				sex="M"
			} else if( $(col_map["sex"]) == "2" ){
				sex="F"
			}
			casecontrol="1"
			print $(col_map["IID"]),"cidr","IPS",age,sex,casecontrol,$(col_map["rad"]),$(col_map["PC1"]),$(col_map["PC2"]),$(col_map["PC3"]),$(col_map["PC4"]),$(col_map["PC5"]),$(col_map["PC6"]),$(col_map["PC7"]),$(col_map["PC8"])
		}' $infile
elif [ "${dataset}" == "i370" ] ; then
	echo "Processing ${dataset}"
	awk 'BEGIN {FS=OFS="\t"} 
		(NR==1){ for (i=1; i<=NF; i++) { col_map[$i] = i } }
		(NR>1){
			print $(col_map["IID"]),"i370","xxx",$(col_map["Age"]),$(col_map["sex"]),$(col_map["case"]),$(col_map["rad"]),$(col_map["PC1"]),$(col_map["PC2"]),$(col_map["PC3"]),$(col_map["PC4"]),$(col_map["PC5"]),$(col_map["PC6"]),$(col_map["PC7"]),$(col_map["PC8"])
		}' $infile
elif [ "${dataset}" == "onco" ] ; then
	echo "Processing ${dataset}"
	awk 'BEGIN {FS=OFS="\t"} 
		(NR==1){ for (i=1; i<=NF; i++) { col_map[$i] = i } }
		(NR>1){
			print $(col_map["IID"]),"onco",$(col_map["source"]),$(col_map["age"]),$(col_map["sex"]),$(col_map["case"]),$(col_map["rad"]),$(col_map["PC1"]),$(col_map["PC2"]),$(col_map["PC3"]),$(col_map["PC4"]),$(col_map["PC5"]),$(col_map["PC6"]),$(col_map["PC7"]),$(col_map["PC8"])
		}' $infile
elif [ "${dataset}" == "tcga" ] ; then
	echo "Processing ${dataset}"
	awk 'BEGIN {FS=OFS="\t"} 
		(NR==1){ for (i=1; i<=NF; i++) { col_map[$i] = i } }
		(NR>1){
			rad=""
			print $(col_map["IID"]),"tcga","xxx",$(col_map["age"]),sex,$(col_map["case"]),rad,$(col_map["PC1"]),$(col_map["PC2"]),$(col_map["PC3"]),$(col_map["PC4"]),$(col_map["PC5"]),$(col_map["PC6"]),$(col_map["PC7"]),$(col_map["PC8"])
		}' $infile
else
	echo "I don't recognize the dataset :${dataset}:"
fi





exit 0

Once all 4 of these are done, try to unify them

chemo/tmz (0=no, 1=yes?; if known. not in TCGA; tmz for CIDR) temodar?
vstatus (0=dead, 1=alive? or vice versa?; deceased in CIDR)
survdays (continuous int)
idh (0=wildtype, 1=mutant?) From idh or idhwt_gwas/idhmut_gwas
pq (0=intact, 1=codel?) from either pq or pqimpute?
tert (0=?, 1=?) (not in CIDR)

grade (high and low thresholds?) (grade (2,3,4,NA) in CIDR; ngrade (1,2,3,4,NA in Onco,I370; TCGA is GBM v LGG based on sample id?) This is the tricky one. 

Should all TCGA samples be used as cases even those that whose sample code is Normal?

I am mostly finding in Onco and I370 that ngrade=1,2,3 are in Geno's LGG list and ngrade=4 is in the HGG list. While I haven't found one in the other, sometimes they aren't in either list. Is there more to the grade?


./normalize_covariates.bash cidr pgs-calc-scores-merged/cidr/cidr-covariates.tsv | head
./normalize_covariates.bash i370 pgs-calc-scores-merged/i370/i370-covariates.tsv | head
./normalize_covariates.bash onco pgs-calc-scores-merged/onco/onco-covariates.tsv | head
./normalize_covariates.bash tcga pgs-calc-scores-merged/tcga/tcga-covariates.tsv | head

