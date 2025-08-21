#!/usr/bin/env Rscript


library(survival)
for( b in c('i370','onco','tcga') ){

	scores=paste0('pgs-',b,'-hg19/',b,'-covariates-scores.csv')

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
		ci2 = numeric()
	))
	
	for ( PGS in c(
		'PGS000017',
		'PGS000155',
		'PGS000618',
		'PGS000619',
		'PGS000620',
		'PGS000621',
		'PGS000622',
		'PGS000623',
		'PGS000624',
		'PGS000625',
		'PGS000781',
		'PGS002302',
		'PGS002724',
		'PGS002788',
		'PGS003384',
		'PGS003387',
		'PGS003737',
		'PGS003981',
		'PGS004013',
		'PGS004023',
		'PGS004038',
		'PGS004051',
		'PGS004067',
		'PGS004081',
		'PGS004135',
		'PGS004151'
	)){
	
		pgs_scores <- data.table::fread( scores , sep = ",")

		pgs_scores$SexFemale = ifelse( ( pgs_scores$sex == "F" | pgs_scores$sex == "female" ), 1L, 0L)

		#	prepare all available covariates for the formula
		cov=c()
		if( 'age' %in% names(pgs_scores) ){
			cov=c(cov,'age')
		} else if( 'Age' %in% names(pgs_scores) ) {
			cov=c(cov,'Age')
		}
		if( 'SexFemale' %in% names(pgs_scores) && length(unique(pgs_scores$SexFemale)) > 1 )
			cov=c(cov,'SexFemale')
		if( 'chemo' %in% names(pgs_scores)  && length(unique(pgs_scores$chemo)) > 1 )
			cov=c(cov,'chemo')
		if( 'rad' %in% names(pgs_scores)    && length(unique(pgs_scores$rad)) > 1 )
			cov=c(cov,'rad')
		if( 'ngrade' %in% names(pgs_scores) && length(unique(pgs_scores$ngrade)) > 1 )
			cov=c(cov,'ngrade')
		if( 'dxyear' %in% names(pgs_scores) && length(unique(pgs_scores$dxyear)) > 1 )
			cov=c(cov,'dxyear')
		if( 'source' %in% names(pgs_scores) && length(unique(pgs_scores$source)) > 1 ){
			pgs_scores$SourceAGS = ifelse(pgs_scores$source =="AGS",1L,0L)
			cov=c(cov,"SourceAGS")
		}
		cov=c(cov, "PC1", "PC2", "PC3", "PC4", "PC5", "PC6", "PC7", "PC8")
		cov=c(cov,PGS)
		formula=paste("Surv(survdays, vstatus) ~",paste(cov,collapse=" + "))
		print(formula)
		
		res.cox <- coxph(as.formula(formula), data = pgs_scores)
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
		df[nrow(df) + 1, ] <- list( PGS, cox_coef, cox_expcoef, cox_secoef, cox_z, cox_pvalue, cox_HR, cox_CI1, cox_CI2)
	}

	write.csv(df, paste0('pgs-',b,'-hg19/',b,'-coxphoutput.csv'),row.names = FALSE, quote = FALSE)
}


