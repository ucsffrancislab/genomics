#!/usr/bin/env Rscript


metadata='metadata.csv'

featureCounts='h38au.bowtie2-loc.unmapped.blastn.viral.raw.1e-30.summary.csv'

presence_threshold=1


#	read blast counts
countdata <- read.table(featureCounts, header=TRUE, row.names=1, sep="\t")

#	remove Chr,Start,End,Strand,Length
countdata <- countdata[ ,6:ncol(countdata)]

#	convert counts to just 1
countdata[countdata>=presence_threshold] <- 1

#	Filter dataset on row sums
#countdata <- countdata[rowSums(countdata) >= row_threshold,]

#	read case / control data
casecontrol <- read.table(metadata, header=TRUE, row.names=1, sep=",")

#	Add case / control row
countdata['cc',] <- casecontrol$cc

#	select just cases
ca <- countdata[,countdata['cc',] == 'Case']

#	select just controls
co <- countdata[,countdata['cc',] == 'Control']

#	merge cases and controls so grouped together
merged=cbind(ca,co)

#	write output csv
write.csv(merged, file=paste0(featureCounts,".binary.csv"), quote=c())


