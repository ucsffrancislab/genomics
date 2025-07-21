#!/usr/bin/env bash
#SBATCH --export=NONE

#	From Geno

pwd; hostname; date

set -x

if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	module load CBI WitteLab
	module load r plink2 bcftools 
fi

outbase=${PWD}
while [ $# -gt 0 ] ; do
	case $1 in
		--dataset)
			shift; dataset=$1; shift;;
		--vcffile)
			shift; vcffile=$1; shift;;
		--outbase)
			shift; outbase=$1; shift;;
		*)
			echo "Unknown param :$1:"; exit;;
	esac
done

if [ ${dataset} == "onco" ] ; then
	array="20210226-AGS-Mayo-Oncoarray"
	base="AGS_Onco"
	covariates="AGS_Mayo_Oncoarray_covariates.txt"
elif [ ${dataset} == "il370" ] ; then
	array="20210302-AGS-illumina"
	base="AGS_i370"
	covariates="AGS_illumina_covariates.txt"
else
	echo "Unknown dataset"
	exit 1
fi

cp /francislab/data1/working/$array/20210305-covariates/${covariates} $TMPDIR/	#covariates.txt
cp $vcffile     $TMPDIR/
cp $vcffile.tbi $TMPDIR/

for IDfile in /francislab/data1/users/gguerra/Pharma_TMZ_glioma/Data/${base}*meta*cases.txt ; do
	subset=$( basename ${IDfile} .txt )
	echo $subset

	outpath="${outbase}/${subset}"
	
	mkdir -p $outpath
	
	cp $IDfile      $TMPDIR/


#	Loading required package: gdsfmt
#	SNPRelate -- supported by Streaming SIMD Extensions 2 (SSE2)
#	Analysis started on 2025-07-01 at 09:29:16
#	Covariates included in the models are: dxyear, ngrade, chemo, rad, PC1, PC2, PC3, PC4, PC5, PC6, PC7, PC8, PC9, PC10, SexFemale
#	410 samples are included in the analysis
#	Error in pheno.file[, covariates] : subscript out of bounds
#	Calls: michiganCoxSurv -> coxPheno -> coxParam
#	Execution halted
#	mv: cannot stat '/scratch/gwendt/708643/AGS_Onco_IDHmut_meta_cases*': No such file or directory
#	AGS_Onco_IDHwt_meta_cases
#	Loading required package: Biobase
#	Loading required package: BiocGenerics


	#gwasurvivr.r ${dataset} $TMPDIR/$( basename $vcffile ) $TMPDIR/covariates.txt $TMPDIR/$( basename $IDfile ) $TMPDIR/$subset
	gwasurvivr.r ${dataset} $TMPDIR/$( basename $vcffile ) $TMPDIR/$( basename $covariates ) $TMPDIR/$( basename $IDfile ) $TMPDIR/$subset

	ls -l $TMPDIR/

	\rm $TMPDIR/$( basename $IDfile )
	mv $TMPDIR/$subset* $outpath/

done

date

