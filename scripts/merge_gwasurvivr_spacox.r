#!/usr/bin/env Rscript
#SBATCH --export=NONE

#	From Geno



#SPACox GWASurvivr merger 

#date=20220810


args = commandArgs(trailingOnly=TRUE)

# # test if there is at least one argument: if not, return an error
if (length(args)!=4) {
	print(length(args))
	stop(print("4 arguments needed"), call.=FALSE)
}

dataset=args[1]

# GWASsurvivr file 
gwas_file = args[2]
# SPACox file 
spac_file = args[3]
#outfile
outfile = args[4]


srv = read.csv(gwas_file, header = TRUE, sep = "")
spa=read.csv(spac_file, header=TRUE, sep = "")


# Step 1: find the common markers and filter both down 
srv$RSID=as.character(srv$RSID)
spa$RSID=as.character(spa$RSID)
in_both = intersect(srv$RSID, spa$RSID)
srv=data.frame(srv[which(srv$RSID %in% in_both),])
spa = spa[which(spa$RSID %in% in_both),]

# Step 2: Add an SPACox p value column to the GWASurivivr file 
PVALUE.SPA = c()

# Step 3: Loop through the GWASsurvivr file and pull the matching SPACox p value 
for(i in c(1:nrow(srv))){
	PVALUE.SPA = c(PVALUE.SPA, spa$p.value.spa[which(spa$RSID == srv$RSID[i])])
}
srv$PVALUE.SPA = PVALUE.SPA
# Step 4: Return a new file with the new column 
write.table(srv, file = outfile, quote = FALSE, row.names=FALSE, col.names=TRUE, sep = "\t")

