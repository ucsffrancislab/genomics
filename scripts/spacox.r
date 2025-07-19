#!/usr/bin/env Rscript
#SBATCH --export=NONE

#	From Geno



# AGS i370 Pharma SNPs SPACox

# gwasurvivr analysis pipeline 

#https://rdrr.io/github/WenjianBI/SPACox/man/SPACox.html
# GG 
# UCSF
#date=20220810


args = commandArgs(trailingOnly=TRUE)

# # test if there is at least one argument: if not, return an error
if (length(args)!=5) {
	print(length(args))
	stop(print("5 arguments needed"), call.=FALSE)
}

dataset = args[1]

imputed_filename = args[2] #VCF 

cov_filename= args[3]

sample_list_filename = args[4]

out_filename = args[5]

library(SPACox)
library(survival)

#sample_list_filename= "/home/gguerra/Pharma_TMZ_glioma/Data/AGS_i370_glioma_cases.txt"
#cov_filename = "/francislab/data1/working/20210302-AGS-illumina/20210305-covariates/AGS_illumina_covariates.txt"
#imputed_filename = "/francislab/data1/working/20210302-AGS-illumina/20220425-Pharma/data/AGS_i370_glioma_cases.dosage"
#out_filename = "/francislab/data1/working/20210302-AGS-illumina/20220425-Pharma/results/survival/SPA_Cox_AGS_i370_glioma_cases.txt"



# Read in the data 
sample_list = read.csv(sample_list_filename, header = FALSE)
if ( dataset == "il370" ){
	sep=""
} else {
	sep="\t"
}
pheno.file <- read.table(cov_filename, sep=sep, header=TRUE, stringsAsFactors = FALSE)

vcf.file =read.csv(imputed_filename, sep = "", header =TRUE, row.names = 1)
vcf.file = t(vcf.file)

pheno.file$SexFemale = ifelse(pheno.file$sex == "F", 1L, 0L)


#sample.ids = sample_list[,1]

# Convert IDs with integer first character to have an "X" at the start, to accomodate the row.names of vcf.file
add_X =function(rname){
	b= strsplit(rname, split = "")[[1]]
	retname = rname

	if(!is.na(as.numeric(b[1]))){
		retname = paste("X", rname, sep ="")
	#}else{
	}
	return(retname)
}
sample.ids = as.character(sapply(as.character(sample_list[,1]) , add_X))

pheno.file$IID = as.character(sapply(as.character(pheno.file$IID), add_X))



# Alter the VCF rownames by replacing the period with a -
dotwithdash = function(rname){
	b= strsplit(rname, split = "")[[1]]
	b[which(b ==".")]= "-"
	d= paste(b, collapse = "")
	return(d)
}
row.names(vcf.file) = as.character(sapply(row.names(vcf.file), dotwithdash))
sample.ids = as.character(sapply(as.character(sample.ids) , dotwithdash))
pheno.file$IID = as.character(sapply(as.character(pheno.file$IID), dotwithdash))


#Restrict vcf.file and pheno.file to sample.ids
vcf.file = vcf.file[which(row.names(vcf.file) %in% sample.ids), ]
pheno.file = pheno.file[which(pheno.file$IID %in% sample.ids), ]


in_both = intersect(row.names(vcf.file), pheno.file$IID)
vcf.file = vcf.file[which(row.names(vcf.file) %in% in_both), ]
pheno.file = pheno.file[which(pheno.file$IID %in% in_both), ]

nrow(pheno.file)
length(sample.ids)







#	

if( dataset == "onco" ){
	if(length(unique(pheno.file$ngrade)) >1){
		obj.null = SPACox_Null_Model(Surv(survdays, vstatus)~age + sex + ngrade + PC1 + PC2 +PC3 + PC4 + PC5 + PC6 +PC7 + PC8 +PC9 +PC10, 
			data = pheno.file, pIDs =pheno.file$IID, gIDs = rownames(vcf.file))
	}else{
		obj.null = SPACox_Null_Model(Surv(survdays, vstatus)~age + sex + PC1 + PC2 +PC3 + PC4 + PC5 + PC6 +PC7 + PC8 +PC9 +PC10,
			data = pheno.file, pIDs =pheno.file$IID, gIDs = rownames(vcf.file))
	}

} else {	#	dataset == "il370"
	if(length(unique(pheno.file$ngrade)) >1){
		obj.null = SPACox_Null_Model(
			Surv(survdays, vstatus)~Age + SexFemale + chemo + rad + ngrade + dxyear + PC1 + PC2 +PC3 + PC4 + PC5 + PC6 +PC7 + PC8 +PC9 +PC10,
			data = pheno.file,
			pIDs =pheno.file$IID,
			gIDs = rownames(vcf.file))
	}else{
		obj.null = SPACox_Null_Model(
			Surv(survdays, vstatus)~Age + SexFemale + chemo + rad  + dxyear +  PC1 + PC2 +PC3 + PC4 + PC5 + PC6 +PC7 + PC8 +PC9 +PC10,
			data = pheno.file,
			pIDs =pheno.file$IID,
			gIDs = rownames(vcf.file))
	}
}

SPACox.res = SPACox(obj.null, vcf.file)

SPACox.res = cbind(row.names(SPACox.res), SPACox.res)
colnames(SPACox.res)[1] ="RSID"
write.table(file= out_filename, x = SPACox.res, col.names =TRUE, quote = FALSE, row.names= FALSE, sep = "\t")



