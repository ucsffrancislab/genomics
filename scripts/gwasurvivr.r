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

# test if there are enough arguments: if not, return an error
if (length(args)!=5) {
  print(length(args))
  stop(print("5 arguments needed"), call.=FALSE)
}

dataset = args[1]			#	No longer used

vcf.file = args[2] #VCF

cov_filename= args[3]

sample_list_filename = args[4]

out_filename = args[5]

log <- file(paste0(out_filename,".log"), open = "wt")
sink( log )
sink( log, type = "message" )

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



print(vcf.file)

vcf_header <- scanVcfHeader(vcf.file)
print(vcf_header)

print(paste("Sample length",length(samples(vcf_header)),"in VCF"))


# Read in the data
sample_list = read.csv(sample_list_filename, header = FALSE)
sample.ids = sample_list[,1]
head(sample.ids)
tail(sample.ids)


print(paste("Sample length",length(sample.ids),"in list"))
sample.ids=intersect(as.character(sample.ids),samples(vcf_header))
print(paste("Sample length",length(sample.ids),"in list AND VCF"))



print("Reading pheno file")

#	Some pheno files include spaces in the fields so this MUST be a tab sep
pheno.file <- read.table(cov_filename, sep="\t", header=TRUE, stringsAsFactors = FALSE)
#	tcga is male/female
#	i370 and onco are M/F
#	cidr is 1/2
#pheno.file$SexFemale = ifelse(pheno.file$sex == "F", 1L, 0L)
pheno.file$SexFemale = ifelse( ( pheno.file$sex == "F" | pheno.file$sex == "female" | pheno.file$sex == 2 ), 1L, 0L) # single | not double



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
sample.ids=intersect(as.character(sample.ids),pheno.file$IID)

print(paste("Sample length",length(sample.ids),"in all 3"))
head(sample.ids)
tail(sample.ids)

print(paste("Writing samples ids to",paste0(out_filename,".samples")))
write.table(sample.ids, paste0(out_filename,".samples"),quote=FALSE ,row.names=FALSE ,col.names=FALSE )

dim(pheno.file)
print("Filtering pheno file")
pheno.file= pheno.file[which(pheno.file$IID %in% sample.ids),]
#head(pheno.file)
dim(pheno.file)







covs=c()
if( 'source' %in% names(pheno.file) && length(unique(pheno.file$source)) > 1 ){
	pheno.file$SourceAGS = ifelse(pheno.file$source =="AGS",1L,0L)
	covs=c(covs,"SourceAGS")
}
for( possible in c('age','Age','age_ucsf_surg','SexFemale','chemo','rad','dxyear','ngrade','grade',
	'PC1', 'PC2', 'PC3', 'PC4', 'PC5', 'PC6', 'PC7', 'PC8', 'PC9', 'PC10') ) {

	if( possible %in% names(pheno.file) ) {
		print(paste(possible,"found in pheno file"))
		uniq_count = length(unique(pheno.file[[possible]]))
		print(paste(uniq_count,"values for",possible,"found"))
		if( uniq_count > 1 ){
			print(paste("Adding",possible,"to covariates used"))
			covs=c(covs,possible)
		} else {
			print(paste("Not adding",possible,"to covariates used"))
		}
	} else {
		print(paste(possible,"NOT found in pheno file"))
	}
}

print("Using covs")
print(covs)


#	for cidr
if( ( 'deceased' %in% names(pheno.file) ) && !( 'vstatus' %in% names(pheno.file) ) )
	names(pheno.file)[names(pheno.file) == "deceased"] <- "vstatus"


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


sink( type = "message" )
sink( )

