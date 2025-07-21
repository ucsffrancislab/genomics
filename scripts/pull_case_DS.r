#!/usr/bin/env Rscript

#	from Geno
#	/francislab/data1/working/20210302-AGS-illumina/20210310-scripts/Pharma/Pull_case_dosage


#date=20220427
#ncores = 1

ncores=as.numeric(Sys.getenv("SLURM_NTASKS", unset = 4 ))	#	Not sure that this matters


args = commandArgs(trailingOnly=TRUE)

# # test if there is at least one argument: if not, return an error
if (length(args)!=3) {
  print(length(args))
  stop(print("3 arguments needed"), call.=FALSE)
}
imputed_file = args[1] #VCF 


sample_list_filename = args[2]

out_filename = args[3]

#	Not sure if all of these are needed now
library(gwasurvivr)
library(ncdf4)
library(matrixStats)
library(parallel)
library(survival)
library(GWASTools)
library(VariantAnnotation)
library(SummarizedExperiment)
library(SNPRelate)

options("gwasurvivr.cores"=ncores)	#	Not sure that this matters

# Read in the data 
sample_list = read.csv(sample_list_filename, header = FALSE)

vcf.file <- imputed_file

sample.ids = sample_list[,1]

#	param=ScanVcfParam(geno="DS", info=c("AF", "MAF", "R2", "ER2"))
#	
#	#	This is a memory HOG. >197GB for the ONCO data, then crashed
#	#	Il370 is 3x the size. Not sure how that's gonna go.
#	print('Running readVcf(vcf.file, param=param)')
#	data <- readVcf(vcf.file, param=param)
#	genotypes <- geno(data)$DS[, as.character(sample.ids), drop=FALSE]

# Alternative?
#	data <- read.vcfR()


library("vcfR")
my_vcf <- read.vcfR(vcf.file)
genos <- extract.gt(my_vcf, element = "DS", as.numeric=TRUE)

#	minor different. extract.gt will add a counter suffix to the rowname ...
#	rs377452492_48
#	rs5993997_49
#	rs772378070_50 
#	Not sure why. Not sure how to stop. Not sure if it matters.

#	Testing on Onco QC Concat ... 69GB

genotypes <- genos[, as.character(sample.ids), drop=FALSE]




write.table(genotypes, out_filename, quote=FALSE, row.names=TRUE, col.names=TRUE)

#	the previous output dosage files have rownames like chr#:#######:A:C, not the rsID, and no suffixes

#	Geno's VCFs didn't have rsIDs. They had these style names. An issue?

#	AGS40015_AGS40015 AGS40020_AGS40020 AGS40050_AGS40050 AGS40094_AGS40094 AGS40097_AGS40097 AGS40103_A
#	chr1:1773215:C:A 0.863 0.811 0 0.971 0.014 0 0.84 0.97 1.803 0.052 0 0.9 1.584 0 1.893 1.026 0.806 0
#	chr1:1774165:A:G 0.859 0.811 0 0.972 0.014 0 0.84 0.97 1.797 0.052 0 0.899 1.584 0 1.893 1.026 0.805
#	chr1:1774308:G:A 0.859 0.811 0 0.971 0.014 0 0.84 0.97 1.798 0.052 0 0.899 1.585 0 1.894 1.026 0.806
#	chr1:1776301:T:G 0.86 0.811 0 0.972 0.014 0 0.841 0.97 1.804 0.052 0 0.9 1.585 0 1.894 1.027 0.806 0
#	chr1:1780791:C:T 0.86 0.811 0 0.965 0.014 0 0.84 0.97 1.804 0.042 0 0.9 1.586 0 1.894 1.024 0.806 0.
#	chr1:1794321:C:T 0.86 0.811 0 0.959 0.014 0 0.842 0.97 1.804 0.041 0 0.9 1.586 0 1.894 1.023 0.806 0

#	if so, plink2
#  --set-missing-var-ids <t>  : Given a template string with a '@' where the
#  --set-all-var-ids <t>        chromosome code should go and '#' where the bp
#                               coordinate belongs, --set-missing-var-ids
#                               assigns chromosome-and-bp-based IDs to unnamed
#                               variants, while --set-all-var-ids resets all
#                               IDs.
#                               You may also use '$r'/'$a' to refer to the
#                               ref and alt1 alleles, or '$1'/'$2' to refer to
#                               them in alphabetical order.

#	--set-all-var-ids chr@:#:$r:$a --new-id-max-allele-len 50


