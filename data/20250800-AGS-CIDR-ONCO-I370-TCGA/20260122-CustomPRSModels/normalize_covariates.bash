#!/usr/bin/env bash

set -e  # Exit on error
set -u  # Exit on undefined variable

dataset=$1
infile=$2


echo "IID,dataset,source,age,sex,case,grade,idh,pq,tert,rad,chemo,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,survdays,vstatus"



if [ "${dataset}" == "cidr" ] ; then
	#SUBJECT_ID,Subject ID,string,,,,,,,,,,,,,
	#age_ucsf_surg,Age at IPS enrollment surgery ,years,,,,,,,,,,,,,
	#age_first_surg,"For patients with an earlier diagnosis, age when first surgically diagnosed with a glioma",years,,,,,,,,,,,,,
	#sex,Biological sex,encoded value,1=Male,2=Female,,,,,,,,,,,
	#grade,Tumor grade per pathology report from study enrollment surgery,encoded value,2=tumor grade 2,3=tumor grade 3,4=tumor grade 4,blank=missing/unknown grade,,,,,,,,,
	#who2021,WHO2021 classification per enrollment surgery pathology report,encoded value,"1=Astrocytoma, IDH-mutant, CNS WHO grade 2","2=Astrocytoma, IDH-mutant, CNS WHO grade 3","3=Astrocytoma, IDH-mutant, CNS WHO grade 4","4=Diffuse glioma with molecular features of glioblastoma, IDH-wildtype, WHO grade 4","5=Giant cell glioblastoma, IDH-wildtype, WHO grade 4","6=Glioblastoma, IDH- and histone H3-wildtype, WHO grade 4","7=Glioblastoma, IDH-wildtype, CNS WHO grade 4","8=Gliosarcoma, IDH-wildtype, CNS WHO grade 4","9=Oligodendroglioma, IDH-mutant and 1p/19q codeleted, CNS WHO grade 2","10=Oligodendroglioma, IDH-mutant and 1p/19q codeleted, CNS WHO grade 3",13=Not in WHO 2021 Classification,14=Other,"15=Diffuse midline glioma, H3 K27-altered, WHO grade 4"
	#pq,Medical record/path review confirmation that tumor was 1p19q co-deleted. Only pulled and confirmed for oligodendroglioma patients,encoded value,0= 1p/19q intact  ,1= 1p/19q codeleted,blank=not abstracted,,,,,,,,,,
	#idhmut,IDH mutation status ,encoded value,1=mutated,0=wildtype, 9=unknown,,,,,,,,,,
	#survdays,Days between first glioma diagnosis and death (if deceased) or last contact (if alive at last follow-up),days,,,,,,,,,,,,,
	#deceased,Vital status at last follow-up,encoded value,0=alive as of last follow up,1= deceased,,,,,,,,,,,
	#rad,1,Received any radiation after IPS eligible surgery
	#,0,No radiation documented after IPS eligible surgery
	#,9,Unknown if given (could not find treatment information)
	#tmz,1,TMZ given at any point after IPS eligible surgery
	#,0,Not given (in some cases not able to determine because no information or tx was given elsewhere and we did not follow the patient)
	#,9,Unknown if given (could not find treatment information)
	awk 'BEGIN {FS="\t";OFS=","} 
		(NR==1){ for (i=1; i<=NF; i++) { col_map[$i] = i } }
		(NR>1){
			dataset="cidr"
			source="IPS"
			age = ($(col_map["age_first_surg"]) != "" ? $(col_map["age_first_surg"]) : $(col_map["age_ucsf_surg"]))
			sex_value = (c = col_map["sex"]) ? $c : ""
			sex=""
			if( sex_value == "1" ){
				sex="M"
			} else if( sex_value == "2" ){
				sex="F"
			}
			casecontrol="1"
			grade_value = (c = col_map["grade"]) ? $c : ""
			grade=""
			if( grade_value <= 3 ){
				grade="LGG"
			} else if( grade_value > 3 ){
				grade="HGG"
			}
			idh = (c = col_map["idhmut"]) ? $c : ""
			pq = (c = col_map["pq"]) ? $c : ""
			tert=""
			rad = (c = col_map["rad"]) ? $c : ""
			chemo=$(col_map["tmz"])
			vstatus = (c = col_map["deceased"]) ? $c : ""
			print $(col_map["IID"]),dataset,source,age,sex,casecontrol,grade,idh,pq,tert,rad,chemo,$(col_map["PC1"]),$(col_map["PC2"]),$(col_map["PC3"]),$(col_map["PC4"]),$(col_map["PC5"]),$(col_map["PC6"]),$(col_map["PC7"]),$(col_map["PC8"]),$(col_map["survdays"]),vstatus
		}' $infile | sed 's/,NA/,/g'
elif [ "${dataset}" == "i370" ] ; then
	awk 'BEGIN {FS="\t";OFS=","} 
		(NR==1){ for (i=1; i<=NF; i++) { col_map[$i] = i } }
		(NR>1){
			dataset="I370"
			source="AGS"
			age = (c = col_map["Age"]) ? $c : ""
			sex = (c = col_map["sex"]) ? $c : ""
			casecontrol = (c = col_map["case"]) ? $c : ""
			grade_value = (c = col_map["ngrade"]) ? $c : ""
			grade=""
			if( grade_value <= 3 ){
				grade="LGG"
			} else if( grade_value > 3 ){
				grade="HGG"
			}
			idh = (c = col_map["idhmut"]) ? $c : ""
			pq = (c = col_map["pqimpute"]) ? $c : ""
			tert = (c = col_map["tert"]) ? $c : ""
			rad = (c = col_map["rad"]) ? $c : ""
			chemo = (c = col_map["chemo"]) ? $c : ""
			vstatus = (c = col_map["vstatus"]) ? $c : ""
			print $(col_map["IID"]),dataset,source,age,sex,casecontrol,grade,idh,pq,tert,rad,chemo,$(col_map["PC1"]),$(col_map["PC2"]),$(col_map["PC3"]),$(col_map["PC4"]),$(col_map["PC5"]),$(col_map["PC6"]),$(col_map["PC7"]),$(col_map["PC8"]),$(col_map["survdays"]),vstatus
		}' $infile | sed 's/,NA/,/g'
elif [ "${dataset}" == "onco" ] ; then
	awk 'BEGIN {FS="\t";OFS=","} 
		(NR==1){ for (i=1; i<=NF; i++) { col_map[$i] = i } }
		(NR>1){
			dataset="onco"
			source = (c = col_map["source"]) ? $c : ""
			age = (c = col_map["age"]) ? $c : ""
			sex = (c = col_map["sex"]) ? $c : ""
			casecontrol = (c = col_map["case"]) ? $c : ""
			grade_value = (c = col_map["ngrade"]) ? $c : ""
			grade=""
			if( grade_value <= 3 ){
				grade="LGG"
			} else if( grade_value > 3 ){
				grade="HGG"
			}
			idh = (c = col_map["idh"]) ? $c : ""
			pq = (c = col_map["pq"]) ? $c : ""
			tert = (c = col_map["tert"]) ? $c : ""
			rad = (c = col_map["rad"]) ? $c : ""
			chemo = (c = col_map["chemo"]) ? $c : ""
			vstatus = (c = col_map["vstatus"]) ? $c : ""
			print $(col_map["IID"]),dataset,source,age,sex,casecontrol,grade,idh,pq,tert,rad,chemo,$(col_map["PC1"]),$(col_map["PC2"]),$(col_map["PC3"]),$(col_map["PC4"]),$(col_map["PC5"]),$(col_map["PC6"]),$(col_map["PC7"]),$(col_map["PC8"]),$(col_map["survdays"]),vstatus
		}' $infile | sed 's/,NA/,/g'
elif [ "${dataset}" == "tcga" ] ; then
	awk 'BEGIN {FS="\t";OFS=","} 
		(NR==1){ for (i=1; i<=NF; i++) { col_map[$i] = i } }
		(NR>1){
			iid_value = (c = col_map["IID"]) ? $c : ""
			dataset="tcga"
			source="TCGA"
			age = (c = col_map["age"]) ? $c : ""
			sex = (c = col_map["sex"]) ? $c : ""
			casecontrol = (c = col_map["case"]) ? $c : ""
			grade=""
			if( iid_value ~ /^TCGA-(CS|DB|DH|DU|E1|EZ|F6|FG|FN|HK|HT|HW|IK|KT|P5|QH|R8|RY|S9|TM|TQ|VM|VV|VW|W9|WH|WY)-/){
				grade="LGG"
			} else if( iid_value ~ /^TCGA-(02|06|08|12|14|15|16|19|26|27|28|32|41|4W|65|74|76|81|87|OX|RR)-/){
				grade="HGG"
			}
			idh = (c = col_map["idh"]) ? $c : ""
			pq = (c = col_map["pqimpute"]) ? $c : ""
			tert = (c = col_map["tert"]) ? $c : ""
			rad=""
			chemo=""
			vstatus = (c = col_map["vstatus"]) ? $c : ""
			print $(col_map["IID"]),dataset,source,age,sex,casecontrol,grade,idh,pq,tert,rad,chemo,$(col_map["PC1"]),$(col_map["PC2"]),$(col_map["PC3"]),$(col_map["PC4"]),$(col_map["PC5"]),$(col_map["PC6"]),$(col_map["PC7"]),$(col_map["PC8"]),$(col_map["survdays"]),vstatus
		}' $infile | sed 's/,NA/,/g'
else
	echo "I don't recognize the dataset :${dataset}:"
fi





exit 0

Once all 4 of these are done, try to unify them

grade (high and low thresholds?) (grade (2,3,4,NA) in CIDR; ngrade (1,2,3,4,NA in Onco,I370; TCGA is GBM v LGG based on sample id?) This is the tricky one. 

Should all TCGA samples be used as cases even those that whose sample code is Normal?

I am mostly finding in Onco and I370 that ngrade=1,2,3 are in Geno's LGG list and ngrade=4 is in the HGG list. While I haven't found one in the other, sometimes they aren't in either list. Is there more to the grade?


./normalize_covariates.bash cidr pgs-calc-scores-merged/cidr/cidr-covariates.tsv > edison_covariates/cidr-covariates.tsv
./normalize_covariates.bash i370 pgs-calc-scores-merged/i370/i370-covariates.tsv > edison_covariates/i370-covariates.tsv
./normalize_covariates.bash onco pgs-calc-scores-merged/onco/onco-covariates.tsv > edison_covariates/onco-covariates.tsv
./normalize_covariates.bash tcga pgs-calc-scores-merged/tcga/tcga-covariates.tsv > edison_covariates/tcga-covariates.tsv

