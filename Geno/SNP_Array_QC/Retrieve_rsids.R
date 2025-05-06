# biomart get rsids
library(biomaRt)
args = commandArgs(trailingOnly=TRUE)
snp = useMart(biomart = "ENSEMBL_MART_SNP", dataset = "hsapiens_snp")

mydatloc =args[1]
scratchfile = args[2]
mydat = c(read.table(mydatloc, header = FALSE))
coords =as.character(mydat$V1)
head(coords)
length(coords)
batch_size=as.numeric(args[3])
counter = 0
lc= length(coords)
n_batches = ceiling(lc/batch_size)
print(paste("N batches: ", n_batches, sep = ""))
for(i in c(1:n_batches)){
  print(paste("Batch: ", i, sep = ""))
  start = 1+batch_size*counter
  end = min(start+batch_size, lc)
  batch_coords = coords[c(start:end)]
  
  temp=getBM(attributes = c('refsnp_id', 'chr_name', 'chrom_start', 'chrom_end', 'allele'),filters ='chromosomal_region', values = batch_coords, mart = snp, useCache=FALSE)  
  if(i==1){
write.table(temp, scratchfile, col.names = TRUE, row.names=FALSE, quote=FALSE, sep = "\t")}else{

  write.table(temp, scratchfile, col.names = FALSE, row.names=FALSE, quote=FALSE, sep = "\t", append= TRUE)
}  
  counter = counter +1 
}

