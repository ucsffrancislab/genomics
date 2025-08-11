#!/usr/bin/env Rscript
#SBATCH --export=NONE

#	From Geno


# AGS i370 Pharma SNPs GWASurvivr

# gwasurvivr analysis pipeline 

#https://bioconductor.org/packages/release/bioc/vignettes/gwasurvivr/inst/doc/gwasurvivr_Introduction.html
#http://www.bioconductor.org/packages/devel/bioc/manuals/gwasurvivr/man/gwasurvivr.pdf
# GG 
# UCSF
#date=20220427

ncores = 1

args = commandArgs(trailingOnly=TRUE)

# # test if there is at least one argument: if not, return an error
if (length(args)!=5) {
  print(length(args))
  stop(print("5 arguments needed"), call.=FALSE)
}

dataset = args[1]

imputed_file = args[2] #VCF 

cov_filename= args[3]

sample_list_filename = args[4]

out_filename = args[5]

library(gwasurvivr)
library(ncdf4)
library(matrixStats)
library(parallel)
library(survival)
library(GWASTools)
library(VariantAnnotation)
library(SummarizedExperiment)
library(SNPRelate)

options("gwasurvivr.cores"=ncores)



vcf.file <- imputed_file
print(vcf.file)


		#	This takes quite a while
		#print("Reading vcf to get the sample ids in it")
		#data <- readVcf(vcf.file, param=ScanVcfParam(geno="GT", info=c("AF", "MAF", "R2", "ER2")))
		#	This is fast
		vcf_header <- scanVcfHeader(vcf.file)
		print(vcf_header)

print(paste("Sample length",length(samples(vcf_header)),"in VCF"))


# Read in the data 
sample_list = read.csv(sample_list_filename, header = FALSE)
sample.ids = sample_list[,1]
head(sample.ids)



print(paste("Sample length",length(sample.ids),"in list"))

		#print("Geno's sample id filter")
		# sample IDS not in the genotype file for some reason
		#ni = which((as.character(sample.ids) %in% colnames(geno(data)$GT))== FALSE)
		#ni = which((as.character(sample.ids) %in% samples(vcf_header))== FALSE)
		#print(paste("Found ",length(ni)," not in vcf")
		#if(length(ni)>0){
		#	sample.ids = sample.ids[-ni]
		#}
		sample.ids=intersect(as.character(sample.ids),samples(vcf_header))

print(paste("Sample length",length(sample.ids),"in list AND VCF"))



print("Reading pheno file")

#	Some pheno files include spaces in the fields so this MUST be a tab sep
pheno.file <- read.table(cov_filename, sep="\t", header=TRUE, stringsAsFactors = FALSE)
pheno.file$SexFemale = ifelse(pheno.file$sex == "F", 1L, 0L)


#	only ONCO has a 'source' column
#if( dataset == "i370" ) {
#	#	I370
#	covs = c("Age", "SexFemale", "chemo","rad", "dxyear", "PC1", "PC2", "PC3", "PC4", "PC5", "PC6", "PC7", "PC8", "PC9", "PC10")
#}else{
#  # Onco and TCGA
#	pheno.file$SourceAGS = ifelse(pheno.file$source =="AGS",1L,0L)
#	covs = c("age", "SexFemale","SourceAGS","chemo","rad", "dxyear","PC1", "PC2", "PC3", "PC4", "PC5", "PC6", "PC7", "PC8", "PC9", "PC10")
#}


#if( dataset == "onco" ) {
#	pheno.file$SourceAGS = ifelse(pheno.file$source =="AGS",1L,0L)
#	covs = c("age", "SexFemale","SourceAGS","chemo","rad", "dxyear","PC1", "PC2", "PC3", "PC4", "PC5", "PC6", "PC7", "PC8", "PC9", "PC10")
#}else if(dataset == 'i370') {
#	#	I370 and TCGA
#	covs = c("Age", "SexFemale", "chemo","rad", "dxyear", "PC1", "PC2", "PC3", "PC4", "PC5", "PC6", "PC7", "PC8", "PC9", "PC10")
#}else{
#	covs = c("age", "SexFemale", "PC1", "PC2", "PC3", "PC4", "PC5", "PC6", "PC7", "PC8", "PC9", "PC10")
#}

covs=c()
if( 'source' %in% names(pheno.file) ){
	pheno.file$SourceAGS = ifelse(pheno.file$source =="AGS",1L,0L)
	covs=c(covs,"SourceAGS")
}
if( 'age' %in% names(pheno.file) ) covs=c(covs,"age")
if( 'Age' %in% names(pheno.file) ) covs=c(covs,"Age")
if( 'chemo' %in% names(pheno.file) ) covs=c(covs,"chemo")
if( 'rad' %in% names(pheno.file) ) covs=c(covs,"rad")
if( 'dxyear' %in% names(pheno.file) ) covs=c(covs,"dxyear")
covs=c(covs,"SexFemale","PC1", "PC2", "PC3", "PC4", "PC5", "PC6", "PC7", "PC8", "PC9", "PC10")

print("Using covs")
print(covs)


#	head -1 lists/tcga_covariates.tsv 
#	IID	sex	case	idh	pqimpute	tert	vstatus	survdays	age	hist	idhmut_gwas	idhmut_1p19qnoncodel_gwas	trippos_gwas	idhwt_gwas	idhmut_1p19qcodel_gwas	idhwt_1p19qnoncodel_TERTmut_gwas	idhwt_1p19qnoncodel_gwas	idhmut_only_gwas	tripneg_gwas	PC1	PC2	PC3	PC4	PC5	PC6	PC7	PC8	PC9	PC10	PC11	PC12	PC13	PC14	PC15	PC16	PC17	PC18	PC19	PC20
#	
#	head -1 lists/onco_covariates.tsv 
#	IID	case	sex	age_group	idh	pq	tert	vstatus	survdays	source	VZVsr	age	dxcode	WHO2016type	temodar	dxyear	hospname	ngrade	chemo	rad	idhmut_gwas	idhmut_1p19qnoncodel_gwas	trippos_gwas	idhwt_gwas	idhmut_1p19qcodel_gwas	idhwt_1p19qnoncodel_TERTmut_gwas	idhwt_1p19qnoncodel_gwas	idhmut_only_gwas	tripneg_gwas	PC1	PC2	PC3	PCPC5	PC6	PC7	PC8	PC9	PC10	PC11	PC12	PC13	PC14	PC15	PC16	PC17	PC18	PC19	PC20
#	
#	head -1 lists/i370_covariates.tsv 
#	IID	Age	sex	case	idhmut	pqimpute	tert	idhmut_gwas	idhmut_1p19qnoncodel_gwas	trippos_gwas	idhwt_gwas	idhmut_1p19qcodel_gwas	idhwt_1p19qnoncodel_TERTmut_gwas	idhmut_only_gwas	tripneg_gwas	idhwt_1p19qnoncodel_gwas	vstatus	survdays	VZVsr	dxcode	WHO2016type	temodar	dxyear	hospname	ngrade	chemo	rad	PC1	PC2	PC3	PC4	PC5	PC6	PCPC8	PC9	PC10	PC11	PC12	PC13	PC14	PC15	PC16	PC17	PC18	PC19	PC20


print(paste("Sample length",length(pheno.file$IID),"in cov file"))

		print("Filtering sample ids in pheno file")
		#sample.ids = as.character(sample.ids[which(sample.ids %in% pheno.file$IID)])
		#sample.ids = as.character(sample.ids[which(sample.ids %in% pheno.file$IID)])
		sample.ids=intersect(as.character(sample.ids),pheno.file$IID)

print(paste("Sample length",length(sample.ids),"in all 3"))

head(sample.ids)
tail(sample.ids)

dim(pheno.file)
print("Filtering pheno file")
pheno.file= pheno.file[which(pheno.file$IID %in% sample.ids),]
head(pheno.file)
dim(pheno.file)


#	After any filtering cause they all could be the same then it would probably cause an issue
if(length(unique(pheno.file$ngrade)) >1){
	covs = c(covs, "ngrade")
}



#	Analysis started on 2025-08-08 at 18:55:08
#	Covariates included in the models are: PC1, PC2, PC3, PC4, PC5, PC6, PC7, PC8, PC9, PC10, SexFemale
#	696 samples are included in the analysis
#	Error in pheno.file[, covariates] : subscript out of bounds
#	Calls: michiganCoxSurv -> coxPheno -> coxParam
#	Execution halted







#		cox.params <- coxPheno(covariate.file=pheno.file,
#			covariates=covs,
#			id.column='IID',
#			inter.term=NULL,
#			time.to.event='survdays',
#			event='vstatus',
#			sample.ids=sample.ids,
#			verbose=TRUE)
#		head(cox.params)
#		head(cox.params$ids)
#		
#		#data <- readVcf(vcf.file,
#		#	param=ScanVcfParam(geno="DS",
#		#	info=c("AF", "MAF", "R2", "ER2")))
#		#head(data)
#		#	genotypes <- geno(data)$DS[, cox.params$ids, drop=FALSE]
#		#	head(genotypes)
#		
#		library("vcfR")
#		my_vcf <- read.vcfR(vcf.file)
#		genos <- extract.gt(my_vcf, element = "DS", as.numeric=TRUE)
#		genotypes <- genos[, as.character(sample.ids), drop=FALSE]
#		
#		rowmeans <- rowMeans2(genotypes)
#		head(rowmeans)
#		
#		samp.exp_alt <- round(rowMeans2(genotypes)*0.5, 4)
#		head(samp.exp_alt))







#	print("Reading VCF. takes a while.")
#	data <- readVcf(vcf.file, param=ScanVcfParam(geno="DS", info=c("AF", "MAF", "R2", "ER2")))
#	genotypes <- geno(data)$DS[, as.character(sample.ids), drop=FALSE]
#	print(class(genotypes))
#	print(head(genotypes))

#	print("Analyzing")
#	a=0
#	for(i in c(1:nrow(genotypes))){
#		for( j in c(1:ncol(genotypes))){
#			if(genotypes[i,j][[1]]>=0 && genotypes[i,j][[1]]<=2.0 ){
#				a=a+1
#			}else{
#				print(genotypes[i,j][[1]])
#				print(paste("row ", i,", col ", j, sep = ""))
#			}
#		}
#	}




#	Analyzing chunk 298400-298500
#	Analyzing chunk 298500-298600
#	Analysis completed on 2025-07-01 at 10:06:41
#	8387 SNPs were removed from the analysis for not meeting the threshold criteria.
#	List of removed SNPs can be found in /scratch/gwendt/708647/AGS_Onco_HGG_IDHmut_meta_cases.snps_removed
#	 SNPs were analyzed in total
#	The survival output can be found at /scratch/gwendt/708647/AGS_Onco_HGG_IDHmut_meta_cases.coxph
#	There were 50 or more warnings (use warnings() to see the first 50)
#	AGS_Onco_HGG_IDHwt_meta_cases
#	Loading required package: Biobase
#	Loading required package: BiocGenerics

print("michiganCoxSurv")

michiganCoxSurv(vcf.file=as.character(vcf.file),
                covariate.file=pheno.file,
                id.column="IID",
                sample.ids=as.character(sample.ids),
                time.to.event="survdays",
                event="vstatus",
                covariates=covs,
                inter.term=NULL,
                print.covs="only",
                out.file=out_filename,
                r2.filter=0.1,
                maf.filter=0.01,
                chunk.size=100,
                verbose=TRUE,
                clusterObj=NULL)



#	AF and DS NEED to be Number=1 AND NOT Number=A

#	If DS is Number=A ...
#
#	Covariates included in the models are: Age, dxyear, ngrade, chemo, rad, PC1, PC2, PC3, PC4, PC5, PC6, PC7, PC8, PC9, PC10, SexFemale
#	41 samples are included in the analysis
#	Analyzing chunk 0-100
#	Error in rowMeans2(genotypes) : 
#  Argument 'x' must be of type logical, integer or numeric, not 'list'
#	Calls: michiganCoxSurv -> coxVcfMichigan -> rowMeans2
#	Execution halted

#	If AF is Number=A ...
#
#	Covariates included in the models are: Age, dxyear, chemo, rad, PC1, PC2, PC3, PC4, PC5, PC6, PC7, PC8, PC9, PC10, SexFemale
#	371 samples are included in the analysis
#	Analyzing chunk 0-100
#	Error in write.table(out.list$res, paste0(out.file, ".coxph"), append = FALSE,  : 
#	 unimplemented type 'list' in 'EncodeElement'
#	Calls: michiganCoxSurv -> write.table
#	Execution halted

#	recommended fix is bcftools norm -m- followed by sed to actually change the tag.


