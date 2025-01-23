#!/usr/bin/env Rscript


args = commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)==0) {
	stop("At least one argument must be supplied (input file).n", call.=FALSE)
} else if (length(args)==1) {
	# default mapping file
	args[2] = "/home/gguerra/reference/snp_2_hla_hg38_coords.txt"
}

bimfile = args[1]
refbimfile = args[2]
mapfile = args[3]


# read in bim file

bim = read.csv(bimfile, header = FALSE, sep ="")
bim =data.frame(bim)
bim[,2]= as.character(bim[,2])
bim[,5]= as.character(bim[,5])
bim[,6]= as.character(bim[,6])

#read in ref bim file
refbim=read.csv(refbimfile, header=FALSE, sep="")
refbim=data.frame(refbim)
refbim[,5]= as.character(refbim[,5])
refbim[,6]= as.character(refbim[,6])

# read in map file
map = read.csv(mapfile, header = FALSE, sep =" ")

get_name <- function(chrname){
	# find colons
	splitname= strsplit(as.character(chrname), split="")[[1]]
	colons = which(splitname==":")
  
	return(paste(strsplit(as.character(chrname), split="")[[1]][c(1:colons[2])], collapse = ""))
  
}

for( i in c(1:nrow(bim))){
	print(as.character(bim[i,2]))
	shortname = get_name(as.character(bim[i,2]))
	print(shortname)
	rsid = map[which(as.character(map[,1])==as.character(shortname)),2]
	print(as.character(rsid))
	if(length(rsid) > 1){
		print("----ALLELE CHECK-----")
		# Determine which rsid actually fits by comparing alleles 
		bimalleles= as.character(bim[i,c(5,6)])
		print(bimalleles)
		for(r in c(1:length(rsid))){
			refbimalleles= as.character(refbim[which(as.character(refbim[,2])==as.character(rsid[r])),c(5,6)])
			print(refbimalleles)
			if( bimalleles[1]== refbimalleles[1] |bimalleles[1]== refbimalleles[2]){
				temprsid = rsid[r]
				break
			}
		}
		rsid=temprsid
	}
	bim[i,2]= as.character(rsid)
}
write.table(bim, file= paste(bimfile,".2", sep = ""),row.names= FALSE, col.names = FALSE, quote = FALSE)

