#!/usr/bin/env bash
#SBATCH --export=NONE

# From Geno
#	/francislab/data1/working/20210302-AGS-illumina/20210310-scripts/Pharma/Pull_case_dosage

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

#dataset="onco"
#dataset="il370"
if [ ${dataset} == "onco" ] ; then
	array="20210226-AGS-Mayo-Oncoarray"
#	vcffile="AGS_Onco_pharma_merged.vcf.gz"
	#	/francislab/data1/working/20210302-AGS-illumina/20220425-Pharma/data/AGS_i370_pharma_merged.vcf.gz
	base="AGS_Onco"
#	covariates="AGS_Mayo_Oncoarray_covariates.txt"
elif [ ${dataset} == "il370" ] ; then
	array="20210302-AGS-illumina"
	#vcffile="AGS_i370_pharma_merged.vcf.gz"
	#	/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20220425-Pharma/data/AGS_Onco_pharma_merged.vcf.gz
	base="AGS_i370"
#	covariates="AGS_illumina_covariates.txt"
else
	echo "Unknown dataset"
	exit 1
fi


for subset in /francislab/data1/users/gguerra/Pharma_TMZ_glioma/Data/${base}*meta*cases.txt ; do
	subset=$( basename ${subset} .txt )
	echo $subset

#	datpath="/francislab/data1/working/$array/20220425-Pharma/data"

#	subsetpath="/home/gguerra/Pharma_TMZ_glioma/Data"  # <-- can't read
	subsetpath="/francislab/data1/users/gguerra/Pharma_TMZ_glioma/Data"
	IDfile="$subset.txt"
	#scriptpath="/francislab/data1/working/$array/20210310-scripts/Pharma/Survival_GWAS"		# <-- pwd?
#	covpath="/francislab/data1/working/$array/20210305-covariates/${covariates}"
	scratchpath=$TMPDIR

	#outpath="/francislab/data1/working/$array/20220425-Pharma/results/survival/$subset"
	#outpath="${PWD}/GWAStest/${subset}"
	outpath="${outbase}/${subset}"
	
	mkdir -p $outpath
	



#	IDfile="$1.txt"
#	scriptpath="/francislab/data1/working/$array/20210310-scripts/Pharma/"
#	#covpath="/francislab/data1/working/$array/20210305-covariates/AGS_Mayo_Oncoarray_covariates.txt"
#	scratchpath=$TMPDIR
#	outpath="/francislab/data1/working/$array/20220425-Pharma/data/"

	#mkdir -p $outpath

#	outdate=20220427

	cp $vcffile  $scratchpath/
	cp $vcffile.tbi $scratchpath/
	cp $subsetpath/$IDfile $scratchpath/
	#cp $covpath $scratchpath/covariates.txt

	#Rscript $scriptpath/Pull_case_dosage.R $scratchpath/$vcffile  $scratchpath/$IDfile $scratchpath/$1.GT
	pull_case_GT.r $scratchpath/$( basename $vcffile )  $scratchpath/$IDfile $scratchpath/${subset}.GT
	mv $scratchpath/$1.GT $outpath/	#$1.GT

	#Rscript $scriptpath/Pull_case_dosage_2.R $scratchpath/$vcffile  $scratchpath/$IDfile $scratchpath/$1.dosage
	pull_case_DS.r $scratchpath/$( basename $vcffile )  $scratchpath/$IDfile $scratchpath/${subset}.dosage
	rm $scratchpath/$IDfile
	mv $scratchpath/${subset}.dosage $outpath/	#$1.dosage

done


