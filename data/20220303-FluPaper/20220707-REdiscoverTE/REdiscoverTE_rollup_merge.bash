#!/usr/bin/env bash


####!/usr/bin/env Rscript

module load r

#	quote EOF to stop variable expansion in the R script 

cat <<- "EOF" | R --no-save --no-echo

library(edgeR)
library(limma)

#	--dirs rollup.00 rollup.01 rollup.02
#	--out rollup.merged

#dirs=c(
#	'rollup/rollup.00',
#	'rollup/rollup.01')

subdirs=list.files("rollup", pattern="rollup.*")
#[1] "rollup.00" "rollup.01" "rollup.02" "rollup.03" "rollup.04"

#	'rollup/rollup.02',
#	'rollup/rollup.03',
#	'rollup/rollup.04')

files=c(
	'GENE_1_raw_counts.RDS',
	'GENE_2_counts_normalized.RDS',
	'GENE_3_TPM.RDS',
	'RE_all_1_raw_counts.RDS',
	'RE_all_2_counts_normalized.RDS',
	'RE_all_3_TPM.RDS',
	'RE_all_repFamily_1_raw_counts.RDS',
	'RE_all_repFamily_2_counts_normalized.RDS',
	'RE_all_repFamily_3_TPM.RDS',
	'RE_exon_1_raw_counts.RDS',
	'RE_exon_2_counts_normalized.RDS',
	'RE_exon_3_TPM.RDS',
	'RE_exon_repFamily_1_raw_counts.RDS',
	'RE_exon_repFamily_2_counts_normalized.RDS',
	'RE_exon_repFamily_3_TPM.RDS',
	'RE_intergenic_1_raw_counts.RDS',
	'RE_intergenic_2_counts_normalized.RDS',
	'RE_intergenic_3_TPM.RDS',
	'RE_intergenic_repFamily_1_raw_counts.RDS',
	'RE_intergenic_repFamily_2_counts_normalized.RDS',
	'RE_intergenic_repFamily_3_TPM.RDS',
	'RE_intron_1_raw_counts.RDS',
	'RE_intron_2_counts_normalized.RDS',
	'RE_intron_3_TPM.RDS',
	'RE_intron_repFamily_1_raw_counts.RDS',
	'RE_intron_repFamily_2_counts_normalized.RDS',
	'RE_intron_repFamily_3_TPM.RDS')

#	mkdir out
outdir="rollup/rollup.merged"
#mkdir(outdir)
dir.create(outdir, showWarnings = TRUE, recursive = FALSE, mode = "0700")



#	can't use length(list(dge)) as it always returns 2?


for( file in files ){
	first=TRUE
	message(paste("Reading and merging",file))
	#for( dir in dirs ){
	for( subdir in subdirs ){
		dir=paste("rollup",subdir,sep='/')
		if( first ){
			message(paste("Reading first",subdir))
			first=FALSE
			a=readRDS( paste(dir,file,sep='/') )
		} else {
			message(paste("Merging",subdir))
			b = readRDS( paste(dir,file,sep='/') )

			mergedCounts=merge(
				as.data.frame(a$counts),
				as.data.frame(b$counts),
				by = 'row.names', all = TRUE)
			row.names(mergedCounts)=mergedCounts$Row.names
			mergedCounts= mergedCounts[,!(names(mergedCounts)=='Row.names')]
			mergedCounts[is.na(mergedCounts)] = 0
	
			mergedSamples=rbind(a$samples,b$samples)
	
			mergedGenes=unique(rbind(a$genes,b$genes))

			res <- DGEList(counts=mergedCounts,
				samples=mergedSamples,
				genes=mergedGenes)
			res$samples<-res$samples[,!(names(res$samples) %in% c("lib.size.1", "norm.factors.1"))]

			a=res
		}
	}
	message(paste("Writing MERGED",outdir,file))
	saveRDS(res, file=file.path(outdir,file))
}

EOF


