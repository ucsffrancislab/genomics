#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)

out_dir = args[3]
prefix = args[11]
column = args[5]

i = args[8]
#iname=sub("_1_raw_counts.RDS","",list.files(path=args[1],pattern="*_1_raw_counts.RDS")[strtoi(i)])
filetypes <- c("GENE", "RE_intron", "RE_exon", "RE_intergenic", "RE_all", "RE_all_repFamily", "RE_intron_repFamily", "RE_exon_repFamily", "RE_intergenic_repFamily", "")
iname=filetypes[strtoi(i)]

alpha_thresh = args[9]
logFC_thresh = args[10]

output_dir = out_dir
output_file = paste(prefix,column,iname,"alpha",alpha_thresh,"logFC",logFC_thresh,"html", sep=".")

rmarkdown::render("REdiscoverTE_EdgeR_rmarkdown.Rmd", output_dir = output_dir, output_file = output_file )

