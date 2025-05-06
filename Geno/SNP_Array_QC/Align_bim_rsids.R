# Find and replace 

args = commandArgs(trailingOnly=TRUE)

bimfile = args[1]
convfile = args[2]
outfile = args[3]

# Read files in 

bim = read.table(bimfile, header = FALSE)
conv_file= read.table(convfile, header = FALSE)


bim_names = paste("chr",bim[,1],":",bim[,4], sep = "")


# Eliminate any duplicated chr pos in the conv_file 
##IMPORTANT (for future, should correctly identify allele types, but this isnt automated nicely due to disagreements)
print("conv_file before de dup")
print(nrow(conv_file))
duped = unique(conv_file[duplicated(conv_file[,1]),1])
conv_file = conv_file[-which(conv_file[,1] %in% duped),]
print("after")
print(nrow(conv_file))

# Determine which bim_names are in convfile[,1]
z= intersect(bim_names, conv_file[,1])
print(length(z))
in_bim = match(z, bim_names)
print(length(in_bim))
in_conv =match(z, conv_file[,1])
print(length(in_conv))

bim[,2] = as.character(bim[,2])
bim[in_bim,2] = as.character(conv_file[in_conv, 2])
# duped in bim, remove rsid from them 
dupeydupe = (duplicated(bim_names) | duplicated(bim_names, fromLast=TRUE))
bim[dupeydupe,2] = paste(bim_names[dupeydupe], ":", bim[dupeydupe,6], ":", bim[dupeydupe,5], sep = "")


write.table(bim, outfile, row.names=FALSE, col.names = FALSE, quote=FALSE, sep = "\t")



