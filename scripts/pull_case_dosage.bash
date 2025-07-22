#!/usr/bin/env bash
#SBATCH --export=NONE

# From Geno
#	/francislab/data1/working/20210302-AGS-illumina/20210310-scripts/Pharma/Pull_case_dosage


TMPDIR=$TMPDIR/$$
mkdir -p $TMPDIR


pwd; hostname; date

set -x

if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	module load CBI WitteLab
	module load r bcftools #plink2
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

	#	My awk script doesn't take any memory. The datamash transpose call only needs the size of the uncompressed file.
	#	The full imputed, concated vcf files are large and will likely require over 100GB
	#	If it the dosage file really only uses cases, perhap create a vcf with just the cases.
	#		bcftools view -S samples_to_keep.txt input.vcf > filtered.vcf 
	#		-S (samples-file): Provide a file containing sample IDs (one per line) to include or exclude. 

	bcftools view -S $TMPDIR/$( basename $IDfile ) -Oz -o $TMPDIR/${subset}.vcf.gz $TMPDIR/$( basename $vcffile ) 
	bcftools index --tbi $TMPDIR/${subset}.vcf.gz

	#zcat $TMPDIR/$( basename $vcffile ) | \

	zcat $TMPDIR/${subset}.vcf.gz | \
	awk 'BEGIN{FS="\t";OFS=" "}
		(/^##/){next}
		(/^#CHROM/){
			line=""
			for(i=10;i<=NF;i++){ line=line" "$i }
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
				split($i,a,":");line=line" "a[DS]
			} 
			print line 
		}' > $TMPDIR/${subset}.dosage

#		}' > $TMPDIR/All.dosage

	#	TODO Add a check for the chr prefix before adding it.

#	Don't need to transpose and filter if vcf is already filtered.

#	#	this is probably already sorted, however ... NOT
#	sort -t, -k1,1 $TMPDIR/$( basename $IDfile ) > $TMPDIR/sorted_case_ids
#	sed -i '1iID' $TMPDIR/sorted_case_ids
#
#	cat $TMPDIR/All.dosage | datamash transpose -t, > ${TMPDIR}/tmp1.csv
#	head -1 ${TMPDIR}/tmp1.csv > ${TMPDIR}/tmp2.csv
#	tail -n +2 ${TMPDIR}/tmp1.csv | sort -t, -k1,1 >> ${TMPDIR}/tmp2.csv
#	join --header -t, ${TMPDIR}/sorted_case_ids ${TMPDIR}/tmp2.csv | datamash transpose -t, | tr "," " " > $TMPDIR/${subset}.dosage

	#	dosage files don't have a header for the first column
	#sed -i '1s/^ID //' $TMPDIR/${subset}.dosage
#	sed -i 's/,/ /g' $TMPDIR/${subset}.dosage





#	some of the DS values are just "." . Not sure how that will be received later.
#	could fix with sed or possible before with the `vcf-dosage=DS-force`

#	As a . could mean 0, 1 or 2 depending on the genotype, this NEEDs fixed by rerunning.





	ls -l $TMPDIR/

	mv $TMPDIR/${subset}.vcf.gz $outpath/
	mv $TMPDIR/${subset}.vcf.gz.tbi $outpath/
	mv $TMPDIR/${subset}.dosage $outpath/
	chmod -w $outpath/${subset}.*

#	\rm $TMPDIR/$( basename $IDfile )

#done

date

echo "Runtime : $((SECONDS/3600)) hrs $((SECONDS%3600/60)) mins $((SECONDS%3600%60)) secs"

