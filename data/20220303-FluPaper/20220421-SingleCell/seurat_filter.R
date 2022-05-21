#!/usr/bin/env Rscript

# ~/github/ucsffrancislab/genomics/scripts/manhattan_qq_plot.r

#	./seurat_filter.R -d /francislab/data2/working/20220303-FluPaper/20220421-SingleCell/out/B1-c1/outs/filtered_feature_bc_matrix

#	install.packages('optparse')
#	http://tuxette.nathalievilla.org/?p=1696
#	http://tuxette.nathalievilla.org/2015/09/passing-arguments-to-a-r-script-from-command-lines/

library("optparse")
 
option_list = list(
	make_option(c("-d", "--datadir"), type="character", default=NULL, 
		help="Data dir", metavar="character")
); 
 
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

message( "DataDir: ",opt$datadir )
message()

if (is.null(opt$datadir)){
  print_help(opt_parser)
  stop("Data dir required.\n", call.=FALSE)
}

out= gsub('/*$', '.seurat_barcodes', opt$datadir)
message( "out: ",out)


library(Seurat)
library(dplyr)
library(Matrix)
library(gdata)


counts <- Read10X( data.dir = opt$datadir )
#	data.dir = "/francislab/data2/working/20220303-FluPaper/20220421-SingleCell/out/B1-c1/outs/filtered_feature_bc_matrix")

seurat<-CreateSeuratObject(counts = counts, min.cells = 3, min.features = 350, project = "FLU")


mito.genes <- grep(pattern = "^MT-", x = rownames(x = seurat@assays$RNA@data), value = TRUE)

percent.mito <- Matrix::colSums(seurat@assays$RNA@data[mito.genes, ])/Matrix::colSums(seurat@assays$RNA@data)

seurat <- AddMetaData(object = seurat, percent.mito, col.name = "percent.mito")


seurat <- subset(seurat, subset = nFeature_RNA > 200 & nFeature_RNA < 2500 & percent.mito < 0.1)

write.table(colnames(seurat@assays$RNA@data),
	out, append = FALSE, sep = " ", dec = ".",
	row.names = FALSE, col.names = FALSE, quote = FALSE )




#	for d in /francislab/data2/working/20220303-FluPaper/20220421-SingleCell/out/*/outs/filtered_feature_bc_matrix ; do echo $d ; ./seurat_filter.R -d ${d} ; done

