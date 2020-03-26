#!/usr/bin/env Rscript

#	manhattan_plot.r -m for_plots/chr10_127658643_R_PRE.for.manhattan.plot -q for_plots/chr10_127658643_R_PRE.for.qq.plot -o ~/Desktop/

#	install.packages('optparse')
#	http://tuxette.nathalievilla.org/?p=1696
library("optparse")
 
option_list = list(
	make_option(c("-m", "--manhattan"), type="character", default=NULL, 
		help="manhattan.plot file name", metavar="character"),
	make_option(c("-q", "--qq"), type="character", default=NULL, 
		help="qq file name", metavar="character"),
	make_option(c("-o", "--outpath"), type="character", default="./", 
		help="output file name [default= %default]", metavar="character")
); 
 
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

message( "Manhattan: ",opt$manhattan )
message( "QQ:  ",opt$qq )
message( "OutPath: ",opt$outpath )
message()


if (is.null(opt$manhattan)){
  print_help(opt_parser)
  stop("Manhattan file required.\n", call.=FALSE)
}

if (is.null(opt$qq)){
  print_help(opt_parser)
  stop("QQ file required.\n", call.=FALSE)
}

if( ( file.info(opt$manhattan)$size == 0 ) || ( file.info(opt$qq)$size == 0 ) ){
  stop("Manhattan or QQ file is empty\n", call.=FALSE)
}

#dir.create(file.path(opt$outpath), showWarnings = FALSE)
dir.create(opt$outpath, showWarnings = FALSE)


library("qqman") 

#	Disable all the warnings
options(warn=-1)
#Warning messages:
#1: In min(d[d$CHR == i, ]$pos) :
#  no non-missing arguments to min; returning Inf
#2: In max(d[d$CHR == i, ]$pos) :
#  no non-missing arguments to max; returning -Inf


png(paste(opt$outpath, basename(opt$manhattan), '.png', sep=""))
db<-read.table(opt$manhattan, sep=" ")
dbgP<-data.frame(SNP=db$V2, CHR=db$V1, BP=db$V3, P=db$V4)
dbgP$P<-ifelse(dbgP$P==0.000e+00,1.000e-302,dbgP$P)
dq<-read.table(opt$qq, sep=" ")
dqgP<-data.frame(SNP=dq$V2, CHR=dq$V1, BP=dq$V3, P=dq$V4)
par(mfrow=c(2,1)) 
manhattan(dbgP, chr = "CHR", main=basename(opt$manhattan))
qq(dqgP$P, main=basename(opt$qq))

#	Why? This prints "null device\n 1". Seems to work when removed?
dev.off()	

rm(db)
rm(dq)
rm(dbgP)
rm(dqgP)

message( 'Done' )

