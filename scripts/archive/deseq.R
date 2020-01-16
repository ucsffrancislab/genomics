#!/usr/bin/env Rscript

#	message -> STDERR
#	print -> STDOUT

#	adapted from https://gist.githubusercontent.com/stephenturner/f60c1934405c127f09a6/raw/3971589c8c017953ec0493329ed8c4b711cbe358/deseq2-analysis-template.R

#if (!requireNamespace("BiocManager", quietly = TRUE))
#    install.packages("BiocManager")
#BiocManager::install(version = "3.10")
#BiocManager::install(c('RColorBrewer','gplots','genefilter','calibrate','DESeq2','optparse','Cairo'))
#BiocManager::install(c('vsn','ggplot2'))


options(bitmapType='cairo')
#options(bitmapType='Xlib')



#	install.packages('optparse')
#	http://tuxette.nathalievilla.org/?p=1696
library("optparse")

option_list = list(
	make_option(c("-f", "--featureCounts"), type="character", default=NULL,
		help="featureCounts file name", metavar="character"),
	make_option(c("-m", "--metadata"), type="character", default=NULL,
		help="metadata file name", metavar="character")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

print( paste0("featureCounts: ",opt$featureCounts ) )
print( paste0("metadata: ",opt$metadata ) )
#print()


if (is.null(opt$featureCounts)){
	print_help(opt_parser)
	stop("featureCounts file required.\n", call.=FALSE)
}

if (is.null(opt$metadata)){
	print_help(opt_parser)
	stop("metadata file required.\n", call.=FALSE)
}


#	Set value otherwise Rplots.pdf is used
pdf( paste0(opt$featureCount,'.deseq.plots.pdf') )


## RNA-seq analysis with DESeq2
## Stephen Turner, @genetics_blog

# RNA-seq data from GSE52202
# http://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=gse52202. All patients with
# ALS, 4 with C9 expansion ("exp"), 4 controls without expansion ("ctl")

# Import & pre-process ----------------------------------------------------

# Import data from featureCounts
# Previously ran at command line something like this:
# featureCounts -a genes.gtf -o counts.txt -T 12 -t exon -g gene_id GSM*.sam
#	default sep is white space. some files contain "gene names" with spaces
#	which will cause "more columns than column names" error
countdata <- read.table(opt$featureCounts, header=TRUE, row.names=1, sep="\t")
head(countdata)

# Remove first five columns (chr, start, end, strand, length)
countdata <- countdata[ ,6:ncol(countdata)]
head(countdata)
#df = subset(df, select=-c(Chr,Start,End,Strand,Length))



# Remove .bam or .sam from filenames
#colnames(countdata) <- gsub("^/data/shared/francislab/data/raw/SFGF-Shaw-GS-13361/trimmed/unpaired/", "", colnames(countdata))
#colnames(countdata) <- gsub("^X.data.shared.francislab.data.raw.SFGF.Shaw.GS.13361.trimmed.unpaired.", "", colnames(countdata))
#colnames(countdata) <- gsub("\\.[sb]am$", "", colnames(countdata))
#colnames(countdata) <- gsub(".h38au.bowtie2.e2e$", "", colnames(countdata))

# Convert to matrix
countdata <- as.matrix(countdata)
head(countdata)


# Assign condition (first four are controls, second four contain the expansion)
#(condition <- factor(c(rep("ctl", 4), rep("exp", 4))))
#condition

#casecontrol <- read.table("metadata.csv", header=TRUE, row.names=1, sep=",")
casecontrol <- read.table(opt$metadata, header=TRUE, row.names=1, sep=",")
#	expecting comma separated, 2 column csf with id and cc columns
condition <- casecontrol$cc

# Analysis with DESeq2 ----------------------------------------------------

library(DESeq2)


# Create a coldata frame and instantiate the DESeqDataSet. See ?DESeqDataSetFromMatrix
#(coldata <- data.frame(row.names=colnames(countdata), condition))
#	why wrapped in parentheses?)
coldata <- data.frame(row.names=colnames(countdata), condition)
head(coldata)

dds <- DESeqDataSetFromMatrix(countData=countdata, colData=coldata, design=~condition)
dds


# Run the DESeq pipeline
dds <- DESeq(dds)


#	20191220 - From Intro to DGE Analysis
# remove genes without any counts
dds <- dds[rowSums(counts(dds)) > 0,]
#
#	NORMALIZE
dds <- estimateSizeFactors(dds)
sizeFactors(dds)
counts.sf_normalized <- counts(dds, normalized=TRUE)
log.norm.counts <- log2(counts.sf_normalized + 1)

par(mfrow=c(2,1))

print("boxplot(counts.sf_normalized")
boxplot(counts.sf_normalized, notch=TRUE,
	main="untransformed read counts", ylab="read counts")
print("boxplot(log.norm.counts")
boxplot(log.norm.counts, notch=TRUE,
	main="log2-transformed read counts",
	ylab="log2(read counts)")

print("plot(log.norm.counts[,1:2]")
plot(log.norm.counts[,1:2], cex=.1, main="Normalized log2(read counts)")

library ( vsn )
library ( ggplot2 )
print("meanSdPlot(log.norm.counts")
msd_plot<-meanSdPlot(log.norm.counts,ranks=FALSE,plot=FALSE)
msd_plot$gg+ggtitle("sequencing depth normalized log2(read counts)")+ylab("standard deviation")


dds.rlog<-rlog(dds,blind=TRUE)
rlog.norm.counts<-assay(dds.rlog)

# mean-sd plot for rlog - transformed data
print("meanSdPlot(rlog.norm.counts")
msd_plot<-meanSdPlot(rlog.norm.counts,ranks=FALSE,plot=FALSE)
msd_plot$gg+ggtitle("rlog-transformed read counts")+ylab("standard deviation")


# cor () calculates the correlation between columns of a matrix
distance.m_rlog<-as.dist(1-cor(rlog.norm.counts,method="pearson"))
# plot () can directly interpret the output of hclust ()
print("plot(hclust(distance.m_rlog)")
plot(hclust(distance.m_rlog),
	labels=colnames(rlog.norm.counts),
	main="rlog transformed read counts\ndistance : Pearson correlation")


pc<-prcomp(t(rlog.norm.counts))
print("plot(pc$x[,1],pc$x[,2],")
plot(pc$x[,1],pc$x[,2],
	col=colData(dds)[,1],
	main="PCA of seq.depth normalized\nand rlog-transformed read counts")

# PCA
print("plotPCA")
P<-plotPCA(dds.rlog)
P<-P+theme_bw()+ggtitle("Rlog transformed counts")
print(P)


#	reset par
par(mfrow=c(1,1))

##################################################







res <- results(dds)
head(results(dds, tidy=TRUE))
summary(res) #summary of results




print("plotMA")
plotMA( res, ylim = c(-1, 1) )
plotMA( res, ylim = c(-2, 2) )
plotMA( res, ylim = c(-5, 5) )




print("plotDispEsts")
plotDispEsts( dds, ylim = c(1e-6, 1e1) )
plotDispEsts( dds, ylim = c(1e-6, 1e4) )


print("hist pvalue")
hist( res$pvalue, breaks=20, col="grey" )


print("hist padj")
hist( res$padj, breaks=20, col="grey" )


print("res")
res <- res[order(res$padj),]
head(res)

#par(mfrow=c(2,3))

print("Looping over head 10")
for(gene in row.names(head(res,10))){
	print(gene)
	#print(plotCounts(dds, gene=gene, intgroup="cc"))
	print(plotCounts(dds, gene=gene, intgroup="condition"))
}
print("end loop over head 10")

#	Not sure if this is sorted in the correct order

print("Looping over tail 10")
for(gene in row.names(tail(res,10))){
	print(gene)
	#print(plotCounts(dds, gene=gene, intgroup="cc"))
	print(plotCounts(dds, gene=gene, intgroup="condition"))
}
print("end loop over tail 10")




#reset par
#par(mfrow=c(1,1))

# Make a basic volcano plot
with(res, plot(log2FoldChange, -log10(pvalue), pch=20, main="Volcano plot", xlim=c(-3,3)))

# Add colored points: blue if padj<0.01, red if log2FC>1 and padj<0.05)
with(subset(res, padj<.01 ), points(log2FoldChange, -log10(pvalue), pch=20, col="blue"))
with(subset(res, padj<.01 & abs(log2FoldChange)>2), points(log2FoldChange, -log10(pvalue), pch=20, col="red"))

with(subset(res, padj<.001 ), points(log2FoldChange, -log10(pvalue), pch=20, col="green"))
with(subset(res, padj<.001 & abs(log2FoldChange)>2), points(log2FoldChange, -log10(pvalue), pch=20, col="yellow"))

legend("topright",
	legend=c('All','padj<0.01','padj<0.01 & abs>2','padj<0.001','padj<0.001 & abs>2'),
	col=c('black','blue','red','green','yellow'),
	pch = 20,
	lty=1:2, cex=0.8)


#github/unreno/genomics/dev/data_sets/Stanford_Project71/20190917-exploratory/deseq2.R

#github/unreno/genomics/dev/data_sets/E-GEOD-105052/20190926-exploratory/deseq2.R


print("rlog")
rld <- rlog(dds)
print("plotPCA")
plotPCA(rld, intgroup=c( 'condition' ))




# also possible to perform custom transformation:
print("estimateSizeFactors")
dds <- estimateSizeFactors(dds)
# shifted log of normalized counts
print("SummarizedExperiment")
se <- SummarizedExperiment(log2(counts(dds, normalized=TRUE) + 1), colData=colData(dds))
# the call to DESeqTransform() is needed to
# trigger our plotPCA method.
print("plotPCA")
plotPCA( DESeqTransform( se ), intgroup=c( 'condition' ) )


#	Concentration of counts over total sum of counts
print("estimateSizeFactors")
dds <- estimateSizeFactors(dds)
print("plotSparsity")
plotSparsity(dds)


#	Cluster Dendrogram
print("varianceStabilizingTransformation")
vsd <- varianceStabilizingTransformation(dds)
print("dist(t(assay(vsd)))")
dists <- dist(t(assay(vsd)))
print("plot(hclust(dists))")
plot(hclust(dists))



# Plot dispersions
print("plotDispEsts")
plotDispEsts(dds, main="Dispersion plot")


# Regularized log transformation for clustering/heatmaps, etc
rld <- rlogTransformation(dds)
head(assay(rld))
hist(assay(rld))

# Colors for plots below
## Ugly:
## (mycols <- 1:length(unique(condition)))
## Use RColorBrewer, better
library(RColorBrewer)
(mycols <- brewer.pal(8, "Dark2")[1:length(unique(condition))])

# Sample distance heatmap
sampleDists <- as.matrix(dist(t(assay(rld))))
library(gplots)
print("heatmap.2")
heatmap.2(as.matrix(sampleDists), key=F, trace="none",
	col=colorpanel(100, "black", "white"),
	ColSideColors=mycols[condition], RowSideColors=mycols[condition],
	margin=c(10, 10), main="Sample Distance Matrix")


# Principal components analysis
## Could do with built-in DESeq2 function:
## DESeq2::plotPCA(rld, intgroup="condition")
## I like mine better:
print("define rld_pca")
rld_pca <- function (rld, intgroup = "condition", ntop = 500, colors=NULL,
		legendpos="bottomleft", main="PCA Biplot", textcx=1, ...) {
	require(genefilter)
	require(calibrate)
	require(RColorBrewer)
	rv = rowVars(assay(rld))
	select = order(rv, decreasing = TRUE)[seq_len(min(ntop, length(rv)))]
	pca = prcomp(t(assay(rld)[select, ]))
	fac = factor(apply(as.data.frame(colData(rld)[, intgroup, drop = FALSE]), 1, paste, collapse = " : "))
	if (is.null(colors)) {
		if (nlevels(fac) >= 3) {
			colors = brewer.pal(nlevels(fac), "Paired")
		} else {
			colors = c("black", "red")
		}
	}
	pc1var <- round(summary(pca)$importance[2,1]*100, digits=1)
	pc2var <- round(summary(pca)$importance[2,2]*100, digits=1)
	pc1lab <- paste0("PC1 (",as.character(pc1var),"%)")
	pc2lab <- paste0("PC1 (",as.character(pc2var),"%)")
	plot(PC2~PC1, data=as.data.frame(pca$x), bg=colors[fac], pch=21, xlab=pc1lab, ylab=pc2lab, main=main, ...)
	with(as.data.frame(pca$x), textxy(PC1, PC2, labs=rownames(as.data.frame(pca$x)), cex=textcx))
	legend(legendpos, legend=levels(fac), col=colors, pch=20)
	#rldyplot(PC2 ~ PC1, groups = fac, data = as.data.frame(pca$rld),
	#  pch = 16, cerld = 2, aspect = "iso", col = colours,
  #  main = draw.key(key = list(rect = list(col = colours),
	#  terldt = list(levels(fac)), rep = FALSE)))
}


print("rld_pca")
rld_pca(rld, colors=mycols, intgroup="condition", xlim=c(-75, 35))


# Get differential expression results
res <- results(dds)
table(res$padj<0.05)

## Order by adjusted p-value
res <- res[order(res$padj), ]

## Merge with normalized count data
resdata <- merge(as.data.frame(res), as.data.frame(counts(dds, normalized=TRUE)), by="row.names", sort=FALSE)
names(resdata)[1] <- "Gene"
head(resdata)

## Write results
print("write csv")
write.csv(resdata, file=paste0(opt$featureCounts,".deseq.diffexpr-results.csv"))

## Examine plot of p-values
print("hist")
hist(res$pvalue, breaks=50, col="grey")

## Examine independent filtering
print("attr filterThreshold")
attr(res, "filterThreshold")

#
#	Error in plot.window(...) : need finite 'xlim' values
#	Calls: plot -> plot -> plot.default -> localWindow -> plot.window
#	In addition: Warning messages:
#	1: In min(x) : no non-missing arguments to min; returning Inf
#	2: In max(x) : no non-missing arguments to max; returning -Inf
#	3: In min(x) : no non-missing arguments to min; returning Inf
#	4: In max(x) : no non-missing arguments to max; returning -Inf
#	Execution halted
#
#print("plot")
#plot(attr(res,"filterNumRej"), type="b", xlab="quantiles of baseMean", ylab="number of rejections")


## MA plot
## Could do with built-in DESeq2 function:
## DESeq2::plotMA(dds, ylim=c(-1,1), cex=1)
## I like mine better:
print("define mplot")
maplot <- function (res, thresh=0.05, labelsig=TRUE, textcx=1, ...) {
	with(res, plot(baseMean, log2FoldChange, pch=20, cex=.5, log="x", ...))
	with(subset(res, padj<thresh), points(baseMean, log2FoldChange, col="red", pch=20, cex=1.5))
	if (labelsig) {
		require(calibrate)
		with(subset(res, padj<thresh), textxy(baseMean, log2FoldChange, labs=Gene, cex=textcx, col=2))
	}
}

print("maplot")
maplot(resdata, main="MA Plot")


## Volcano plot with "significant" genes labeled
print("define volcanoplot")
volcanoplot <- function (res, lfcthresh=2, sigthresh=0.05, main="Volcano Plot",
		legendpos="bottomright", labelsig=TRUE, textcx=1, ...) {
	with(res, plot(log2FoldChange, -log10(pvalue), pch=20, main=main, ...))
	with(subset(res, padj<sigthresh ), points(log2FoldChange,
		-log10(pvalue), pch=20, col="red", ...))
	with(subset(res, abs(log2FoldChange)>lfcthresh), points(log2FoldChange,
		-log10(pvalue), pch=20, col="orange", ...))
	with(subset(res, padj<sigthresh & abs(log2FoldChange)>lfcthresh),
		points(log2FoldChange, -log10(pvalue), pch=20, col="green", ...))
	if (labelsig) {
		require(calibrate)
		with(subset(res, padj<sigthresh & abs(log2FoldChange)>lfcthresh),
			textxy(log2FoldChange, -log10(pvalue), labs=Gene, cex=textcx, ...))
	}
	legend(legendpos, xjust=1, yjust=1,
		legend=c(paste("FDR<",sigthresh,sep=""),
		paste("|LogFC|>",lfcthresh,sep=""), "both"),
		pch=20, col=c("red","orange","green"))
}


print("volcanoplot")
volcanoplot(resdata, lfcthresh=1, sigthresh=0.05, textcx=.8, xlim=c(-2.3, 2))

