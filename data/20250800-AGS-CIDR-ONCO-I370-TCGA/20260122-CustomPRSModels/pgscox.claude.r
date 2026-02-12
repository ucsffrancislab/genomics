#!/usr/bin/env Rscript
#SBATCH --export=NONE


args = commandArgs(trailingOnly=TRUE)

# test if there are enough arguments: if not, return an error
if (length(args)!=5) {
	print(length(args))
	stop(print("5 arguments needed"), call.=FALSE)
}

dataset = args[1]			#	No longer used

pgs_filename = args[2]

cov_filename= args[3]

sample_list_filename = args[4]

out_base = args[5]			#	out BASE

log <- file(paste0(out_base,".log"), open = "wt")
sink( log )
sink( log, type = "message" )

library(data.table)
library(survival)



#	tranpose t() does add an X before sample names that start with a number
#		and replaces - with . ( X0_WG0238625.DNAB04.AGS51818 )
#
#	0_WG0238625.DNAB04.AGS51818
#	0_WG0238625-DNAB04-AGS51818
#
#	Oddly, you can change it back so I don't know why it does that.
#
# Alter the Dosage rownames by replacing ALL periods with dashes.
#	gsub is an alternative solution
dotwithdash = function(rname){
	return( gsub('.','-',rname,fixed=TRUE) )
#	b= strsplit(rname, split = "")[[1]]
#	b[which(b ==".")]= "-"
#	d= paste(b, collapse = "")
#	return(d)
}

#	tranpose t() does add an X before sample names that start with a number
#	Rather than remove leading Xs, which could be incorrect, add leading X to the other lists.
#
#	0_WG0238625.DNAB04.AGS51818
#	X0_WG0238625.DNAB04.AGS51818
#
# Convert IDs with integer first character to have an "X" at the start, to accomodate the row.names of dosage
add_X =function(rname){
	return( sub('^([[:digit:]])',"X\\1",rname) )
#	b= strsplit(rname, split = "")[[1]]
#	retname = rname
#	if(!is.na(as.numeric(b[1]))){
#		retname = paste("X", rname, sep ="")
#	}
#	return(retname)
}


##################################################


#	read sample list
sample_list = read.csv(sample_list_filename, header = FALSE)
sample.ids = sample_list[,1]
#sample.ids = as.character(sapply(as.character(sample_list[,1]) , add_X))
print(paste("Sample length",length(sample.ids),"in list file"))
head(sample.ids)

#	read cov
print(paste("Reading covariates file:",cov_filename))
pheno.file <- read.table(cov_filename, sep="\t", header=TRUE, stringsAsFactors = FALSE, row.names = 1)
pheno.file$SexFemale = ifelse( ( pheno.file$sex == "F" | pheno.file$sex == "female" ), 1L, 0L)
#pheno.file$IID = as.character(sapply(as.character(pheno.file$IID), add_X))
print(pheno.file[1:5, 1:5])

#print(paste("Sample length",length(pheno.file$IID),"in covariates file"))
#sample.ids = intersect(sample.ids, pheno.file$IID)
print(paste("Sample length",length(row.names(pheno.file)),"in covariates file"))
sample.ids = intersect(sample.ids, row.names(pheno.file))
print(paste("Sample length",length(sample.ids),"in list and cov file"))


#	read pgs
print(paste("Reading pgs scores data table:",pgs_filename))
dt <- data.table::fread(pgs_filename, sep = ",")
print("Convert to data frame")
pgsscores <- data.frame(dt,row.names=1)

# Strip quotes from row names if present
row.names(pgsscores) <- gsub('^"|"$', '', row.names(pgsscores))

# Strip quotes from column names if present  
colnames(pgsscores) <- gsub('^"|"$', '', colnames(pgsscores))

#row.names(pgsscores) = as.character(sapply(row.names(pgsscores), dotwithdash))
print(pgsscores[1:5, 1:5])

# VERIFY Z-SCORES
print("Checking if PRS scores are z-scored (mean~0, sd~1)...")
pgs_means <- colMeans(pgsscores, na.rm=TRUE)
pgs_sds <- apply(pgsscores, 2, sd, na.rm=TRUE)
n_not_zscored <- sum(abs(pgs_means) > 0.5 | abs(pgs_sds - 1) > 0.5)
if(n_not_zscored > 0) {
	warning(paste(n_not_zscored, "PRS models appear not to be z-scored!"))
	print("First few models:")
	print(head(data.frame(PGS=names(pgs_means), Mean=pgs_means, SD=pgs_sds)))
} else {
	print("PRS scores appear properly z-scored")
}

rm(dt)	#	free up some memory
#pgsscores = t(pgsscores)
#print(pgsscores[1:5, 1:5])

#	Not transposing so don't need to swap . with - or add X prefix

print(paste("Sample length",length(row.names(pgsscores)),"in pgsscores file"))
sample.ids = intersect(sample.ids, row.names(pgsscores))
print(paste("Sample length",length(sample.ids),"in all 3"))


#	filter cov file by sample
#pheno.file = pheno.file[which(pheno.file$IID %in% sample.ids), ]
pheno.file = pheno.file[which(row.names(pheno.file) %in% sample.ids), ]
dim(pheno.file)

#	filter pgs by sample
pgsscores = pgsscores[which(row.names(pgsscores) %in% sample.ids), ]
dim(pgsscores)

#	merge pgs and cov
#df <- merge( pheno.file, pgsscores, by=0, all=TRUE)
scores <- merge( pheno.file, pgsscores, by='row.names', all=FALSE) # inner join
rownames(scores) <- scores$Row.names
scores$Row.names <- NULL
dim(scores)
print(scores[1:5, 1:5])


print(paste("Writing samples ids to",paste0(out_base,".samples")))
write.table(sample.ids, paste0(out_base,".samples"),quote=FALSE ,row.names=FALSE ,col.names=FALSE )




#	prepare an empty dataframe
df <- as.data.frame(list(
	pgs = character(),
	coef = numeric(),
	exp_coef = numeric(),
	se_coef = numeric(),
	z = numeric(),
	pvalue = numeric(),
	hr = numeric(),
	ci1 = numeric(),
	ci2 = numeric(),
	n_samples = integer()
))

#for ( PGS in c(
#	'PGS000017',
#	'PGS000155',
#	'PGS000618',
#	'PGS000619',
#	'PGS000620',
#	'PGS000621',
#	'PGS000622',
#	'PGS000623',
#	'PGS000624',
#	'PGS000625',
#	'PGS000781',
#	'PGS002302',
#	'PGS002724',
#	'PGS002788',
#	'PGS003384',
#	'PGS003387',
#	'PGS003737',
#	'PGS003981',
#	'PGS004013',
#	'PGS004023',
#	'PGS004038',
#	'PGS004051',
#	'PGS004067',
#	'PGS004081',
#	'PGS004135',
#	'PGS004151'
#)){

for ( PGS in names(pgsscores) ) {

	print(paste("Processing", PGS, "..."))

#	scores <- data.table::fread( scores , sep = ",")
#
#	scores$SexFemale = ifelse( ( scores$sex == "F" | scores$sex == "female" ), 1L, 0L)



	#	prepare all available covariates for the formula
	covs=c()
	if( 'source' %in% names(scores) && length(unique(scores$source)) > 1 ){
		scores$SourceAGS = ifelse(scores$source =="AGS",1L,0L)
		covs=c(covs,"SourceAGS")
	}
	for( possible in c('age','Age','age_ucsf_surg','SexFemale','chemo','rad','dxyear','ngrade','grade',
		'PC1', 'PC2', 'PC3', 'PC4', 'PC5', 'PC6', 'PC7', 'PC8', 'PC9', 'PC10') ) {
	
		if( possible %in% names(scores) ) {
			print(paste(possible,"found in pheno file"))
			uniq_count = length(unique(scores[[possible]]))
			print(paste(uniq_count,"values for",possible,"found"))
			if( uniq_count > 1 ){
				print(paste("Adding",possible,"to covariates used"))
				covs=c(covs,possible)
			} else {
				print(paste("Not adding",possible,"to covariates used"))
			}
		} else {
			print(paste(possible,"NOT found in pheno file"))
		}
	}
	covs=c(covs,PGS)

	print("Using covs")
	print(covs)

	#	for cidr
	if( ( 'deceased' %in% names(scores) ) && !( 'vstatus' %in% names(scores) ) )
		names(scores)[names(scores) == "deceased"] <- "vstatus"

	formula=paste("Surv(survdays, vstatus) ~",paste(covs,collapse=" + "))
	print(formula)
	
	# Count non-missing samples for this PGS
	n_complete <- sum(complete.cases(scores[, c("survdays", "vstatus", PGS, setdiff(covs, PGS))]))
	
	# Skip if too few samples
	if(n_complete < 10) {
		warning(paste("Skipping", PGS, "- only", n_complete, "complete cases"))
		next
	}
	
	# Fit Cox model with error handling
	tryCatch({
		res.cox <- coxph(as.formula(formula), data = scores)
		summary_cox <- summary(res.cox)
		
		cox_coef    <- summary_cox$coefficients[PGS, "coef"]
		cox_expcoef <- summary_cox$coefficients[PGS, "exp(coef)"]
		cox_secoef  <- summary_cox$coefficients[PGS, "se(coef)"]
		cox_z       <- summary_cox$coefficients[PGS, "z"]
		cox_pvalue  <- summary_cox$coefficients[PGS, "Pr(>|z|)"]
		cox_HR      <- exp(coef(res.cox))[[PGS]]
		cox_CI1     <- exp(confint(res.cox))[PGS,1]
		cox_CI2     <- exp(confint(res.cox))[PGS,2]
		
		#	add these data to the data frame
		if( !is.na( cox_pvalue ) )
			df[nrow(df) + 1, ] <- list( PGS, cox_coef, cox_expcoef, cox_secoef, cox_z, cox_pvalue, cox_HR, cox_CI1, cox_CI2, n_complete)
	}, error = function(e) {
		warning(paste("Error fitting model for", PGS, ":", e$message))
	})
}

# Sort by p-value
df <- df[order(df$pvalue), ]

# Write main output
write.csv(df, paste0(out_base,".csv"), row.names = FALSE, quote = FALSE)

# Write METAL-compatible output
metal_df <- data.frame(
	MarkerName = df$pgs,
	Allele1 = "RISK",
	Allele2 = "REF", 
	Effect = df$coef,
	StdErr = df$se_coef,
	Pvalue = df$pvalue,
	N = df$n_samples
)
write.table(metal_df, paste0(out_base,"_metal.txt"), sep="\t", row.names = FALSE, quote = FALSE)

print(paste("Analysis complete. Results written to", paste0(out_base,".csv")))
print(paste("METAL input written to", paste0(out_base,"_metal.txt")))
