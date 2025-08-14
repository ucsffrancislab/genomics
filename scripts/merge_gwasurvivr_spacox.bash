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

outfile="merged_$subset.txt"

cp $outpath/$subset.coxph      $TMPDIR/	#srv.txt
cp $outpath/SPACox_$subset.txt $TMPDIR/	#spa.txt

merge_gwasurvivr_spacox.r ${dataset} $TMPDIR/$subset.coxph $TMPDIR/SPACox_$subset.txt $TMPDIR/$subset.out

\rm $TMPDIR/$subset.coxph $TMPDIR/SPACox_$subset.txt
mv $TMPDIR/$subset.out $outpath/$outfile


date

echo "Runtime : $((SECONDS/3600)) hrs $((SECONDS%3600/60)) mins $((SECONDS%3600%60)) secs"

