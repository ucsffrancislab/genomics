#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

script_dir=$( dirname $0 )

# -m, --mer-len=uint32                    *Length of mer
# -s, --size=uint64                       *Hash size
# -t, --threads=uint32                     Number of threads (1)
# -o, --output=string                      Output prefix (mer_counts)
# -C, --both-strands                       Count both strand, canonical representation (false)

while [ $# -gt 0 ] ; do
	case $1 in
		-i|--i*)
			shift; file=$1; shift;;
		-t|--t*)
			shift; threads=$1; shift ;;
		-c|--c*|-C|--b*)
			shift; canonical='--both-strands';;		#	in jellyfish 2, this is --canonical
		-k|--k*|-m|--m*)
			shift; kmersize=$1; shift ;;
		*)
			shift;;
	esac
done


unique_extension=".fastq.gz"

INDIR=$( dirname $file )
OUTPREFIX=$( basename $file	${unique_extension} )
OUTDIR="${INDIR}/${OUTPREFIX}"


f1=${OUTDIR}_kmers_sorted.txt.gz
if [ -f $f1 ] && [ ! -w $f1 ] ; then
	echo "Write-protected $f1 exists. Skipping."
else


	f=${OUTDIR}_kmers_jellyfish
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
	
		mkdir -p ${OUTDIR}_kmers
	
	
		#	I think that perhaps this samtools fastq should have some flags added to filter out only high quality, proper pair aligned reads?
		#	Sadly "samtools fastq" does not have a -q quality filter as does "samtools view". Why not?
		#	I suppose that I could pipe one to the other like ...
		#		<( samtools view -h -q 40 -f 2 ${file} | samtools fastq - )
	
		#	I think that when extracting reads from a bam, we probably shouldn't use the -C(canonical) flag,
		#		particularly when select high quality mappings
	
		date
		#	--matrix ${f}.Matrix 
		hawk_jellyfish count ${canonical} --output ${OUTDIR}_kmers/tmp \
			--mer-len ${kmersize} --threads ${threads} --size 5G \
			--timing ${f}.Timing --stats ${f}.Stats \
			<( zcat ${file} )
		date
	
		COUNT=$(ls ${OUTDIR}_kmers/tmp* |wc -l)
	
		if [ $COUNT -eq 1 ]
		then
			mv ${OUTDIR}_kmers/tmp_0 ${f}
		else
			hawk_jellyfish merge -o ${f} ${OUTDIR}_kmers/tmp*
		fi
		rm -rf ${OUTDIR}_kmers
	
		chmod a-w $f
	fi




	f=${OUTDIR}.kmers.hist.csv
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"

		f2=${OUTDIR}.kmers.jellyfish.hist.csv
		if [ -f $f2 ] && [ ! -w $f2 ] ; then
			echo "Write-protected $f2 exists. Skipping."
		else
			echo "Creating $f2"
			hawk_jellyfish histo --full --output ${f2} --threads ${threads} ${OUTDIR}_kmers_jellyfish
			chmod a-w $f2
		fi

		# swap, for some reason
		awk '{print $2"\t"$1}' ${f2} > ${f}
		chmod a-w $f

		rm -f $f2
	fi

	f=${OUTDIR}_total_kmers_counts.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		awk -f ${script_dir}/hawk_countTotalKmer.awk ${OUTDIR}.kmers.hist.csv > ${f}
		chmod a-w $f
	fi







	f2=${OUTDIR}_kmers_sorted.txt
	if [ -f $f2 ] && [ ! -w $f2 ] ; then
		echo "Write-protected $f2 exists. Skipping."
	else
		#	Original version does this with CUTOFF. I have no idea why.
		#	Set it to 1, output it to a file, then add 1 and use as the lower limit.
		#	Everytime? Why not just fixed as 2?
		#	CUTOFF=1
		#	echo $CUTOFF > ${OUTPREFIX}_cutoff.csv
		#	${jellyfishDir}/jellyfish dump -c -L `expr $CUTOFF + 1` \
		#		${OUTPREFIX}_kmers_jellyfish > ${OUTPREFIX}_kmers.txt

		f3=${OUTDIR}_kmers.txt
		if [ -f $f3 ] && [ ! -w $f3 ] ; then
			echo "Write-protected $f3 exists. Skipping."
		else
			echo "Creating $f3"
			hawk_jellyfish dump --column --lower-count 2 ${OUTDIR}_kmers_jellyfish > ${f3}
			chmod a-w $f3
		fi

		echo "Creating $f2"
		#sort --parallel=${threads} -n -k 1 ${f3} > ${f2}
		sort --parallel=${threads} --numeric-sort --key 1 ${f3} > ${f2}
		#sort -n -k 1 ${f3} > ${f2}
		chmod a-w $f2

		rm -f $f3
	fi

	gzip --best $f2
	#	should be "a-w" already as gzip preserves
	#	it also removes the source so no rm necessary

	rm -f ${OUTDIR}_kmers_jellyfish

fi

