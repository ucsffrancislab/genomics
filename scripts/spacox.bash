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
		--idfile)
			shift; IDfile=$1; shift;;
		--dataset)
			shift; dataset=$1; shift;;
		--dosage)
			shift; dosage=$1; shift;;
		--covfile)
			shift; covfile=$1; shift;;
		--outbase)
			shift; outbase=$1; shift;;
		*)
			echo "Unknown param :$1:"; exit;;
	esac
done



#if [ ${dataset} == "onco" ] ; then
#	array="20210226-AGS-Mayo-Oncoarray"
##	base="AGS_Onco"
#	covariates="AGS_Mayo_Oncoarray_covariates.txt"
#elif [ ${dataset} == "il370" -o ${dataset} == "i370" ] ; then
#	array="20210302-AGS-illumina"
##	base="AGS_i370"
#	covariates="AGS_illumina_covariates.txt"
#elif [ ${dataset} == "tcga" ] ; then
#	array="20210223-TCGA-GBMLGG-WTCCC-Affy6"
##	base="AGS_i370"
#	covariates="TCGA_WTCCC_covariates.txt"
#else
#	echo "Unknown dataset"
#	exit 1
#fi


subset=$( basename ${IDfile} .txt )
echo $subset

outpath="${outbase}/${subset}"

mkdir -p $outpath

if [ -f $outpath/SPACox_$subset.txt ] ; then
	echo "$outpath/SPACox_$subset.txt exists. Skipping"
else

	cp $covfile $TMPDIR/
	cp $dosage  $TMPDIR/
	cp $IDfile $TMPDIR/

	#echo spacox.r ${dataset} $TMPDIR/$dosage $TMPDIR/covariates.txt $TMPDIR/$IDfile $TMPDIR/$subset.out

	#spacox.r ${dataset} $TMPDIR/$( basename $dosage ) $TMPDIR/covariates.txt $TMPDIR/$( basename $IDfile ) $TMPDIR/$subset.out
	#spacox.r ${dataset} $TMPDIR/$( basename $dosage ) $TMPDIR/$( basename $covariates ) $TMPDIR/$( basename $IDfile ) $TMPDIR/$subset.out
	spacox.r ${dataset} $TMPDIR/$( basename $dosage ) $TMPDIR/$( basename $covfile ) $TMPDIR/$( basename $IDfile ) $TMPDIR/$subset.out

	\rm $TMPDIR/$( basename $IDfile )
	mv $TMPDIR/$subset.out $outpath/SPACox_$subset.txt
	chmod -w $outpath/SPACox_$subset.txt

fi

date

echo "Runtime : $((SECONDS/3600)) hrs $((SECONDS%3600/60)) mins $((SECONDS%3600%60)) secs"

