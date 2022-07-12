#!/usr/bin/env Rscript

# REDISCOVERTE EdgeR Template 
# GG 
# UCSF


# THIS COMMAND, WHEN RUN AFTER SETTING THE PARAMETERS BELOW, WILL RUN THIS SCRIPT AND OUTPUT TO A .HTML RMARKDOWN FILE
# unsure if this works with command line arguments. 
### rmarkdown::render("/Users/gguerra/Box Sync/EdgeR_Template.R", output_file = paste(out_dir,"/",date,".",group_col,".",user_filename,filetypes[filetype],".alpha_",alpha_thresh,".logFC_",logFC_thresh,".NoQuestion.EdgeR.html", sep=""))

# Command line user input

args = commandArgs(trailingOnly=TRUE)
print(args)
# test if there is at least one argument: if not, return an error
if (length(args)!=11) {
  print(length(args))
  stop(print("11 arguments need to be provided, in this order 
       \n 1. path to data 
       \n 2. cov file 
       \n 3. path to output directory
       \n 4. column name in cov file
       \n 5. group col name in cov file 
       \n 6. covariates (column names) in format like c('Age', 'Sex', 'race') or NA
       \n 7. covariate filetypes in format like c(numeric, factor, factor) or NA
       \n 8. Number (1-10) indicating which REdiscover file to use
       \n 9. Alpha threshold
       \n 10. logFC threshold
       \n 11. date (and any prefix you want on the output file)"), call.=FALSE)
}

#args=c("/Users/gguerra/Box\ Sync/Francis\ _Lab_Share/20200603\ 20191008_Stanford71\ 20200602-REdiscoverTE", "/Users/gguerra/Box Sync/Francis\ _Lab_Share/20191008_Stanford71/20200110/metadata.tsv", "/Users/gguerra/Desktop", "id", "cc", NA, NA, 5, 0.05, 0.25, 20210419)

# PATH/TO/REDISCOVERTE/DATA
data_dir = args[1] 
# PATH/TO/COV/FILE/cov.txt
cov_file = args[2]
# PATH/TO/OUTDIR
out_dir = args[3]
# Column name in Covfile of the sample names 
case_ID_col = args[4]
# Column name in Covfile to split groups by
group_col = args[5]
# Comma-separated list of covariates to adjust for, e.g. c("Age","sex","race")
covs = args[6]
# Comma-separated list with the equal length to covs, indicating data types, e.g. c(numeric, factor, factor)
cov_types = args[7]
# NUMBER indicating the prefix of the REdiscover file you want to analyze, e.g. 6 (which corresponds to RE_all_repFamily)
filetype = as.numeric(args[8])
# Alpha threshold for signficant results (p value threshold), the smaller the less amount of results will print out (values like 0.05 or 0.01)
alpha_thresh = args[9]
# log Fold Change thresh (x in 2^x for actual fold change).  Normal values are around ~ 0.25, 0.5, 1, 2. The smaller the more results will print out
logFC_thresh = args[10]
# The date, will be used in the output file 
date = args[11]


# # User input ---------------------------------
# #date="20200924.DiscNoDicenPreB"
# date="20201216"
# 
# 
# # Location of the REdiscover files 
# #data_dir <- "/Users/gguerra/Box Sync/Francis _Lab_Share/20200813 20200720-TCGA-GBMLGG-RNA_bam 20200808-REdiscoverTE]"
# #data_dir <- "/Users/gguerra/Box Sync/Francis _Lab_Share/20200826 20200720-TCGA-GBMLGG-RNA_bam 20200808-REdiscoverTE/REdiscoverTE_rollup_noquestion"
# #data_dir <- "/Users/gguerra/Box Sync/Francis _Lab_Share/20200916 20200909-TARGET-ALL-P2-RNA_bam 20200914-REdiscoverTE/REdiscoverTE_rollup.noquestion"
# 
# # Location of covariate files (including filename)
# #cov_file <-  "/Users/gguerra/Box Sync/TCGA_Glioma_Groups/TCGA.Glioma.metadata.tsv"
# #cov_file <- paste("/Users/gguerra/Box Sync/Francis _Lab_Share/20200916 20200909-TARGET-ALL-P2-RNA_bam 20200914-REdiscoverTE/TARGET_covariates/TARGET_ALL_ClinicalData_Phase_II_", date,".tsv", sep = "") 
# 
# #Location to print out the results
# #out_dir <- "/Users/gguerra/Box Sync/Francis _Lab_Share/20200813 20200720-TCGA-GBMLGG-RNA_bam 20200808-REdiscoverTE]/EdgeR_Analysis"
# #out_dir <- "/Users/gguerra/Box Sync/Francis _Lab_Share/20200916 20200909-TARGET-ALL-P2-RNA_bam 20200914-REdiscoverTE/EdgeR_Analysis"
# 
# 
# ## ALU analysis of TCGA raw data 
# #data_dir <-"/Users/gguerra/Box Sync/Francis _Lab_Share/20201023 20200720-TCGA-GBMLGG-RNA_bam 20200805-STAR_hg38"
# #out_dir <- "/Users/gguerra/Box Sync/Francis _Lab_Share/20201023 20200720-TCGA-GBMLGG-RNA_bam 20200805-STAR_hg38/EdgeR_Analysis"
# 
# 
# # # Delwart Schizo Analysis 
# # data_dir <-"/Users/gguerra/Box Sync/Francis _Lab_Share/20201026 20200407_Schizophrenia 20201026-REdiscoverTE/rollup/REdiscoverTE_rollup.noquestion"
# # cov_file <- "/Users/gguerra/Box Sync/Francis _Lab_Share/20201026 20200407_Schizophrenia 20201026-REdiscoverTE/metadata.tsv"
# # out_dir <- "/Users/gguerra/Box Sync/Francis _Lab_Share/20201026 20200407_Schizophrenia 20201026-REdiscoverTE/EdgeR_Analysis"
# 
# #GTEx TCGA joint Analysis
# # PATH/TO/REDISCOVERTE/DATA
# data_dir <-"/Users/gguerra/Box Sync/Francis _Lab_Share/20201213-GTEx 20201117-TCGA-GBMLGG-RNA_bam 20200808-Combined-REdiscoverTE/REdiscoverTE_rollup.noquestion"
# # PATH/TO/COV/FILE/cov.txt
# cov_file <- "/Users/gguerra/Box Sync/Francis _Lab_Share/20201213-GTEx 20201117-TCGA-GBMLGG-RNA_bam 20200808-Combined-REdiscoverTE/TCGA.GTEx.metadata.tsv"
# #PATH/TO/OUTDIR
# out_dir <-"/Users/gguerra/Box Sync/Francis _Lab_Share/20201213-GTEx 20201117-TCGA-GBMLGG-RNA_bam 20200808-Combined-REdiscoverTE/EdgeR_Analysis"
# 
# 
# # If file type is not the traditional RE_discover output, put the name (- the .RDS) here, and set filetype to 11, and datatype to 2, have = "" otherwise
# #user_filename <-"featureCounts.SINE.Alu.Abox.sync.intergenic"
# # Don't touch unless non_standard filename (i.e. NOT *_1_raw_counts.RDS)
# user_filename <-""
# 
# # Column name for case IDs (in the covariate file) that exactly match the REDiscover IDs 
# case_ID_col="RE_names"
# 
# # Column name to group by and perform differential expression on 
# #group_col <- "WHO_groups"
# #group_col <-"IDH"
# #group_col <- "Primary_Subtype"
# #group_col <-"Schizo_Status"
# group_col <-"body_site"
# 
# ##Secondary grouping -- NOT USED ANYMORE
# ##second_col <-"MGMT"
# ##second_col<-"Ethnicity"
# 
# # Covariates to be included in the model (column names of the covariate file) and their datatype
# #covs = c("Gender","Race", "Age_at_Diagnosis_in_Days")
# covs = c("gender", "race", "Age")
# cov_types = c("factor","factor",  "numeric")
# #covs = c("gender")
# #cov_types = c("factor")
# #covs = c()
# #cov_types= c()
# # Choose a filetype to use (1 through 11)
# filetypes <- c("GENE", "RE_intron", "RE_exon", "RE_intergenic", "RE_all", "RE_all_repFamily", "RE_all_repClass", "RE_intron_repFamily", "RE_exon_repFamily", "RE_intergenic_repFamily", "")
# filetype <- 6
# 
# # Don't touch this unless it is an unconventional REdiscover datafile
# datatypes <-c("_1_raw_counts", "")
# datatype <-1
# 
# # Parameters to control which plots are produced. Elements need to reach the threshold in both p value and log fold change. 
# # FDR alpha threshold (adjusted p-value)
# alpha_thresh= 0.01
# 
# # Log FC threshold (fold change) 2^logFC_thresh = actual fold change, (takes values in (0, INF), set this low UNLESS there are too many results being printed, then increase)
# # Normal values can be ~ 0.25, 0.5, 1, 2 
# logFC_thresh=0.5
# 
# 
# # END PARAMETER SETTING 
# -------------------------------------------
library('readr')
library('edgeR')
require('EDASeq')
library('ggplot2')
library('RColorBrewer')
library('pheatmap')
library('gridExtra')
library(RColorBrewer)
options(max.print=1000000)

#filetypes <- c("GENE", "RE_intron", "RE_exon", "RE_intergenic", "RE_all", "RE_all_repFamily", "RE_all_repClass", "RE_intron_repFamily", "RE_exon_repFamily", "RE_intergenic_repFamily", "")
#
#	Rollup Never produces RE_all_repClass???
#
filetypes <- c("GENE", "RE_intron", "RE_exon", "RE_intergenic", "RE_all", "RE_all_repFamily", "RE_intron_repFamily", "RE_exon_repFamily", "RE_intergenic_repFamily", "")
datatypes <-c("_1_raw_counts", "")
user_filename <-""
#case_ID_col="RE_names"
datatype=1

# Read in the data 
filename <- paste(data_dir, "/",user_filename, filetypes[filetype], datatypes[datatype],".RDS", sep ="")
#	message("filename")
#	message(filename)

RE_disc = readRDS(filename)
#	message("RE_disc")
#	head(RE_disc)
#	message(RE_disc)

#covars = read.csv(cov_file, sep =",",header = TRUE , colClasses=c("character","character"))
#	DON'T USE LEADING ZEROES. IF INTEGERS, LEADING ZEROES ARE DROPPED. THEN CAN'T BE REFERENCED WITH THE LEADING ZERO! (Stanford 71)
covars = read_csv(cov_file, col_names = TRUE , col_types = cols(.default = "c") )

#	message("covars")
#	head(covars)

#Establish if there are covariates to include 
#Cov_check = (is.na(covs) == FALSE)
Cov_check = ((covs == "NA") == FALSE)

if(Cov_check ==FALSE){
	#	message("covs false")
  covs = c()
  cov_types = c()
}

# Add the group id to the REdiscover file  NO LONGER COMPATIBLE WITH SECONDARY GROUP
group_list = data.frame(mat.or.vec(nrow(RE_disc$samples),(1+length(covs))))
not.present= c()

covar_groups = covars[group_col]
#	message("covar_groups")
#	message(covar_groups)

#second_groups = covars[second_col]
colnames(group_list)= c(group_col, covs)
for(i in c(1:nrow(RE_disc$samples))){
  
	id = as.character(RE_disc$samples$sample[i])
	#	message("id")
	#	message(id)
	#print("group")
	#print(as.character(RE_disc$samples$group[i]))

	#id = data.set$id[i]
	#print(data.set$id[i])
	#print(id)
	ref_id = which(covars[case_ID_col] == id)
	#	message("ref_id")
	#	message(ref_id)


	#	Filter out samples that have been rolled up but not included in metadata file.


	if(length(ref_id)==1){
		#	message("length ref_id == 1")
		group_list[i,1] = as.character(covar_groups[ref_id,1])
		#group_list[i,2] = as.character(second_groups[ref_id,1])
		if(Cov_check ==TRUE){
			print(paste("length(covs) ",length(covs)))
			for(k in c(1:length(covs))){
				group_list[i,(1+k)] = as.character(covars[covs[k]][ref_id,])
			}
		}
	}else{
		#	message("length ref_id != 1")
		#	message(length(ref_id))
		#print(id)
		group_list[i,1]= "NA"
		#group_list[i,2]= "NA"
		if(Cov_check ==TRUE){
			for(k in c(1:length(covs))){
				group_list[i,(1+k)] = "NA"
			}
		}
		not.present= c(not.present,i)
	}
	#	message("group_list[i,1]")
	#	message(group_list[i,1])
}

group_list[,1] = as.factor(group_list[,1])
#group_list[,2] = as.factor(group_list[,2])
if(Cov_check ==TRUE){
	for(k in c(1:length(covs))){
		group_list[,k+1]=as.character(group_list[,k+1])
	}
}


# Remove the not present samples 
if(length(not.present) >=1){
  print(paste("Number of samples not found in covariate file = ", length(not.present), sep = ""))
  #groups_less = group_list[-not.present,1]	#	????? Typo? Unused? Comment out?
  #second_less = group_list[-not.present,2]
  RE_disc= RE_disc[,-not.present]
  group_less =group_list[-not.present,]
}else{
  group_less = group_list
}

#	message("group_list")
#	message(group_list)
#	message("group_less")
#	message(group_less)
#	message("group_less[,1]")
#	message(group_less[,1])
#	message("RE_disc 0")
#	message(RE_disc)
#	message("RE_disc$samples$group")
#	message(RE_disc$samples$group)
#	message("as.factor(group_less)")
#	message(as.factor(group_less))
#	message("as.factor(group_less[,1])")
#	message(as.factor(group_less[,1]))
#	Warning message:
#	In xtfrm.data.frame(x) : cannot xtfrm data frames
#	as.factor(group_less[,1])







# Cov_check is always FALSE, but if the metadata file contains other columns
#	group_less needs to be group_less
#	Otherwise group_less[,1] ????

if(Cov_check == TRUE){
	RE_disc$samples$group = as.factor(group_less[,1])
}else{

	#	I THINK that if the dataset only contains one of the groups, this gets messy. (ie all are EUR or AFR or something)
	#	No. I don't get why this does this. Yet.
	#	Could raise
	#	Warning message:
	#	In xtfrm.data.frame(x) : cannot xtfrm data frames
	#if( is.na(as.factor(group_less)) ){
	if( length(as.factor(group_less))>0 ){
		RE_disc$samples$group = as.factor(group_less[,1]) 
	}else{
		RE_disc$samples$group = as.factor(group_less)
	}

#	RE_disc$samples$group = as.factor(group_less) #	JAKE - groups get lost if this is used? All NA. Then all filtered. Then crash.
	#RE_disc$samples$group = as.factor(group_less) #	JAKE - groups get lost if this is used? All NA. Then all filtered. Then crash.
#	#message(group_less)	#	IPMNMCNIPMNMCNIPMNMCNIPMNIPMNIPMN
#	RE_disc$samples$group = as.factor(group_less[,1]) 
#	#	Error in h(simpleError(msg, call)) : 
#	#	  error in evaluating the argument 'x' in selecting a method for function 'as.factor': incorrect number of dimensions
#	#	Calls: as.factor ... [ -> [.factor -> NextMethod -> .handleSimpleError -> h
#	#	Execution halted
#	#RE_disc$samples$group = as.factor(group_less)
#
}


#message("JAKE")
#message(Cov_check)
#message(group_less[,1])
#message("JAKE")
#RE_disc$samples$group = as.factor(group_less[,1]) 


#RE_disc$samples$second = as.factor(group_less[,2])

#	message("RE_disc$samples$group")
#	message(RE_disc$samples$group)
#	message("as.factor(group_less)")
#	message(as.factor(group_less))
#	message("RE_disc 1")
#	message(RE_disc)
#	message("RE_disc$samples$group")
#	message(RE_disc$samples$group)

if(Cov_check ==TRUE){
	for(k in c(1:length(covs))){
	  RE_disc$samples[covs[k]] = type.convert(group_less[covs[k]], cov_types[k])
	}
}

#	message("RE_disc 2")
#	message(RE_disc)
#	message("RE_disc$samples$group")
#	message(RE_disc$samples$group)

# Filter out any groups with no group assignment (== NA)
Nas = which(is.na(RE_disc$samples$group))
if(length(Nas >0)){
	RE_disc=RE_disc[,-Nas]
}

#	message("RE_disc 3")
#	message(RE_disc)

# Filter out groups with too little sample size (i.e <10)
u_groups = unique(RE_disc$samples$group)
for(grp in u_groups){
	n_grp=which(RE_disc$samples$group == grp)
	n_in_group = length(n_grp)  
	if(n_in_group <1){
		RE_disc= RE_disc[,-n_grp]
	}
}
RE_disc$samples$group = droplevels(RE_disc$samples$group)

#	message("RE_disc 5")
#	message(RE_disc)

# Filter out samples with NA covariates 
if(Cov_check ==TRUE){
	for(cov_n in covs){
		Nas = which(is.na(RE_disc$samples[cov_n]))
		if(length(Nas >=1)){
			RE_disc = RE_disc[,-Nas]
		}
	}
}

#	message("RE_disc 6")
#	message(RE_disc)

# ##### Filter out the Healthy individuals  REMOVE REMOVE REMOVE
# healthy = which(RE_disc$samples$group =="Healthy")
# RE_disc = RE_disc[,-healthy]

# Make sure the "factor" covariates do not have levels with 0 entries
if(Cov_check ==TRUE){
	for(k in c(1:length(covs))){
		if(cov_types[k]=="factor"){
			RE_disc$samples[covs[k]] = droplevels(RE_disc$samples[covs[k]])
		}
	}
}
summary(RE_disc$samples$group)

#	message("RE_disc 7")
#	message(RE_disc)

#apply(x$counts, 2, sum)
dim(RE_disc)
RE_disc <- calcNormFactors(RE_disc, method = "TMM") # WAS RLE if this fails

keep <- rowSums(cpm(RE_disc)>50) >= 2
RE_disc <- RE_disc[keep,]
dim(RE_disc)
RE_disc$samples$lib.size <- colSums(RE_disc$counts)




# Normalize the data
RE_disc <- calcNormFactors(RE_disc, method = "TMM") # WAS RLE if this fails

n_groups = length(unique(RE_disc$samples$group))

# Data Exploration -----------------------------------------------------------


# Get the proper group colors 
u_groups = as.character(unique(RE_disc$samples$group))
col_groups= brewer.pal(n = length(u_groups), name = "Paired")
possible_shapes= c(21,22,23,24,25)
shape_groups = c()
for(i in c(1:length(u_groups))){
  shape_groups =c(shape_groups, possible_shapes[i%%length(possible_shapes)+1])
}

color_p = c()
shape_p = c()
for(i in c(1:length(RE_disc$samples$group))){
  color_p = c(color_p, col_groups[which(u_groups == RE_disc$samples$group[i])])
  shape_p = c(shape_p, shape_groups[which(u_groups == RE_disc$samples$group[i])])
	
}

message("BCV")
plotMDS(RE_disc, method="bcv", pch=shape_p, bg= color_p, col="black")
plot(NULL ,xaxt='n',yaxt='n',bty='n',ylab='',xlab='', xlim=0:1, ylim=0:1)
legend("top", u_groups,  pch=shape_groups, col= "black", pt.bg=col_groups, y.intersp=1.25)
#legend("top", u_groups, col=1:length(u_groups), pch=20)

plotMDS(RE_disc, method="bcv", pch=shape_p, bg= color_p, col="black", labels=RE_disc$samples$sample)
plot(NULL ,xaxt='n',yaxt='n',bty='n',ylab='',xlab='', xlim=0:1, ylim=0:1)
legend("top", u_groups,  pch=shape_groups, col= "black", pt.bg=col_groups, y.intersp=1.25)
#legend("top", u_groups, col=1:length(u_groups), pch=20)



message("logFC")
# From the R documentiation: 
# The default method (method="logFC") is to convert the counts to log-counts-per-million using cpm and to pass these to the limma plotMDS function.
# This method calculates distances between samples based on log2 fold changes. 
plotMDS(RE_disc, method="logFC", bg=color_p, col = "black",  pch=shape_p)
plot(NULL ,xaxt='n',yaxt='n',bty='n',ylab='',xlab='', xlim=0:1, ylim=0:1)
legend("top", u_groups,  pch=shape_groups, col= "black", pt.bg=col_groups, y.intersp=1.25)

plotMDS(RE_disc, method="logFC", bg=color_p, col = "black",  pch=shape_p, labels=RE_disc$samples$sample)
plot(NULL ,xaxt='n',yaxt='n',bty='n',ylab='',xlab='', xlim=0:1, ylim=0:1)
legend("top", u_groups,  pch=shape_groups, col= "black", pt.bg=col_groups, y.intersp=1.25)



#Normalization for PCA and t-SNE, not exactly the same 
normcounts = 1e6*cpm(RE_disc, normalized.lib.sizes=T)
message("PCA")

## Perform PCA analysis and make plot
plotPCA(normcounts, bg=color_p, labels= FALSE , pch=shape_p, col = "black")
plot(NULL ,xaxt='n',yaxt='n',bty='n',ylab='',xlab='', xlim=0:1, ylim=0:1)
legend("top", u_groups,  pch=shape_groups, col= "black", pt.bg=col_groups, y.intersp=1.25)

## Perform PCA analysis and make plot
plotPCA(normcounts, bg=color_p, labels= TRUE , pch=shape_p, col = "black")
plot(NULL ,xaxt='n',yaxt='n',bty='n',ylab='',xlab='', xlim=0:1, ylim=0:1)
legend("top", u_groups,  pch=shape_groups, col= "black", pt.bg=col_groups, y.intersp=1.25)


# message("t-SNE")
# #t-SNE dimensionality reduction 
# # Following: https://www.analyticsvidhya.com/blog/2017/01/t-sne-implementation-r-python/
# train = data.frame(t(normcounts))
# labels = x$samples$group
# train$label = as.factor(x$samples$group)
# colors = c("black", "red", "green")
# names(colors) = unique(train$label)
# 
# seeds = c(1,324, 5345, 234872345)
# perps = c(5, 10, 20, 50)
# par(mfrow=c(2,2))
# for(perp in perps){
#   for(seed in seeds){
#     set.seed(seed)
#     
#     tsne <- Rtsne(train[,-ncol(train)], dims = 2, perplexity=perp, verbose=FALSE, max_iter = 10000)
#     plot(tsne$Y, t='n', main=paste("tsne, perplexity = ", perp, "\nseed = ", seed, sep = ""), xlab= "", ylab="")
#     text(tsne$Y, labels=y$samples$sample, col=colors[train$label])
#     #legend("topleft", as.character(unique(y$samples$group)), col=1:3, pch=20)
#   }
#   
# }

par(mfrow=c(1,1))

# Dispersion analysis 
d1 <- estimateCommonDisp(RE_disc, verbose=T)
d1 <- estimateTagwiseDisp(d1)
plotBCV(d1)




# Design Matrix -----------------------------------------------------------------------
if(Cov_check ==TRUE){
	design.mat <- model.matrix(~ 0 +., RE_disc$samples[c("group",covs)]  )
}else{
  design.mat <- model.matrix(~ 0 +., RE_disc$samples[c("group")]  )
}
head(design.mat)

#colnames(design.mat) <- levels(RE_disc$samples$group)
d2 <- estimateGLMCommonDisp(RE_disc,design.mat)
d2 <- estimateGLMTrendedDisp(d2,design.mat, method="auto")
# You can change method to "auto", "bin.spline", "power", "spline", "bin.loess".
# The default is "auto" which chooses "bin.spline" when > 200 tags and "power" otherwise.
d2 <- estimateGLMTagwiseDisp(d2,design.mat)
plotBCV(d2)

fit <- glmFit(d2, design.mat)

# make some contrast patterns
col_groups = levels(RE_disc$samples$group)
n_contrasts = choose(length(col_groups), 2)
contrasts = mat.or.vec(n_contrasts, ncol(design.mat))
combos = t(combn(length(col_groups), 2))
colnames(contrasts)= colnames(design.mat)
for(nc in c(1:n_contrasts)){
  contrasts[nc,combos[nc,1]] =1
  contrasts[nc,combos[nc,2]] =-1
}

sig_trans = c()

for(nc in c(1:n_contrasts)){
	lrt <- glmLRT(fit, contrast=contrasts[nc,])
	glmt = topTags(lrt, n=1000)
	#glmt = glmt[glmt$table$FDR <alpha_thresh,]
	#glmt = glmt[which(abs(glmt$table$logFC)>logFC_thresh),]

	print(glmt[,-which(colnames(glmt) == "LR")])

	#sig_trans = c(sig_trans, row.names(glmt[which(glmt$table$FDR<alpha_thresh),1][[1]])   )
	pass_logFC= row.names(glmt[which(abs(glmt$table$logFC)>logFC_thresh),1][[1]])
	pass_alpha = row.names(glmt[which(glmt$table$FDR<alpha_thresh),1][[1]])
	pass_both = intersect(pass_logFC, pass_alpha)
	if(length(pass_both) > 0){
		sig_trans = c(sig_trans, pass_both)
	}
	#sig_trans = c(sig_trans, row.names(glmt[which(abs(glmt$table$logFC)>logFC_thresh),1][[1]])   )
}


# Plotting the top results for each pairwise test 
to_plot = unique(sig_trans)

for( gene in to_plot){
  message(gene)
  plot_data = data.frame(as.numeric(normcounts[which(row.names(normcounts) == gene),]))
  plot_data$group = RE_disc$samples$group
  #print(paste("Individual with max value = ", row.names(plot_data)[which(plot_data[,1] == max(plot_data[,1]))], sep=""))
  colnames(plot_data) = c(gene, "group")
  plot_data$group = as.factor(plot_data$group)
  p <- ggplot(plot_data, aes(x=as.factor(plot_data[,2]), y=as.numeric(plot_data[,1]), fill=as.factor(plot_data[,2]))) +
    geom_boxplot()+
    labs(title=paste(gene, sep = ""),x=group_col, y = "Count (normalized)")+
    theme(legend.position= "right")+
    theme(plot.title = element_text(hjust = 0.5))+
    geom_jitter(color="black", size=0.4, alpha=0.7) +
    theme(axis.text.x = element_blank())+
    labs(fill = group_col)
 
  print(p)
}


# HeatMap of significant traits
 # for the repname case

# Get all significant results from each test 

sig.results = to_plot

sig.loc = mat.or.vec(length(sig.results), 1)

if(length(sig.loc) >1){
  
	for(i in c(1:length(sig.results))){
  
  	sig.loc[i] = which(row.names(normcounts) == sig.results[i])
	}
	normcounts = normcounts[sig.loc,]

	gaps =c()
	# Need to reorder the data so that it is collected by group
	ordered= c()
	for(k in c(1:length(col_groups))){
  	ordered = c(ordered,which(RE_disc$samples$group ==col_groups[k]) )
  	if(k!=length(col_groups)){
  		gaps=c(gaps,length(ordered))
  	}
	}
	normcounts = normcounts[,as.integer(ordered)]
	Groups = RE_disc$samples$group
	names(Groups) = rownames(RE_disc$samples)

	##if(strsplit(filename, split ="")[[1]][1] =="R" ){
  	##family colors 
  	##fams = RE_disc$genes$repFamily[sig.loc]
  	##classes = RE_disc$genes$repClass[sig.loc]
 	 
  	##repFamilies= data.frame(as.factor(fams))
  	##repFamilies$repClass = as.factor(classes)
  	##row.names(repFamilies)=sig.results
  	##colnames(repFamilies)= c("repFamily", "repClass")
  	##repFamilies = repFamilies[,c(2,1)]
  	##heatmap(normcounts, Colv= NA, ColSideColors = colSide, scale = "row", col=brewer.pal(11,"RdBu"))
  
	##  pheat.plot=pheatmap(normcounts, cluster_rows = T,scale="row", cluster_cols = F,annotation_col = data.frame(Groups),col=brewer.pal(11,"RdYlGn"), annotation_row=data.frame(repFamilies)  )

  colorpal= rev(brewer.pal(11,"RdBu"))

	##}else{

  pheat.plot=pheatmap(log(normcounts+0.01,base = 2), cluster_rows = T,scale="row", cluster_cols = F,annotation_col = data.frame(Groups),col=colorpal,show_colnames = FALSE ,gaps_col=gaps, main = paste(group_col, ": log_2 REdiscoverTE ", filetypes[filetype], sep ="") )
  pheat.plot.clust = pheatmap(log(normcounts+0.01,base = 2), cluster_rows = T,scale="row", cluster_cols = T,annotation_col = data.frame(Groups),col=colorpal,show_colnames = FALSE ,gaps_col=gaps, main = paste(group_col, ": log_2 REdiscoverTE ", filetypes[filetype], " clustered", sep ="") )
  
	##}

	message("See corresponding PDF for a better version of this heatmap.")
	save_pheatmap_pdf <- function(z, filename, width=30, height=20) {
  	stopifnot(!missing(z))
  	stopifnot(!missing(filename))
  	pdf(filename, width=width, height=height)
  	grid::grid.newpage()
  	grid::grid.draw(z$gtable)
  	dev.off()
	}
	save_pheatmap_pdf(pheat.plot,  paste(out_dir,"/",date,".",group_col,".",user_filename,filetypes[filetype],".alpha_",alpha_thresh,".logFC_",logFC_thresh,".NoQuestion.heatmap.pdf", sep=""))
	save_pheatmap_pdf(pheat.plot.clust,  paste(out_dir,"/",date,".",group_col,".",user_filename,filetypes[filetype],".alpha_",alpha_thresh,".logFC_",logFC_thresh,".NoQuestion.clustered.heatmap.pdf", sep=""))

}else{
 	message("Not enough significant results at these thresholds to plot a heatmap.")
}

# # -------------------- Pie Charts -------------------------------------------------
# # Make a pie chart showing the rep class and rep families significant in each test, and overall. 
# # Only do if there are rep class and rep families (aka not GENE file)
# 
# piechart = function(rep_list, rep_type, i1, i2){
#   
#   # get unique
#   unique_reps = unique(rep_list)
#   unique_counts = c()
#   for(i in c(1:length(unique_reps))){
#     unique_counts[i] = sum(rep_list == unique_reps[i])
#   }
#   for_pie = data.frame(cbind(unique_reps, unique_counts))
#   colnames(for_pie) = c("name", "count")
#   for_pie$name= as.factor(for_pie$name)
#   for_pie$count = as.numeric(for_pie$count)
#   
#   pie_plot <- ggplot(for_pie, aes(x="", y=count, fill=name))+ geom_bar(width = 1, stat = "identity")+ coord_polar("y", start=0) + theme(axis.text.x=element_blank())+labs(title=paste(rep_type,": ",i1, " - ", i2,  sep = ""), x = "", y = "")
#   return(pie_plot)
# }
# 
# 
# if(strsplit(filename, split ="")[[1]][1] =="R" ){
#   
#   
#   print("rep_Family")
#   
#   print( "Methylation subgroup 1 vs 2 ")
#   rep_list = glmtt12$table$repFamily
#   rep_type = "rep_Family"
#   fam.plot = piechart(rep_list,rep_type,1,2)
#   print(fam.plot)
#   
#   print( "Methylation subgroup 1 vs 3 ")
#   rep_list = glmtt13$table$repFamily
#   rep_type = "rep_Family"
#   fam.plot = piechart(rep_list,rep_type,1,3)
#   print(fam.plot)
#   
#   print( "Methylation subgroup 2 vs 3 ")
#   rep_list = glmtt23$table$repFamily
#   rep_type = "rep_Family"
#   fam.plot = piechart(rep_list,rep_type,2,3)
#   print(fam.plot)
#   
#   print("rep_Class")
#   
#   print( "Methylation subgroup 1 vs 2 ")
#   rep_list = glmtt12$table$repClass
#   rep_type = "rep_Class"
#   class.plot = piechart(rep_list,rep_type,1,2)
#   print(class.plot)
#   
#   print( "Methylation subgroup 1 vs 3 ")
#   rep_list = glmtt13$table$repClass
#   rep_type = "rep_Class"
#   class.plot = piechart(rep_list,rep_type,1,3)
#   print(class.plot)
#   
#   print( "Methylation subgroup 2 vs 3 ")
#   rep_list = glmtt23$table$repClass
#   rep_type = "rep_Class"
#   class.plot = piechart(rep_list,rep_type,2,3)
#   print(class.plot)
# }


