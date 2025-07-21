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
		--dosage)
			shift; dosage=$1; shift;;
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
cp /francislab/data1/working/$array/20220425-Pharma/data/$dosage  $TMPDIR/

for IDfile in /francislab/data1/users/gguerra/Pharma_TMZ_glioma/Data/${base}*meta*cases.txt ; do
	subset=$( basename ${IDfile} .txt )
	echo $subset

	outpath="${outbase}/${subset}"

	mkdir -p $outpath

	cp $IDfile $TMPDIR/

	#echo spacox.r ${dataset} $TMPDIR/$dosage $TMPDIR/covariates.txt $TMPDIR/$IDfile $TMPDIR/$subset.out

	#spacox.r ${dataset} $TMPDIR/$( basename $dosage ) $TMPDIR/covariates.txt $TMPDIR/$( basename $IDfile ) $TMPDIR/$subset.out
	spacox.r ${dataset} $TMPDIR/$( basename $dosage ) $TMPDIR/$( basename $covariates ) $TMPDIR/$( basename $IDfile ) $TMPDIR/$subset.out

	\rm $TMPDIR/$( basename $IDfile )
	mv $TMPDIR/$subset.out $outpath/SPACox_$subset.txt

done

date

echo "Runtime : $((SECONDS/3600)) hrs $((SECONDS%3600/60)) mins $((SECONDS%3600%60)) secs"

