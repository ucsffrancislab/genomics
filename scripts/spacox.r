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

# test if there are enough arguments: if not, return an error
if (length(args)!=5) {
	print(length(args))
	stop(print("5 arguments needed"), call.=FALSE)
}

dataset = args[1]			#	No longer used

dosage_filename = args[2]

cov_filename= args[3]

sample_list_filename = args[4]

out_filename = args[5]

log <- file(paste0(out_filename,".log"), open = "wt")
sink( log )
sink( log, type = "message" )

library(SPACox)
library(survival)


#	tranpose t() does add an X before sample names that start with a number
#		and replaces - with . ( X0_WG0238625.DNAB04.AGS51818 )
#
#	0_WG0238625.DNAB04.AGS51818
#	0_WG0238625-DNAB04-AGS51818
#
#	Oddly, you can change it back so I don't know why it does that.
#
# Alter the Dosage rownames by replacing ALL periods with dashes.
#	gsub is an alternative solution
dotwithdash = function(rname){
	#return( gsub('.','-',rname,fixed=TRUE) )
	b= strsplit(rname, split = "")[[1]]
	b[which(b ==".")]= "-"
	d= paste(b, collapse = "")
	return(d)
}

#	tranpose t() does add an X before sample names that start with a number
#	Rather than remove leading Xs, which could be incorrect, add leading X to the other lists.
#
#	0_WG0238625.DNAB04.AGS51818
#	X0_WG0238625.DNAB04.AGS51818
#
# Convert IDs with integer first character to have an "X" at the start, to accomodate the row.names of dosage
add_X =function(rname){
	#return( sub('^([[:digit:]])',"X\\1",rname) )
	b= strsplit(rname, split = "")[[1]]
	retname = rname

	if(!is.na(as.numeric(b[1]))){
		retname = paste("X", rname, sep ="")
	}
	return(retname)
}


##################################################



# Read in the data
print(paste("Reading select case sample list file:",sample_list_filename))
sample_list = read.csv(sample_list_filename, header = FALSE)
sample.ids = as.character(sapply(as.character(sample_list[,1]) , add_X))
#sample.ids = as.character(sapply(as.character(sample.ids) , dotwithdash))
print(paste("Sample length ",length(sample.ids)," in list"))
head(sample.ids)
tail(sample.ids)



#	Some pheno files include spaces in the fields so this MUST be a tab sep

#	Not sure if this is a problem, but there are apostrophes in the data

print(paste("Reading covariates file:",cov_filename))
pheno.file <- read.table(cov_filename, sep="\t", header=TRUE, stringsAsFactors = FALSE)
#	tcga is male/female
#	i370 and onco are M/F
#pheno.file$SexFemale = ifelse(pheno.file$sex == "F", 1L, 0L)
pheno.file$SexFemale = ifelse( ( pheno.file$sex == "F" | pheno.file$sex == "female" ), 1L, 0L) # single | not double



pheno.file$IID = as.character(sapply(as.character(pheno.file$IID), add_X))
#pheno.file$IID = as.character(sapply(as.character(pheno.file$IID), dotwithdash))
head(pheno.file$IID)
tail(pheno.file$IID)
print(paste("Sample length",length(pheno.file$IID),"in cov file"))

sample.ids = intersect(sample.ids, pheno.file$IID)
print(paste("Sample length",length(sample.ids),"in list and cov file"))
head(sample.ids)
tail(sample.ids)


#	This is actually a LARGE dosage SPACE-separated file. The whole thing is read in so needs MEMORY
#	This file's header is 1 column less than the rest

#	do it once then use the transposed dosage file
#	for f in imputed-*/*/*dosage ; do echo $f; sed '1s/^/ /' $f | datamash transpose -t' ' | sed '1s/^ //' > ${f}.transposed; done
#	won't load? Too many columns?


library(data.table)

#	topmed onco is the largest by far and takes about 300GB of memory
#	-r--r----- 1 gwendt francislab  9024128667 Aug  7 18:18 imputed-topmed-i370/i370-cases/i370-cases.dosage
#	-r--r----- 1 gwendt francislab 32843668261 Aug  7 22:34 imputed-topmed-onco/onco-cases/onco-cases.dosage
#	-r--r----- 1 gwendt francislab 12820260268 Aug  7 19:01 imputed-topmed-tcga/tcga-cases/tcga-cases.dosage
#	-r--r----- 1 gwendt francislab  3779937534 Aug  7 17:09 imputed-umich19-i370/i370-cases/i370-cases.dosage
#	-r--r----- 1 gwendt francislab 16207757122 Aug  7 19:05 imputed-umich19-onco/onco-cases/onco-cases.dosage
#	-r--r----- 1 gwendt francislab  8050039607 Aug  7 17:47 imputed-umich19-tcga/tcga-cases/tcga-cases.dosage

print(paste("Reading dosage data table:",dosage_filename))
dt <- data.table::fread(dosage_filename, sep = " ")

#	For some reason, reading the transposed dosage file causes ...
#[1] "Read data table"
# *** caught segfault ***
#address 0x7f1c71792920, cause 'memory not mapped'
#Traceback:
# 1: data.table::fread(transposed_dosage_filename, sep = " ")
#An irrecoverable exception occurred. R is aborting now ...
#/c4/home/gwendt/.local/bin/spacox.bash: line 80: 957406 Segmentation fault      (core dumped) spacox.r ${dataset} $TMPDIR/$( basename $dosage ) $TMPDIR/$( basename $covfile ) $TMPDIR/$( basename $IDfile ) $TMPDIR/$subset.out

print("Convert to data frame")
dosage <- data.frame(dt,row.names=1)
rm(dt)	#	free up some memory
dosage = t(dosage)
#	t() actually returns a [1] "matrix" "array" rather than a [1] "data.frame". Doesn't seem to matter
row.names(dosage) = as.character(sapply(row.names(dosage), dotwithdash))
head(row.names(dosage))
tail(row.names(dosage))

#dosage =read.csv(transposed_dosage_filename, sep = "", header =TRUE, row.names = 1) #	never completed and job hangs
#dosage = t(dosage)	#	using an already transposed dosage file


print(paste("Sample length",length(row.names(dosage)),"in dosage file"))
sample.ids = intersect(sample.ids, row.names(dosage))
print(paste("Sample length",length(sample.ids),"in all 3"))
head(sample.ids)
tail(sample.ids)


print(paste("Writing samples ids to",paste0(out_filename,".samples")))
write.table(sample.ids, paste0(out_filename,".samples"),quote=FALSE ,row.names=FALSE ,col.names=FALSE )



#	row.names? aren't the samples in column names?
#	the dosage has been transposed, so yes, row.names


#Restrict dosage and pheno.file to sample.ids
dosage = dosage[which(row.names(dosage) %in% sample.ids), ]
pheno.file = pheno.file[which(pheno.file$IID %in% sample.ids), ]

fields=c()
if( 'age' %in% names(pheno.file) ){
	fields=c(fields,'age')
} else if( 'Age' %in% names(pheno.file) ) {
	fields=c(fields,'Age')
}
if( 'SexFemale' %in% names(pheno.file) && length(unique(pheno.file$SexFemale)) > 1 )
	fields=c(fields,'SexFemale')
if( 'chemo' %in% names(pheno.file)  && length(unique(pheno.file$chemo)) > 1 )
	fields=c(fields,'chemo')
if( 'rad' %in% names(pheno.file)    && length(unique(pheno.file$rad)) > 1 )
	fields=c(fields,'rad')
if( 'ngrade' %in% names(pheno.file) && length(unique(pheno.file$ngrade)) > 1 )
	fields=c(fields,'ngrade')
if( 'dxyear' %in% names(pheno.file) && length(unique(pheno.file$dxyear)) > 1 )
	fields=c(fields,'dxyear')

fields=c(fields, "PC1", "PC2", "PC3", "PC4", "PC5", "PC6", "PC7", "PC8", "PC9", "PC10")
formula=paste("Surv(survdays, vstatus) ~",paste(fields,collapse=" + "))
print("Using formula:")
print(formula)
obj.null = SPACox_Null_Model( as.formula(formula), data = pheno.file, pIDs = pheno.file$IID, gIDs = rownames(dosage) )

print("Running SPACox")
SPACox.res = SPACox(obj.null, dosage)

print("Running cbind")
SPACox.res = cbind(row.names(SPACox.res), SPACox.res)

print("Adjusting colnames")
colnames(SPACox.res)[1] ="RSID"

print("Writing table")
write.table(file= out_filename, x = SPACox.res, col.names =TRUE, quote = FALSE, row.names= FALSE, sep = "\t")

sink( type = "message" )
sink( )

