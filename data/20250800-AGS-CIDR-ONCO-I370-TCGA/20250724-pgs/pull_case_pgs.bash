#!/usr/bin/env bash
#SBATCH --export=NONE

#	if running by hand off cluster ...
#TMPDIR=$TMPDIR/$$
#mkdir -p $TMPDIR

pwd; hostname; date

set -x

if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
#	module load CBI WitteLab
#	module load r bcftools #plink2
fi

outbase=${PWD}
while [ $# -gt 0 ] ; do
	case $1 in
		--IDfile)
			shift; IDfile=$1; shift;;
		--pgsfile)
			shift; pgsfile=$1; shift;;
		--outbase)
			shift; outbase=$1; shift;;
		*)
			echo "Unknown param :$1:"; exit;;
	esac
done





cat ${pgsfile} | tr -d \" | head -1 > $TMPDIR/scores.csv
cat ${pgsfile} | tr -d \" | tail -n +2 | sort -t, -k1,1 >> $TMPDIR/scores.csv
sed '1isample' $IDfile > $TMPDIR/IDfile

join --header -t,  $TMPDIR/IDfile $TMPDIR/scores.csv > $TMPDIR/case_scores.csv

cat $TMPDIR/case_scores.csv | datamash transpose -t, | tr ',' ' ' > ${outbase}/case_scores.csv


date

echo "Runtime : $((SECONDS/3600)) hrs $((SECONDS%3600/60)) mins $((SECONDS%3600%60)) secs"

