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
		--vcffile)
			shift; vcffile=$1; shift;;
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

if [ -f $outpath/$subset.coxph ] ; then
	echo "$outpath/$subset.coxph exists. Skipping"
else

	cp $covfile     $TMPDIR/
	cp $vcffile     $TMPDIR/
	cp $vcffile.tbi $TMPDIR/
	cp $IDfile      $TMPDIR/

	gwasurvivr.r ${dataset} $TMPDIR/$( basename $vcffile ) $TMPDIR/$( basename $covfile ) $TMPDIR/$( basename $IDfile ) $TMPDIR/$subset

	ls -l $TMPDIR/

	\rm $TMPDIR/$( basename $IDfile )
	mv $TMPDIR/$subset.coxph $outpath/
	mv $TMPDIR/$subset.snps_removed $outpath/
	mv $TMPDIR/$subset.samples $outpath/
	chmod -w $outpath/$subset*

fi

date

echo "Runtime : $((SECONDS/3600)) hrs $((SECONDS%3600/60)) mins $((SECONDS%3600%60)) secs"

