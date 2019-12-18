#!/usr/bin/env Rscript

#	https://pachterlab.github.io/sleuth_walkthroughs/pval_agg/analysis.html
#	https://github.com/griffithlab/rnaseq_tutorial/wiki/Kallisto
#	http://chagall.med.cornell.edu/RNASEQcourse/Intro2RNAseq.pdf	


#	OLD METHOD
#	source("https://bioconductor.org/biocLite.R")	
#	biocLite( 'pheatmap' )
#	biocLite("devtools")    # only if devtools not yet installed
#	biocLite("pachterlab/sleuth")


#	BiocManager::install(c('devtools','pheatmap','pachterlab/sleuth','cowplot','biomaRt'))
#	BiocManager::install(c('RColorBrewer','gplots','genefilter','calibrate','DESeq2','optparse','Cairo'))

#	BiocManager::install(c('pheatmap','pachterlab/sleuth','cowplot','biomaRt','RColorBrewer','gplots','genefilter','calibrate','DESeq2','optparse','Cairo'))

#suppressMessages({
	library('cowplot')
	library('sleuth')
#})



options(bitmapType='cairo')
#options(bitmapType='Xlib')



# install.packages('optparse')
# http://tuxette.nathalievilla.org/?p=1696
library("optparse")

option_list = list(
  make_option(c("-p", "--path"), type="character", default=NULL,
    help="root path", metavar="character"),
  make_option(c("-s", "--suffix"), type="character", default=NULL,
    help="folder suffix ( kallisto.single.mi_11 )", metavar="character"),
  make_option(c("-m", "--metadata"), type="character", default=NULL,
    help="metadata file name", metavar="character")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

message( "path: ",opt$path )
message( "suffix: ",opt$suffix )
message( "metadata: ",opt$metadata )
message()

if (is.null(opt$path)){
  print_help(opt_parser)
  stop("path is required.\n", call.=FALSE)
}

if (is.null(opt$suffix)){
  print_help(opt_parser)
  stop("suffix is required.\n", call.=FALSE)
}

if (is.null(opt$metadata)){
  print_help(opt_parser)
  stop("metadata file required.\n", call.=FALSE)
}


# Set value otherwise Rplots.pdf is used
pdf( paste0(opt$path,opt$suffix,'.sleuth.plots.pdf') )

















#	kmer 11 causes ... for hairpin and mirna
#Sample '01' had this error message: Error in apply(bs_mat, 2, quantile) : dim(X) must have a positive length

#	Plotting inside a loop requires a print() as the for loop only returns the last thing it did to main.
#	mature seems to have too little data
#for( val in c( 'mature','hairpin','mirna' ) ){

#val=opt$suffix	#	kallisto.single.mi_11


message(paste0("Processing ",opt$suffix))
#	For some reason, ONLY 1 plot ends up in this file.
#	Probably has something to do with cowplot
pdf( paste0(opt$suffix, ".plots.pdf") )

#	specify colClasses as sample ids are numbers and R will strip leading zeroes
message("Reading metadata")
#metadata <- read.table('/raid/data/raw/Stanford_Project71/metadata.csv', sep=',',
metadata <- read.table(opt$metadata, sep=',',
	header=TRUE,
	stringsAsFactors = FALSE,
	colClasses='character')

metadata <- dplyr::select(metadata, c( 'id','cc') )

metadata[is.na(metadata)] <- 0

#metadata <- dplyr::rename(metadata, run = id )
#  'metadata' (sample_to_covariates) must contain a column named 'sample'
#	Changing "run" to "sample", although not entirely accurate
metadata <- dplyr::rename(metadata, sample = id )


#	message("Selecting only present datasets.")
#	#	
#	metadata <- dplyr::filter(metadata, file.exists(file.path( paste0(sample,".Homo_sapiens.GRCh38.rna"))))
#	head(metadata)
#	
#	
#	message("Selecting only lane 1 so 1 sample per line.")
#	#	Select only the _1 so 1 run per line 
#	metadata <- dplyr::filter( metadata, grepl('_1$', run_with_lane ))
#	head(metadata)


#	'metadata' (sample_to_covariates) must contain a column named 'path'
#	metadata <- dplyr::mutate(metadata, path = file.path( paste0(sample,".Homo_sapiens.GRCh38.rna"), 'abundance.h5'))
#	head(metadata)
metadata <- dplyr::mutate(metadata, path = file.path( paste0(opt$path,'/',sample,'.',opt$suffix), 'abundance.h5'))


#	#	Select only the _1 so 1 run per line 
#	metadata <- dplyr::filter( metadata, grepl('_1$', run_with_lane ))
#	head(metadata)



message(paste("Using existing",nrow(metadata),"datasets"))
head(metadata)




#	#> library("biomaRt")
#	#> listMarts()
#	#> ensembl=useMart("ensembl")
#	#> listDatasets(ensembl)
#	
#	message("Setting biomart")
#	mart <- biomaRt::useMart(biomart = "ensembl", dataset = "hsapiens_gene_ensembl", host = "www.ensembl.org", ensemblRedirect = FALSE)
#	#	Sometimes, the next step fails due to default host being down or being redirected
#	#	to so include the host and stop the redirection. (redirection seems to be the problem at the moment)
#	
#	message("Getting biomart")
#	ttg <- biomaRt::getBM(attributes = c("ensembl_transcript_id", "ensembl_gene_id", "external_gene_name"), mart = mart)
#	
#	message("Modifying biomart")
#	ttg <- dplyr::rename(ttg, target_id = ensembl_transcript_id, ens_gene = ensembl_gene_id, ext_gene = external_gene_name)
#	
#	message("Subselecting biomart")
#	ttg <- dplyr::select(ttg, c('target_id', 'ens_gene', 'ext_gene'))
#	head(ttg)



#norm_factors(metadata)



#	so <- sleuth_prep(metadata, target_mapping = ttg,
#		aggregation_column = 'ens_gene', extra_bootstrap_summary = TRUE)
so <- sleuth_prep(metadata, extra_bootstrap_summary = TRUE)
head(so)






#	https://pachterlab.github.io/sleuth/docs/sleuth_fit.html

#	Need multiple values for each of the offered factors so this doesn't run until enough data exists.
#	  contrasts can be applied only to factors with 2 or more levels
message("Fitting full")
#so <- sleuth_fit(so, ~gender+smoke+tissue, 'full')
so <- sleuth_fit(so, ~cc, 'full')

message("Fitting reduced")
#so <- sleuth_fit(so, ~gender+smoke, 'reduced')
so <- sleuth_fit(so, ~1, 'reduced')

#	
#	#	sleuth_fit does not like NAs, so need to replace them with 0s or something as I've done above
#	#Error in dimnames(x) <- dn : 
#	#  length of 'dimnames' [1] not equal to array extent
#	
#	#	https://pachterlab.github.io/sleuth/docs/sleuth_wt.html
#	#so <- sleuth_wt(so, 'gender_smale')

message("Performing likelihood ratio test")
so <- sleuth_lrt(so, 'reduced', 'full')


message("models(so)")
models(so)


message("tests(so)")
tests(so)



#	https://pachterlab.github.io/sleuth/docs/sleuth_results.html

#message("Obtaining gene-level differential expression results")
message("Obtaining differential expression results")

#sleuth_table <- sleuth_results(so, 'gender_smale', show_all = FALSE)
sleuth_table <- sleuth_results(so, 'reduced:full', 'lrt', show_all = FALSE)
#head(sleuth_table,20)
#typeof(sleuth_table)

print(head(sleuth_table[order(sleuth_table$pval),],20))

sleuth_table_select <- dplyr::filter(sleuth_table, qval <= 0.05)
print(head(sleuth_table_select,20))

message("Looping over top 5")
#print(head(sleuth_table[order(sleuth_table$pval),],5)[['target_id']])
for(ref in head(sleuth_table[order(sleuth_table$pval),],5)[['target_id']]){
#	for(ref in head(sleuth_table[order(sleuth_table$pval),],5) ){
##		print(plot_bootstrap(so, ref$target_id, units = "est_counts", color_by = "cc"))
	print(ref)
	print(plot_bootstrap(so, ref, units = "est_counts", color_by = "cc"))
}
message("end loop over top 5")

#print(plot_bootstrap(so, "hsa-mir-3908-hairpin", units = "est_counts", color_by = "cc"))
#print(plot_bootstrap(so, "hsa-mir-4430-hairpin", units = "est_counts", color_by = "cc"))
#plot_bootstrap(so, "hsa-mir-5588-hairpin", units = "est_counts", color_by = "cc")
#plot_bootstrap(so, "hsa-mir-619-hairpin", units = "est_counts", color_by = "cc")



#	#	message("Obtaining consistent transcript-level differential expression results")
#	#	
#	#	#sleuth_table_tx <- sleuth_results(so, 'gender_smale', show_all = FALSE, pval_aggregate = FALSE)
#	#	sleuth_table_tx <- sleuth_results(so, 'reduced:full', 'lrt', show_all = FALSE, pval_aggregate = FALSE)
#	#	
#	#	sleuth_table_tx <- dplyr::filter(sleuth_table_tx, qval <= 0.05)
#	#	
#	#	head(sleuth_table_tx)
#	#	
#	#	
#	#	So it runs. Not exactly sure what each of these have done.
#	#	Perhaps clearer with bigger data set and more metadata to group.


#	message("plot_pca(so, color_by = 'gender')")
#	plot_pca(so, color_by = 'gender')
#	
#	message("plot_pca(so, color_by = 'smoke')")
#	plot_pca(so, color_by = 'smoke')
#	
#	message("plot_pca(so, color_by = 'tissue')")
#	plot_pca(so, color_by = 'tissue')


message("plot_pca(so, color_by = 'cc')")
print(plot_pca(so, color_by = 'cc'))

message("plot_pca(so, text_labels = TRUE, color_by = 'cc')")
print(plot_pca(so, text_labels = TRUE, color_by = 'cc'))



#plot_group_density(so, use_filtered = TRUE, units = "est_counts",
#  trans = "log", grouping = setdiff(colnames(so$sample_to_covariates),
#  "sample"), offset = 1)






#	https://www.rdocumentation.org/packages/sleuth/versions/0.30.0/topics/plot_sample_heatmap
#	https://cran.r-project.org/web/packages/pheatmap/pheatmap.pdf

#	When print/plotting heatmap, nothing after it prints.

#message("plot_sample_heatmap(so)")
#print(plot_sample_heatmap(so, main="test1"))

#message("plot_sample_heatmap(so) without legend")
#print(plot_sample_heatmap(so, legend=FALSE, main="test2"))




#message("plot_group_density")

#message("plot_qq(so,TEST)")
#print(plot_qq(so,TEST))

#message("plot_volcano(so,TEST)")
#print(plot_volcano(so,TEST))


#	#	plot_bootstrap
#	#	
#	#	plot_fld.kallisto
#	#	
#	#	plot_fld.sleuth
#	#	
#	#	plot_loadings
#	#	
#	#	plot_ma
#	#	
#	#	plot_mean_var
#	#	
#	#	plot_pc_variance
#	#	
#	#	plot_sample_density
#	#	
#	#	plot_sample_heatmap
#	#	
#	#	plot_scatter
#	#	
#	#	plot_transcript_heatmap
#	#	
#	#	plot_vars

