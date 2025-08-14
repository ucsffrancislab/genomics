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

	spacox.r ${dataset} $TMPDIR/$( basename $dosage ) $TMPDIR/$( basename $covfile ) $TMPDIR/$( basename $IDfile ) $TMPDIR/$subset.out

	ls -l $TMPDIR/

	\rm $TMPDIR/$( basename $IDfile )
	mv $TMPDIR/$subset.out $outpath/SPACox_$subset.txt
	mv $TMPDIR/$subset.out.samples $outpath/SPACox_$subset.samples
	mv $TMPDIR/$subset.out.log $outpath/SPACox_$subset.log
	chmod -w $outpath/SPACox_$subset.txt

fi

date

echo "Runtime : $((SECONDS/3600)) hrs $((SECONDS%3600/60)) mins $((SECONDS%3600%60)) secs"

