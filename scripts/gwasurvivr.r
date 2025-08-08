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

print(paste("Sample length ",length(samples(vcf_header))," in VCF"))


# Read in the data 
sample_list = read.csv(sample_list_filename, header = FALSE)
sample.ids = sample_list[,1]
head(sample.ids)



print(paste("Sample length ",length(sample.ids)," in list"))

		#print("Geno's sample id filter")
		# sample IDS not in the genotype file for some reason
		#ni = which((as.character(sample.ids) %in% colnames(geno(data)$GT))== FALSE)
		#ni = which((as.character(sample.ids) %in% samples(vcf_header))== FALSE)
		#print(paste("Found ",length(ni)," not in vcf")
		#if(length(ni)>0){
		#	sample.ids = sample.ids[-ni]
		#}
		sample.ids=intersect(as.character(sample.ids),samples(vcf_header))

print(paste("Sample length ",length(sample.ids)," in list AND VCF"))



print("Reading pheno file")

pheno.file <- read.table(cov_filename, sep="", header=TRUE, stringsAsFactors = FALSE)
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

if( dataset == "onco" ) {
	pheno.file$SourceAGS = ifelse(pheno.file$source =="AGS",1L,0L)
	covs = c("age", "SexFemale","SourceAGS","chemo","rad", "dxyear","PC1", "PC2", "PC3", "PC4", "PC5", "PC6", "PC7", "PC8", "PC9", "PC10")
}else{
	#	I370 and TCGA
	covs = c("Age", "SexFemale", "chemo","rad", "dxyear", "PC1", "PC2", "PC3", "PC4", "PC5", "PC6", "PC7", "PC8", "PC9", "PC10")
}

print(paste("Sample length ",length(pheno.file$IID)," in cov file"))

		print("Filtering sample ids in pheno file")
		#sample.ids = as.character(sample.ids[which(sample.ids %in% pheno.file$IID)])
		#sample.ids = as.character(sample.ids[which(sample.ids %in% pheno.file$IID)])
		sample.ids=intersect(as.character(sample.ids),pheno.file$IID)

print(paste("Sample length ",length(sample.ids)," in all 3"))

head(sample.ids)
tail(sample.ids)

dim(pheno.file)
print("Filtering pheno file")
pheno.file= pheno.file[which(pheno.file$IID %in% sample.ids),]
head(pheno.file)
dim(pheno.file)


if(length(unique(pheno.file$ngrade)) >1){
	covs = c(covs, "ngrade")
}










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



#	be nice if knew how many "chunks" there were so knew how long

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


