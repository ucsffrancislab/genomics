#!/usr/bin/env Rscript

#	based on PhIP-Seq/scripts/Multi_Plate_Case_Control_Peptide_Regression.R

#	Uses a logistic regression framework to assess the association between the presence of each peptide and user specified case control status.
#	Uses a user specifed Z score threshold (i.e. Z >3.5) to call positivity
#	Takes as input a list of directories (e.g. plates), to use in the analysis, the directories should contain the Zscores.t.csv and the manifest* files.
#	Only peptides found in both files are included in the analysis
#	The logistic regression adjusts for age (continuous), sex (M/F factor), and plate (1..n plates, factor)
#	The output (to a user specified directory owd , is a list of peptides, ordered by ascending p-value. It includes peptide ID, species, frequency of peptide in the first group, frequency of the peptide in the second group, and the beta, standard error, and p-value from the multivariable logistic regression (NA if there is no variation in the presence of the peptide overall, e.g. all 0 or all 1).
#	The file will also output a logfile with similar naming convention, which includes the details of the plates used in the analysis, sample sizes, etc.


library("argparse")
args=commandArgs()
scriptname=sub("--file=", "", args[grepl("--file=", args)])
parser <- ArgumentParser(description=scriptname)
parser$add_argument("-a", "--group1", type="character", required=TRUE,
	help="first group to compare", metavar="group")
parser$add_argument("-b", "--group2", type="character", required=TRUE,
	help="second group to compare", metavar="group")
parser$add_argument("-s", "--sex", type="character", default="",
	help="limit sex", metavar="sex")
parser$add_argument("-o", "--output_dir", type="character", default="./",
	help="output dir [default=%(default)s]", metavar="directory")
parser$add_argument("-p", "--plate", type="character", required=TRUE, action="append",
	help="plate to compare (use multiple times for each)", metavar="group")
parser$add_argument("--zfile_basename", type="character", default="Zscores.csv",
	help="zfile_basename [default=%(default)s]", metavar="Zscores file basename")

opt <- parser$parse_args()


groups_to_compare = c(opt$group1,opt$group2)
print("Comparing these groups")
print(groups_to_compare)

plates=opt$plate
print("Comparing these plates")
print(plates)

owd=opt$output_dir
print("Output dir")
print(owd)
dir.create(owd,showWarnings=F)


library(data.table)

# Multi plate Logistic regression for tile presence on case/control status, adjusting for age, sex, and plate

#Groups to compare, from the manifest file.
# Order here matters, the first will be coded to 1, the second to 0. So choose the event (aka glioma or pemphigus) to be coded to 1.


date=format(Sys.Date(),"%Y%m%d")
#	paste(date, "Multiplate_Peptide_Comparison",


output_base = paste0(owd, "/", gsub(" ","_",
	paste("PGS_Case_Control_Score_Comparison",
		fs::path_ext_remove(basename(opt$zfile_basename)),
		paste(groups_to_compare, collapse="-"),"Prop_test_results-sex",opt$sex,sep="-")))

print(output_base)
dir.create(owd, recursive = TRUE)


# Log the parameter choices into a logfile
logname = paste0(output_base,'.log')

cat("Multi plate Logistic regression for tile presence on case/control status, adjusting for age, sex, and plate.",
	file=logname,sep="\n")
cat("Plates used in this analysis:", file = logname, append = TRUE, sep = "\n")
for(i in c(1:length(plates))){
	cat(plates[i], file = logname, append= TRUE, sep = "\n")
}
cat("\n", file = logname, append = TRUE)

cat("\nGroups compared in this analysis:", file = logname, append = TRUE, sep = "\n")
for(i in c(1:length(groups_to_compare))){
	cat(groups_to_compare[i], file = logname, append= TRUE, sep = "\n")
}
cat("\n", file = logname, append = TRUE)



# Read in multiple plate Zscores.t files.
Zfiles = list()
species_ids = list()

for(i in c(1:length(plates))){
	Zfilename = paste(plates[i], opt$zfile_basename, sep="/")
	print(paste0("Reading ",Zfilename))
	Zfile <- data.frame(data.table::fread(Zfilename, sep = ",", header=FALSE))	#	50x faster

	print("Zfile[1:5,1:5]")
	print(Zfile[1:5,1:5])

	species_id = data.frame(t(Zfile[c(1),]))
	#colnames(species_id) = species_id[1,]		# id
	species_id = species_id[-1,]
	species_ids[[i]] = species_id
	#Zfile = Zfile[-2,]	#	drop species name
	colnames(Zfile) = Zfile[1,]
	Zfiles[[i]] = Zfile
	#colnames(species_ids[[i]]) = c("id")

}
rm(Zfile)
rm(species_id)

print("Zfiles[[1]][1:5,1:5]")
print(Zfiles[[1]][1:5,1:5])

print("species_ids[[1]][1:5]")
print(species_ids[[1]][1:5])


# Read in the multiple manifest files.
mfs  = list()

for(i in c(1:length(plates))){
	# Find the manifest file for the given plate. Requires only ONE manifest file per plate folder
	mfname = list.files(plates[i], pattern="manifest", full.names=TRUE)
	if(length(mfname)!=1){
		print(paste0(plates[i], " needs a single manifest file!"))
	}

	# read in the manifest file
	mf <- data.frame(data.table::fread(mfname, sep = ",", header=TRUE))	#	50x faster

	# Create a categorical variable, assign all of these the same number to indicate plate.

	#	The plate number is now a column in the manifest file
	#	Later in this script it is used in a formula and can't all the be the same
	#	However, it is used as the index and not the actual plate number.
	mf$plate = i
	mfs[[i]] = mf
}

# Create an aggregate metadata file. This requires identical column structure in the files.

manifest = Reduce(rbind, mfs)
# can get rid of mfs list.
rm(mfs)

print(head(manifest))


# Identify the unique subjects to include in the analyses.

if ( opt$sex == "" ){
	print("Sex is not set so not filtering on sex.")
	uniq_sub = unique(manifest$subject[which(manifest$group %in% groups_to_compare)])
} else {
	print(paste0("Sex is set to ",opt$sex,". Filtering"))
	uniq_sub = unique(manifest$subject[which( manifest$group %in% groups_to_compare & manifest$sex==opt$sex )])
}

print(head(uniq_sub))

cat(paste0("\nTotal number of included subjects: ", length(uniq_sub)), file = logname, append = TRUE, sep = "\n")

# Get the overlapping peptides included in each file
#common_peps = Reduce(intersect, sapply(species_ids, `[`,1))
common_peps = Reduce(intersect, species_ids )
print("length(common_peps)")
print(length(common_peps))
print("common_peps[1:5]")
print(common_peps[1:5])
print(common_peps)
#	[1] "1"     "10"    "100"   "1000"  "10000"

cat(paste0("\nTotal number of included peptides: ", length(common_peps)), file = logname, append = TRUE, sep = "\n")



# Go back into the Z score files and reorder them/cull them to have only the common_peps, in that specific order.
print("for(i in c(1:length(plates))){")
#print("IMPORTANT: The column is 'id' NOT 'ids'")
#	[1] "IMPORTANT: The column is 'id' NOT 'ids'"
for(i in c(1:length(plates))){
	print(i)
	print(Zfiles[[i]][1:5,1:5])
	#Zfiles[[i]] = Zfiles[[i]][,c("id", common_peps)]
	Zfiles[[i]] = Zfiles[[i]][,c("sample", common_peps)]
}
#	[1] 1
#	           id   1  10                  100 1000
#	1          id   1  10                  100 1000
#	3    14078-01 0.0 0.0   0.8133400627769187  0.0
#	4 14078-01dup 0.0 0.0 -0.48156984062927694  0.0
#	5    14118-01 0.0 0.0   1.1354027662377901  0.0
#	6 14118-01dup 0.0 0.0    5.141737192497063  0.0



# Convert every Z score pair to a binary 0/1 call based on the Z thresh.


cat("\nStart converting Z scores to peptide binary calls", file = logname, append = TRUE, sep = "\n")





#common_peps = common_peps[1:1000]
#print(common_peps[1:5])
#[1] "1"     "10"    "100"   "1000"  "10000"
#print(dim(common_peps))
#NULL





peptide_calls = data.frame(mat.or.vec(length(uniq_sub), length(common_peps)+1))
colnames(peptide_calls) = c("ID", common_peps)
peptide_calls$ID = uniq_sub
print("peptide_calls[1:5,1:5]")
print(peptide_calls[1:9,1:9])
#        ID 1 10 100 1000
#1 14078-01 0  0   0    0
#2 14118-01 0  0   0    0
#3 14127-01 0  0   0    0
#4 14142-01 0  0   0    0
#5 14206-01 0  0   0    0
print(dim(peptide_calls))
#[1]  126 1001

# Loop over every person, and convert all of their peptide Z scores into 0's and 1's.
print("Loop over every person, extract mins and, if z scores, convert all of their peptide Z scores into 0's and 1's.")
print("for(i in c(1:nrow(peptide_calls))){")
for(i in c(1:nrow(peptide_calls))){
	print(i)

	id = peptide_calls$ID[i]
	# Get plate to pull from
	mp = manifest$plate[which(manifest$subject==id)][[1]]

	# Extract the rows containing the duplicate samples, assumes they both contain the id, and that id doesn't match another subjects in a grep (i.e IDs 100 and 1000.)
	rlocs = grep(id, Zfiles[[mp]][,1])
#	print("head(rlocs)")
#	print(head(rlocs))

	myZs = data.frame(t(Zfiles[[mp]][c(1,rlocs), which(Zfiles[[mp]][1,] %in% common_peps)]))

#	print("myZs 1")
#	print(myZs)

	#myZs[,c(2:3)] = sapply(myZs[,c(2:3)], as.numeric)
	myZs[,c(2)] = sapply(myZs[,c(2)], as.numeric)			# <-- needed?

#	print("myZs 2")
#	print(myZs)

	if(length(which((common_peps == myZs[,1])==FALSE))>0){
		cat(paste("\nError:", id, ":", "plate", mp, ":Peptides out of order, need to ensure they are ordered the same as the common_peps vector. This should never appear.", sep = " "), file=logname, append = TRUE, sep= "\n")
	}
#	mymins = apply(myZs[,c(2:3)],1, min)
#	if(length(is.na(mymins)) >0){
#		mymins[which(is.na(mymins))] = 0
#	}

#	peptide_calls[i, -1] = mymins
	peptide_calls[i, -1] = myZs[,c(2)]

}
cat("...Complete.", file = logname, append = TRUE, sep = "\n")

print("peptide_calls[1:5,1:5]")
print(peptide_calls[1:5,1:5])

rm(Zfiles)

#	Create a shell file for analysis, Leaves the peptide column blank, we will repopulate this with every peptide.
#	I still don't know what a "shell file" is in this context

# datfile = data.frame(mat.or.vec(length(uniq_sub),6))
#colnames(datfile) = c("ID", "case", "peptide", "sex", "age", "plate")
datfile = data.frame(mat.or.vec(length(uniq_sub),8))
colnames(datfile) = c("ID", "case", "peptide", "sex", "plate","PC1","PC2","PC3")
datfile$ID = uniq_sub
datfile$peptide = NA
#print(datfile)
print("for(i in c(1:nrow(datfile))){")
for(i in c(1:nrow(datfile))){
	print(i)
	man_loc = which(manifest$subject== datfile$ID[i])[1]
	datfile$case[i] = ifelse(manifest$group[man_loc] == groups_to_compare[1], 1, 0)
#	datfile$age[i] = manifest$age[man_loc]
	datfile$sex[i] = manifest$sex[man_loc]
	datfile$plate[i] = manifest$plate[man_loc]
	datfile$PC1[i] = manifest$PC1[man_loc]
	datfile$PC2[i] = manifest$PC2[man_loc]
	datfile$PC3[i] = manifest$PC3[man_loc]
}
#datfile$age = as.numeric(datfile$age)
datfile$sex = as.factor(datfile$sex)
datfile$plate = as.factor(datfile$plate)

#print("datfile")
#print(datfile)


#----- Shell function for logistic regression analysis.
log_reg = function(df){

	# A simple model that simply adjusts for plate/batch in the model. When the number
	#	of plates becomes large, a mixed effects regression model should be considered.
	# as there are likely differences in the peptide calling sensitivity between plates,
	#	and so peptide probably has different associations with case based on plate.

	#	if plate is always the same this fails. check or ignore

#	if ( opt$sex == "" ){
#		#logitmodel = "case~ peptide +age + sex + plate"
#		#logitmodel = "case~ peptide + sex + plate"
#		#logitmodel = "case~ peptide + sex"
#		logitmodel = "case~ peptide + sex + PC1 + PC2 + PC3"
#	} else{
#		#logitmodel = "case~ peptide +age + plate"
#		#logitmodel = "case~ peptide + plate"
#		#logitmodel = "case~ peptide"
#		logitmodel = "case~ peptide + PC1 + PC2 + PC3"
#	}

	#print("Building logitmodel")
	logitmodel = "case ~ peptide + PC1 + PC2 + PC3"
	if ( opt$sex == "" ){
		#print("Including sex in the regression")
		logitmodel = paste0( logitmodel," + sex")
	}
	if( length(unique(df$plate))>1 ){
		#print("Including plate in the regression")
		logitmodel = paste0( logitmodel," + plate")
	}
	#print("Final logitmodel")
	#print(logitmodel)

	logit_fun = glm(as.formula(logitmodel), data = df, family=binomial(link="logit"))

	go= summary(logit_fun)
	#beta = go$coefficients[2,1]
	#se = go$coefficients[2,2]
	#pval = go$coefficients[2,4]
	#	sometimes "Coefficients: (1 not defined because of singularities)"
	#	and peptide doesn't exist. This would then return the age coefficients.
	beta <- if('peptide' %in% rownames(go$coefficients)) go$coefficients['peptide','Estimate'] else NA
	se <- if('peptide' %in% rownames(go$coefficients)) go$coefficients['peptide','Std. Error'] else NA
	pval <- if('peptide' %in% rownames(go$coefficients)) go$coefficients['peptide','Pr(>|z|)'] else NA
	return(c(beta, se, pval))
}
#-------


# Result File
#pvalues = data.frame(mat.or.vec(length(common_peps), 7))
#colnames(pvalues) = c("peptide", "species",  "freq_case", "freq_control", "beta", "se", "pval")
#pvalues = data.frame(mat.or.vec(length(common_peps), 6))
#colnames(pvalues) = c("peptide", "freq_case", "freq_control", "beta", "se", "pval")
pvalues = data.frame(mat.or.vec(length(common_peps), 4))
colnames(pvalues) = c("peptide", "beta", "se", "pval")
pvalues$peptide = common_peps

print("pvalues[1:5,]")
print(pvalues[1:5,])

n_case = length(which(datfile$case==1))
n_control = length(which(datfile$case==0))

cat(paste0("\nTotal number of ", groups_to_compare[1], ": ", n_case), file = logname, append = TRUE, sep = "\n")
cat(paste0("\nTotal number of ", groups_to_compare[2], ": ", n_control), file = logname, append = TRUE, sep = "\n")


# Loop over peptides, populate the datfile, and run analyses.
cat("\nStart loop over peptide logistic regression analysis:", file = logname, append = TRUE, sep = "\n")

print("length(common_peps)")
print(length(common_peps))

print("for(i in c(1:length(common_peps))){")
for(i in c(1:length(common_peps))){
#	print(i)

	# Pull the species assignment of the peptide (this could be more efficient but not really a heavy lookup)
	#pvalues$species[i] = species_ids[[1]]$species[which(species_ids[[1]]$id==common_peps[i])][1]

#print("common_peps[i]")
#print(common_peps[i])

#print("colnames(peptide_calls)")
#print(colnames(peptide_calls))

	# Extract all peptide information into the new datfile.
	datfile$peptide = peptide_calls[, which(colnames(peptide_calls)== common_peps[i])]
#print(datfile$peptide)

	#	prep for log transform of 0, or perhaps even negative
	datfile$peptide <- ifelse(datfile$peptide <= 0, 0.001, datfile$peptide)

	#	log transform data to normalize
	datfile$peptide <- log(datfile$peptide)

#	pvalues$freq_case[i] = "UNK"
#	pvalues$freq_control[i] = "UNK"
#print(datfile)
	results =log_reg(datfile)
	pvalues$beta[i]= results[1]
	pvalues$se[i] = results[2]
	pvalues$pval[i] = results[3]

}
cat("...Complete.", file = logname, append = TRUE, sep = "\n")


print("pvalues[1:5,]")
print(pvalues[1:5,])
#  peptide               species freq_case freq_control         beta
#1       1 Papiine herpesvirus 2       UNK          UNK   0.00240489
#2      10        Vaccinia virus       UNK          UNK   0.31687319
#3     100   Human herpesvirus 3       UNK          UNK  -0.22301611
#4    1000     Hepatitis B virus       UNK          UNK -52.93485789
#5   10000   Human herpesvirus 8       UNK          UNK  -0.69588877


#colnames(pvalues) = c("peptide", "species",
colnames(pvalues) = c("peptide",
	"beta", "se", "pval")
#	paste0("freq_", groups_to_compare[1]),
#	paste0("freq_", groups_to_compare[2]),

write.table(pvalues[order(pvalues$pval,decreasing = FALSE, na.last = TRUE),],paste0(output_base,'.csv'),
	col.names = TRUE, sep = ",", row.names=FALSE, quote= FALSE)

cat("\n Analysis complete.", file = logname, append = TRUE, sep = "\n")



