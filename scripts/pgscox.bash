#!/usr/bin/env bash
#SBATCH --export=NONE


pwd; hostname; date

set -x

if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	module load CBI WitteLab
	module load r #plink2 bcftools 
fi

outbase=${PWD}
while [ $# -gt 0 ] ; do
	case $1 in
		--idfile)
			shift; IDfile=$1; shift;;
		--dataset)
			shift; dataset=$1; shift;;
		--pgsscores)
			shift; pgsscores=$1; shift;;
		--covfile)
			shift; covfile=$1; shift;;
		--outbase)
			shift; outbase=$1; shift;;
		*)
			echo "Unknown param :$1:"; exit;;
	esac
done



subset=$( basename ${IDfile} .txt )
echo $subset

outpath="${outbase}/${subset}"

mkdir -p $outpath

if [ -f $outpath/$subset.cox_coeffs.csv ] ; then
	echo "$outpath/$subset.cox_coeffs.csv exists. Skipping"
else

	cp $covfile $TMPDIR/
	cp $pgsscores  $TMPDIR/
	cp $IDfile $TMPDIR/

	pgscox.r ${dataset} $TMPDIR/$( basename $pgsscores ) $TMPDIR/$( basename $covfile ) $TMPDIR/$( basename $IDfile ) $TMPDIR/$subset.cox_coeffs

	ls -l $TMPDIR/

	\rm $TMPDIR/$( basename $IDfile )
	mv $TMPDIR/$subset.cox_coeffs.csv $outpath/
	mv $TMPDIR/$subset.cox_coeffs.samples $outpath/
	mv $TMPDIR/$subset.cox_coeffs.log $outpath/
	chmod -w $outpath/$subset.cox_coeffs.*

fi

date

echo "Runtime : $((SECONDS/3600)) hrs $((SECONDS%3600/60)) mins $((SECONDS%3600%60)) secs"


