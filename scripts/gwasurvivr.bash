#!/usr/bin/env bash
#SBATCH --export=NONE

pwd; hostname; date

if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	module load CBI WitteLab
	module load r plink2 bcftools 
fi


while [ $# -gt 0 ] ; do
	case $1 in
		--dataset)
			shift; dataset=$1; shift;;
		*)
			echo "Unknown param :$1:"; exit;;
	esac
done

#dataset="onco"
dataset="il370"
if [ ${dataset} == "onco" ] ; then
	array="20210226-AGS-Mayo-Oncoarray"
	vcffile="AGS_Onco_pharma_merged.vcf.gz"
	#	/francislab/data1/working/20210302-AGS-illumina/20220425-Pharma/data/AGS_i370_pharma_merged.vcf.gz
	base="AGS_Onco"
	covariates="AGS_Mayo_Oncoarray_covariates.txt"
elif [ ${dataset} == "il370" ] ; then
	array="20210302-AGS-illumina"
	vcffile="AGS_i370_pharma_merged.vcf.gz"
	#	/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20220425-Pharma/data/AGS_Onco_pharma_merged.vcf.gz
	base="AGS_i370"
	covariates="AGS_illumina_covariates.txt"
else
	
	echo "Unknown dataset"
	exit 1
fi


for subset in /francislab/data1/users/gguerra/Pharma_TMZ_glioma/Data/${base}*meta*cases.txt ; do
	subset=$( basename ${subset} .txt )
	echo $subset

	datpath="/francislab/data1/working/$array/20220425-Pharma/data"
#	subsetpath="/home/gguerra/Pharma_TMZ_glioma/Data"  # <-- can't read
	subsetpath="/francislab/data1/users/gguerra/Pharma_TMZ_glioma/Data"
	IDfile="$subset.txt"
	#scriptpath="/francislab/data1/working/$array/20210310-scripts/Pharma/Survival_GWAS"		# <-- pwd?
	covpath="/francislab/data1/working/$array/20210305-covariates/${covariates}"
	scratchpath=$TMPDIR

	#outpath="/francislab/data1/working/$array/20220425-Pharma/results/survival/$subset"
	outpath="${PWD}/GWAStest/${subset}"
	
	mkdir -p $outpath
	
	#echo cp $datpath/$vcffile  $scratchpath/$vcffile
	#echo cp $datpath/$vcffile.tbi $scratchpath/$vcffile.tbi
	#echo cp $subsetpath/$IDfile $scratchpath/$IDfile
	#echo cp $covpath $scratchpath/covariates.txt

	cp $datpath/$vcffile  $scratchpath/$vcffile
	cp $datpath/$vcffile.tbi $scratchpath/$vcffile.tbi
	cp $subsetpath/$IDfile $scratchpath/$IDfile
	cp $covpath $scratchpath/covariates.txt


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

	
	#echo Rscript ${PWD}/gwasurvivr.R $scratchpath/$vcffile $scratchpath/covariates.txt $scratchpath/$IDfile $scratchpath/$subset

	#Rscript ${PWD}/gwasurvivr.R ${dataset} $scratchpath/$vcffile $scratchpath/covariates.txt $scratchpath/$IDfile $scratchpath/$subset

	gwasurvivr.r ${dataset} $scratchpath/$vcffile $scratchpath/covariates.txt $scratchpath/$IDfile $scratchpath/$subset

	ls -l $scratchpath/

	rm $scratchpath/$IDfile
	mv $scratchpath/$subset* $outpath/

done

date

