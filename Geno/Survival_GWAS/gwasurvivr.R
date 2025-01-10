#!/usr/bin/env Rscript


# AGS Pharma SNPs GWASurvivr

# gwasurvivr analysis pipeline 

#BiocManager::install(c('gwasurvivr','ncdf4','matrixStats','parallel','survival','GWASTools','VariantAnnotation','SummarizedExperiment','SNPRelate'))


#https://bioconductor.org/packages/release/bioc/vignettes/gwasurvivr/inst/doc/gwasurvivr_Introduction.html
#http://www.bioconductor.org/packages/devel/bioc/manuals/gwasurvivr/man/gwasurvivr.pdf
# GG 
# UCSF
#date=20220427

ncores = 1


args = commandArgs(trailingOnly=TRUE)

# # test if there is at least one argument: if not, return an error
if (length(args)!=4) {
	print(length(args))
	stop(print("4 arguments needed"), call.=FALSE)
}
imputed_file = args[1] #VCF 

cov_filename= args[2]

sample_list_filename = args[3]

out_filename = args[4]

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

# TCGA Specific 
pheno.file <- read.table(cov_filename,
	sep="\t", 
	header=TRUE,
	stringsAsFactors = FALSE)

# Recode the covariates so they are numeric!!!!
pheno.file$SexFemale = ifelse(pheno.file$sex == "female", 1L, 0L)

sample.ids =as.character(sample_list[,1])

head(sample.ids)

data <- readVcf(vcf.file, param=ScanVcfParam(geno="GT", info=c("AF", "MAF", "R2", "ER2")))

# sample IDS not in the genotype file for some reason
ni = which((as.character(sample.ids) %in% colnames(geno(data)$GT))== FALSE)
if(length(ni)>0){
	sample.ids = sample.ids[-ni]
}

sample.ids = as.character(sample.ids[which(sample.ids %in% pheno.file$IID)])

head(pheno.file$IID)

pheno.file= pheno.file[which(pheno.file$IID %in% sample.ids),]
pheno.file$IID = as.character(pheno.file$IID)

head(pheno.file$IID)

covs = c("age", "SexFemale", "PC1", "PC2", "PC3", "PC4", "PC5", "PC6", "PC7", "PC8", "PC9", "PC10")

if(length(unique(pheno.file$ngrade)) >1){
	covs = c (covs, "ngrade")
}

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

