#!/usr/bin/env bash

set -e  # Exit on error
set -u  # Exit on undefined variable

dataset=$1
infile=$2

awk -v dataset=$1 '
BEGIN {
	FS="\t";OFS=",";
	print "IID,dataset,source,age,sex,case,grade,idh,pq,tert,rad,chemo,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,survdays,vstatus"
} 
(NR==1){ for (i=1; i<=NF; i++) { col[$i] = i } }
(NR>1){
	if( dataset == "cidr" ){
		source="IPS"
		age = ($(col["age_first_surg"]) != "" ? $(col["age_first_surg"]) : $(col["age_ucsf_surg"]))
		sex_value = (c = col["sex"]) ? $c : ""
		sex=""
		if( sex_value == "1" ){
			sex="M"
		} else if( sex_value == "2" ){
			sex="F"
		}
		casecontrol="1"
		grade_value = (c = col["grade"]) ? $c : ""
		grade=""
		if( grade_value <= 3 ){
			grade="LGG"
		} else if( grade_value > 3 ){
			grade="HGG"
		}
		idh = (c = col["idhmut"]) ? $c : ""
 		#pq,Medical record/path review confirmation that tumor was 1p19q co-deleted. Only pulled and confirmed for oligodendroglioma patients,encoded value,0= 1p/19q intact  ,1= 1p/19q codeleted,blank=not abstracted,,,,,,,,,,
		# there are no 0s. 

		#pq = (c = col["pq"]) ? $c : ""
		pq = (c = col["pq"]) ? $c : 0
		tert=""
		rad = (c = col["rad"]) ? $c : ""
		chemo=$(col["tmz"])
		vstatus = (c = col["deceased"]) ? $c : ""
	} else if ( dataset == "i370" ){
		source="AGS"
		age = (c = col["Age"]) ? $c : ""
		sex = (c = col["sex"]) ? $c : ""
		casecontrol = (c = col["case"]) ? $c : ""
		grade_value = (c = col["ngrade"]) ? $c : ""
		grade=""
		if( grade_value <= 3 ){
			grade="LGG"
		} else if( grade_value > 3 ){
			grade="HGG"
		}
		idh = (c = col["idhmut"]) ? $c : ""
		pq = (c = col["pqimpute"]) ? $c : ""
		tert = (c = col["tert"]) ? $c : ""
		rad = (c = col["rad"]) ? $c : ""
		chemo = (c = col["chemo"]) ? $c : ""
		vstatus = (c = col["vstatus"]) ? $c : ""
	} else if ( dataset == "onco" ){
		source = (c = col["source"]) ? $c : ""
		age = (c = col["age"]) ? $c : ""
		sex = (c = col["sex"]) ? $c : ""
		casecontrol = (c = col["case"]) ? $c : ""
		grade_value = (c = col["ngrade"]) ? $c : ""
		grade=""
		if( grade_value <= 3 ){
			grade="LGG"
		} else if( grade_value > 3 ){
			grade="HGG"
		}
		idh = (c = col["idh"]) ? $c : ""
		pq = (c = col["pq"]) ? $c : ""
		tert = (c = col["tert"]) ? $c : ""
		rad = (c = col["rad"]) ? $c : ""
		chemo = (c = col["chemo"]) ? $c : ""
		vstatus = (c = col["vstatus"]) ? $c : ""
	} else if ( dataset == "tcga" ){





		#	ONLY INCLUDE THE NORMAL "10" samples. Not 01. Not 11.
		#	This will also drop the controls, but we are not using them at the moment
		#	Perhaps, just drop the TCGA non-normal?
		#	TCGA only normal as a case - DROP ALL TUMORS
		#	Keep only from SINGLE UNIQUE SUBJECT
		#	10	Blood Derived Normal	NB
		#	11	Solid Tissue Normal	NT
		iid_value = (c = col["IID"]) ? $c : ""
		if ( iid_value ~ /^TCGA-/ && iid_value !~ /^TCGA-..-....-10/ )
			next




		dataset="tcga"
		source="TCGA"
		age = (c = col["age"]) ? $c : ""
		sex_value = (c = col["sex"]) ? $c : ""
		sex=""
		if( sex_value == "male" ){
			sex="M"
		} else if( sex_value == "female" ){
			sex="F"
		}
		casecontrol = (c = col["case"]) ? $c : ""
		grade=""
		if( iid_value ~ /^TCGA-(CS|DB|DH|DU|E1|EZ|F6|FG|FN|HK|HT|HW|IK|KT|P5|QH|R8|RY|S9|TM|TQ|VM|VV|VW|W9|WH|WY)-/){
			grade="LGG"
		} else if( iid_value ~ /^TCGA-(02|06|08|12|14|15|16|19|26|27|28|32|41|4W|65|74|76|81|87|OX|RR)-/){
			grade="HGG"
		}
		idh = (c = col["idh"]) ? $c : ""
		pq = (c = col["pqimpute"]) ? $c : ""
		tert = (c = col["tert"]) ? $c : ""
		rad=""
		chemo=""
		vstatus = (c = col["vstatus"]) ? $c : ""
	} else {
		print "Unknown dataset"
		exit 1
	}
	print $(col["IID"]),dataset,source,age,sex,casecontrol,grade,idh,pq,tert,rad,chemo,$(col["PC1"]),$(col["PC2"]),$(col["PC3"]),$(col["PC4"]),$(col["PC5"]),$(col["PC6"]),$(col["PC7"]),$(col["PC8"]),$(col["survdays"]),vstatus

}' $infile | sed 's/,NA/,/g'



exit 0


grade (high and low thresholds?) (grade (2,3,4,NA) in CIDR; ngrade (1,2,3,4,NA in Onco,I370; TCGA is GBM v LGG based on sample id?) This is the tricky one. 

Should all TCGA samples be used as cases even those that whose sample code is Normal?

I am mostly finding in Onco and I370 that ngrade=1,2,3 are in Geno's LGG list and ngrade=4 is in the HGG list. While I haven't found one in the other, sometimes they aren't in either list. Is there more to the grade?


./normalize_covariates.bash cidr pgs-calc-scores-merged/cidr/cidr-covariates.tsv > edison_covariates/cidr-covariates.tsv
./normalize_covariates.bash i370 pgs-calc-scores-merged/i370/i370-covariates.tsv > edison_covariates/i370-covariates.tsv
./normalize_covariates.bash onco pgs-calc-scores-merged/onco/onco-covariates.tsv > edison_covariates/onco-covariates.tsv
./normalize_covariates.bash tcga pgs-calc-scores-merged/tcga/tcga-covariates.tsv > edison_covariates/tcga-covariates.tsv


