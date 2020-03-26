#!/usr/bin/env Rscript

#mfiles <- list.files(path="for_plots", pattern="*.for.manhattan.plot", full.names=T, recursive=FALSE)
#qfiles <- list.files(path="for_plots", pattern="*.for.qq.plot", full.names=T, recursive=FALSE)

#mfiles <- list.files(path="for_plots", pattern="*.for.manhattan.plot", full.names=T, recursive=TRUE)
#qfiles <- list.files(path="for_plots", pattern="*.for.qq.plot", full.names=T, recursive=TRUE)

#	Doing it this way instead of above to place the in-dir in one place.
#	Could then set with variables

message( getwd() )
setwd("for_plots")
message( getwd() )
mfiles <- list.files(pattern="*.for.manhattan.plot", full.names=T, recursive=TRUE)
qfiles <- list.files(pattern="*.for.qq.plot", full.names=T, recursive=TRUE)


length(mfiles)
length(qfiles)

somePNGPath = "plots"

#	install.packages('qqman')
library("qqman")

#	Disable all the warnings
options(warn=-1)
#Warning messages:
#1: In min(d[d$CHR == i, ]$pos) :
#  no non-missing arguments to min; returning Inf
#2: In max(d[d$CHR == i, ]$pos) :
#  no non-missing arguments to max; returning -Inf

for (i in 1:length(mfiles))
{
	message( i," / ",length(mfiles) )
	message( "Manhattan file: ", mfiles[i] )
	message( "Q-Q file: ", qfiles[i] )

	if( ( file.info(mfiles[i])$size == 0 ) || ( file.info(qfiles[i])$size == 0 ) ){
	  message("Manhattan or QQ file is empty. Skipping.")
		next
	}

	outdir=file.path( "..", somePNGPath, dirname(mfiles[i]) )
	message( outdir )
	dir.create( outdir, showWarnings = FALSE, recursive = TRUE )

	outpng=paste( file.path("..", somePNGPath, mfiles[i]), '.png', sep="")
	message( outpng )
	png( outpng )

	db<-read.table(mfiles[i], sep=" ")
	dbgP<-data.frame(SNP=db$V2, CHR=db$V1, BP=db$V3, P=db$V4)
	dbgP$P<-ifelse(dbgP$P==0.000e+00,1.000e-302,dbgP$P)
	dq<-read.table(qfiles[i], sep=" ")
	dqgP<-data.frame(SNP=dq$V2, CHR=dq$V1, BP=dq$V3, P=dq$V4)
	par(mfrow=c(2,1))
	manhattan(dbgP, chr = "CHR", main=basename(mfiles[i]))
	qq(dqgP$P, main=basename(qfiles[i]))
	dev.off()
	rm(db)
	rm(dq)
	rm(dbgP)
	rm(dqgP)
}

message( 'Done' )
