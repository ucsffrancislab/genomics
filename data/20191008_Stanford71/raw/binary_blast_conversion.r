#!/usr/bin/env Rscript

library("optparse")

#featureCounts='h38au.bowtie2-loc.unmapped.blastn.viral.raw.1e-30.summary.csv'



option_list = list(
	make_option(c("-f", "--featureCounts"), type="character", default=NULL,
		help="featureCounts file name", metavar="character"),
	make_option(c("-m", "--metadata"), type="character", default='metadata.csv',
		help="metadata file name", metavar="character"),
	make_option(c("-p", "--presence_threshold"), type="integer", default=1,
		help="presence threshold", metavar="integer"),
	make_option(c("-r", "--rowsum_threshold"), type="integer", default=1,
		help="rowsum threshold", metavar="integer")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

print( paste0("featureCounts: ",opt$featureCounts ) )
print( paste0("metadata: ",opt$metadata ) )
print( paste0("presence_threshold: ",opt$presence_threshold ) )
print( paste0("rowsum threshold: ",opt$rowsum_threshold ) )


if (is.null(opt$featureCounts)){
	print_help(opt_parser)
	stop("featureCounts file required.\n", call.=FALSE)
}

if (is.null(opt$metadata)){
	print_help(opt_parser)
	stop("metadata file required.\n", call.=FALSE)
}









#	read blast counts
countdata <- read.table(opt$featureCounts, header=TRUE, row.names=1, sep="\t")

#	remove Chr,Start,End,Strand,Length
countdata <- countdata[ ,6:ncol(countdata)]




#	convert counts to just 1 or 0
countdata[countdata <  opt$presence_threshold] <- 0
countdata[countdata >= opt$presence_threshold] <- 1

#	Would be nice to do the presence threshold row by row
#	perhaps below certain percentage of mean rather than a fixed number



#	Filter dataset on row sums
countdata <- countdata[rowSums(countdata) >= opt$rowsum_threshold,]

#	read case / control data
casecontrol <- read.table(opt$metadata, header=TRUE, row.names=1, sep=",")

#	Add case / control row
countdata['cc',] <- casecontrol$cc

#	select just cases
ca <- countdata[,countdata['cc',] == 'Case']

#	select just controls
co <- countdata[,countdata['cc',] == 'Control']

#	merge cases and controls so grouped together
merged=cbind(ca,co)

#	write output csv
out = sub('\\.csv$', '', opt$featureCounts) 

write.csv(merged, file=paste0(out,".p",opt$presence_threshold,".r",opt$rowsum_threshold,".binary.csv"))


