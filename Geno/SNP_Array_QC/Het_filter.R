# Process the heterozygosity values 
#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
} else if (length(args)==1) {
  # default output file
  args[2] = "/home/gguerra/"
}

infile = args[1]

outfile = args[2]


# Read in the heterozygous file 
het_vals = read.csv(infile, header=TRUE, sep = "")

mF= mean(het_vals$F)
sdF = sd(het_vals$F)
threshF = mF+3*sdF
threshFl = mF -3*sdF

# Return names that meet the right criteria
keep_names= het_vals[(het_vals$F < threshF)&(het_vals$F>threshFl), c(1,2)]

write.table(keep_names, file = outfile, row.names= FALSE, col.names = FALSE, quote = FALSE)

