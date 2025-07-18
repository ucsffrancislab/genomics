#!/usr/bin/env Rscript

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

# Read in the data 
sample_list = read.csv(sample_list_filename, header = FALSE)

vcf.file <- imputed_file

# AGS Onco Specific 
pheno.file <- read.table(cov_filename,
                         sep="", 
                         header=TRUE,
                         stringsAsFactors = FALSE)

pheno.file$SexFemale = ifelse(pheno.file$sex == "F", 1L, 0L)



if( dataset == "onco" ) {
	pheno.file$SourceAGS = ifelse(pheno.file$source =="AGS",1L,0L)
	covs = c("age", "SexFemale","SourceAGS","chemo","rad", "dxyear","PC1", "PC2", "PC3", "PC4", "PC5", "PC6", "PC7", "PC8", "PC9", "PC10")
}else{
	covs = c("Age", "SexFemale", "chemo","rad", "dxyear", "PC1", "PC2", "PC3", "PC4", "PC5", "PC6", "PC7", "PC8", "PC9", "PC10")
}




sample.ids = sample_list[,1]

pheno.file= pheno.file[which(pheno.file$IID %in% sample.ids),]


if(length(unique(pheno.file$ngrade)) >1){
	covs = c(covs, "ngrade")
}

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
                sample.ids=sample.ids,
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

# 
# 
# data <- readVcf(vcf.file, param=ScanVcfParam(geno="DS", info=c("AF", "MAF", "R2", "ER2")))
# genotypes <- geno(data)$DS[, as.character(sample.ids), drop=FALSE]
# a=0
# for(i in c(1:nrow(genotypes))){
#   for( j in c(1:ncol(genotypes))){
#     if(genotypes[i,j][[1]]>=0 && genotypes[i,j][[1]]<=2.0 ){
#       a=a+1
#     }else{
#       print(genotypes[i,j][[1]])
#       print(paste("row ", i,", col ", j, sep = ""))
#     }
#     
#   }
# }

