#!/usr/bin/env bash
#SBATCH --export=NONE

# From Geno
#	/francislab/data1/working/20210302-AGS-illumina/20210310-scripts/Pharma/Pull_case_dosage


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
		--IDfile)
			shift; IDfile=$1; shift;;
#		--dataset)
#			shift; dataset=$1; shift;;
		--vcffile)
			shift; vcffile=$1; shift;;
		--outbase)
			shift; outbase=$1; shift;;
		*)
			echo "Unknown param :$1:"; exit;;
	esac
done

#if [ ${dataset} == "onco" ] ; then
#	base="AGS_Onco"
#elif [ ${dataset} == "il370" ] ; then
#	base="AGS_i370"
#else
#	echo "Unknown dataset"
#	exit 1
#fi


cp $vcffile     $TMPDIR/
cp $vcffile.tbi $TMPDIR/



#	Geno only has 1 dosage file, yet this script makes several


#for IDfile in /francislab/data1/users/gguerra/Pharma_TMZ_glioma/Data/${base}*meta*cases.txt ; do


	subset=$( basename ${IDfile} .txt )
	echo $subset

	outpath="${outbase}/${subset}"
	
	mkdir -p $outpath
	
	cp $IDfile      $TMPDIR/

#	#	not sure where the GT file is used
#	pull_case_GT.r $TMPDIR/$( basename $vcffile )  $TMPDIR/$( basename $IDfile ) $TMPDIR/${subset}.GT
#	mv $TMPDIR/${subset}.GT $outpath/
#	chmod -w $outpath/${subset}.GT

#	pull_case_DS.r $TMPDIR/$( basename $vcffile )  $TMPDIR/$( basename $IDfile ) $TMPDIR/${subset}.dosage

##	The above takes way too much memory


	zcat $TMPDIR/$( basename $vcffile ) | \
	awk 'BEGIN{FS="\t";OFS=" "}
		(/^##/){next}
		(/^#CHROM/){
			line=""
			for(i=10;i<=NF;i++){ line=line","$i }
			print line 
			next
		}
		{	
			if(!DS){
				split($9,a,":");
				for(i in a){
					if(a[i]=="DS"){DS=i;break}
				}
			}
			line="chr"$1":"$2":"$4":"$5;
			for(i=10;i<=NF;i++){
				split($i,a,":");line=line","a[DS]
			} 
			print line 
		}' > $TMPDIR/All.dosage


	#	this is probably already sorted, however ... NOT
	sort -t, -k1,1 $TMPDIR/$( basename $IDfile ) > $TMPDIR/sorted_case_ids
	sed -i '1iID' $TMPDIR/sorted_case_ids

	cat $TMPDIR/All.dosage | datamash transpose -t, > ${TMPDIR}/tmp1.csv
	head -1 ${TMPDIR}/tmp1.csv > ${TMPDIR}/tmp2.csv
	tail -n +2 ${TMPDIR}/tmp1.csv | sort -t, -k1,1 >> ${TMPDIR}/tmp2.csv
	join --header -t, ${TMPDIR}/sorted_case_ids ${TMPDIR}/tmp2.csv | datamash transpose -t, | tr " " "," > $TMPDIR/${subset}.dosage

	#	dosage files don't have a header for the first column
	sed -i '1s/^ID,//' $TMPDIR/${subset}.dosage


	ls -l $TMPDIR/

	mv $TMPDIR/${subset}.dosage $outpath/
	chmod -w $outpath/${subset}.dosage

#	\rm $TMPDIR/$( basename $IDfile )

#done

date



