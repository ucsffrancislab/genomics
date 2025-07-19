#!/usr/bin/env Rscript
#SBATCH --export=NONE

# From Geno
#	/francislab/data1/working/20210302-AGS-illumina/20210310-scripts/Pharma/Pull_case_dosage

# Pull Pharma Dosage Data
#date=20220427
ncores = 1


args = commandArgs(trailingOnly=TRUE)

# # test if there is at least one argument: if not, return an error
if (length(args)!=3) {
  print(length(args))
  stop(print("3 arguments needed"), call.=FALSE)
}
imputed_file = args[1] #VCF 


sample_list_filename = args[2]

out_filename = args[3]

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

sample.ids = sample_list[,1]
data <- readVcf(vcf.file, param=ScanVcfParam(geno="DS", info=c("AF", "MAF", "R2", "ER2")))
genotypes <- geno(data)$DS[, as.character(sample.ids), drop=FALSE]

write.table(genotypes, out_filename, quote=FALSE, row.names=TRUE, col.names=TRUE)
