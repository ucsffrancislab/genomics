#!/usr/bin/env Rscript

#	REdiscoverTE_EdgeR_rmarkdown.R ${PWD}/rollup ${PWD}/metadata.case_control.GBM.csv ${PWD}/results_case_control_GBM_TEST ID timepoint NA NA 1 0.9 0.5 k15

args <- commandArgs()
print(args)
fname <- normalizePath(sub("--file=", "", args[grepl("--file=", args)]))
args = commandArgs(trailingOnly=TRUE)
thisfile <- readLines(fname)
tempfname <- paste0(tempdir(), "/", tools::file_path_sans_ext(basename(fname)) , ".Rmd")
#print(tempfname)
writeLines(thisfile[-1:-which(thisfile == "quit(\"no\")")], tempfname)

#	could specify the actuall output file here
#	 output_file = paste('report.', Sys.Date(), '.pdf', sep=''))
#rmarkdown::render(tempfname, output_dir = dirname(fname))
#rmarkdown::render(tempfname, output_dir = getwd() )

#	render to temp output then cat to fd3
#	fd0 is stdin
#	fd1 is stdout and contains most of render's output
#	fd2 is stderr and sadly contains a tiny bit of render's output
#	fd3 appears to be unused. So. Use it.
tempoutput <- paste0(tempdir(), "/", tools::file_path_sans_ext(basename(fname)) , ".html")
rmarkdown::render(tempfname)
system(paste("cat",tempoutput,">&3"))

quit("no")

---
title: REDISCOVERTE EdgeR Template (Modified by Geno 20220712)
author: John Doe
date: 20220712
#output: pdf_document
output: html_document
---

<!--

THAT MUST BE FIRST TO BE USEFUL!

-->

```{r "Figure Settings", include = FALSE}
knitr::opts_chunk$set(fig.width=12, fig.height=8) 
```






<!--

This is a comment that will only be rendered as an html comment.

Not sure what happens if output is a pdf document.

-->

```{r "Comment note", include = FALSE}
#	This is r code that isn't included, ie printed.
#	As it is comment, it isn't run.
#	I think this is the most straight forward way to include comments in an rmarkdown file.
```


```{r "Show Args"}
#args = commandArgs(trailingOnly=TRUE)
print(args)
```

```{r}
# test if there are the correct number of arguments: if not, return an error
if (length(args)!=11) {
	print(length(args))
	stop(print("11 arguments need to be provided, in this order 
		\n 1. path to data 
		\n 2. cov file 
		\n 3. path to output directory ( for saved plots, not used now )
		\n 4. column name in cov file
		\n 5. group col name in cov file 
		\n 6. covariates (column names) in format like c('Age', 'Sex', 'race') or NA
		\n 7. covariate filetypes in format like c(numeric, factor, factor) or NA
		\n 8. Number (1-10) indicating which REdiscover file to use
		\n 9. Alpha threshold
		\n 10. logFC threshold
		\n 11. date (and any prefix you want on the output file)"), call.=FALSE)
}
```

```{r, include = FALSE}
# PATH/TO/REDISCOVERTE/DATA
data_dir = args[1] 
# PATH/TO/COV/FILE/cov.txt
cov_file = args[2]
# PATH/TO/OUTDIR
out_dir = args[3]

#dir.create(out_dir, recursive = TRUE)

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


library('readr')
library('edgeR')
require('EDASeq')
library('ggplot2')
library('RColorBrewer')
library('pheatmap')
library('gridExtra')
library('grid') # New 20220712
library('gtable') # New 20220712
library(RColorBrewer)
options(max.print=1000000)
```



```{r}
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
```



Remove the not present samples 

```{r}
if(length(not.present) >=1){
	print(paste("Number of samples not found in covariate file = ", length(not.present), sep = ""))
	#groups_less = group_list[-not.present,1]	#	????? Typo? Unused? Comment out?
	#second_less = group_list[-not.present,2]
	RE_disc= RE_disc[,-not.present]
	group_less =group_list[-not.present,]
}else{
	group_less = group_list
}
```
```{r}
# Cov_check is always FALSE, but if the metadata file contains other columns
#	group_less needs to be group_less
#	Otherwise group_less[,1] ????

if(Cov_check == TRUE){
	message("Cov_check == TRUE")
	RE_disc$samples$group = as.factor(group_less[,1])
}else if( length(group_less) > 1 ){
	message("length(group_less) > 1")
	RE_disc$samples$group = as.factor(group_less)
}else if( is.na(as.factor(group_less)) ){
	message("is.na(as.factor(group_less))")
	RE_disc$samples$group = as.factor(group_less[,1]) 
}else{
	message("OTHER")

	message("group_less")
	message(group_less)
	message("length(group_less)")
	message(length(group_less))

	RE_disc$samples$group = as.factor(group_less)

}
```
```{r}





if(Cov_check ==TRUE){
	for(k in c(1:length(covs))){
		RE_disc$samples[covs[k]] = type.convert(group_less[covs[k]], cov_types[k])
	}
}
```
```{r}


# Filter out any groups with no group assignment (== NA)
Nas = which(is.na(RE_disc$samples$group))
if(length(Nas >0)){
	RE_disc=RE_disc[,-Nas]
}
```
```{r}


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
```
```{r}


# Filter out samples with NA covariates 
if(Cov_check ==TRUE){
	for(cov_n in covs){
		Nas = which(is.na(RE_disc$samples[cov_n]))
		if(length(Nas >=1)){
			RE_disc = RE_disc[,-Nas]
		}
	}
}
```
```{r}


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


#apply(x$counts, 2, sum)
dim(RE_disc)
RE_disc <- calcNormFactors(RE_disc, method = "TMM") # WAS RLE if this fails

keep <- rowSums(cpm(RE_disc)>50) >= 2
RE_disc <- RE_disc[keep,]
dim(RE_disc)
RE_disc$samples$lib.size <- colSums(RE_disc$counts)


```
```{r}


# Normalize the data
RE_disc <- calcNormFactors(RE_disc, method = "TMM") # WAS RLE if this fails
```
```{r}

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
```

BCV

```{r}
plotMDS(RE_disc, method="bcv", pch=shape_p, bg= color_p, col="black")
```

```{r fig1, echo = FALSE}
plot(NULL ,xaxt='n',yaxt='n',bty='n',ylab='',xlab='', xlim=0:1, ylim=0:1)
legend("top", u_groups,  pch=shape_groups, col= "black", pt.bg=col_groups, y.intersp=1.25)
```

```{r}
plotMDS(RE_disc, method="bcv", pch=shape_p, bg= color_p, col="black")
```

```{r fig2, echo = FALSE}
plot(NULL ,xaxt='n',yaxt='n',bty='n',ylab='',xlab='', xlim=0:1, ylim=0:1)
legend("top", u_groups,  pch=shape_groups, col= "black", pt.bg=col_groups, y.intersp=1.25)

```

```{r}
plotMDS(RE_disc, method="bcv", pch=shape_p, bg= color_p, col="black", labels=RE_disc$samples$sample)
```

```{r fig3, echo = FALSE}
plot(NULL ,xaxt='n',yaxt='n',bty='n',ylab='',xlab='', xlim=0:1, ylim=0:1)
legend("top", u_groups,  pch=shape_groups, col= "black", pt.bg=col_groups, y.intersp=1.25)
```



logFC


```{r}
# From the R documentiation: 
# The default method (method="logFC") is to convert the counts to log-counts-per-million using cpm and to pass these to the limma plotMDS function.
# This method calculates distances between samples based on log2 fold changes. 
plotMDS(RE_disc, method="logFC", bg=color_p, col = "black",  pch=shape_p)
```

```{r, echo = FALSE}
plot(NULL ,xaxt='n',yaxt='n',bty='n',ylab='',xlab='', xlim=0:1, ylim=0:1)
legend("top", u_groups,  pch=shape_groups, col= "black", pt.bg=col_groups, y.intersp=1.25)
```

```{r}
plotMDS(RE_disc, method="logFC", bg=color_p, col = "black",  pch=shape_p, labels=RE_disc$samples$sample)
```

```{r, echo = FALSE}
plot(NULL ,xaxt='n',yaxt='n',bty='n',ylab='',xlab='', xlim=0:1, ylim=0:1)
legend("top", u_groups,  pch=shape_groups, col= "black", pt.bg=col_groups, y.intersp=1.25)

```

```{r}
#Normalization for PCA and t-SNE, not exactly the same 
normcounts = 1e6*cpm(RE_disc, normalized.lib.sizes=T)
```

PCA

```{r}
## Perform PCA analysis and make plot
plotPCA(normcounts, bg=color_p, labels= FALSE , pch=shape_p, col = "black")
```

```{r, echo = FALSE}
plot(NULL ,xaxt='n',yaxt='n',bty='n',ylab='',xlab='', xlim=0:1, ylim=0:1)
legend("top", u_groups,  pch=shape_groups, col= "black", pt.bg=col_groups, y.intersp=1.25)
```

```{r}
## Perform PCA analysis and make plot
plotPCA(normcounts, bg=color_p, labels= TRUE , pch=shape_p, col = "black")
```

```{r, echo = FALSE}
plot(NULL ,xaxt='n',yaxt='n',bty='n',ylab='',xlab='', xlim=0:1, ylim=0:1)
legend("top", u_groups,  pch=shape_groups, col= "black", pt.bg=col_groups, y.intersp=1.25)
```

```{r}
par(mfrow=c(1,1))

# Dispersion analysis 
d1 <- estimateCommonDisp(RE_disc, verbose=T)
d1 <- estimateTagwiseDisp(d1)
plotBCV(d1)
```

```{r}
# Design Matrix -----------------------------------------------------------------------
if(Cov_check ==TRUE){
	design.mat <- model.matrix(~ 0 +., RE_disc$samples[c("group",covs)]  )
}else{
	design.mat <- model.matrix(~ 0 +., RE_disc$samples[c("group")]  )
}
head(design.mat)
```

```{r}
#colnames(design.mat) <- levels(RE_disc$samples$group)
d2 <- estimateGLMCommonDisp(RE_disc,design.mat)
d2 <- estimateGLMTrendedDisp(d2,design.mat, method="auto")
# You can change method to "auto", "bin.spline", "power", "spline", "bin.loess".
# The default is "auto" which chooses "bin.spline" when > 200 tags and "power" otherwise.
d2 <- estimateGLMTagwiseDisp(d2,design.mat)
plotBCV(d2)
```

```{r}

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

```

```{r}
for(nc in c(1:n_contrasts)){
	print(nc)
	lrt <- glmLRT(fit, contrast=contrasts[nc,])
	glmt = topTags(lrt, n=1000)

	pass_logFC= row.names(glmt[which(abs(glmt$table$logFC)>logFC_thresh),1][[1]])
	pass_alpha = row.names(glmt[which(glmt$table$FDR<alpha_thresh),1][[1]])
	pass_both = intersect(pass_logFC, pass_alpha)
	if(length(pass_both) > 0){
		sig_trans = c(sig_trans, pass_both)
		sig_results = glmt[which(row.names(glmt) %in% pass_both),-which(colnames(glmt) == "LR")] # New 20220712

#		# New 20220712 Plot to PDF
#		title_plot=glmt$comparison
#		t1 = tableGrob(head(data.frame(sig_results), n=40))
#		title <- textGrob(title_plot,gp=gpar(fontsize=15))
#		padding <- unit(5,"mm")
#
#		table <- gtable_add_rows(
#			t1, 
#			heights = grobHeight(title) + padding,
#			pos = 0)
#		table <- gtable_add_grob(
#			table, 
#			title, 
#			1, 1, 1, ncol(table))
#
#		grid.newpage()
#		grid.draw(table)

		print(sig_results)
	}
	#sig_trans = c(sig_trans, row.names(glmt[which(abs(glmt$table$logFC)>logFC_thresh),1][[1]])   )
}


```

```{r}
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

```

```{r}

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

	colorpal= rev(brewer.pal(11,"RdBu"))

	pheat.plot=pheatmap(log(normcounts+0.01,base = 2), cluster_rows = T,scale="row", cluster_cols = F,annotation_col = data.frame(Groups),col=colorpal,show_colnames = FALSE ,gaps_col=gaps, main = paste(group_col, ": log_2 REdiscoverTE ", filetypes[filetype], sep ="") )
#	print(pheat.plot)
	pheat.plot.clust = pheatmap(log(normcounts+0.01,base = 2), cluster_rows = T,scale="row", cluster_cols = T,annotation_col = data.frame(Groups),col=colorpal,show_colnames = FALSE ,gaps_col=gaps, main = paste(group_col, ": log_2 REdiscoverTE ", filetypes[filetype], " clustered", sep ="") )
#	print(pheat.plot.clust)


#  message("See corresponding PDF for a better version of this heatmap.")
#  save_pheatmap_pdf <- function(z, filename, width=30, height=20) {
#    stopifnot(!missing(z))
#    stopifnot(!missing(filename))
#    pdf(filename, width=width, height=height)
#    grid::grid.newpage()
#    grid::grid.draw(z$gtable)
#    dev.off()
#  }
#  save_pheatmap_pdf(pheat.plot,  paste(out_dir,"/",date,".",group_col,".",user_filename,filetypes[filetype],".alpha_",alpha_thresh,".logFC_",logFC_thresh,".NoQuestion.heatmap.pdf", sep=""))
#  save_pheatmap_pdf(pheat.plot.clust,  paste(out_dir,"/",date,".",group_col,".",user_filename,filetypes[filetype],".alpha_",alpha_thresh,".logFC_",logFC_thresh,".NoQuestion.clustered.heatmap.pdf", sep=""))

}else{
	message("Not enough significant results at these thresholds to plot a heatmap.")
}

```



```{r "Convert Ensemble Peptide Ids", include = FALSE}
#	convert ensemble peptide ids to gene names (hgns_symbol)
#	BiocManager::install()
#	BiocManager::install('biomaRt')
#	library('biomaRt')
#	mart <- useDataset("hsapiens_gene_ensembl", useMart("ensembl"))
#	getBM(filters = "ensembl_peptide_id", attributes = c("ensembl_peptide_id", "hgnc_symbol", "description"),values=c("ENSP00000227378"),mart=mart)

#	Can be done on full column
#	genes <- df$genes
#G_list <- getBM(filters = "ensembl_peptide_id", 
#                attributes = c("ensembl_peptide_id", "entrezgene", "description"),
#                values = genes, mart = mart)
```
