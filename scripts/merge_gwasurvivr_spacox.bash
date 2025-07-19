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
	#vcffile="AGS_Onco_pharma_merged.vcf.gz"
	#vcffile="AGS_Onco_glioma_cases.dosage"
	#	/francislab/data1/working/20210302-AGS-illumina/20220425-Pharma/data/AGS_i370_pharma_merged.vcf.gz
	base="AGS_Onco"
	#covariates="AGS_Mayo_Oncoarray_covariates.txt"
elif [ ${dataset} == "il370" ] ; then
	array="20210302-AGS-illumina"
	#vcffile="AGS_i370_pharma_merged.vcf.gz"
	#vcffile="AGS_i370_glioma_cases.dosage"
	#	/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20220425-Pharma/data/AGS_Onco_pharma_merged.vcf.gz
	base="AGS_i370"
	#covariates="AGS_illumina_covariates.txt"
else
	echo "Unknown dataset"
	exit 1
fi


for subset in /francislab/data1/users/gguerra/Pharma_TMZ_glioma/Data/${base}*meta*cases.txt ; do
	subset=$( basename ${subset} .txt )
	echo $subset

#	datpath="/francislab/data1/working/$array/20220425-Pharma/data"
#	subsetpath="/francislab/data1/users/gguerra/Pharma_TMZ_glioma/Data"
	IDfile="$subset.txt"
#	covpath="/francislab/data1/working/$array/20210305-covariates/${covariates}"
	scratchpath=$TMPDIR

	outpath="${outbase}/${subset}"
	mkdir -p $outpath

	outfile="merged_$subset.txt"


	cp $outpath/$subset.coxph  $scratchpath/srv.txt
	cp $outpath/SPACox_$subset.txt $scratchpath/spa.txt

	merge_gwasurvivr_spacox.r ${dataset} $scratchpath/srv.txt $scratchpath/spa.txt $scratchpath/$subset.out

	mv $scratchpath/$subset.out $outpath/$outfile

done

date

